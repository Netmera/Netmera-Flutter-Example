import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/app_driver.dart';
import 'support/stub_client.dart';

const _read = 1;
const _unread = 2;
const _readOrUnread = 3;
const _deleted = 4;
const _all = 7;

/// Same push ids the native suites use on each platform.
String _pushId(int index) =>
    Platform.isIOS ? 'piid-$index' : 'ui-test-piid-$index';

/// An `inbox/fetch` response with unread messages, in the shape each native
/// SDK parses.
Map<String, Object> _messages(int count) => {
  'msgs': [
    for (var i = 1; i <= count; i++)
      if (Platform.isIOS)
        {
          'aps': {
            'alert': {'title': 'Title ${_pushId(i)}', 'body': 'Body'},
            'badge': 1,
            'content-available': 0,
          },
          '_nm': {'pt': 1, 'pid': 'pid-$i', 'piid': _pushId(i), 'st': _unread},
        }
      else
        {'pid': 'pid-$i', 'piid': _pushId(i), 'sts': 0, 'st': _unread},
  ],
  // The Android SDK throws without it.
  'cnts': <String, Object>{},
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stub = StubClient();
  tearDownAll(stub.close);
  setUp(stub.reset);

  Future<void> openInbox(WidgetTester tester, {int messages = 0}) async {
    if (messages > 0) {
      await stub.stubResponse('inbox/fetch', _messages(messages));
    }
    await launchApp(tester);
    await openMenu(tester, ['home.menu.inbox']);
    await stub.waitForRequest('inbox/fetch');
    await pumpFor(tester, const Duration(seconds: 1));
  }

  Future<Map<String, dynamic>> bodyOf(String path, int after) async =>
      (await stub.waitForRequest(path, after: after)).jsonBody
          as Map<String, dynamic>;

  Future<void> menu(WidgetTester tester, String item) async {
    await tapKey(tester, 'inbox.list.menu');
    await tapText(tester, item);
  }

  testWidgets('Opening the inbox fetches messages and counts', (tester) async {
    await launchApp(tester);
    final after = await stub.requestCount();
    await openMenu(tester, ['home.menu.inbox']);

    final fetch = await bodyOf('inbox/fetch', after);
    expect(fetch['st'], _readOrUnread);
    expect(fetch['ie'], isTrue);
    final count = await bodyOf('inbox/count', after);
    expect(count['st'], _all);
    expect(count['ie'], isTrue);
  });

  testWidgets('Unread chip fetches unread messages', (tester) async {
    await openInbox(tester);
    final after = await stub.requestCount();
    await tapKey(tester, 'inbox.list.chip.Unread');

    expect((await bodyOf('inbox/fetch', after))['st'], _unread);
  });

  testWidgets('Show deleted messages fetches every status', (tester) async {
    await openInbox(tester);
    final after = await stub.requestCount();
    await menu(tester, 'Show deleted messages');

    expect((await bodyOf('inbox/fetch', after))['st'], _all);
  });

  testWidgets('Include expired off is sent to fetch and count', (tester) async {
    await openInbox(tester);
    final after = await stub.requestCount();
    await menu(tester, 'Include expired messages');

    expect((await bodyOf('inbox/fetch', after))['ie'], isFalse);
    expect((await bodyOf('inbox/count', after))['ie'], isFalse);
  });

  testWidgets('Load next page fetches again', (tester) async {
    // The page offers a next page once the first one is full.
    await stub.stubResponse('inbox/fetch', {
      ..._messages(10),
      'prms': {'nId': 1},
    });
    await openInbox(tester);
    final after = await stub.requestCount();
    await menu(tester, 'Load next page');

    await stub.waitForRequest('inbox/fetch', after: after);
  });

  for (final (item, status) in const [
    ('Mark all as read', _read),
    ('Mark all as unread', _unread),
    ('Delete all', _deleted),
  ]) {
    testWidgets('$item updates every message', (tester) async {
      await openInbox(tester);
      final after = await stub.requestCount();
      await menu(tester, item);
      if (status == _deleted) await tapText(tester, 'Delete');

      final body = await bodyOf('inbox/set', after);
      expect(body['st'], status);
      expect(body['all'], isTrue);
    });
  }

  testWidgets('Swiping a row right marks it read', (tester) async {
    await openInbox(tester, messages: 1);
    final after = await stub.requestCount();
    await closePushEvents(tester);
    await tester.drag(
      find.byKey(const ValueKey('inbox.list.cell.0')),
      const Offset(400, 0),
    );
    await pumpFor(tester, const Duration(milliseconds: 500));

    final body = await bodyOf('inbox/set', after);
    expect(body['st'], _read);
    expect(body['piids'], [_pushId(1)]);
  });

  testWidgets('Two selected rows are marked read together', (tester) async {
    await openInbox(tester, messages: 2);
    await closePushEvents(tester);
    await tester.longPress(find.byKey(const ValueKey('inbox.list.cell.0')));
    await pumpFor(tester, const Duration(milliseconds: 500));
    await tapKey(tester, 'inbox.list.cell.1');

    final after = await stub.requestCount();
    await tapText(tester, 'Mark as read');

    final body = await bodyOf('inbox/set', after);
    expect(body['st'], _read);
    expect(Set.of(body['piids'] as List), {_pushId(1), _pushId(2)});
  });

  testWidgets('Opening an unread message marks it read', (tester) async {
    await openInbox(tester, messages: 1);
    await tapKey(tester, 'inbox.list.cell.0');
    final detail = find.byKey(const ValueKey('inbox.detail'));
    await pumpUntilFound(tester, detail);

    // The message is marked read once the detail sheet closes.
    final after = await stub.requestCount();
    await tester.tapAt(Offset(20, tester.getTopLeft(detail).dy / 2));
    await pumpFor(tester, const Duration(seconds: 1));

    final body = await bodyOf('inbox/set', after);
    expect(body['st'], _read);
    expect(body['piids'], [_pushId(1)]);
  });

  testWidgets('Delete in the detail sheet deletes the message', (tester) async {
    await openInbox(tester, messages: 1);
    await tapKey(tester, 'inbox.list.cell.0');

    final after = await stub.requestCount();
    await tapKey(tester, 'inbox.detail.delete');

    final body = await bodyOf('inbox/set', after);
    expect(body['st'], _deleted);
    expect(body['piids'], [_pushId(1)]);
  });
}

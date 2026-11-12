import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netmera_flutter_example/main.dart' as app;

const _step = Duration(milliseconds: 100);

/// Starts the app and waits for the home menu.
Future<void> launchApp(WidgetTester tester) async {
  app.main();
  await pumpUntilFound(tester, find.byKey(const ValueKey('home.menu.core')));
  // The push token callback, and with it the push window, arrives shortly
  // after launch.
  await pumpFor(tester, const Duration(seconds: 3));
  await closePushEvents(tester);
}

/// Pumps frames for [duration] without waiting for animations to settle;
/// spinners and snackbars keep the app from ever settling.
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(_step);
  }
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(_step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

/// The app opens a full-screen "Push Callbacks" window when a push callback
/// arrives (e.g. the token at launch); it swallows taps until closed.
Future<void> closePushEvents(WidgetTester tester) async {
  final overlay = find.byKey(const ValueKey('pushEvents.overlay'));
  if (overlay.evaluate().isEmpty) return;
  await tester.tapAt(tester.getTopLeft(overlay) + const Offset(8, 8));
  await tester.pump(_step);
}

/// Scrolls the page until [finder] is built; list rows far down a page are
/// not built until they scroll into view.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await pumpFor(tester, const Duration(milliseconds: 300));
  if (finder.evaluate().isNotEmpty) return;
  await closePushEvents(tester);
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await pumpUntilFound(tester, finder);
  await closePushEvents(tester);
  await tester.ensureVisible(finder.first);
  await tester.pump(_step);
  await tester.tap(finder.first);
  await pumpFor(tester, const Duration(milliseconds: 500));
}

Future<void> tapKey(WidgetTester tester, String key) =>
    tap(tester, find.byKey(ValueKey(key)));

Future<void> tapText(WidgetTester tester, String text) =>
    tap(tester, find.text(text));

Future<void> enterText(WidgetTester tester, String key, String text) async {
  final field = find.byKey(ValueKey(key));
  await reveal(tester, field);
  await pumpUntilFound(tester, field);
  await closePushEvents(tester);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump(_step);
}

/// Opens a page by following menu keys from the home menu,
/// e.g. `openMenu(tester, ['home.menu.user', 'user.menu.identify'])`.
Future<void> openMenu(WidgetTester tester, List<String> keys) async {
  for (var i = 0; i < keys.length; i++) {
    await tapKey(tester, keys[i]);
    if (i + 1 < keys.length && !await _appears(tester, keys[i + 1])) {
      // A push window that opened during the tap swallowed it.
      await tapKey(tester, keys[i]);
    }
  }
}

Future<bool> _appears(WidgetTester tester, String key) async {
  try {
    await pumpUntilFound(
      tester,
      find.byKey(ValueKey(key)),
      timeout: const Duration(seconds: 3),
    );
    return true;
  } on TestFailure {
    return false;
  }
}

/// Pops pages until the home menu is showing again.
Future<void> backToHome(WidgetTester tester) async {
  final home = find.byKey(const ValueKey('home.menu.core'));
  while (home.hitTestable().evaluate().isEmpty) {
    await closePushEvents(tester);
    await tester.pageBack();
    await pumpFor(tester, const Duration(milliseconds: 500));
  }
}

Future<void> sendLoginEvent(WidgetTester tester) async {
  await backToHome(tester);
  await openMenu(tester, ['home.menu.events', 'events.menu.general']);
  await tapKey(tester, 'general.menu.login');
}

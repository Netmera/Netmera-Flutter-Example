import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netmera_flutter_example/features/inbox/inbox_call_log.dart';
import 'package:netmera_flutter_example/features/inbox/inbox_detail_sheet.dart';
import 'package:netmera_flutter_example/features/inbox/inbox_format.dart';
import 'package:netmera_flutter_example/features/inbox/inbox_widgets.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/states.dart';
import 'package:netmera_flutter_example/utils/category_channel_utils.dart';
import 'package:netmera_flutter_sdk/NMInboxStatusCountFilter.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraCategory.dart';
import 'package:netmera_flutter_sdk/NetmeraCategoryFilter.dart';
import 'package:netmera_flutter_sdk/NetmeraInboxFilter.dart';
import 'package:netmera_flutter_sdk/NetmeraInteractiveAction.dart';
import 'package:netmera_flutter_sdk/NetmeraPushInbox.dart';

const _allChip = 'All';
const _unreadChip = 'Unread';
const _pageSizes = [1, 2, 5, 10, 20];
const _categoryTimeout = Duration(seconds: 15);

const _read = Netmera.PUSH_OBJECT_STATUS_READ;
const _unread = Netmera.PUSH_OBJECT_STATUS_UNREAD;
const _readOrUnread = Netmera.PUSH_OBJECT_STATUS_READ_OR_UNREAD;
const _deleted = Netmera.PUSH_OBJECT_STATUS_DELETED;
const _all = Netmera.PUSH_OBJECT_STATUS_ALL;

class _Counts {
  const _Counts({
    required this.read,
    required this.unread,
    required this.deleted,
  });

  final int read;
  final int unread;
  final int deleted;

  String get line => '$unread unread · $read read · $deleted deleted';
}

enum _MenuAction {
  select,
  readAll,
  unreadAll,
  deleteAll,
  showDeleted,
  includeExpired,
  pageSize,
  nextPage,
  developerInfo,
}

/// Inbox hub matching the native demos: category chips, count summary,
/// swipe actions, multi-select, detail sheet and a developer panel.
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final _log = InboxCallLog();
  final _scrollController = ScrollController();

  String _selectedChip = _allChip;
  bool _showDeleted = false;
  bool _includeExpired = true;
  bool _showDeveloperInfo = false;
  int _pageSize = 10;

  List<NetmeraPushInbox> _messages = [];
  bool _loaded = false;
  bool _loading = false;
  bool _loadingNextPage = false;
  bool _hasNextPage = false;
  String? _error;
  bool _nextPageFailed = false;

  List<String> _preferenceCategories = [];
  List<NetmeraCategory>? _categories;
  _Counts? _countApi;
  _Counts? _inboxCounts;

  /// Push instance ids; message objects are replaced on every fetch.
  final Set<String> _selection = {};
  bool _selecting = false;

  /// Late responses from an older filter are dropped.
  int _generation = 0;

  /// The bridge keeps a single native inbox; overlapping fetches would leave
  /// whichever finished last as the one later updates are matched against.
  Future<void>? _inFlightFetch;

  bool _refreshingCounts = false;
  bool _refreshCountsAgain = false;

  String? get _selectedCategory =>
      _selectedChip == _allChip || _selectedChip == _unreadChip
      ? null
      : _selectedChip;

  static String _keyOf(NetmeraPushInbox message) =>
      message.getPushInstanceId() ?? message.getPushId() ?? '';

  List<NetmeraPushInbox> get _selectedMessages =>
      _messages.where((m) => _selection.contains(_keyOf(m))).toList();

  int get _fetchStatus => _selectedChip == _unreadChip
      ? _unread
      : (_showDeleted ? _all : _readOrUnread);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFirstPage();
    _loadPreferenceCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.extentAfter < 200 && !_nextPageFailed) _fetchNextPage();
  }

  Future<void> _fetchFirstPage({bool keepList = false}) async {
    final generation = ++_generation;
    while (_inFlightFetch != null) {
      await _inFlightFetch;
    }
    if (!mounted || generation != _generation) return;
    final completer = Completer<void>();
    _inFlightFetch = completer.future;
    setState(() {
      _loading = true;
      _error = null;
      _nextPageFailed = false;
      if (!keepList) {
        _messages = [];
        _loaded = false;
        _countApi = null;
        _inboxCounts = null;
        _endSelection();
      }
    });

    final category = _selectedCategory;
    final filter = NetmeraInboxFilter()
      ..setPageSize(_pageSize)
      ..setStatus(_fetchStatus)
      ..setCategories(category == null ? null : [category])
      ..setIncludeExpiredObjects(_includeExpired);
    final call =
        'fetchInbox(status: ${inboxStatusName(_fetchStatus)}'
        '${category == null ? '' : ', categories: [$category]'}'
        ', pageSize: $_pageSize, includeExpired: $_includeExpired)';

    try {
      final messages = await _log.run(call, () => Netmera.fetchInbox(filter));
      if (!mounted || generation != _generation) return;
      setState(() {
        _messages = messages;
        _pruneSelection();
        _hasNextPage = messages.length >= _pageSize;
        _loaded = true;
        _loading = false;
      });
      _loadMoreIfListIsShort();
      unawaited(_refreshCounts());
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _error = 'Could not load messages: ${errorMessage(error)}';
      });
    } finally {
      _inFlightFetch = null;
      completer.complete();
    }
  }

  Future<void> _fetchNextPage() async {
    if (!_hasNextPage || _loadingNextPage || _loading) return;
    final generation = _generation;
    final before = _messages.length;
    setState(() => _loadingNextPage = true);
    try {
      final messages = await _log.run('fetchNextPage()', Netmera.fetchNextPage);
      if (!mounted || generation != _generation) return;
      setState(() {
        _messages = messages;
        _pruneSelection();
        _hasNextPage = messages.length > before;
        _error = null;
      });
      _loadMoreIfListIsShort();
    } on PlatformException catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        if (_isEndOfList(error)) {
          _hasNextPage = false;
        } else {
          _nextPageFailed = true;
          _error = 'Could not load messages: ${errorMessage(error)}';
        }
      });
    } finally {
      if (mounted) setState(() => _loadingNextPage = false);
    }
  }

  /// A first page shorter than the screen cannot be scrolled, so the next one
  /// is requested right away.
  void _loadMoreIfListIsShort() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) _fetchNextPage();
    });
  }

  void _retry() {
    if (_nextPageFailed) {
      setState(() => _nextPageFailed = false);
      _fetchNextPage();
    } else {
      _fetchFirstPage(keepList: true);
    }
  }

  /// Android reports the end with code 2018, iOS with 2016 + hasNoNextItems.
  bool _isEndOfList(PlatformException error) =>
      error.code == '2018' ||
      (error.code == '2016' &&
          '${error.details}'.toLowerCase().contains('nonext'));

  Future<void> _loadPreferenceCategories() async {
    try {
      final preferences = await _log.run(
        'getUserCategoryPreferenceList()',
        Netmera.getUserCategoryPreferenceList,
      );
      if (!mounted) return;
      setState(() {
        _preferenceCategories = preferences
            .map((preference) => preference.getCategoryName()?.trim() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
      });
    } catch (_) {
      // Chips still come from the category summary.
    }
  }

  /// Runs one refresh at a time: the bridge has a single native category
  /// manager, and a newer request would otherwise page an older one's results.
  Future<void> _refreshCounts() async {
    if (_refreshingCounts) {
      _refreshCountsAgain = true;
      return;
    }
    _refreshingCounts = true;
    try {
      do {
        _refreshCountsAgain = false;
        final generation = _generation;
        void apply(VoidCallback update) {
          if (mounted && generation == _generation) setState(update);
        }

        await Future.wait([
          _loadCountApi().then((counts) => apply(() => _countApi = counts)),
          _loadInboxCounts().then(
            (counts) => apply(() => _inboxCounts = counts),
          ),
          _loadCategories().then(
            (categories) => apply(() => _categories = categories),
          ),
        ]);
      } while (_refreshCountsAgain && mounted);
    } finally {
      _refreshingCounts = false;
    }
  }

  /// The count API's category filter is broken in the Flutter bridge (it only
  /// accepts ids), so it is always called without categories.
  Future<_Counts?> _loadCountApi() async {
    final filter = NMInboxStatusCountFilter()
      ..setStatus(_all)
      ..setIncludeExpired(_includeExpired);
    try {
      final counts = await _log.run(
        'getInboxCountForStatus(status: all, includeExpired: $_includeExpired)',
        () => Netmera.getInboxCountForStatus(filter),
      );
      int count(int status) => (counts['$status'] as num?)?.toInt() ?? 0;
      return _Counts(
        read: count(_read),
        unread: count(_unread),
        deleted: count(_deleted),
      );
    } catch (_) {
      return null;
    }
  }

  /// Pages through categories until a page adds no new name, like the native
  /// demos. iOS can leave these futures pending, hence the timeout.
  Future<List<NetmeraCategory>?> _loadCategories() async {
    final status = _showDeleted ? _all : _readOrUnread;
    final filter = NetmeraCategoryFilter()
      ..setStatus(status)
      ..setPageSize(_pageSize)
      ..setIncludeExpiredObjects(_includeExpired);
    try {
      var categories = await _log.run(
        'fetchCategory(status: ${inboxStatusName(status)}, pageSize: $_pageSize, '
        'includeExpired: $_includeExpired)',
        () => Netmera.fetchCategory(filter).timeout(_categoryTimeout),
      );
      // Without hasNextPage in the bridge, a short page means there is no next one.
      var lastPageSize = categories.length;
      while (lastPageSize >= _pageSize) {
        final names = categories.map((c) => c.getCategoryName()).toSet();
        try {
          final next = await _log.run(
            'fetchCategory.fetchNextPage()',
            () => Netmera.fetchNextCategory().timeout(_categoryTimeout),
          );
          if (next.map((c) => c.getCategoryName()).toSet().length <=
              names.length) {
            return next;
          }
          lastPageSize = next.length - categories.length;
          categories = next;
        } catch (_) {
          return categories;
        }
      }
      return categories;
    } catch (_) {
      return null;
    }
  }

  Future<_Counts?> _loadInboxCounts() async {
    final unread = await Netmera.countForStatus(_unread);
    final read = await Netmera.countForStatus(_read);
    final deleted = await Netmera.countForStatus(_deleted);
    if (unread == null || read == null || deleted == null) return null;
    if (unread < 0 || read < 0 || deleted < 0) return null;
    return _Counts(read: read, unread: unread, deleted: deleted);
  }

  Future<bool> _updateStatus(
    List<NetmeraPushInbox> messages,
    int status,
  ) async {
    final pushIds = messages
        .map((m) => m.getPushId())
        .whereType<String>()
        .toSet();
    if (pushIds.isEmpty) return false;
    try {
      await _log.run(
        'updateStatus(${messages.length} messages, status: ${inboxStatusName(status)})',
        () => Netmera.inboxUpdateStatus(pushIds.toList(), status),
      );
    } catch (error) {
      showFeedback(
        'Something went wrong: ${errorMessage(error)}',
        style: FeedbackStyle.error,
      );
      return false;
    }
    if (!mounted) return true;
    final fetchStatus = _fetchStatus;
    bool updated(NetmeraPushInbox m) => pushIds.contains(m.getPushId());
    setState(() {
      for (final message in [...messages, ..._messages.where(updated)]) {
        message.setInboxStatus(status);
      }
      // The native SDK drops messages that no longer match the filter.
      if (fetchStatus & status == 0) {
        _messages = _messages.where((m) => !updated(m)).toList();
      }
    });
    unawaited(_refreshCounts());
    return true;
  }

  Future<void> _delete(List<NetmeraPushInbox> messages) async {
    if (await _updateStatus(messages, _deleted)) {
      showFeedback(
        messages.length == 1
            ? 'Message deleted'
            : '${messages.length} messages deleted',
      );
    }
  }

  Future<void> _updateAll(int status) async {
    final category = _selectedCategory;
    final name = inboxStatusName(status);
    try {
      if (category == null) {
        await _log.run(
          'updateAll(status: $name)',
          () => Netmera.updateAll(status),
        );
      } else {
        await _log.run(
          'updateStatusByCategories(status: $name, categories: [$category])',
          () => Netmera.updateStatusByCategories(status, [category]),
        );
      }
    } catch (error) {
      showFeedback(
        'Something went wrong: ${errorMessage(error)}',
        style: FeedbackStyle.error,
      );
      return;
    }
    showFeedback('Inbox updated', style: FeedbackStyle.success);
    await _fetchFirstPage(keepList: true);
  }

  Future<void> _confirmDeleteAll() async {
    final category = _selectedCategory;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all messages?'),
        content: Text(
          category == null
              ? 'All inbox messages will be deleted.'
              : 'All messages in “$category” will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _updateAll(_deleted);
  }

  Future<void> _choosePageSize() async {
    final size = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Page size'),
        children: [
          for (final option in _pageSizes)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, option),
              child: Row(
                children: [
                  Expanded(child: Text('$option')),
                  if (option == _pageSize)
                    const Icon(Icons.check, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
    if (size != null && size != _pageSize) {
      _pageSize = size;
      await _fetchFirstPage();
    }
  }

  void _onMenu(_MenuAction action) {
    switch (action) {
      case _MenuAction.select:
        setState(() => _selecting = true);
      case _MenuAction.readAll:
        _updateAll(_read);
      case _MenuAction.unreadAll:
        _updateAll(_unread);
      case _MenuAction.deleteAll:
        _confirmDeleteAll();
      case _MenuAction.showDeleted:
        _showDeleted = !_showDeleted;
        _fetchFirstPage();
      case _MenuAction.includeExpired:
        _includeExpired = !_includeExpired;
        _fetchFirstPage();
      case _MenuAction.pageSize:
        _choosePageSize();
      case _MenuAction.nextPage:
        _fetchNextPage();
      case _MenuAction.developerInfo:
        setState(() => _showDeveloperInfo = !_showDeveloperInfo);
    }
  }

  void _selectChip(String id) {
    if (id == _selectedChip) return;
    _selectedChip = id;
    _fetchFirstPage();
  }

  void _pruneSelection() {
    final keys = _messages.map(_keyOf).toSet();
    _selection.removeWhere((key) => !keys.contains(key));
  }

  void _endSelection() {
    _selecting = false;
    _selection.clear();
  }

  Future<void> _applyToSelection(int status) async {
    final messages = _selectedMessages;
    setState(_endSelection);
    if (status == _deleted) {
      await _delete(messages);
    } else {
      await _updateStatus(messages, status);
    }
  }

  void _toggleSelection(NetmeraPushInbox message) {
    final key = _keyOf(message);
    setState(() {
      if (!_selection.remove(key)) _selection.add(key);
    });
  }

  Future<void> _openMessage(NetmeraPushInbox message) async {
    final wasUnread = message.getInboxStatus() == _unread;
    if (wasUnread) setState(() => message.setInboxStatus(_read));
    var statusChanged = false;
    await showInboxDetailSheet(
      context,
      message: message,
      showSdkFields: _showDeveloperInfo,
      onOpen: () => _handlePushObject(message),
      onAction: _handleInteractiveAction,
      onMarkUnread: () {
        statusChanged = true;
        _updateStatus([message], _unread);
      },
      onDelete: () {
        statusChanged = true;
        _delete([message]);
      },
    );
    // Marked read only after the sheet closes: on the Unread chip the SDK drops
    // read messages, and the sheet's actions look the message up by push id.
    if (wasUnread && !statusChanged && mounted) {
      final updated = await _updateStatus([message], _read);
      if (!updated && mounted) setState(() => message.setInboxStatus(_unread));
    }
  }

  void _handlePushObject(NetmeraPushInbox message) {
    final pushId = message.getPushId();
    if (pushId == null) return;
    Netmera.handlePushObject(pushId);
    setState(() => _log.recordFireAndForget('handlePushObject($pushId)'));
  }

  /// The bridge matches actions by id across every loaded message, so ids that
  /// repeat in different messages may run the first match.
  void _handleInteractiveAction(NetmeraInteractiveAction action) {
    Netmera.handleInteractiveAction(action);
    setState(
      () => _log.recordFireAndForget(
        'handleInteractiveAction(${action.getId()})',
      ),
    );
  }

  List<InboxChip> get _chips {
    final names = <String>[
      ..._preferenceCategories,
      for (final category in _categories ?? const <NetmeraCategory>[])
        if ((category.getCategoryName() ?? '').trim().isNotEmpty)
          category.getCategoryName()!.trim(),
      ?_selectedCategory,
    ];
    final unreadByName = {
      for (final category in _categories ?? const <NetmeraCategory>[])
        category.getCategoryName(): category.getUnReadCount() ?? 0,
    };
    return [
      const InboxChip(id: _allChip, label: _allChip),
      const InboxChip(id: _unreadChip, label: _unreadChip),
      for (final name in names.toSet())
        InboxChip(
          id: name,
          label: (unreadByName[name] ?? 0) > 0
              ? '$name · ${unreadByName[name]}'
              : name,
        ),
    ];
  }

  /// Category counts come from fetchCategory because the count API cannot
  /// filter by category in the Flutter bridge.
  _Counts? get _summaryCounts {
    final category = _selectedCategory;
    if (category == null) return _countApi;
    for (final summary in _categories ?? const <NetmeraCategory>[]) {
      if (summary.getCategoryName() == category) {
        return _Counts(
          read: summary.getReadCount() ?? 0,
          unread: summary.getUnReadCount() ?? 0,
          deleted: summary.getDeletedCount() ?? 0,
        );
      }
    }
    return null;
  }

  String? get _summaryText {
    final counts = _summaryCounts;
    if (counts == null || _messages.isEmpty) return null;
    final total = counts.read + counts.unread;
    return [
      '$total ${total == 1 ? 'message' : 'messages'}',
      '${counts.unread} unread',
      if (_showDeleted) '${counts.deleted} deleted',
    ].join(' · ');
  }

  String get _developerInfo {
    final inbox = _inboxCounts;
    final api = _countApi;
    // Only comparable when the inbox is not narrowed down by a chip.
    final comparable = _selectedChip == _allChip;
    final mismatch =
        comparable &&
        inbox != null &&
        api != null &&
        (inbox.unread != api.unread || inbox.read != api.read);
    final categories = _categories;
    return [
      _log.lastCallLine,
      if (inbox != null) 'Inbox counts: ${inbox.line}',
      api == null
          ? 'Count API: not loaded'
          : 'Count API: ${api.line}${mismatch ? ' ⚠︎ mismatch' : ''}',
      if (categories == null)
        'Categories: not loaded'
      else if (categories.isEmpty)
        'Categories: none'
      else
        'Categories: ${categories.map((c) => '${c.getCategoryName()} ${c.getUnReadCount() ?? 0} unread').join(' · ')}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_endSelection);
      },
      child: Scaffold(
        appBar: _selecting ? _selectionAppBar() : _defaultAppBar(),
        body: SafeArea(
          top: false,
          child: Column(
            key: const ValueKey('inbox.list'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InboxChipBar(
                chips: _chips,
                selectedId: _selectedChip,
                onSelected: _selectChip,
                enabled: !_selecting,
              ),
              if (_summaryText case final summary?)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    summary,
                    key: const ValueKey('inbox.list.summary'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              if (_error case final error?)
                ErrorBanner(
                  key: const ValueKey('inbox.list.errorBanner'),
                  message: error,
                  onRetry: _retry,
                ),
              SizedBox(
                height: 2,
                child: (_loading || _loadingNextPage)
                    ? const LinearProgressIndicator(minHeight: 2)
                    : null,
              ),
              Expanded(child: _messageList()),
              if (_showDeveloperInfo)
                MonoPanel(
                  _developerInfo,
                  key: const ValueKey('inbox.list.developerPanel'),
                ),
              if (_selecting) _selectionToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _defaultAppBar() {
    return AppBar(
      title: const Text('Inbox'),
      actions: [
        PopupMenuButton<_MenuAction>(
          key: const ValueKey('inbox.list.menu'),
          tooltip: 'Inbox options',
          onSelected: _onMenu,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _MenuAction.select,
              enabled: _messages.isNotEmpty,
              child: const Text('Select messages'),
            ),
            PopupMenuItem(
              value: _MenuAction.readAll,
              enabled: _loaded,
              child: const Text('Mark all as read'),
            ),
            PopupMenuItem(
              value: _MenuAction.unreadAll,
              enabled: _loaded,
              child: const Text('Mark all as unread'),
            ),
            PopupMenuItem(
              value: _MenuAction.deleteAll,
              enabled: _loaded,
              child: const Text('Delete all'),
            ),
            const PopupMenuDivider(),
            _checkableItem(
              _MenuAction.showDeleted,
              'Show deleted messages',
              checked: _showDeleted,
            ),
            _checkableItem(
              _MenuAction.includeExpired,
              'Include expired messages',
              checked: _includeExpired,
            ),
            PopupMenuItem(
              value: _MenuAction.pageSize,
              child: Text('Page size: $_pageSize'),
            ),
            PopupMenuItem(
              value: _MenuAction.nextPage,
              enabled: _hasNextPage && !_loadingNextPage,
              child: const Text('Load next page'),
            ),
            const PopupMenuDivider(),
            _checkableItem(
              _MenuAction.developerInfo,
              'Developer info',
              checked: _showDeveloperInfo,
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<_MenuAction> _checkableItem(
    _MenuAction value,
    String label, {
    required bool checked,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (checked) const Icon(Icons.check, color: AppColors.primary),
        ],
      ),
    );
  }

  PreferredSizeWidget _selectionAppBar() {
    return AppBar(
      leading: IconButton(
        tooltip: 'Cancel',
        icon: const Icon(Icons.close),
        onPressed: () => setState(_endSelection),
      ),
      title: Text('${_selection.length} selected'),
    );
  }

  Widget _selectionToolbar() {
    final enabled = _selection.isNotEmpty;
    return Container(
      key: const ValueKey('inbox.list.selectionToolbar'),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: enabled ? () => _applyToSelection(_read) : null,
            child: const Text('Mark as read'),
          ),
          TextButton(
            onPressed: enabled ? () => _applyToSelection(_unread) : null,
            child: const Text('Mark as unread'),
          ),
          TextButton(
            onPressed: enabled ? () => _applyToSelection(_deleted) : null,
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _messageList() {
    final showEmpty = _loaded && _messages.isEmpty && _error == null;
    return RefreshIndicator(
      onRefresh: () => _fetchFirstPage(keepList: true),
      child: showEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                EmptyState(
                  key: ValueKey('inbox.list.emptyState'),
                  icon: Icons.inbox_outlined,
                  title: 'No messages',
                  message: 'Pull down to refresh',
                ),
              ],
            )
          : ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const Divider(indent: 36),
              itemBuilder: (context, index) => _messageRow(index),
            ),
    );
  }

  Widget _messageRow(int index) {
    final message = _messages[index];
    final status = message.getInboxStatus();
    final deleted = status == _deleted;
    final row = InboxMessageRow(
      key: ValueKey('inbox.list.cell.$index'),
      message: message,
      selected: _selection.contains(_keyOf(message)),
      onTap: () =>
          _selecting ? _toggleSelection(message) : _openMessage(message),
      onLongPress: _selecting
          ? null
          : () => setState(() {
              _selecting = true;
              _selection.add(_keyOf(message));
            }),
    );
    final restoreOrToggle = deleted || status == _unread ? _read : _unread;

    return Dismissible(
      key: ObjectKey(message),
      direction: _selecting
          ? DismissDirection.none
          : (deleted
                ? DismissDirection.startToEnd
                : DismissDirection.horizontal),
      background: SwipeBackground(
        color: AppColors.primary,
        alignment: Alignment.centerLeft,
        icon: deleted
            ? Icons.restore
            : (status == _unread
                  ? Icons.mark_email_read
                  : Icons.mark_email_unread),
      ),
      secondaryBackground: const SwipeBackground(
        color: AppColors.destructive,
        alignment: Alignment.centerRight,
        icon: Icons.delete,
      ),
      // The list updates itself after the SDK call, so the row never dismisses.
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _updateStatus([message], restoreOrToggle);
        } else {
          await _delete([message]);
        }
        return false;
      },
      child: row,
    );
  }
}

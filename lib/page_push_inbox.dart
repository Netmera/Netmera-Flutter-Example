///
/// Copyright (c) 2022 Inomera Research.
///
import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/NMInboxStatusCountFilter.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraInboxFilter.dart';
import 'package:netmera_flutter_sdk/NetmeraPushInbox.dart';

class PushInboxPage extends StatefulWidget {
  const PushInboxPage({Key? key}) : super(key: key);

  @override
  _PushInboxPageState createState() => _PushInboxPageState();
}

class _PushInboxPageState extends State<PushInboxPage> {
  String _currentStatus = Netmera.PUSH_OBJECT_STATUS_ALL.toString();
  String _count = "0";
  List<NetmeraPushInbox> _pushInboxList = List.empty(growable: true);

  List<DropdownMenuItem<String>> getInboxList() {
    List<DropdownMenuItem<String>> items = List.empty(growable: true);
    items.add(DropdownMenuItem(
        value: Netmera.PUSH_OBJECT_STATUS_ALL.toString(),
        child: const Text("ALL")));
    items.add(DropdownMenuItem(
        value: Netmera.PUSH_OBJECT_STATUS_READ.toString(),
        child: const Text("READ")));
    items.add(DropdownMenuItem(
        value: Netmera.PUSH_OBJECT_STATUS_UNREAD.toString(),
        child: const Text("UNREAD")));
    items.add(DropdownMenuItem(
        value: Netmera.PUSH_OBJECT_STATUS_DELETED.toString(),
        child: const Text("DELETED")));
    return items;
  }

  onInboxStatusChanged(String status) {
    setState(() {
      _currentStatus = status;
    });
  }

  String getStatusText(int status) {
    switch (status) {
      case Netmera.PUSH_OBJECT_STATUS_ALL:
        return "ALL";
      case Netmera.PUSH_OBJECT_STATUS_READ:
        return "READ";
      case Netmera.PUSH_OBJECT_STATUS_UNREAD:
        return "UNREAD";
      case Netmera.PUSH_OBJECT_STATUS_DELETED:
        return "DELETED";
    }
    return "";
  }

  fillInboxList(list) {
    setState(() {
      _pushInboxList = list;
    });
  }

  // Click Functions
  emptyAction() {}

  getInboxFilter() {
    NetmeraInboxFilter inboxFilter = NetmeraInboxFilter();
    inboxFilter.setPageSize(2);
    inboxFilter.setStatus(int.parse(_currentStatus));
    inboxFilter.setIncludeExpiredObjects(true);
    inboxFilter.setCategories(null);
    return inboxFilter;
  }

  fetchInbox() async {
    Netmera.fetchInbox(getInboxFilter()).then((list) {
      fillInboxList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  fetchNextPage() async {
    Netmera.fetchNextPage().then((list) {
      fillInboxList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  countForStatus() async {
    Netmera.countForStatus(int.parse(_currentStatus)).then((val) {
      setState(() {
        if (val != -1) {
          _count = val.toString();
        }
      });
    });
  }

  handlePushObject() async {
    if (_pushInboxList.isNotEmpty) {
      Netmera.handlePushObject(_pushInboxList[0].getPushId()!);
    }
  }

  handleInteractiveAction() async {
    if (_pushInboxList.isNotEmpty) {
      for (var element in _pushInboxList) {
        if (element.getInteractiveActions() != null &&
            element.getInteractiveActions()!.isNotEmpty) {
          Netmera.handleInteractiveAction(element.getInteractiveActions()![0]);
          return;
        }
      }
    }
  }

  inboxUpdateStatus() {
    List<String> selectedPushList = List.empty(growable: true);
    if (_pushInboxList.length > 1) {
      selectedPushList.add(_pushInboxList[0].getPushId()!);
      selectedPushList.add(_pushInboxList[1].getPushId()!);
    }
    int status = Netmera.PUSH_OBJECT_STATUS_UNREAD;
    Netmera.inboxUpdateStatus(selectedPushList, status).then((netmeraError) {
      if (netmeraError != null) {
        debugPrint(netmeraError);
      }
    }).catchError((error) {
      debugPrint(error);
    });
  }

  updateAll() async {
    if (_pushInboxList.isNotEmpty) {
      var updateStatus = int.parse(_currentStatus);
      if (updateStatus == Netmera.PUSH_OBJECT_STATUS_ALL) {
        debugPrint("Please select different status than all!!");
        return;
      }

      Netmera.updateAll(updateStatus).then((netmeraError) {
        fetchInbox();
      }).catchError((error) {
        debugPrint(error);
      });
    }
  }

  inboxCountForStatus() async {
    NMInboxStatusCountFilter filter = NMInboxStatusCountFilter();
    filter.setStatus(int.parse(_currentStatus));
    filter.setIncludeExpired(true);
    Netmera.getInboxCountForStatus(filter).then((map) {
      String countStatusText = "ALL: " +
          map[Netmera.PUSH_OBJECT_STATUS_ALL.toString()].toString() +
          ", " +
          "READ: " +
          map[Netmera.PUSH_OBJECT_STATUS_READ.toString()].toString() +
          ", " +
          "UNREAD: " +
          map[Netmera.PUSH_OBJECT_STATUS_UNREAD.toString()].toString() +
          ", " +
          "DELETED: " +
          map[Netmera.PUSH_OBJECT_STATUS_DELETED.toString()].toString();
      setState(() {
        _count = countStatusText;
      });
    }).catchError((error) {
      debugPrint(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Push Inbox"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 16.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: IntrinsicHeight(
                      child: DropdownButton(
                          value: _currentStatus,
                          items: getInboxList(),
                          onChanged: (String? status) {
                            setState(() {
                              _currentStatus = status!;
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: IntrinsicHeight(
                      child: ElevatedButton(
                        child: const Text('Fetch Inbox'),
                        onPressed: fetchInbox,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IntrinsicHeight(
                      child: ElevatedButton(
                        child: const Text('Fetch Next Page'),
                        onPressed: fetchNextPage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: IntrinsicHeight(
                      child: ElevatedButton(
                        child: const Text('Update All'),
                        onPressed: updateAll,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IntrinsicHeight(
                      child: ElevatedButton(
                        child: const Text('Update Status(Unread 2 elem.)'),
                        onPressed: inboxUpdateStatus,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IntrinsicHeight(
                      child: ElevatedButton(
                        child: const Text('Inbox Count For Status'),
                        onPressed: inboxCountForStatus,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: IntrinsicHeight(
                      child: ElevatedButton(
                        child: const Text('Count For Status'),
                        onPressed: countForStatus,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IntrinsicHeight(
                      child: ElevatedButton(
                        child: const Text('Handle Push Object'),
                        onPressed: handlePushObject,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IntrinsicHeight(
                      child: ElevatedButton(
                        child: const Text('Handle Interactive Action'),
                        onPressed: handleInteractiveAction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "Count For Status:" + _count,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _pushInboxListView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pushInboxListView(BuildContext context) {
    return ListView.separated(
      itemCount: _pushInboxList.length,
      itemBuilder: (context, index) {
        final inboxItem = _pushInboxList[index];
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Title: ' +
                (inboxItem.getTitle() == null
                    ? "null"
                    : inboxItem.getTitle()!)),
            Text('Subtitle: ' +
                (inboxItem.getSubtitle() == null
                    ? "null"
                    : inboxItem.getSubtitle()!)),
            Text('Body: ' +
                (inboxItem.getBody() == null ? "null" : inboxItem.getBody()!)),
            Text('Push Type: ' + inboxItem.getPushType().toString()),
            Text('Push Id: ' +
                (inboxItem.getPushId() == null
                    ? "null"
                    : inboxItem.getPushId()!)),
            Text('Push Instance Id: ' +
                (inboxItem.getPushInstanceId() == null
                    ? "null"
                    : inboxItem.getPushInstanceId()!)),
            Text('Send Date: ' +
                (inboxItem.getSendDate() == null
                    ? "null"
                    : inboxItem.getSendDate()!)),
            Text('Inbox Status: ' + inboxItem.getInboxStatus().toString()),
            Text('Action Deeplink Url: ' +
                (inboxItem.getDeepLink() == null
                    ? "null"
                    : inboxItem.getDeepLink()!)),
            Text('Action Web Page Url: ' +
                (inboxItem.getWebPage() == null
                    ? "null"
                    : inboxItem.getWebPage()!)),
            Text('External Id: ' +
                (inboxItem.getExternalId() == null
                    ? "null"
                    : inboxItem.getExternalId()!)),
            Text('Media Attachment Url: ' +
                (inboxItem.getMediaAttachmentUrl() == null
                    ? "null"
                    : inboxItem.getMediaAttachmentUrl()!)),
            Text('Categories: ' +
                (inboxItem.getCategories() == null
                    ? "null"
                    : inboxItem.getCategories().toString())),
            Text('Custom Json: ' +
                (inboxItem.getCustomJson() == null
                    ? "null"
                    : inboxItem.getCustomJson().toString())),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Carousel: '),
                inboxItem.getCarousel() == null
                    ? const Text("null")
                    : Expanded(
                        child: _carouselList(inboxItem.getCarousel()!),
                      )
              ],
            )
          ]),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
    );
  }

  Widget _carouselList(List carousel) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: carousel.length,
      itemBuilder: (context, index) {
        final carouselItem = carousel[index];
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('id: ' + (carouselItem["id"] ?? "null")),
            Text('bpp: ' + (carouselItem["bpp"] ?? "null")),
            Text('ctext: ' + (carouselItem["ctext"] ?? "null")),
            Text('ctitle: ' + (carouselItem["ctitle"] ?? "null")),
          ]),
        );
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
    );
  }
}

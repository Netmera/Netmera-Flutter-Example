///
/// Copyright (c) 2022 Inomera Research.
///
import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraCategory.dart';
import 'package:netmera_flutter_sdk/NetmeraCategoryFilter.dart';
import 'package:netmera_flutter_sdk/NetmeraCategoryPreference.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _currentStatus = Netmera.PUSH_OBJECT_STATUS_ALL.toString();
  List<dynamic> _categoryList = List.empty(growable: true);

  List<DropdownMenuItem<String>> getCategoryStatusList() {
    List<DropdownMenuItem<String>> items = List.empty(growable: true);
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_ALL.toString(), child: const Text("ALL")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_READ.toString(), child: const Text("READ")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_UNREAD.toString(), child: const Text("UNREAD")));
    items.add(DropdownMenuItem(value: Netmera.PUSH_OBJECT_STATUS_DELETED.toString(), child: const Text("DELETED")));
    return items;
  }

  onCategoryStatusChanged(String status) {
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

  // Click Functions
  emptyAction() {}

  getCategoryFilter() {
    NetmeraCategoryFilter categoryFilter = NetmeraCategoryFilter();
    categoryFilter.setPageSize(2);
    categoryFilter.setStatus(int.parse(_currentStatus));
    categoryFilter.setIncludeExpiredObjects(true);
    return categoryFilter;
  }

  fetchCategory() async {
    Netmera.fetchCategory(getCategoryFilter()).then((list) {
      fillCategoryList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  fetchNextCategoryPage() async {
    Netmera.fetchNextCategory().then((list) {
      fillCategoryList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  fillCategoryList(list) {
    setState(() {
      _categoryList = list;
    });
  }

  handleLastMessage() async {
    if (_categoryList.isNotEmpty) {
      Netmera.handleLastMessage(_categoryList[0]);
    }
  }

  updateStatusCategories() async {
    if (_categoryList.isNotEmpty) {
      List<String> selectedCategories = List.empty(growable: true);
      if (_categoryList.length == 1) {
        selectedCategories.add(_categoryList[0].getCategoryName()!);
      } else if (_categoryList.length > 1) {
        selectedCategories.add(_categoryList[0].getCategoryName()!);
        selectedCategories.add(_categoryList[1].getCategoryName()!);
      }

      Netmera.updateStatusByCategories(Netmera.PUSH_OBJECT_STATUS_READ, selectedCategories).then((netmeraError) {
        fetchCategory();
      }).catchError((error) {
        debugPrint(error);
      });
    }
  }

  getUserCategoryPreferenceList() async {
    Netmera.getUserCategoryPreferenceList().then((list) {
      fillCategoryList(list);
    }).catchError((error) {
      debugPrint(error);
    });
  }

  setUserCategoryPreference(NetmeraCategoryPreference item) async {
    Netmera.setUserCategoryPreference(item.getCategoryId()!, !item.getOptInStatus()!).then((value) {
      debugPrint("Successfully set user category preference list");
    }).catchError((error) {
      debugPrint(error);
    });
  }

  Widget categoryListView(BuildContext context) {
    if (_categoryList is List<NetmeraCategory>) {
      return ListView.separated(
        itemCount: _categoryList.length,
        itemBuilder: (context, index) {
          final categoryItem = _categoryList[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Category Name: ' + (categoryItem.getCategoryName() == null ? "null" : categoryItem.getCategoryName()!)),
              Text('Read Count: ' + (categoryItem.getReadCount() == null ? "null" : categoryItem.getReadCount()!.toString())),
              Text('Unread Count: ' +
                  (categoryItem.getUnReadCount() == null ? "null" : categoryItem.getUnReadCount()!.toString())),
              Text('Deleted Count: ' +
                  (categoryItem.getDeletedCount() == null ? "null" : categoryItem.getDeletedCount()!.toString())),
              Text('Last Message: ' + (categoryItem.getLastMessage().toString())),
            ]),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      );
    } else if (_categoryList is List<NetmeraCategoryPreference>) {
      return ListView.separated(
        itemCount: _categoryList.length,
        itemBuilder: (context, index) {
          final preferenceItem = _categoryList[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(children: [
              Expanded(
                child: IntrinsicHeight(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('Category Id: ' +
                        (preferenceItem.getCategoryId() == null ? "null" : preferenceItem.getCategoryId()!.toString())),
                    Text('Category Name: ' +
                        (preferenceItem.getCategoryName() == null ? "null" : preferenceItem.getCategoryName()!)),
                  ]),
                ),
              ),
              IntrinsicHeight(
                child: ElevatedButton(
                  child: Text(preferenceItem.getOptInStatus() ? 'Disable' : 'Enable'),
                  onPressed: () => {setUserCategoryPreference(preferenceItem)},
                ),
              ),
            ]),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      );
    }
    return const Text("");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: IntrinsicHeight(
                    child: DropdownButton(
                        value: _currentStatus,
                        items: getCategoryStatusList(),
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
                      child: const Text('Fetch Category'),
                      onPressed: fetchCategory,
                    ),
                  ),
                ),
                Expanded(
                  child: IntrinsicHeight(
                    child: ElevatedButton(
                      child: const Text('Fetch Next Category Page'),
                      onPressed: fetchNextCategoryPage,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: IntrinsicHeight(
                    child: ElevatedButton(
                      child: const Text('Handle Last Message'),
                      onPressed: handleLastMessage,
                    ),
                  ),
                ),
                Expanded(
                  child: IntrinsicHeight(
                    child: ElevatedButton(
                      child: const Text('Update Status For First Two Categories'),
                      onPressed: updateStatusCategories,
                    ),
                  ),
                ),
                Expanded(
                  child: IntrinsicHeight(
                    child: ElevatedButton(
                      child: const Text('User Category Preference List'),
                      onPressed: getUserCategoryPreferenceList,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: categoryListView(context),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraCouponDetail.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({Key? key}) : super(key: key);

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  List<NetmeraCouponDetail> coupons = [];
  String max = "";
  String page = "";

  @override
  void initState() {
    super.initState();
  }

  onFetchCouponsPress() {
    if (max != "" && page != "") {
      Netmera.fetchCoupons(int.parse(page), int.parse(max))
          .then((fetchedCoupons) {
        setState(() {
          coupons = fetchedCoupons;
        });
      }).catchError((error) {
        debugPrint(error);
        Fluttertoast.showToast(
            msg: error.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Coupons"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Page',
                    ),
                    onChanged: (value) {
                      setState(() {
                        page = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max',
                    ),
                    onChanged: (value) {
                      setState(() {
                        max = value;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 32, bottom: 32),
            child: ElevatedButton(
              onPressed: onFetchCouponsPress,
              child: const Text('FETCH COUPONS'),
            ),
          ),
          coupons.isEmpty
              ? const Text('No coupons found')
              : Expanded(
                  child: ListView.builder(
                      itemCount: coupons.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = coupons[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Coupon id: ${item.getCouponId()}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Coupon Name: ${item.getName()}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Code: ${item.getCode()}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Assign Date: ${item.getAssignDate()}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              Text(
                                'Expire Date: ${item.getExpireDate()}',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
        ],
      ),
    );
  }
}

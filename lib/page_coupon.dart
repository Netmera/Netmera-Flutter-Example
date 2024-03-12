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

  onFetchCouponsPress() {
    if (max != "" && page != "") {
      Netmera.fetchCoupons(int.parse(page), int.parse(max))
          .then((fetchedCoupons) {
        coupons = fetchedCoupons;
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
            margin: const EdgeInsets.only(top: 32, bottom: 16),
            child: ElevatedButton(
              onPressed: onFetchCouponsPress,
              child: const Text('FETCH COUPONS'),
            ),
          ),
          const Text('No coupons found')
        ],
      ),
    );
  }
}

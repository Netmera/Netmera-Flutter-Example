import 'package:flutter/material.dart';

Future<T?> pushPage<T extends Object?>(
  BuildContext context,
  Widget page,
  String title,
) {
  return Navigator.push<T>(
    context,
    MaterialPageRoute<T>(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: page,
      ),
    ),
  );
}

///
/// Copyright (c) 2022 Inomera Research.
///
import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraUser.dart';

import 'main.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController msisdnController = TextEditingController();

  identifyUserAsync() {
    NetmeraUser user = NetmeraUser();
    if (userController.text != "") user.setUserId(userController.text);
    if (emailController.text != "") user.setEmail(emailController.text);
    if (msisdnController.text != "") user.setMsisdn(msisdnController.text);
    Netmera.identifyUser(user);
  }

  identifyUser() {
    NetmeraUser user = NetmeraUser();
    if (userController.text != "") user.setUserId(userController.text);
    if (emailController.text != "") user.setEmail(emailController.text);
    if (msisdnController.text != "") user.setMsisdn(msisdnController.text);

    Netmera.identifyUser(user,
      onSuccess: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User identified successfully!')));
        }
      },
      onFailure: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Identify user failed: $error')));
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("User Identify"),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                child: TextField(
                  controller: userController,
                  decoration:
                      const InputDecoration(labelText: 'User Id (Optional)'),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: TextField(
                    controller: emailController,
                    decoration:
                        const InputDecoration(labelText: 'Email (Optional)'),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: TextField(
                    controller: msisdnController,
                    decoration:
                        const InputDecoration(labelText: 'Msisdn (Optional)'),
                  )),
              Container(
                margin: const EdgeInsets.only(top: 30, right: 32, left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    button('Identify User', identifyUser),
                    button('Identify User Async', identifyUserAsync),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

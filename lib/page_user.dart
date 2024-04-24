///
/// Copyright (c) 2022 Inomera Research.
///
import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraUser.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'main.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController userController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController msisdnController = TextEditingController();
  String _selectedGender = NetmeraUser.GENDER_NOT_SPECIFIED.toString();

  updateUserAsync() {
    NetmeraUser user = NetmeraUser();
    user.setUserId(userController.text);
    user.setName(nameController.text);
    user.setSurname(surnameController.text);
    user.setEmail(emailController.text);
    user.setMsisdn(msisdnController.text);
    user.setGender(int.parse(_selectedGender));
    Netmera.updateUser(user);
  }

  updateUserSync() {
    NetmeraUser user = NetmeraUser();
    user.setUserId(userController.text);
    user.setName(nameController.text);
    user.setSurname(surnameController.text);
    user.setEmail(emailController.text);
    user.setMsisdn(msisdnController.text);
    user.setGender(int.parse(_selectedGender));

    print("a");

    Netmera.updateUser(user).then((_) {
      print("b");

      Fluttertoast.showToast(
          msg: 'User updated successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 166, 186, 171),
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  List<DropdownMenuItem<String>> getGenderList() {
    List<DropdownMenuItem<String>> items = List.empty(growable: true);
    items.add(DropdownMenuItem(
        value: NetmeraUser.GENDER_NOT_SPECIFIED.toString(),
        child: const Text("NOT SPECIFIED")));
    items.add(DropdownMenuItem(
        value: NetmeraUser.GENDER_MALE.toString(), child: const Text("MALE")));
    items.add(DropdownMenuItem(
        value: NetmeraUser.GENDER_FEMALE.toString(),
        child: const Text("FEMALE")));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("User"),
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
                      const InputDecoration(labelText: 'User (Optional)'),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Name (Optional)'),
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: TextField(
                    controller: surnameController,
                    decoration:
                        const InputDecoration(labelText: 'Surname (Optional)'),
                  )),
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
              Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Row(children: [
                    const Text('Gender (Optional)'),
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: DropdownButton(
                            value: _selectedGender,
                            items: getGenderList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedGender = val as String;
                              });
                            }))
                  ])),
              Container(
                margin: const EdgeInsets.only(top: 30, right: 32, left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    button('Update User Sync', updateUserSync),
                    button('Update User Async', updateUserAsync),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

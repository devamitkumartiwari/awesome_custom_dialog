library awesome_custom_dialog;

import 'package:awesome_custom_dialog/awesome_custom_dialog.dart';
import 'package:flutter/material.dart';

import 'notice_dialog.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AppHome(),
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    ACDDialog.init(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          showAlertDialog(context),
        ],
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Awesome custom dialog"),
        const SizedBox(
          height: 20,
        ),
        Column(
          children: [
            MaterialButton(
              onPressed: () {
                acdNoticeDialog();
              },
              child: Container(
                height: 40,
                width: 300,
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Success Dialog",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

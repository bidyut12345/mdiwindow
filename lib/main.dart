import 'package:flutter/material.dart';

import 'mdi_controller.dart';
import 'mdi_manager.dart';

void main() {
  runApp(MyApp());
}

late MdiController mdiController;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MDI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    mdiController = MdiController(() {
      setState(() {});
    });
  }

  int formID = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mdiController.addWindow("Form$formID", formID);
          formID++;
        },
      ),
      body: MdiManager(
        windowCount: formID,
        mdiController: mdiController,
      ),
    );
  }
}

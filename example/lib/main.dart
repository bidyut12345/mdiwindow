import 'package:flutter/material.dart';
import 'package:mdiwindow/mdiwindow.dart';
// import 'package:mdiwindow/mdiwindow.dart';
import 'package:menu_bar/menu_bar.dart';

void main() {
  MdiConfig.adjustWindowSizePositionOnParentSizeChanged = true;
  runApp(const MyApp());
}

late MdiController mdiController;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MDI Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
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
    return MenuBarWidget(
      barStyle: MenuStyle(
        visualDensity: VisualDensity.compact,
        padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry?>(
          (Set<MaterialState> states) {
            // if (states.contains(MaterialState.focused)) {
            //   return Theme.of(context).colorScheme.primary.withOpacity(1);
            // }
            // return null; // Use the component's default.
            return EdgeInsets.all(1);
          },
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            // if (states.contains(MaterialState.focused)) {
            //   return Theme.of(context).colorScheme.primary.withOpacity(1);
            // }
            // return null; // Use the component's default.
            return Color.fromARGB(255, 51, 51, 51);
          },
        ),
      ),
      // The buttons in this List are displayed as the buttons on the bar itself
      barButtons: [
        BarButton(
          text: const Text(
            'File',
            style: TextStyle(color: Colors.white),
          ),
          submenu: SubMenu(
            menuItems: [
              BarButton(
                text: const Text(
                  'File',
                  style: TextStyle(color: Colors.white),
                ),
                submenu: SubMenu(
                  menuItems: [
                    MenuButton(
                      text: const Text('New'),
                      onTap: () {},
                      // icon: const Icon(Icons.save),
                      shortcutText: 'Ctrl+N',
                    ),
                    MenuButton(
                      text: const Text('Save'),
                      onTap: () {},
                      // icon: const Icon(Icons.save),
                      shortcutText: 'Ctrl+S',
                    ),
                    MenuButton(
                      text: const Text('Close'),
                      onTap: () {},
                      // icon: const Icon(Icons.save),
                      shortcutText: 'Ctrl+X',
                    ),
                    const MenuDivider(),
                    MenuButton(
                      text: const Text('Exit'),
                      onTap: () {},
                      icon: const Icon(Icons.exit_to_app),
                      shortcutText: 'Ctrl+Q',
                    ),
                  ],
                ),
              ),
              MenuButton(
                text: const Text('New'),
                onTap: () {},
                // icon: const Icon(Icons.save),
                shortcutText: 'Ctrl+N',
              ),
              MenuButton(
                text: const Text('Save'),
                onTap: () {},
                // icon: const Icon(Icons.save),
                shortcutText: 'Ctrl+S',
              ),
              MenuButton(
                text: const Text('Close'),
                onTap: () {},
                // icon: const Icon(Icons.save),
                shortcutText: 'Ctrl+X',
              ),
              const MenuDivider(),
              MenuButton(
                text: const Text('Exit'),
                onTap: () {},
                icon: const Icon(Icons.exit_to_app),
                shortcutText: 'Ctrl+Q',
              ),
            ],
          ),
        ),
        BarButton(
          text: const Text(
            'Help',
            style: TextStyle(color: Colors.white),
          ),
          submenu: SubMenu(
            menuItems: [
              MenuButton(
                text: const Text('View License'),
                onTap: () {},
              ),
              MenuButton(
                text: const Text('About'),
                onTap: () {},
                icon: const Icon(Icons.info),
              ),
            ],
          ),
        ),
      ],

      // Set the child, i.e. the application under the menu bar
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            mdiController.addWindow(title: "Form$formID", child: page(), uniqueId: formID.toString(), uniqueSettingName: "MDIDemo");
            formID++;
          },
        ),
        body: MdiManager(
          mdiController: mdiController,
        ),
      ),
    );
  }

  Widget page() {
    return Builder(builder: (context) {
      return Container(
        child: Center(
          child: ElevatedButton(
            child: Text("Dialog"),
            onPressed: () {
              mdiController.addWindow(
                title: "Form$formID",
                child: page(),
                uniqueId: formID.toString(),
                uniqueSettingName: "MDIDemo",
                isDailog: true,
                dialogParent: mdiController.thisWindow(context),
              );
              formID++;
            },
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:mdiwindow/main.dart';
import 'mdi_controller.dart';
import 'resizable_window.dart';

class MdiManager extends StatefulWidget {
  final MdiController mdiController;
  final int windowCount;

  const MdiManager({super.key, required this.mdiController, required this.windowCount});

  @override
  // ignore: library_private_types_in_public_api
  _MdiManagerState createState() => _MdiManagerState();
}

class _MdiManagerState extends State<MdiManager> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, boxcons) {
            return Stack(
                fit: StackFit.expand,
                children: widget.mdiController.windows.map((e) {
                  return Visibility(
                    key: ValueKey("formid${e.formIndex}"),
                    visible: !(e.isMinimized && e.isAnimationEnded),
                    child: AnimatedPositioned(
                      duration: Duration(milliseconds: e.isWindowDraggin ? 0 : 300),
                      curve: Curves.easeOutCubic,
                      onEnd: () {
                        e.isAnimationEnded = true;
                        e.globalSetState!();
                      },

                      left: e.isMinimized ? 0 : (e.isMaximized ? 0 : e.x),
                      top: e.isMinimized ? boxcons.maxHeight : (e.isMaximized ? 0 : e.y),

                      height: e.isMinimized ? 0 : (e.isMaximized ? boxcons.maxHeight : e.currentHeight),
                      width: e.isMinimized ? 50 : (e.isMaximized ? boxcons.maxWidth : e.currentWidth),
                      // right: e.isMaximized ? 0 : null,
                      // bottom: e.isMaximized ? 0 : null,
                      // key: e.key,
                      child: e,
                    ),
                  );
                }).toList());
          }),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            //Here goes the same radius, u can put into a var or function
            borderRadius: BorderRadius.all(Radius.circular(2)),
            boxShadow: [
              BoxShadow(
                color: Color(0x54000000),
                spreadRadius: 3,
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    widget.windowCount + 2,
                    (index) {
                      ResizableWindow? item;
                      try {
                        item = widget.mdiController.windows.firstWhere((element) => element.formIndex == index);
                      } catch (_) {}

                      return item == null
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.only(top: 3, left: 10, bottom: 3),
                                    backgroundColor: item == widget.mdiController.windows.last ? Colors.blue[700] : Colors.blue[500],
                                    minimumSize: Size(100, 32),
                                    alignment: Alignment.centerLeft),
                                onPressed: () {
                                  var isRestored = false;
                                  item?.isAnimationEnded = false;
                                  if (item?.isMinimized ?? false) {
                                    isRestored = true;
                                    item?.isWindowDraggin = false;
                                    item?.isAnimationEnded = true;
                                    item?.isMinimized = false;
                                    mdiController.onUpdate();
                                  } else {}

                                  if (mdiController.windows.isNotEmpty && mdiController.windows.last == item && !isRestored) {
                                    item?.isMinimized = true;
                                    mdiController.onUpdate();
                                  } else {
                                    item?.onWindowDown!();
                                    item?.globalSetState!();
                                  }
                                },
                                child: Text(
                                  item.title,
                                ),
                              ),
                            );
                    },
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

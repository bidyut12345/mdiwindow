import 'package:flutter/material.dart';
import 'package:mdiwindow/mdiwindow.dart';
import 'global.dart';
// import 'mdi_controller.dart';
import 'resizable_window.dart';

class MdiManager extends StatefulWidget {
  final MdiController mdiController;

  const MdiManager({super.key, required this.mdiController});

  @override
  MdiManagerState createState() => MdiManagerState();
}

class MdiManagerState extends State<MdiManager> {
  @override
  void initState() {
    super.initState();
    mdiController = widget.mdiController;
  }

  bool isDarkMode() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LayoutBuilder(builder: (context, boxcons) {
            mdiController.mdiHeight = boxcons.maxHeight;
            mdiController.mdiWidth = boxcons.maxWidth;
            // print("maxWidth12345 : ${MediaQuery.of(context).size.height}");
            return Stack(
              fit: StackFit.expand,
              children: [
                Stack(
                  fit: StackFit.expand,
                  children: widget.mdiController.windows.where((element) => !element.isDialog).map((e) {
                    return getItem(e, boxcons, context);
                  }).toList(),
                ),
                Visibility(
                  visible: widget.mdiController.windows.where((element) => element.isDialog).isNotEmpty,
                  child: Container(
                    color: isDarkMode() ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
                    child: Stack(
                      fit: StackFit.expand,
                      children: widget.mdiController.windows.where((element) => element.isDialog).map((e) {
                        return getItem(e, boxcons, context);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        bottomBar(),
      ],
    );
  }

  var _tapPosition;

  void _showCustomMenu(ResizableWindow? item) async {
    if (_tapPosition == null) {
      return;
    }
    final overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) {
      return;
    }

    final delta = await showMenu(
      context: context,
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 1,
          child: ListTile(
            leading: const Icon(Icons.close),
            title: const Text("Close"),
            onTap: () {
              item?.onWindowClosed!(item.returnvalue);
              Navigator.pop(context);
            },
          ),
        ),
      ],
      position: RelativeRect.fromRect(
        _tapPosition! & const Size(40, 40),
        Offset.zero & overlay.semanticBounds.size,
      ),
    );

    if (delta == null) {
      return;
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget bottomBar() {
    return widget.mdiController.windows.where((element) => element.isDialog).isNotEmpty
        ? Container()
        : Container(
            decoration: BoxDecoration(
              color: isDarkMode() ? const Color.fromARGB(120, 15, 20, 15) : Color.fromARGB(120, 179, 194, 199),
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
                PopupMenuButton<String>(
                  // child: FlutterLogo(),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        child: ListTile(
                          title: Text("Show Windows Side by Side"),
                          leading: mdiController.isSideBySide
                              ? Icon(Icons.check)
                              : Opacity(
                                  opacity: 0,
                                  child: Icon(Icons.email),
                                ),
                          onTap: () {
                            //   var sublist = widget.mdiController.windows
                            //       .where((element) => !element.isMaximized && !element.isMinimized)
                            //       .toList();
                            //   var count = sublist.length;
                            //   if (count > 1) {
                            //     double widt = widget.mdiController.mdiWidth / count;
                            //     // double lff = widget.mdiController.mdiWidth / count;
                            //     if (MdiConfig.adjustWindowSizePositionOnParentSizeChanged) {
                            //       widt = (1.0 / count);
                            //     }
                            //     var left = widt / widget.mdiController.mdiWidth / 2;
                            //     if (MdiConfig.adjustWindowSizePositionOnParentSizeChanged) {
                            //       left = widt / 2;
                            //     }
                            //     for (ResizableWindow item in sublist) {
                            //       item.currentWidth = widt;
                            //       item.currentHeight = widget.mdiController.mdiHeight;
                            //       if (MdiConfig.adjustWindowSizePositionOnParentSizeChanged) {
                            //         item.currentHeight = 1;
                            //       }
                            //       item.x = left;
                            //       item.y = 0.0;
                            //       left += widt;
                            //       item.globalSetState!();
                            //     }
                            // }
                            mdiController.refreshSideBySideWindows();
                            mdiController.isSideBySide = !mdiController.isSideBySide;
                            mdiController.onUpdate();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {},
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Icon(Icons.minimize_outlined),
                            ),
                            Text("Hide All"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {},
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.width_normal),
                            ),
                            Text("Show All"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {},
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.close_rounded),
                            ),
                            Text("Close All"),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        widget.mdiController.formIndex + 2,
                        (index) {
                          ResizableWindow? item;
                          try {
                            item = widget.mdiController.windows.firstWhere((element) => element.formIndex == index);
                          } catch (_) {}

                          return item == null
                              ? Container()
                              : GestureDetector(
                                  onSecondaryTapDown: _storePosition,
                                  onSecondaryTap: () {
                                    _showCustomMenu(item);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: ElevatedButton(
                                      key: ValueKey("form_task${item.formIndex}"),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.only(top: 3, left: 10, bottom: 3, right: 10),
                                        backgroundColor: item == widget.mdiController.windows.last
                                            ? Colors.blue[500]
                                            : const Color.fromARGB(255, 23, 66, 109),
                                        minimumSize: const Size(100, 32),
                                        alignment: Alignment.centerLeft,
                                      ),
                                      onPressed: () {
                                        // widget.onWindowClosed!();
                                        // item?.isWindowDraggin = false;
                                        // if (!item!.isMinimized) {
                                        //   item!.isAnimationEnded = false;
                                        // } else {
                                        //   item!.isAnimationEnded = true;
                                        // }
                                        // item!.isMinimized = !item.isMinimized;
                                        // if (item!.dialogParent != null) {
                                        //   item.dialogParent?.globalSetState!();
                                        // } else {
                                        //   mdiController.onUpdate();
                                        // }
                                        // setState(() {});

                                        var isRestored = false;
                                        item?.isAnimationEnded = false;
                                        if (item?.isMinimized ?? false) {
                                          item?.onWindowDown!();
                                          mdiController.onUpdate();
                                          isRestored = true;
                                          item?.isWindowDraggin = false;
                                          item?.isAnimationEnded = false;
                                          item?.isMinimized = false;
                                          mdiController.onUpdate();
                                        } else {}

                                        if (!isRestored) {
                                          if (mdiController.windows.isNotEmpty &&
                                              mdiController.windows.last == item &&
                                              !isRestored) {
                                            item?.isWindowDraggin = false;
                                            item?.isAnimationEnded = false;
                                            item?.isMinimized = true;
                                            mdiController.onUpdate();
                                          } else {
                                            item?.onWindowDown!();
                                            item?.globalSetState!();
                                          }
                                        }
                                      },
                                      child: Column(children: [
                                        Text(
                                          item.title,
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          height: 2,
                                          child: item == widget.mdiController.windows.last
                                              ? Text(
                                                  item.title,
                                                  style: const TextStyle(height: 1, color: Colors.transparent),
                                                )
                                              : null,
                                        )
                                      ]),
                                    ),
                                  ),
                                );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget getItem(ResizableWindow e, BoxConstraints boxcons, BuildContext context) {
    double? heightLocal = e.isMaximized ? boxcons.maxHeight : e.currentHeight;
    double? widthLocal = e.isMaximized ? boxcons.maxWidth : e.currentWidth;
    if (heightLocal! > boxcons.maxHeight) {
      heightLocal = boxcons.maxHeight;
    }
    if (widthLocal! > boxcons.maxWidth) {
      widthLocal = boxcons.maxWidth;
    }
    if (MdiConfig.adjustWindowSizePositionOnParentSizeChanged) {
      if (heightLocal <= 1) {
        heightLocal = (e.isMaximized ? 1 : (e.currentHeight ?? 0.8)) * boxcons.maxHeight;
      }
      if (widthLocal <= 1) {
        widthLocal = (e.isMaximized ? 1 : (e.currentWidth ?? 0.5)) * boxcons.maxWidth;
      }
    }
    // print("e.currentHeight ${e.currentHeight} e.currentWidth ${e.currentWidth}");

    double minimizedLeft = 0;
    // if (e.isMinimized) {
    //   final RenderBox renderBox = ValueKey("form_task${e.formIndex}")..currentContext?.findRenderObject() as RenderBox;
    //   final Size size = renderBox.size;
    // }
    double leftLocal =
        e.isMinimized ? minimizedLeft : (e.isMaximized ? 0 : ((e.x! * boxcons.maxWidth) - (widthLocal! / 2)));
    double topLocal = e.isMinimized
        ? boxcons.maxHeight + 10
        : (e.isMaximized ? 0 : ((e.y! * boxcons.maxHeight) - (heightLocal! / 2)));
    if (!MdiConfig.adjustWindowSizePositionOnParentSizeChanged) {
      leftLocal = e.isMinimized ? 20 : (e.isMaximized ? 0 : e.x!);
      topLocal = e.isMinimized ? boxcons.maxHeight + 10 : (e.isMaximized ? 0 : e.y!);
    }

    // if (leftLocal < 0) {
    //   leftLocal = 0;
    // }
    if (topLocal < 0) {
      topLocal = 0;
    }
    if (e.dialogParent != null) {
      if ((topLocal + heightLocal) > (e.dialogParent?.currentHeight ?? 0)) {
        topLocal = 0;
      }
    }
    if (mdiController.isSideBySide) {
      if (mdiController.sidebysidewindows.contains(e)) {
        // var sublist = mdiController.windows.where((element) => !element.isMaximized && !element.isMinimized).toList();
        double widt = boxcons.maxWidth / mdiController.sidebysidewindows.length;

        int index = mdiController.sidebysidewindows.indexOf(e);
        widthLocal = widt;
        leftLocal = widt * index;
        topLocal = 0.0;
        heightLocal = boxcons.maxHeight;
      }
    }
    // print("heightLocal $heightLocal widthLocal $widthLocal");
    return AnimatedPositioned(
      key: ValueKey("formid${e.formIndex}"),
      duration: Duration(milliseconds: e.isWindowDraggin ? 0 : 300),
      curve: Curves.easeOutCubic,
      onEnd: () {
        e.isAnimationEnded = true;
        e.globalSetState!();
      },
      // left: e.x,
      // top: e.y,
      height: heightLocal,
      width: widthLocal,
      left: leftLocal,
      top: topLocal,
      // height: e.isMinimized ? 0 : (e.isMaximized ? boxcons.maxHeight : e.currentHeight),
      // width: e.isMinimized ? 50 : (e.isMaximized ? boxcons.maxWidth : e.currentWidth),
      child: AnimatedScale(
        curve: Curves.easeOutCubic,
        alignment: Alignment.topLeft,
        scale: e.isMinimized ? 0.05 : 1,
        duration: Duration(milliseconds: e.isWindowDraggin ? 0 : 300),
        child: AnimatedOpacity(
          opacity: e.isMinimized ? 0.05 : 1,
          duration: Duration(milliseconds: e.isWindowDraggin ? 0 : 200),
          child: e,
        ),
        // Visibility(
        //   visible: true, // !(e.isMinimized && e.isAnimationEnded),
        //   child: e,
        // ),
      ),
    );
  }
}

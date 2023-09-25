import 'package:flutter/material.dart';
import '../mdiwindow.dart';
import 'resizable_window.dart';

class MdiManager extends StatefulWidget {
  final MdiController mdiController;

  const MdiManager({super.key, required this.mdiController});

  @override
  // ignore: library_private_types_in_public_api
  _MdiManagerState createState() => _MdiManagerState();
}

class _MdiManagerState extends State<MdiManager> {
  @override
  void initState() {
    super.initState();
    mdiController = widget.mdiController;
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
            return Stack(
              fit: StackFit.expand,
              children: [
                Stack(
                    fit: StackFit.expand,
                    children: widget.mdiController.windows.where((element) => !element.isDialog).map((e) {
                      return getItem(e, boxcons, context);
                    }).toList()),
                Visibility(
                  visible: widget.mdiController.windows.where((element) => element.isDialog).isNotEmpty,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Stack(
                        fit: StackFit.expand,
                        children: widget.mdiController.windows.where((element) => element.isDialog).map((e) {
                          return getItem(e, boxcons, context);
                        }).toList()),
                  ),
                ),
              ],
            );
          }),
        ),
        widget.mdiController.windows.where((element) => element.isDialog).isNotEmpty
            ? Container()
            : Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 15, 20, 15),
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
                    const SizedBox(height: 30),
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
                                  : Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: ElevatedButton(
                                        key: ValueKey("form_task${item.formIndex}"),
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.only(top: 3, left: 10, bottom: 3, right: 10),
                                            backgroundColor: item == widget.mdiController.windows.last
                                                ? const Color.fromARGB(255, 23, 66, 109)
                                                : Colors.blue[500],
                                            minimumSize: const Size(100, 32),
                                            alignment: Alignment.centerLeft),
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
                                        child: Text(
                                          item.title,
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
              ),
      ],
    );
  }

  Widget getItem(ResizableWindow e, BoxConstraints boxcons, BuildContext context) {
    double? heightLocal = e.isMaximized ? boxcons.maxHeight : e.currentHeight;
    double? widthLocal = e.isMaximized ? boxcons.maxWidth : e.currentWidth;
    if (mdiController.locationInPercent) {
      if (heightLocal! > boxcons.maxHeight) {
        heightLocal = boxcons.maxHeight;
      }
      if (widthLocal! > boxcons.maxWidth) {
        widthLocal = boxcons.maxWidth;
      }
    }

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
    if (!mdiController.locationInPercent) {
      leftLocal = e.isMinimized ? 20 : (e.isMaximized ? 0 : e.x!);
      topLocal = e.isMinimized ? boxcons.maxHeight + 10 : (e.isMaximized ? 0 : e.y!);
    }
    if (leftLocal < 0) {
      leftLocal = 0;
    }
    if (topLocal < 0) {
      topLocal = 0;
    }
    if (e.dialogParent != null) {
      if (topLocal + (heightLocal ?? 0) > (e.dialogParent?.currentHeight ?? 0)) {
        topLocal = 0;
      }
    }
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

import 'package:flutter/material.dart';

import '../mdiwindow.dart';

// ignore: must_be_immutable
class ResizableWindow extends StatefulWidget {
  ResizableWindow({
    super.key,
    required this.title,
    required this.formIndex,
    required this.child,
    this.currentHeight = 600,
    this.currentWidth = 1200,
    required this.uniqueId,
  });

  final String title;
  final int formIndex;
  final Widget child;
  final String? uniqueId;

  double? currentHeight;
  double? currentWidth;
  double minHeight = 50.0;
  double minWidth = 200.0;
  double? x = 0.0;
  double? y = 0.0;
  bool isMinimized = false;
  bool isMaximized = false;
  bool isWindowDraggin = false;
  bool isAnimationEnded = true;
  bool isDialog = false;
  bool isResizeable = true;
  bool isMinimizeable = true;

  Function(double, double, bool)? onWindowDragged;
  Function()? onWindowDown;
  Function(dynamic returnvalue)? onWindowClosed;
  Function()? globalSetState;
  Function<bool>()? onClose;
  Function(dynamic returnvalue)? onClosed;

  ResizableWindow? dialogChild;
  ResizableWindow? dialogParent;

  dynamic returnvalue;
  @override
  // ignore: library_private_types_in_public_api
  _ResizableWindowState createState() => _ResizableWindowState();
}

class _ResizableWindowState extends State<ResizableWindow> {
  var _headerSize = 30.0;
  var _borderRadius = 6.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.globalSetState = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        //Here goes the same radius, u can put into a var or function
        borderRadius:
            widget.isMaximized && widget.isAnimationEnded ? null : BorderRadius.all(Radius.circular(_borderRadius)),
        boxShadow: widget.isMaximized && widget.isAnimationEnded
            ? null
            : const [
                BoxShadow(
                  color: Color(0x54000000),
                  spreadRadius: 3,
                  blurRadius: 20,
                ),
              ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: _getHeader(),
          // ),
          // Positioned(
          //   right: 0,
          //   left: 0,
          //   top: _headerSize,
          //   bottom: 0,
          //   child: _getBody(),
          // ),
          Column(
            children: [
              _getHeader(),
              Expanded(child: _getBody()),
            ],
          ),
          if (!widget.isMaximized && !widget.isMinimized && widget.isResizeable) ...[
            Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: _onHorizontalDragRight,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    opaque: true,
                    child: Container(
                      width: 4,
                    ),
                  ),
                )),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: GestureDetector(
                onVerticalDragUpdate: _onHorizontalDragBottom,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  opaque: true,
                  child: Container(
                    height: 4,
                  ),
                ),
              ),
            ),
            Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: _onHorizontalDragLeft,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    opaque: true,
                    child: Container(
                      width: 4,
                    ),
                  ),
                )),
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              child: GestureDetector(
                onVerticalDragUpdate: _onHorizontalDragTop,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  opaque: true,
                  child: Container(
                    height: 4,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onPanUpdate: _onHorizontalDragBottomRight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeDownRight,
                  opaque: true,
                  child: Container(
                    height: 4,
                    width: 4,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  _getHeader() {
    return Container(
      // width: widget.isMaximized ? null : widget.currentWidth,
      height: _headerSize,
      color: widget == mdiController.thisWindow(context)
          ? Color.fromARGB(255, 12, 25, 39)
          : Color.fromARGB(255, 12, 63, 105),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (tapInfo) {
                if (!widget.isMaximized) {
                  widget.onWindowDragged!(tapInfo.delta.dx, tapInfo.delta.dy, false);
                }
              },
              onDoubleTap: () {
                if (!widget.isResizeable) return;
                widget.isWindowDraggin = false;
                // widget.onWindowClosed!();
                if (!widget.isMaximized) {
                  widget.isAnimationEnded = false;
                } else {
                  widget.isAnimationEnded = true;
                }
                widget.isMaximized = !widget.isMaximized;
                setState(() {});
                if (widget.dialogParent != null) {
                  widget.dialogParent?.globalSetState!();
                } else {
                  mdiController.onUpdate();
                }
              },
              onPanDown: (tapInfo) {
                widget.onWindowDown!();
                setState(() {});
              },
              onPanStart: (details) {
                widget.isWindowDraggin = true;
                if (widget.dialogParent != null) {
                  widget.dialogParent?.globalSetState!();
                } else {
                  mdiController.onUpdate();
                }
              },
              onPanEnd: (details) {
                widget.isWindowDraggin = false;
                if (widget.dialogParent != null) {
                  widget.dialogParent?.globalSetState!();
                } else {
                  mdiController.onUpdate();
                }
              },
              child: Container(
                color: Colors.red.withOpacity(0.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, left: 10.0),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.grey[100],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(2.0),
          //   child: SizedBox(
          //     width: 35,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         // widget.onWindowClosed!();
          //         widget.isWindowDraggin = false;
          //         if (!widget.isMinimized) {
          //           widget.isAnimationEnded = false;
          //         } else {
          //           widget.isAnimationEnded = true;
          //         }
          //         widget.isMinimized = !widget.isMinimized;
          //         if (widget.dialogParent != null) {
          //           widget.dialogParent?.globalSetState!();
          //         } else {
          //           mdiController.onUpdate();
          //         }
          //         setState(() {});
          //       },
          //       style: ElevatedButton.styleFrom(
          //         padding: const EdgeInsets.all(2),
          //       ),
          //       child: Stack(
          //         alignment: Alignment.centerLeft,
          //         children: [
          //           const Icon(Icons.square_outlined),
          //           Transform.scale(
          //             alignment: Alignment.centerLeft,
          //             scaleX: 0.4,
          //             child: const Icon(
          //               Icons.square,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(2.0),
          //   child: SizedBox(
          //     width: 35,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         // widget.onWindowClosed!();
          //         widget.isWindowDraggin = false;
          //         if (!widget.isMinimized) {
          //           widget.isAnimationEnded = false;
          //         } else {
          //           widget.isAnimationEnded = true;
          //         }
          //         widget.isMinimized = !widget.isMinimized;
          //         if (widget.dialogParent != null) {
          //           widget.dialogParent?.globalSetState!();
          //         } else {
          //           mdiController.onUpdate();
          //         }
          //         setState(() {});
          //       },
          //       style: ElevatedButton.styleFrom(
          //         padding: const EdgeInsets.all(2),
          //       ),
          //       child: Stack(
          //         alignment: Alignment.centerLeft,
          //         children: [
          //           const Icon(Icons.square_outlined),
          //           Transform.scale(
          //             alignment: Alignment.centerRight,
          //             scaleX: 0.4,
          //             child: const Icon(
          //               Icons.square,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          widget.isDialog || !widget.isMinimizeable
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SizedBox(
                    width: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        // widget.onWindowClosed!();
                        widget.isWindowDraggin = false;
                        if (!widget.isMinimized) {
                          widget.isAnimationEnded = false;
                        } else {
                          widget.isAnimationEnded = true;
                        }
                        widget.isMinimized = !widget.isMinimized;
                        if (widget.dialogParent != null) {
                          widget.dialogParent?.globalSetState!();
                        } else {
                          mdiController.onUpdate();
                        }
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(2),
                      ),
                      child: Icon(Icons.minimize),
                    ),
                  ),
                ),
          !widget.isResizeable
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SizedBox(
                    width: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.isWindowDraggin = false;
                        // widget.onWindowClosed!();
                        if (!widget.isMaximized) {
                          widget.isAnimationEnded = false;
                        } else {
                          widget.isAnimationEnded = true;
                        }
                        widget.isMaximized = !widget.isMaximized;
                        setState(() {});
                        if (widget.dialogParent != null) {
                          widget.dialogParent?.globalSetState!();
                        } else {
                          mdiController.onUpdate();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Color.fromARGB(255, 238, 0, 0),
                        padding: EdgeInsets.all(2),
                      ),
                      child: Icon(Icons.square_outlined),
                    ),
                  ),
                ),
          // Padding(
          //   padding: const EdgeInsets.all(2.0),
          //   child: SizedBox(
          //     width: 35,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         // widget.onWindowClosed!();
          //       },
          //       style: ElevatedButton.styleFrom(
          //         // backgroundColor: Color.fromARGB(255, 238, 0, 0),
          //         padding: EdgeInsets.all(2),
          //       ),
          //       child: Icon(Icons.dock_outlined),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              width: 35,
              child: ElevatedButton(
                onPressed: () {
                  widget.onWindowClosed!(widget.returnvalue);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 238, 0, 0),
                  padding: EdgeInsets.all(2),
                ),
                child: Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getBody() {
    return GestureDetector(
      onPanDown: (tapInfo) {
        widget.onWindowDown!();
        mdiController.onUpdate();
        setState(() {});
      },
      child: Container(
        color: const Color.fromARGB(255, 39, 41, 43),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            widget.dialogChild == null
                ? Container()
                : Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
            widget.dialogChild == null
                ? Container()
                : AnimatedPositioned(
                    duration: Duration(milliseconds: widget.dialogChild!.isWindowDraggin ? 0 : 300),
                    curve: Curves.easeOutCubic,
                    left: widget.dialogChild!.isMaximized ? 5 : widget.dialogChild?.x,
                    top: widget.dialogChild!.isMaximized ? 3 : widget.dialogChild?.y,
                    height: widget.dialogChild!.isMaximized
                        ? (widget.isMaximized ? mdiController.mdiHeight : widget.currentHeight!) - _headerSize - 10
                        : widget.dialogChild?.currentHeight,
                    width: widget.dialogChild!.isMaximized
                        ? (widget.isMaximized ? mdiController.mdiWidth : widget.currentWidth!) - 10
                        : widget.dialogChild?.currentWidth,
                    child: widget.dialogChild!,
                  ),
          ],
        ),
      ),
    );
  }

  void _onHorizontalDragLeft(DragUpdateDetails details) {
    setState(() {
      widget.currentWidth = widget.currentWidth! - details.delta.dx;
      if (widget.currentWidth! < widget.minWidth) {
        widget.currentWidth = widget.minWidth;
      } else {
        widget.onWindowDragged!(details.delta.dx, 0, true);
      }
      widget.isWindowDraggin = true;
      if (widget.dialogParent != null) {
        widget.dialogParent?.globalSetState!();
      } else {
        mdiController.onUpdate();
      }
    });
  }

  void _onHorizontalDragRight(DragUpdateDetails details) {
    setState(() {
      widget.currentWidth = widget.currentWidth! + details.delta.dx;
      if (widget.currentWidth! < widget.minWidth) {
        widget.currentWidth = widget.minWidth;
      }
      widget.isWindowDraggin = true;
      if (widget.dialogParent != null) {
        widget.dialogParent?.globalSetState!();
      } else {
        mdiController.onUpdate();
      }
    });
  }

  void _onHorizontalDragBottom(DragUpdateDetails details) {
    setState(() {
      widget.currentHeight = widget.currentHeight! + details.delta.dy;
      if (widget.currentHeight! < widget.minHeight) {
        widget.currentHeight = widget.minHeight;
      }
      widget.isWindowDraggin = true;
      if (widget.dialogParent != null) {
        widget.dialogParent?.globalSetState!();
      } else {
        mdiController.onUpdate();
      }
    });
  }

  void _onHorizontalDragTop(DragUpdateDetails details) {
    setState(() {
      widget.currentHeight = widget.currentHeight! - details.delta.dy;
      if (widget.currentHeight! < widget.minHeight) {
        widget.currentHeight = widget.minHeight;
      } else {
        widget.onWindowDragged!(0, details.delta.dy, true);
      }
      widget.isWindowDraggin = true;
      if (widget.dialogParent != null) {
        widget.dialogParent?.globalSetState!();
      } else {
        mdiController.onUpdate();
      }
    });
  }

  void _onHorizontalDragBottomRight(DragUpdateDetails details) {
    _onHorizontalDragRight(details);
    _onHorizontalDragBottom(details);
  }

  void _onHorizontalDragBottomLeft(DragUpdateDetails details) {
    _onHorizontalDragLeft(details);
    _onHorizontalDragBottom(details);
  }

  void _onHorizontalDragTopRight(DragUpdateDetails details) {
    _onHorizontalDragRight(details);
    _onHorizontalDragTop(details);
  }

  void _onHorizontalDragTopLeft(DragUpdateDetails details) {
    _onHorizontalDragLeft(details);
    _onHorizontalDragTop(details);
  }
}

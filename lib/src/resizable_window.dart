import 'dart:ui';

import 'package:flutter/material.dart';

import 'global.dart';
import 'config.dart';

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
  double minHeightP = 0.1;
  double minWidth = 200.0;
  double minWidthP = 0.2;
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
  bool isPercentBased = false;
  dynamic returnvalue;
  @override
  // ignore: library_private_types_in_public_api
  _ResizableWindowState createState() => _ResizableWindowState();

  minimizeAction() {
    // widget.onWindowClosed!();
    isWindowDraggin = false;
    if (!isMinimized) {
      isAnimationEnded = false;
    } else {
      isAnimationEnded = true;
    }
    isMinimized = !isMinimized;
    if (dialogParent != null) {
      dialogParent?.globalSetState!();
    } else {
      mdiController.onUpdate();
    }
    mdiController.refreshSideBySideWindows();
  }

  focusAction() {
    // widget.onWindowClosed!();
    isWindowDraggin = false;
    if (!isMinimized) {
      isAnimationEnded = false;
    } else {
      isAnimationEnded = true;
    }
    isMinimized = !isMinimized;
    if (dialogParent != null) {
      dialogParent?.globalSetState!();
    } else {
      mdiController.onUpdate();
    }
    globalSetState!();
  }
}

class _ResizableWindowState extends State<ResizableWindow> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.globalSetState = () {
      if (mounted) setState(() {});
    };
  }

  bool isDarkMode() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  var _tapPosition;

  void _showCustomMenu() async {
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
              widget.onWindowClosed!(widget.returnvalue);
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

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          //Here goes the same radius, u can put into a var or function
          borderRadius: widget.isMaximized && widget.isAnimationEnded
              ? null
              : BorderRadius.all(Radius.circular(MdiConfig.borderRadius + 3)),
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
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      //Here goes the same radius, u can put into a var or function
                      borderRadius: widget.isMaximized && widget.isAnimationEnded
                          ? null
                          : BorderRadius.all(Radius.circular(MdiConfig.borderRadius)),
                    ),
                    child: Container(
                      color: widget == mdiController.thisWindow(context)
                          ? const Color.fromARGB(50, 12, 25, 39)
                          : const Color.fromARGB(50, 12, 63, 105),
                      child: Column(
                        children: [
                          _getHeader(),
                          Expanded(child: _getBody()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!widget.isMaximized && !widget.isMinimized && widget.isResizeable) ...[
              Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onHorizontalDragRight,
                    child: const MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      opaque: true,
                      child: SizedBox(
                        width: 7,
                      ),
                    ),
                  )),
              Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: GestureDetector(
                  onVerticalDragUpdate: _onHorizontalDragBottom,
                  onDoubleTap: () {
                    if (widget.isPercentBased) {
                      widget.currentHeight = 1;
                      widget.y = 0;
                    } else {
                      widget.y = 0;
                      widget.currentHeight = mdiController.mdiHeight;
                    }
                    if (widget.dialogParent != null) {
                      widget.dialogParent?.globalSetState!();
                    } else {
                      mdiController.onUpdate();
                    }
                  },
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeUpDown,
                    opaque: true,
                    child: SizedBox(
                      height: 7,
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
                    child: const MouseRegion(
                      cursor: SystemMouseCursors.resizeLeftRight,
                      opaque: true,
                      child: SizedBox(
                        width: 7,
                      ),
                    ),
                  )),
              Positioned(
                right: 0,
                left: 0,
                top: 0,
                child: GestureDetector(
                  onVerticalDragUpdate: _onHorizontalDragTop,
                  onDoubleTap: () {
                    if (widget.isPercentBased) {
                      widget.currentHeight = 1;
                      widget.y = 0;
                    } else {
                      widget.y = 0;
                      widget.currentHeight = mdiController.mdiHeight;
                    }
                    if (widget.dialogParent != null) {
                      widget.dialogParent?.globalSetState!();
                    } else {
                      mdiController.onUpdate();
                    }
                  },
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeUpDown,
                    opaque: true,
                    child: SizedBox(
                      height: 7,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onPanUpdate: onHorizontalDragBottomRight,
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    opaque: true,
                    child: SizedBox(
                      height: 7,
                      width: 7,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  _getHeader() {
    return Container(
      // width: widget.isMaximized ? null : widget.currentWidth,
      height: MdiConfig.headerSize,
      child: Row(
        children: [
          //title area
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
              onSecondaryTapDown: _storePosition,
              onSecondaryTap: _showCustomMenu,
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
                  padding: const EdgeInsets.all(0.0),
                  child: SizedBox(
                    width: 40,
                    child: MaterialButton(
                      onPressed: () {
                        widget.minimizeAction();
                        setState(() {});
                      },
                      padding: EdgeInsets.all(2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                      child: Icon(Icons.minimize),
                    ),
                  ),
                ),
          !widget.isResizeable
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: SizedBox(
                    width: 40,
                    child: MaterialButton(
                      onPressed: () {
                        widget.isWindowDraggin = false;
                        // widget.onWindowClosed!();
                        if (!widget.isMaximized) {
                          widget.isAnimationEnded = false;
                        } else {
                          widget.isAnimationEnded = true;
                        }
                        widget.isMaximized = !widget.isMaximized;
                        mdiController.refreshSideBySideWindows();
                        setState(() {});
                        if (widget.dialogParent != null) {
                          widget.dialogParent?.globalSetState!();
                        } else {
                          mdiController.onUpdate();
                        }
                      },
                      // hoverElevation: 10,
                      padding: const EdgeInsets.all(2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                      child: const Icon(Icons.square_outlined),
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
            padding: const EdgeInsets.all(0.0),
            child: SizedBox(
              width: 40,
              child: MaterialButton(
                onPressed: () {
                  widget.onWindowClosed!(widget.returnvalue);
                },
                // style: ElevatedButton.styleFrom(
                //   // backgroundColor: Color.fromARGB(255, 238, 0, 0),
                //   surfaceTintColor: Color.fromARGB(255, 238, 0, 0),
                //   padding: EdgeInsets.all(2),
                //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                // ),
                hoverElevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                hoverColor: Color.fromARGB(255, 238, 0, 0),
                child: Icon(Icons.close),
                padding: EdgeInsets.all(2),
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDarkMode() ? const Color.fromARGB(255, 39, 41, 43) : Color.fromARGB(255, 209, 217, 224),
          borderRadius: widget.isMaximized && widget.isAnimationEnded
              ? null
              : BorderRadius.all(Radius.circular(MdiConfig.borderRadius + 3)),
        ),
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
                        ? (widget.isMaximized ? mdiController.mdiHeight : widget.currentHeight!) -
                            MdiConfig.headerSize -
                            10
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
      if (widget.isPercentBased) {
        // widget.currentWidth = widget.currentWidth! - (details.delta.dx * 2);
        // if (widget.currentWidth! < widget.minWidth) {
        //   widget.currentWidth = widget.minWidth;
        // }
        widget.currentWidth =
            ((widget.currentWidth! * mdiController.mdiWidth) - (details.delta.dx * 1)) / mdiController.mdiWidth;
        if (widget.currentWidth! < widget.minWidthP) {
          widget.currentWidth = widget.minWidthP;
        }
        widget.x = (widget.x ?? 0) + (details.delta.dx / mdiController.mdiWidth / 2);
      } else {
        widget.currentWidth = widget.currentWidth! - details.delta.dx;
        if (widget.currentWidth! < widget.minWidth) {
          widget.currentWidth = widget.minWidth;
        } else {
          widget.onWindowDragged!(details.delta.dx, 0, true);
        }
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
      if (widget.isPercentBased) {
        widget.currentWidth =
            ((widget.currentWidth! * mdiController.mdiWidth) + (details.delta.dx * 1)) / mdiController.mdiWidth;
        if (widget.currentWidth! < widget.minWidthP) {
          widget.currentWidth = widget.minWidthP;
        }
        widget.x = (widget.x ?? 0) + (details.delta.dx / mdiController.mdiWidth / 2);
      } else {
        widget.currentWidth = widget.currentWidth! + details.delta.dx;
        if (widget.currentWidth! < widget.minWidth) {
          widget.currentWidth = widget.minWidth;
        }
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
      if (widget.isPercentBased) {
        // widget.currentHeight = widget.currentHeight! + (details.delta.dy * 2);

        widget.currentHeight =
            ((widget.currentHeight! * mdiController.mdiHeight) + (details.delta.dy * 1)) / mdiController.mdiHeight;
        if (widget.currentHeight! < widget.minHeightP) {
          widget.currentHeight = widget.minHeightP;
        }
        widget.y = (widget.y ?? 0) + (details.delta.dy / mdiController.mdiHeight / 2);
      } else {
        widget.currentHeight = widget.currentHeight! + details.delta.dy;
        if (widget.currentHeight! < widget.minHeight) {
          widget.currentHeight = widget.minHeight;
        }
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
      if (widget.isPercentBased) {
        // widget.currentHeight = widget.currentHeight! - (details.delta.dy * 2);
        // if (widget.currentHeight! < widget.minHeight) {
        //   widget.currentHeight = widget.minHeight;
        // }
        widget.currentHeight =
            ((widget.currentHeight! * mdiController.mdiHeight) - (details.delta.dy * 1)) / mdiController.mdiHeight;
        if (widget.currentHeight! < widget.minHeightP) {
          widget.currentHeight = widget.minHeightP;
        }
        widget.y = (widget.y ?? 0) + (details.delta.dy / mdiController.mdiHeight / 2);
      } else {
        widget.currentHeight = widget.currentHeight! - details.delta.dy;
        if (widget.currentHeight! < widget.minHeight) {
          widget.currentHeight = widget.minHeight;
        } else {
          widget.onWindowDragged!(0, details.delta.dy, true);
        }
      }
      widget.isWindowDraggin = true;
      if (widget.dialogParent != null) {
        widget.dialogParent?.globalSetState!();
      } else {
        mdiController.onUpdate();
      }
    });
  }

  void onHorizontalDragBottomRight(DragUpdateDetails details) {
    _onHorizontalDragRight(details);
    _onHorizontalDragBottom(details);
  }

  void onHorizontalDragBottomLeft(DragUpdateDetails details) {
    _onHorizontalDragLeft(details);
    _onHorizontalDragBottom(details);
  }

  void onHorizontalDragTopRight(DragUpdateDetails details) {
    _onHorizontalDragRight(details);
    _onHorizontalDragTop(details);
  }

  void onHorizontalDragTopLeft(DragUpdateDetails details) {
    _onHorizontalDragLeft(details);
    _onHorizontalDragTop(details);
  }
}

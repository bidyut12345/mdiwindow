import 'package:flutter/material.dart';

import 'main.dart';

// ignore: must_be_immutable
class ResizableWindow extends StatefulWidget {
  ResizableWindow({super.key, required this.title, required this.formIndex, required this.child, this.currentHeight = 600, this.currentWidth = 340});

  final String title;
  final int formIndex;
  final Widget child;

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

  Function(double, double)? onWindowDragged;
  Function()? onWindowDown;
  Function()? onWindowClosed;
  Function()? globalSetState;
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
    return LayoutBuilder(builder: (context, boxconts) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          //Here goes the same radius, u can put into a var or function
          borderRadius: widget.isMaximized && widget.isAnimationEnded ? null : BorderRadius.all(Radius.circular(_borderRadius)),
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
            if (!widget.isMaximized) ...[
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
    });
  }

  _getHeader() {
    return Container(
      // width: widget.isMaximized ? null : widget.currentWidth,
      height: _headerSize,
      color: widget == mdiController.windows.last ? Color.fromARGB(255, 12, 25, 39) : Color.fromARGB(255, 12, 63, 105),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (tapInfo) {
                if (!widget.isMaximized) {
                  widget.onWindowDragged!(tapInfo.delta.dx, tapInfo.delta.dy);
                }
              },
              onDoubleTap: () {
                widget.isWindowDraggin = false;
                // widget.onWindowClosed!();
                if (!widget.isMaximized) {
                  widget.isAnimationEnded = false;
                } else {
                  widget.isAnimationEnded = true;
                }
                widget.isMaximized = !widget.isMaximized;
                setState(() {});
                mdiController.onUpdate();
              },
              onPanDown: (tapInfo) {
                widget.onWindowDown!();
                setState(() {});
              },
              onPanStart: (details) {
                widget.isWindowDraggin = true;
                mdiController.onUpdate();
              },
              onPanEnd: (details) {
                widget.isWindowDraggin = false;
                mdiController.onUpdate();
              },
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
          Padding(
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
                  mdiController.onUpdate();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(2),
                ),
                child: Icon(Icons.minimize),
              ),
            ),
          ),
          Padding(
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
                  mdiController.onUpdate();
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
                  widget.onWindowClosed!();
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
        color: Colors.blueGrey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(),
              widget.child,
            ],
          ),
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
        widget.onWindowDragged!(details.delta.dx, 0);
      }
      widget.isWindowDraggin = true;
      mdiController.onUpdate();
    });
  }

  void _onHorizontalDragRight(DragUpdateDetails details) {
    setState(() {
      widget.currentWidth = widget.currentWidth! + details.delta.dx;
      if (widget.currentWidth! < widget.minWidth) {
        widget.currentWidth = widget.minWidth;
      }
      widget.isWindowDraggin = true;
      mdiController.onUpdate();
    });
  }

  void _onHorizontalDragBottom(DragUpdateDetails details) {
    setState(() {
      widget.currentHeight = widget.currentHeight! + details.delta.dy;
      if (widget.currentHeight! < widget.minHeight) {
        widget.currentHeight = widget.minHeight;
      }
      widget.isWindowDraggin = true;
      mdiController.onUpdate();
    });
  }

  void _onHorizontalDragTop(DragUpdateDetails details) {
    setState(() {
      widget.currentHeight = widget.currentHeight! - details.delta.dy;
      if (widget.currentHeight! < widget.minHeight) {
        widget.currentHeight = widget.minHeight;
      } else {
        widget.onWindowDragged!(0, details.delta.dy);
      }
      widget.isWindowDraggin = true;
      mdiController.onUpdate();
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

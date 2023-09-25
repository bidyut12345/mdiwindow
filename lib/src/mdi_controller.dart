import 'package:flutter/material.dart';

import 'resizable_window.dart';

class MdiController {
  MdiController(this.onUpdate);

  final List<ResizableWindow> _windows = List.empty(growable: true);

  VoidCallback onUpdate;

  List<ResizableWindow> get windows => _windows;

  int formIndex = 0;

  double mdiHeight = 0;
  double mdiWidth = 0;

  final bool locationInPercent = false; //In progress

  void addWindow({
    required String title,
    required Widget child,
    String? uniqueId,
    bool isDailog = false,
    double windowHeight = 600,
    double windowWidth = 1200,
    Function<bool>()? onClose,
    Function(dynamic returnvalue)? onClosed,
    bool isResizeable = true,
    bool isMinimizeable = true,
    bool isMaximized = false,
    ResizableWindow? dialogParent,
    dynamic returnvalue,
  }) {
    if (uniqueId != null && uniqueId.isNotEmpty) {
      if (windows.where((element) => element.uniqueId == uniqueId).isNotEmpty) {
        windows.firstWhere((element) => element.uniqueId == uniqueId).onWindowDown!();
        windows.firstWhere((element) => element.uniqueId == uniqueId).globalSetState!();
        return;
      }
    }

    double parentWidth = mdiWidth;
    double parentHeight = mdiHeight;
    if (dialogParent != null) {
      if (dialogParent.dialogParent != null) {
        if (dialogParent.dialogParent!.dialogParent != null) {
          if (dialogParent.dialogParent!.dialogParent!.dialogParent != null) {
            if (!dialogParent.dialogParent!.dialogParent!.dialogParent!.isMaximized) {
              parentWidth = dialogParent.dialogParent!.dialogParent!.dialogParent!.currentWidth!;
              parentHeight = dialogParent.dialogParent!.dialogParent!.dialogParent!.currentHeight!;
            }
          }
          if (!dialogParent.dialogParent!.dialogParent!.isMaximized) {
            parentWidth = dialogParent.dialogParent!.dialogParent!.currentWidth!;
            parentHeight = dialogParent.dialogParent!.dialogParent!.currentHeight!;
          }
        }
        if (!dialogParent.dialogParent!.isMaximized) {
          parentWidth = dialogParent.dialogParent!.currentWidth!;
          parentHeight = dialogParent.dialogParent!.currentHeight!;
        }
      }
      if (!dialogParent.isMaximized) {
        parentWidth = dialogParent.currentWidth!;
        parentHeight = dialogParent.currentHeight!;
      }
    }
    if (windowHeight > parentHeight) {
      if (dialogParent == null) {
        windowHeight = parentHeight - 20;
      } else {
        windowHeight = parentHeight - 70;
      }
    }
    ResizableWindow resizableWindow = ResizableWindow(
      title: title,
      formIndex: formIndex,
      uniqueId: uniqueId,
      currentHeight: windowHeight,
      currentWidth: windowWidth,
      child: child,
    );
    resizableWindow.isDialog = isDailog;
    resizableWindow.onClose = onClose;
    resizableWindow.onClosed = onClosed;
    resizableWindow.isResizeable = isResizeable;
    resizableWindow.isMinimizeable = isMinimizeable;
    resizableWindow.isMaximized = isMaximized;
    resizableWindow.dialogParent = dialogParent;
    formIndex++;
    //Set initial position
    // var rng = new Random();
    // resizableWindow.x = rng.nextDouble() * 500;
    // resizableWindow.y = rng.nextDouble() * 500;

    if (locationInPercent) {
      // resizableWindow.x = ((parentWidth - (resizableWindow.currentWidth ?? 0)) / 2) / parentWidth;
      // resizableWindow.y = ((parentHeight - (resizableWindow.currentHeight ?? 0)) / 4) / parentHeight;
      resizableWindow.x = 0.5;
      resizableWindow.y = 0.5;
    } else {
      resizableWindow.x = (parentWidth - (resizableWindow.currentWidth ?? 0)) / 2;
      resizableWindow.y = (parentHeight - (resizableWindow.currentHeight ?? 0)) / 4;
      if (resizableWindow.x! < 0) {
        resizableWindow.x = 0;
      }
      if (resizableWindow.y! < 0) {
        resizableWindow.y = 0;
      }
    }

    //Init onWindowDragged
    resizableWindow.onWindowDragged = (dx, dy, isResized) {
      // if (resizableWindow.isDialog && !isResized) return;
      if (locationInPercent) {
        resizableWindow.x = resizableWindow.x! + (dx / parentWidth);
        resizableWindow.y = resizableWindow.y! + (dy / parentHeight);
        onUpdate();
      } else {
        resizableWindow.x = resizableWindow.x! + dx;
        resizableWindow.y = resizableWindow.y! + dy;
        if (resizableWindow.x! < -(resizableWindow.currentWidth! - 130)) {
          resizableWindow.x = -(resizableWindow.currentWidth! - 130);
        }
        if (resizableWindow.y! < 0) {
          resizableWindow.y = 0;
        }
        if (dialogParent != null) {
          if (dialogParent.isMaximized) {
            if (resizableWindow.y! > (mdiHeight - 80)) {
              resizableWindow.y = (mdiHeight - 80);
            }

            if (resizableWindow.x! > (mdiWidth - 50)) {
              resizableWindow.x = (mdiWidth - 50);
            }
          } else {
            if (resizableWindow.y! > (dialogParent.currentHeight! - 80)) {
              resizableWindow.y = (dialogParent.currentHeight! - 80);
            }
            if (resizableWindow.x! > (dialogParent.currentWidth! - 50)) {
              resizableWindow.x = (dialogParent.currentWidth! - 50);
            }
          }

          dialogParent.globalSetState!();
        } else {
          if (resizableWindow.y! > (mdiHeight - 20)) {
            resizableWindow.y = (mdiHeight - 20);
          }

          if (resizableWindow.x! > (mdiWidth - 30)) {
            resizableWindow.x = (mdiWidth - 30);
          }

          onUpdate();
        }
      }
    };
    resizableWindow.onWindowDown = () {
      //Put on top of stack
      if (dialogParent != null) return;
      ResizableWindow? tmp;
      if (windows.isNotEmpty) tmp = _windows.last;
      resizableWindow.isWindowDraggin = true;
      tmp?.isWindowDraggin = true;
      _windows.remove(resizableWindow);
      _windows.add(resizableWindow);
      tmp?.globalSetState!();
      onUpdate();
    };
    resizableWindow.onWindowClosed = (returnvalue) {
      if (resizableWindow.onClose != null) {
        if (!resizableWindow.onClose!()) {
          return;
        }
      }
      if (dialogParent != null) {
        dialogParent.dialogChild = null;
        dialogParent.globalSetState!();
      } else {
        _windows.remove(resizableWindow);
        onUpdate();
      }
      if (resizableWindow.onClosed != null) {
        resizableWindow.onClosed!(returnvalue);
      }
    };

    if (isDailog && dialogParent != null) {
      dialogParent.dialogChild = resizableWindow;
      dialogParent.globalSetState!();
    } else {
      //Add Window to List
      ResizableWindow? tmp;
      if (windows.isNotEmpty) tmp = _windows.last;
      _windows.add(resizableWindow);

      tmp?.globalSetState!();

      // Update Widgets after adding the new App
      onUpdate();
    }
  }

  closeCurrentWindow(BuildContext context, [dynamic returnvalue]) {
    thisWindow(context)?.onWindowClosed!(returnvalue);
  }

  ResizableWindow? thisWindow(BuildContext context) {
    try {
      var item = context.findAncestorWidgetOfExactType<ResizableWindow>();
      return item ?? windows.last;
    } catch (_) {
      return null;
    }
  }
}

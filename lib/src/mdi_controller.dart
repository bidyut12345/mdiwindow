import 'package:flutter/material.dart';
import 'package:mdiwindow/mdiwindow.dart';

class MdiController {
  MdiController(this.onUpdate);

  final List<ResizableWindow> _windows = List.empty(growable: true);
// updates/setstate of mdi container
  VoidCallback onUpdate;
  Function(bool isFullScreen)? onFullScreen;

  List<ResizableWindow> get windows => _windows;
  List<ResizableWindow> sidebysidewindows = [];

  int formIndex = 0;

  double mdiHeight = 0;
  double mdiWidth = 0;
  refreshSideBySideWindows() {
    sidebysidewindows = windows.where((element) => !element.isMaximized && !element.isMinimized).toList();
  }

  // final bool adjustWindowSizePositionOnParentSizeChanged = false; //In progress : locationInPercent
  bool isSideBySide = false;
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
        if (windows.firstWhere((element) => element.uniqueId == uniqueId).isMinimized) {
          windows.firstWhere((element) => element.uniqueId == uniqueId).minimizeAction();
        }
        windows.firstWhere((element) => element.uniqueId == uniqueId).globalSetState!();
        return;
      }
    }

    double parentWidth = mdiWidth;
    double parentHeight = mdiHeight;
    findParentWidth() {
      parentWidth = mdiWidth;
      parentHeight = mdiHeight;
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
      if (dialogParent?.isPercentBased ?? false) {
        parentHeight = mdiHeight * parentHeight;
        parentWidth = mdiWidth * parentWidth;
      }
      if (windowHeight > parentHeight) {
        if (dialogParent == null) {
          windowHeight = parentHeight - 20;
        } else {
          windowHeight = parentHeight - 70;
        }
      }
      // print("Parent width : $parentWidth");
      // print("Parent width : $windowWidth");
      if (parentWidth < windowWidth) {
        windowWidth = parentWidth - 50;
      }
    }

    findParentWidth();
    ResizableWindow resizableWindow = ResizableWindow(
      title: title,
      formIndex: formIndex,
      uniqueId: uniqueId,
      currentHeight: windowHeight,
      currentWidth: windowWidth,
      child: child,
    );
    if (MdiConfig.adjustWindowSizePositionOnParentSizeChanged && dialogParent == null) {
      resizableWindow.currentWidth = windowWidth / mdiWidth;
      resizableWindow.currentHeight = windowHeight / mdiHeight;
      resizableWindow.isPercentBased = true;
    }
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

    if (resizableWindow.isPercentBased) {
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
      findParentWidth();
      // if (resizableWindow.isDialog && !isResized) return;
      if (resizableWindow.isPercentBased) {
        if (parentWidth > 0) {
          resizableWindow.x = resizableWindow.x! + ((dx * 1) / parentWidth);
          resizableWindow.y = resizableWindow.y! + ((dy * 1) / parentHeight);
        } else {
          resizableWindow.x = resizableWindow.x! + ((dx * 1) / mdiWidth);
          resizableWindow.y = resizableWindow.y! + ((dy * 1) / mdiHeight);
        }
        // print("X:${resizableWindow.x}");
        // print("Y:${resizableWindow.y}");
        // if (resizableWindow.x! < 0) resizableWindow.x = 0.1;
        // if (resizableWindow.y! < 0) resizableWindow.y = 0.1;
        // if (resizableWindow.x! > 0.9) resizableWindow.x = 0.9;
        // if (resizableWindow.y! < 0.9) resizableWindow.y = 0.9;
        onUpdate();
      } else {
        resizableWindow.x = resizableWindow.x! + dx;
        resizableWindow.y = resizableWindow.y! + dy;
        // print("window location ${resizableWindow.x}, ${resizableWindow.y}");
        if (resizableWindow.x! < -(resizableWindow.currentWidth! - 130)) {
          resizableWindow.x = -(resizableWindow.currentWidth! - 130);
        }
        if (resizableWindow.y! < 0) {
          resizableWindow.y = 0;
        }
        // if (resizableWindow.x! < 0) {
        //   resizableWindow.x = 0;
        // }
        if (dialogParent != null) {
          if (dialogParent.isMaximized) {
            if (resizableWindow.y! > (mdiHeight - 80)) {
              resizableWindow.y = (mdiHeight - 80);
            }

            if (resizableWindow.x! > (mdiWidth - 50)) {
              resizableWindow.x = (mdiWidth - 50);
            }
          } else {
            if (resizableWindow.y! > (parentHeight - 80)) {
              resizableWindow.y = (parentHeight - 80);
            }
            if (resizableWindow.x! > (parentWidth - 50)) {
              resizableWindow.x = (parentWidth - 50);
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
      refreshSideBySideWindows();
    };

    if (isDailog && dialogParent != null) {
      dialogParent.dialogChild = resizableWindow;
      dialogParent.globalSetState!();
    } else {
      //Add Window to List
      ResizableWindow? tmp;
      if (windows.isNotEmpty) tmp = _windows.last;
      _windows.add(resizableWindow);

      if (tmp?.globalSetState != null) {
        tmp?.globalSetState!();
      }

      // Update Widgets after adding the new App
      onUpdate();
    }
    refreshSideBySideWindows();
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

import 'dart:math';

import 'package:flutter/material.dart';

import 'resizable_window.dart';

class MdiController {
  MdiController(this.onUpdate);

  List<ResizableWindow> _windows = List.empty(growable: true);

  VoidCallback onUpdate;

  List<ResizableWindow> get windows => _windows;

  void addWindow(String title, int formIndex) {
    _createNewWindowedApp(title, formIndex);
  }

  void _createNewWindowedApp(String title, int formIndex) {
    ResizableWindow resizableWindow = ResizableWindow(
      // key: UniqueKey(),
      title: title,
      formIndex: formIndex,
      child: FlutterLogo(
        size: 300,
      ),
    );

    //Set initial position
    var rng = new Random();
    resizableWindow.x = rng.nextDouble() * 500;
    resizableWindow.y = rng.nextDouble() * 500;

    //Init onWindowDragged
    resizableWindow.onWindowDragged = (dx, dy) {
      resizableWindow.x = resizableWindow.x! + dx;
      resizableWindow.y = resizableWindow.y! + dy;
      if (resizableWindow.x! < 0) {
        resizableWindow.x = 0;
      }
      if (resizableWindow.y! < 0) {
        resizableWindow.y = 0;
      }
      onUpdate();
    };
    resizableWindow.onWindowDown = () {
      //Put on top of stack
      ResizableWindow? tmp;
      if (windows.isNotEmpty) tmp = _windows.last;
      _windows.remove(resizableWindow);
      _windows.add(resizableWindow);
      tmp?.globalSetState!();
      onUpdate();
    };
    resizableWindow.onWindowClosed = () {
      _windows.remove(resizableWindow);
      onUpdate();
    };

    //Add Window to List
    ResizableWindow? tmp;
    if (windows.isNotEmpty) tmp = _windows.last;
    _windows.add(resizableWindow);
    tmp?.globalSetState!();

    // Update Widgets after adding the new App
    onUpdate();
  }
}

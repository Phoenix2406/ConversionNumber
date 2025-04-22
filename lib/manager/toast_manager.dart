import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class ToastManager {
  late String _message;
  late int _durationAppear;
  late ToastPosition _textPosition;
  late double _textSize;
  late bool _themeToggle;

  ToastManager({
    required String msg,
    int duration = 3,
    ToastPosition position = ToastPosition.bottom,
    double textSize = 16.0,
    required bool theme,
  }) {
    _message = msg;
    _durationAppear = duration;
    _textPosition = position;
    _textSize = textSize;
    _themeToggle = theme;
  }

  ToastFuture create() {
    return showToast(
      _message,
      duration: Duration(seconds: _durationAppear),
      position: _textPosition,
      textStyle: TextStyle(
        color: _themeToggle ? Colors.white : Colors.black,
        fontSize: _textSize
      ),
      margin: EdgeInsets.all(25),
      textPadding: EdgeInsets.all(10),
    );
  }
}

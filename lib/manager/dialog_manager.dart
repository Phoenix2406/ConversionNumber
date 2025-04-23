import 'dart:io';

import 'package:flutter/material.dart';

class DialogManager {
  late BuildContext _context;
  late String _title;
  late String _content;
  late bool _isDarkMode;

  DialogManager({
    required BuildContext context,
    required String title,
    required String content,
    required bool themeToggle,
  }) {
    _context = context;
    _title = title;
    _content = content;
    _isDarkMode = themeToggle;
  }

  Future<void> create() {
    return showDialog(
      context: _context,
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            elevation: 10,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: IntrinsicWidth(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      _isDarkMode
                          ? Colors.purple[600]
                          : Colors.deepPurpleAccent[400],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color:
                          _isDarkMode
                              ? Colors.purple[600]!
                              : Colors.deepPurpleAccent[400]!,
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: 21.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(_context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _content,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(_context).textTheme.titleLarge?.color,
                      ),
                      softWrap: true,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        style: ButtonStyle(
                          minimumSize:
                              Platform.isWindows || Platform.isMacOS
                                  ? WidgetStateProperty.all(Size(100, 40))
                                  : WidgetStateProperty.all(Size(100, 15)),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color:
                                Theme.of(_context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

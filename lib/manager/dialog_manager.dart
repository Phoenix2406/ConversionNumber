import 'dart:io';

import 'package:flutter/material.dart';

class DialogManager {
  final BuildContext context;
  final String title;
  final String content;
  final bool isDarkMode;

  DialogManager({
    required this.context,
    required this.title,
    required this.content,
    required this.isDarkMode});

  Future<void> create() {
    return showDialog(
      context: context,
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
                  color: isDarkMode
                      ? Colors.purple[600]
                      : Colors.deepPurpleAccent[400],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: isDarkMode
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
                    Text(title,
                      style: TextStyle(
                        fontSize: 21.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(content,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        softWrap: true,
                        textAlign: TextAlign.center),
                    SizedBox(height: 32),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        style: ButtonStyle(
                            minimumSize: Platform.isWindows || Platform.isMacOS ?
                            WidgetStateProperty.all(Size(100, 40)) :
                            WidgetStateProperty.all(Size(100, 15))
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text("Close",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color,
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

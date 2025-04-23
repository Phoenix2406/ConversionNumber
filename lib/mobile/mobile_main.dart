import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../manager/conversion_manager.dart';
import '../manager/dialog_manager.dart';
import '../utils/bool_parse.dart';

class MobileMain extends StatefulWidget {
  final String _title;
  final bool _isDarkMode;
  final VoidCallback _themeCallback;

  const MobileMain({
    super.key,
    required String title,
    required bool themeToggle,
    required VoidCallback themeCallback,
  }) : _title = title,
       _isDarkMode = themeToggle,
       _themeCallback = themeCallback;

  @override
  State<MobileMain> createState() => _MobileHomeScreen();
}

class _MobileHomeScreen extends State<MobileMain> {
  static final List<String> convertOptions = [
    "Binary to Decimal",
    "Decimal to Binary",
    "Binary to Hexadecimal",
    "Hexadecimal to Binary",
    "Decimal to Hexadecimal",
    "Hexadecimal to Decimal",
    "Binary to Octal",
    "Octal to Binary",
    "Decimal to Octal",
    "Octal to Decimal",
    "Hexadecimal to Octal",
    "Octal to Hexadecimal",
    "Decimal to BCD",
    "BCD to Decimal",
    "Binary to Gray",
    "Gray to Binary",
    "Binary to Excess3",
    "Excess3 to Binary",
    "Decimal to Excess3",
    "Excess3 to Decimal",
  ];

  String? convType = convertOptions.first;
  String? value = "";
  int? showExplain = 0;
  DateTime? lastPressed;

  void onDropdownChanged(String? value) {
    setState(() {
      convType = value;
    });
  }

  void onTextFieldChanged(String? value) {
    setState(() {
      this.value = value;
    });
  }

  void onRadioButtonChanged(int? value) {
    setState(() {
      showExplain = value;
    });
  }

  Future<void> onShowExplainButtonPressed(BuildContext context) {
    return DialogManager(
      context: context,
      title: "Coming Soon",
      content: "Explanation of number conversion stages still under progress!",
      themeToggle: widget._isDarkMode,
    ).create();
  }

  Future<void> onConvertButtonPressed(BuildContext context) async {
    if (value!.isEmpty) {
      return DialogManager(
        context: context,
        title: "Conversion Alert",
        content: "Number value can't be empty!",
        themeToggle: widget._isDarkMode,
      ).create();
    }

    List<String> convertType = convType!.split(' to ');
    ConvertType convFrom = ConvertType.values.byName(
      convertType[0].toLowerCase(),
    );
    ConvertType convTo = ConvertType.values.byName(
      convertType[1].toLowerCase(),
    );
    String? conversion =
        ConversionManager(
          value: value!,
          from: convFrom,
          to: convTo,
          explain: showExplain == 0 ? false : true,
          themeToggle: widget._isDarkMode,
        ).convert();

    return DialogManager(
      context: context,
      title: "Conversion Result",
      content:
          "Conversion from ${convFrom.name} to ${convTo.name} "
          "of $value${convFrom.symbol} is $conversion${convTo.symbol}",
      themeToggle: widget._isDarkMode,
    ).create();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        DateTime now = DateTime.now();
        if (lastPressed == null ||
            now.difference(lastPressed!) > Duration(seconds: 5)) {
          lastPressed = now;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Press again to exit")));
        } else {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(widget._title),
          actions: <Widget>[
            IconButton(
              onPressed: widget._themeCallback,
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  widget._isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  key: ValueKey(widget._isDarkMode),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 25.0),
                  child: Text(
                    "Number Conversion",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 80.0),
                  width: 300,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Choose Conversion Type",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      DropdownButtonFormField(
                        value: convType,
                        isExpanded: true,
                        menuMaxHeight: 200,
                        items:
                            convertOptions.map((String val) {
                              return DropdownMenuItem(
                                value: val,
                                child: Row(children: <Widget>[Text(val)]),
                              );
                            }).toList(),
                        onChanged: (String? value) {
                          onDropdownChanged(value);
                        },
                        dropdownColor: Theme.of(context)
                            .dropdownMenuTheme
                            .menuStyle
                            ?.backgroundColor
                            ?.resolve({}),
                        style: TextStyle(
                          fontStyle: FontStyle.normal,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color:
                              widget._isDarkMode
                                  ? Colors.purple
                                  : Colors.deepPurpleAccent,
                        ),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  widget._isDarkMode
                                      ? Colors.purple
                                      : Colors.deepPurpleAccent,
                              width: 2,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  widget._isDarkMode
                                      ? Colors.purple
                                      : Colors.deepPurpleAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Container(height: 20.0),
                      Text(
                        "Input Number",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      Container(height: 10.0),
                      TextField(
                        maxLength: 25,
                        style: TextStyle(
                          fontStyle: FontStyle.normal,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        onChanged: (String value) {
                          onTextFieldChanged(value);
                        },
                        decoration: InputDecoration(
                          hintText: "Input number value",
                          labelText: "Number Value",
                          hintStyle: TextStyle(
                            fontStyle: FontStyle.normal,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                          labelStyle: TextStyle(
                            fontStyle: FontStyle.normal,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                          counterStyle: TextStyle(
                            fontStyle: FontStyle.normal,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  widget._isDarkMode
                                      ? Colors.purple
                                      : Colors.deepPurpleAccent,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  widget._isDarkMode
                                      ? Colors.purple
                                      : Colors.deepPurpleAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Container(height: 15.0),
                      Text(
                        "Show Explain?",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Radio(
                                value: 0,
                                groupValue: showExplain,
                                onChanged: (int? value) {
                                  onRadioButtonChanged(value);
                                },
                              ),
                              Text(
                                "False",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          Container(width: 100.0),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Radio(
                                value: 1,
                                groupValue: showExplain,
                                onChanged: (int? value) {
                                  onRadioButtonChanged(value);
                                },
                              ),
                              Text(
                                "True",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 35.0, bottom: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FilledButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.disabled)) {
                                  return widget._isDarkMode
                                      ? Colors.purple.withValues(alpha: 0.5)
                                      : Colors.deepPurpleAccent.withValues(
                                        alpha: 0.5,
                                      );
                                }
                                return widget._isDarkMode
                                    ? Colors.purple
                                    : Colors.deepPurpleAccent;
                              }),
                        ),
                        onPressed:
                            Boolean.parse(showExplain!)
                                ? () {
                                  onShowExplainButtonPressed(context);
                                }
                                : null,
                        child: Text(
                          "Show Explanation",
                          style: TextStyle(
                            color:
                                Boolean.parse(showExplain!)
                                    ? Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color
                                    : Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color
                                        ?.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Container(width: 50.0),
                      FilledButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size(150, 42)),
                        ),
                        onPressed: () {
                          onConvertButtonPressed(context);
                        },
                        child: Text(
                          "Convert",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                    ],
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

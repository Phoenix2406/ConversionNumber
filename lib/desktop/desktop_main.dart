import 'package:flutter/material.dart';

import '../manager/conversion_manager.dart';
import '../manager/dialog_manager.dart';
import '../utils/bool_parse.dart';

class DesktopMain extends StatefulWidget {
  const DesktopMain({super.key, required this.title, required this.isDarkMode, required this.onThemeToggle});

  final String title;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<DesktopMain> createState() => _DesktopHomeScreen();
}

class _DesktopHomeScreen extends State<DesktopMain> {

  List<String> convertOptions = [
    "Binary to Decimal",
    "Decimal to Binary",
    "Hexadecimal to Decimal",
    "Decimal to Hexadecimal",
    "Hexadecimal to Binary",
    "Binary to Hexadecimal",
    "Octal to Binary",
    "Binary to Octal",
    "Octal to Decimal",
    "Decimal to Octal",
    "Octal to Hexadecimal",
    "Hexadecimal to Octal",
    "Decimal to BCD",
    "BCD to Decimal",
    "Binary to Gray",
    "Gray to Binary",
    "Excess3 to Decimal",
    "Decimal to Excess3",
  ];
  String? convType = "Binary to Decimal";
  String? number = "";
  int? isExplain = 0;

  void onDropdownChanged(String? value) {
    setState(() {
      convType = value;
    });
  }

  void onTextFieldChanged(String? value) {
    setState(() {
      number = value;
    });
  }

  void onRadioButtonChanged(int? value) {
    setState(() {
      isExplain = value;
    });
  }

  Future<void> onShowExplainButtonPressed(BuildContext context) {
    return DialogManager(
        context: context,
        title: "Coming Soon",
        content: "Explanation of number conversion stages still under progress!",
        isDarkMode: widget.isDarkMode)
        .create();
  }

  Future<void> onConvertButtonPressed(BuildContext context) async {
    if (number!.isEmpty) {
      return DialogManager(
          context: context,
          title: "Conversion Alert",
          content: "Number value can't be empty!",
          isDarkMode: widget.isDarkMode)
          .create();
    }

    List<String> convertType = convType!.split(' to ');
    ConvertType convFrom = ConvertType.values.byName(convertType[0].toLowerCase());
    ConvertType convTo = ConvertType.values.byName(convertType[1].toLowerCase());

    String? conversion = ConversionManager(
      value: number!,
      convertFrom: convFrom,
      convertTo: convTo,
      showExplain: isExplain == 0 ? false : true,
    ).convert();

    return DialogManager(
        context: context,
        title: "Conversion Result",
        content: "Conversion from ${convFrom.name} to ${convTo.name} "
            "of $number${convFrom.symbol} is $conversion${convTo.symbol}",
        isDarkMode: widget.isDarkMode)
        .create();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: widget.onThemeToggle,
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  key: ValueKey(widget.isDarkMode),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Text("Number Conversion",
                  style: TextStyle(
                      fontSize: 50.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
            ),
            Container(
              margin: EdgeInsets.only(top: 50.0),
              width: 300,
              child: Column(
                children: <Widget>[
                  Text("Choose Conversion Type",
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)
                  ),
                  DropdownButtonFormField(
                      value: convType,
                      isExpanded: true,
                      menuMaxHeight: 400,
                      items: convertOptions.map((String val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Row(
                            children: <Widget>[
                              Text(val),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) { onDropdownChanged(value); },
                      dropdownColor: Theme.of(context).dropdownMenuTheme.menuStyle?.backgroundColor?.resolve({}),
                      style: TextStyle(
                        fontStyle: FontStyle.normal, color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      icon: Icon(Icons.arrow_drop_down,
                          color: widget.isDarkMode
                            ? Colors.purple
                            : Colors.deepPurpleAccent),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: widget.isDarkMode
                              ? Colors.purple
                              : Colors.deepPurpleAccent, width: 2)
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: widget.isDarkMode
                              ? Colors.purple
                              : Colors.deepPurpleAccent, width: 2)
                      ),
                    ),
                  ),
                  Container(
                    height: 15.0,
                  ),
                  Text("Input Number",
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)
                  ),
                  Container(
                    height: 5.0,
                  ),
                  TextField(
                    maxLength: 25,
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.color,
                    ),
                    onChanged: (String value) {
                      onTextFieldChanged(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Input number value",
                      labelText: "Number Value",
                      hintStyle: TextStyle(
                        fontStyle: FontStyle.normal, color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      labelStyle: TextStyle(
                        fontStyle: FontStyle.normal, color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      counterStyle: TextStyle(
                        fontStyle: FontStyle.normal,
                        color:
                        Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.color,
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: widget.isDarkMode
                                  ? Colors.purple
                                  : Colors.deepPurpleAccent,
                              width: 2)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: widget.isDarkMode
                                  ? Colors.purple
                                  : Colors.deepPurpleAccent,
                              width: 2)
                      ),
                    ),
                  ),
                  Container(
                    height: 15.0,
                  ),
                  Text("Show Explain?",
                      style: TextStyle(
                          fontSize: 25.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio(
                            value: 0,
                            groupValue: isExplain,
                            onChanged: (int? value) {
                              onRadioButtonChanged(value);
                            },
                          ),
                          Text(
                            "False",
                            style: TextStyle(
                              fontSize: 15.0,
                              color:
                              Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color,
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
                            groupValue: isExplain,
                            onChanged: (int? value) {
                              onRadioButtonChanged(value);
                            },
                          ),
                          Text(
                            "True",
                            style: TextStyle(
                              fontSize: 15.0,
                              color:
                              Theme
                                  .of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color,
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
              margin: EdgeInsets.only(top: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FilledButton(
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(Size(150, 50)),
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.disabled)) {
                            return widget.isDarkMode
                                ? Colors.purple.withValues(alpha: 0.5)
                                : Colors.deepPurpleAccent.withValues(alpha: 0.5);
                          }
                          return widget.isDarkMode
                              ? Colors.purple
                              : Colors.deepPurpleAccent;
                        },
                      ),
                    ),
                    onPressed: Boolean.parse(isExplain!) ? () {
                      onShowExplainButtonPressed(context);
                    } : null,
                    child: Text(
                      "Show Explanation",
                      style: TextStyle(
                        color: Boolean.parse(isExplain!) ?
                        Theme.of(context).textTheme.titleLarge?.color :
                        Theme.of(context).textTheme.titleLarge?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Container(width: 50.0),
                  FilledButton(
                    style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(Size(150, 50))
                    ),
                    onPressed: () {
                      onConvertButtonPressed(context);
                    },
                    child: Text(
                      "Convert",
                      style: TextStyle(
                        color:
                        Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
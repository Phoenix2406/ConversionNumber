import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../desktop/desktop_main.dart';
import '../mobile/mobile_main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    bool isDark = await getSavedTheme();
    runApp(MyApp(isDark: isDark));
  });
}

Future<bool> getSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkMode') ?? false;
}

class MyApp extends StatefulWidget {
  final bool _themeToggle;

  const MyApp({super.key, required bool isDark}) : _themeToggle = isDark;

  @override
  State<MyApp> createState() => _MainHomeScreen();
}

class _MainHomeScreen extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget._themeToggle;
  }

  void _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      backgroundColor:
          _isDarkMode
              ? Colors.purple.withValues(alpha: 0.8)
              : Colors.deepPurpleAccent.withValues(alpha: 0.8),
      child: AnimatedTheme(
        data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        duration: Duration(milliseconds: 500),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Conversion Number',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(backgroundColor: Colors.deepPurpleAccent),
            textTheme: TextTheme(titleLarge: TextStyle(color: Colors.black)),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.deepPurpleAccent,
              selectionColor: Colors.deepPurpleAccent.withValues(alpha: 0.3),
              selectionHandleColor: Colors.deepPurpleAccent,
            ),
            radioTheme: RadioThemeData(
              fillColor: WidgetStatePropertyAll<Color>(Colors.deepPurpleAccent),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                  Colors.deepPurpleAccent,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                  Colors.deepPurpleAccent,
                ),
              ),
            ),
            dropdownMenuTheme: DropdownMenuThemeData(
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(
                  Colors.deepPurpleAccent,
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            scaffoldBackgroundColor: Colors.white12,
            appBarTheme: AppBarTheme(backgroundColor: Colors.purple),
            textTheme: TextTheme(titleLarge: TextStyle(color: Colors.white)),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.purple,
              selectionColor: Colors.purple.withValues(alpha: 0.3),
              selectionHandleColor: Colors.purple,
            ),
            radioTheme: RadioThemeData(
              fillColor: WidgetStatePropertyAll<Color>(Colors.purple),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.purple),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(Colors.purple),
              ),
            ),
            dropdownMenuTheme: DropdownMenuThemeData(
              menuStyle: MenuStyle(
                backgroundColor: WidgetStateProperty.all(Colors.purple),
              ),
            ),
          ),
          themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home:
              Platform.isWindows || Platform.isMacOS
                  ? DesktopMain(
                    title: "Conversion Number System",
                    themeToggle: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                  )
                  : MobileMain(
                    title: "Conversion Number System",
                    themeToggle: _isDarkMode,
                    themeCallback: _toggleTheme,
                  ),
        ),
      ),
    );
  }
}

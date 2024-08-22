import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sjq/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrivision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.lexendDecaTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      routes: Routes.routes, // Will start at start: '/'
    );
  }
}

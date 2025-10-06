import 'package:flutter/material.dart';
import 'home_page.dart';
import 'cursos_page.dart';

class SplashScreen extends StatefulWidget {
  final bool nextToCursos; // Para saber a dónde ir luego

  const SplashScreen({super.key, this.nextToCursos = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      // Decide a qué pantalla ir según el parámetro
      if (widget.nextToCursos) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CursosPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

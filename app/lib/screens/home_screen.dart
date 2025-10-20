import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'courses/toefl_screen.dart';
import 'courses/ielts_screen.dart';
import 'courses/business_english_screen.dart';
import 'courses/english_in_action_screen.dart';
import 'courses_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EnglishPro'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CoursesListScreen()),
              );
            },
            tooltip: 'View All Courses',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 100,
              color: Color(0xFF1E3A8A),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to EnglishPro!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Start your English learning journey',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            // Course Cards (placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildCourseCard('TOEFL', Icons.book, Colors.blue),
                  const SizedBox(height: 16),
                  _buildCourseCard('IELTS', Icons.library_books, Colors.green),
                  const SizedBox(height: 16),
                  _buildCourseCard(
                      'Business English', Icons.business, Colors.orange),
                  const SizedBox(height: 16),
                  _buildCourseCard(
                      'English in Action', Icons.chat, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Builder(
        builder: (context) => ListTile(
          leading: Icon(icon, size: 40, color: color),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text('Tap to start learning'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _navigateToCourse(context, title),
        ),
      ),
    );
  }

  void _navigateToCourse(BuildContext context, String courseTitle) {
    Widget screen;

    switch (courseTitle) {
      case 'TOEFL':
        screen = const ToeflScreen();
        break;
      case 'IELTS':
        screen = const IeltsScreen();
        break;
      case 'Business English':
        screen = const BusinessEnglishScreen();
        break;
      case 'English in Action':
        screen = const EnglishInActionScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

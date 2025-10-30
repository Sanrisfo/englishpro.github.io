import 'package:flutter/material.dart';

class BusinessEnglishScreen extends StatelessWidget {
  const BusinessEnglishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business English'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.business, size: 60, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Business English',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Professional English for the Workplace',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Section
            const Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Modules Completed',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '0 / 10',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Modules Section
            const Text(
              'Learning Modules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Professional CV Writing',
              Icons.description,
              Colors.blue,
              'Learn to create impressive resumes',
              isLocked: false,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Business Email Communication',
              Icons.email,
              Colors.green,
              'Master professional email writing',
              isLocked: true,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Job Interview Preparation',
              Icons.person_search,
              Colors.purple,
              'Prepare for successful interviews',
              isLocked: true,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Presentations & Meetings',
              Icons.present_to_all,
              Colors.red,
              'Deliver effective presentations',
              isLocked: true,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Negotiation Skills',
              Icons.handshake,
              Colors.teal,
              'Develop negotiation techniques',
              isLocked: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    String title,
    IconData icon,
    Color color,
    String subtitle, {
    bool isLocked = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isLocked ? Icons.lock : icon,
            color: isLocked ? Colors.grey : color,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isLocked ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isLocked ? Colors.grey : Colors.black54,
          ),
        ),
        trailing: Icon(
          isLocked ? Icons.lock_outline : Icons.arrow_forward_ios,
          size: 16,
          color: isLocked ? Colors.grey : null,
        ),
        onTap: isLocked
            ? null
            : () {
                // TODO: Navigate to module content
              },
      ),
    );
  }
}

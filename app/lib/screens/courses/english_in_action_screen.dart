import 'package:flutter/material.dart';

class EnglishInActionScreen extends StatelessWidget {
  const EnglishInActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('English in Action'),
        backgroundColor: Colors.purple,
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
                    colors: [Colors.purple, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.chat, size: 60, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'English in Action',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Real-Life English for Everyday Situations',
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
                          '0 / 8',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
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
              'At the Restaurant',
              Icons.restaurant,
              Colors.red,
              'Order food and interact with waiters',
              isLocked: false,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Travel & Tourism',
              Icons.flight,
              Colors.blue,
              'Navigate airports and hotels',
              isLocked: true,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Shopping & Services',
              Icons.shopping_cart,
              Colors.green,
              'Shop and request services',
              isLocked: true,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Social Interactions',
              Icons.people,
              Colors.orange,
              'Make friends and socialize',
              isLocked: true,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'At the Doctor',
              Icons.local_hospital,
              Colors.pink,
              'Describe symptoms and get treatment',
              isLocked: true,
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              'Public Transport',
              Icons.train,
              Colors.indigo,
              'Use public transportation effectively',
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

import 'package:flutter/material.dart';

class LeaderBoardScreen extends StatelessWidget {
  const LeaderBoardScreen({super.key});

  final List<Map<String, dynamic>> leaders = const [
    {'name': 'Alice', 'score': 1200, 'avatar': 'A'},
    {'name': 'Bob', 'score': 1100, 'avatar': 'B'},
    {'name': 'Charlie', 'score': 1050, 'avatar': 'C'},
    {'name': 'Diana', 'score': 950, 'avatar': 'D'},
    {'name': 'Ethan', 'score': 900, 'avatar': 'E'},
    {'name': 'Fiona', 'score': 850, 'avatar': 'F'},
    {'name': 'George', 'score': 800, 'avatar': 'G'},
  ];

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return Colors.deepOrangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Eco Warriors',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: leaders.length,
                itemBuilder: (context, index) {
                  final leader = leaders[index];
                  return Card(
                    elevation: index < 3 ? 6 : 2,
                    color: index < 3 ? _getMedalColor(index).withOpacity(0.15) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    margin: const EdgeInsets.only(bottom: 14),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getMedalColor(index),
                        radius: 26,
                        child: Text(
                          leader['avatar'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        leader['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: index < 3 ? _getMedalColor(index) : Colors.black87,
                        ),
                      ),
                      subtitle: Text('Eco Points: ${leader['score']}'),
                      trailing: index < 3
                          ? Icon(
                              index == 0
                                  ? Icons.emoji_events
                                  : index == 1
                                      ? Icons.emoji_events_outlined
                                      : Icons.emoji_events_rounded,
                              color: _getMedalColor(index),
                              size: 32,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

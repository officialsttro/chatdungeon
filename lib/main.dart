import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ChatDungeonApp());
}

class ChatDungeonApp extends StatelessWidget {
  const ChatDungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ChatDungeon',
      home: StatusPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  String story = '⏳ Warte auf den Spielleiter...';
  List<String> options = [];
  List<String> tasks = [];
  String? gegner;
  List<String> teilnehmer = [];

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    try {
      final res = await http.get(Uri.parse('http://192.168.2.38:8000/status'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          story = data['story'] ?? '';
          options = List<String>.from(data['options'] ?? []);
          tasks = List<String>.from(data['tasks'] ?? []);
          gegner = data['enemy'];
          teilnehmer = List<String>.from(data['players'] ?? []);
        });
      } else {
        setState(() {
          story = '⚠️ Fehler beim Laden des Status';
        });
      }
    } catch (e) {
      setState(() {
        story = '❌ Verbindung zum Server fehlgeschlagen';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🗺️ ChatDungeon',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                story,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ...options.map(
                (opt) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    opt,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              if (tasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  '📝 Aufgaben',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                ...tasks.map(
                  (t) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (gegner != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🗡️ Gegner',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      gegner!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              const Text(
                '👥 Teilnehmer',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: teilnehmer
                      .map((t) => Text(
                            t,
                            style: const TextStyle(color: Colors.white),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

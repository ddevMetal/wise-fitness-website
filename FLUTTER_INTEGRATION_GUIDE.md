# Flutter Integration Guide for Training Program Builder

This guide shows how to integrate the web-based Training Program Builder with your Flutter application.

## 📱 Flutter Models

Create these Dart models to handle the training program data:

```dart
// lib/models/training_program.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingProgram {
  final String? id;
  final String title;
  final String description;
  final String duration;
  final String frequency;
  final List<String> trainingDays;
  final String trainingStyle;
  final Map<String, WorkoutDay> workouts;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int version;

  TrainingProgram({
    this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.frequency,
    required this.trainingDays,
    required this.trainingStyle,
    required this.workouts,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.version = 1,
  });

  factory TrainingProgram.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return TrainingProgram(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      duration: data['duration'] ?? '',
      frequency: data['frequency'] ?? '',
      trainingDays: List<String>.from(data['trainingDays'] ?? []),
      trainingStyle: data['trainingStyle'] ?? '',
      workouts: (data['workouts'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, WorkoutDay.fromMap(value))),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      version: data['version'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'frequency': frequency,
      'trainingDays': trainingDays,
      'trainingStyle': trainingStyle,
      'workouts': workouts.map((key, value) => MapEntry(key, value.toMap())),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'version': version,
    };
  }

  // Helper getters
  String get durationDisplay {
    return duration.replaceAll('_', ' ').replaceAll('weeks', 'weeks');
  }

  String get frequencyDisplay {
    return frequency.replaceAll('_', ' ').replaceAll('days', ' days/week');
  }

  int get totalExercises {
    return workouts.values
        .map((workout) => workout.exercises.length)
        .fold(0, (sum, count) => sum + count);
  }

  List<String> get allExerciseNames {
    List<String> names = [];
    workouts.values.forEach((workout) {
      names.addAll(workout.exercises.map((e) => e.name));
    });
    return names.toSet().toList(); // Remove duplicates
  }
}

// lib/models/workout_day.dart
class WorkoutDay {
  final List<Exercise> exercises;

  WorkoutDay({required this.exercises});

  factory WorkoutDay.fromMap(Map<String, dynamic> map) {
    return WorkoutDay(
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map((e) => Exercise.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  // Helper getters
  int get totalSets {
    return exercises.map((e) => e.sets).fold(0, (sum, sets) => sum + sets);
  }

  Duration get estimatedDuration {
    int totalSeconds = 0;
    for (var exercise in exercises) {
      if (exercise.type == 'duration') {
        totalSeconds += (exercise.duration ?? 0) * exercise.sets;
      } else {
        // Estimate 2 seconds per rep
        totalSeconds += (exercise.reps ?? 0) * exercise.sets * 2;
      }
      totalSeconds += exercise.rest * (exercise.sets - 1); // Rest between sets
    }
    return Duration(seconds: totalSeconds);
  }
}

// lib/models/exercise.dart
class Exercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final String type; // 'reps' or 'duration'
  final int sets;
  final int? reps;
  final int? duration; // in seconds
  final int rest; // in seconds
  final String? weight;
  final String? notes;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.type,
    required this.sets,
    this.reps,
    this.duration,
    required this.rest,
    this.weight,
    this.notes,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? '',
      type: map['type'] ?? 'reps',
      sets: map['sets'] ?? 1,
      reps: map['reps'],
      duration: map['duration'],
      rest: map['rest'] ?? 60,
      weight: map['weight'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'type': type,
      'sets': sets,
      if (reps != null) 'reps': reps,
      if (duration != null) 'duration': duration,
      'rest': rest,
      if (weight != null) 'weight': weight,
      if (notes != null) 'notes': notes,
    };
  }

  // Helper getters
  String get displayRepsOrDuration {
    if (type == 'duration') {
      return '${duration}s';
    } else {
      return '${reps} reps';
    }
  }

  String get restDisplay {
    if (rest >= 60) {
      int minutes = rest ~/ 60;
      int seconds = rest % 60;
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      return '${rest}s';
    }
  }
}
```

## 🔥 Firebase Service

Create a service to handle Firebase operations:

```dart
// lib/services/training_program_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/training_program.dart';

class TrainingProgramService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all programs for the current user
  Stream<List<TrainingProgram>> getUserPrograms() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('trainingPrograms')
        .where('createdBy', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrainingProgram.fromFirestore(doc))
            .toList());
  }

  // Get a specific program by ID
  Future<TrainingProgram?> getProgramById(String programId) async {
    try {
      final doc = await _firestore
          .collection('trainingPrograms')
          .doc(programId)
          .get();
      
      if (doc.exists) {
        return TrainingProgram.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting program: $e');
      return null;
    }
  }

  // Delete a program (soft delete)
  Future<bool> deleteProgram(String programId) async {
    try {
      await _firestore
          .collection('trainingPrograms')
          .doc(programId)
          .update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error deleting program: $e');
      return false;
    }
  }

  // Search programs by title
  Future<List<TrainingProgram>> searchPrograms(String query) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('trainingPrograms')
          .where('createdBy', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => TrainingProgram.fromFirestore(doc))
          .where((program) => 
              program.title.toLowerCase().contains(query.toLowerCase()) ||
              program.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching programs: $e');
      return [];
    }
  }

  // Get programs by training style
  Stream<List<TrainingProgram>> getProgramsByStyle(String style) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('trainingPrograms')
        .where('createdBy', isEqualTo: user.uid)
        .where('trainingStyle', isEqualTo: style)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrainingProgram.fromFirestore(doc))
            .toList());
  }

  // Get program statistics
  Future<Map<String, dynamic>> getProgramStats() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final snapshot = await _firestore
          .collection('trainingPrograms')
          .where('createdBy', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .get();

      final programs = snapshot.docs
          .map((doc) => TrainingProgram.fromFirestore(doc))
          .toList();

      Map<String, int> styleCount = {};
      Map<String, int> durationCount = {};
      int totalExercises = 0;

      for (var program in programs) {
        styleCount[program.trainingStyle] = 
            (styleCount[program.trainingStyle] ?? 0) + 1;
        durationCount[program.duration] = 
            (durationCount[program.duration] ?? 0) + 1;
        totalExercises += program.totalExercises;
      }

      return {
        'totalPrograms': programs.length,
        'totalExercises': totalExercises,
        'styleBreakdown': styleCount,
        'durationBreakdown': durationCount,
        'averageExercisesPerProgram': 
            programs.isEmpty ? 0 : totalExercises / programs.length,
      };
    } catch (e) {
      print('Error getting stats: $e');
      return {};
    }
  }
}
```

## 📱 Flutter UI Components

### Program List Screen

```dart
// lib/screens/training_programs_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/training_program_service.dart';
import '../models/training_program.dart';
import '../widgets/program_card.dart';

class TrainingProgramsScreen extends StatefulWidget {
  @override
  _TrainingProgramsScreenState createState() => _TrainingProgramsScreenState();
}

class _TrainingProgramsScreenState extends State<TrainingProgramsScreen> {
  final TrainingProgramService _programService = TrainingProgramService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training Programs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openProgramBuilder(context),
          ),
        ],
      ),
      body: StreamBuilder<List<TrainingProgram>>(
        stream: _programService.getUserPrograms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final programs = snapshot.data ?? [];

          if (programs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              return ProgramCard(
                program: programs[index],
                onTap: () => _viewProgram(programs[index]),
                onDelete: () => _deleteProgram(programs[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProgramBuilder(context),
        child: Icon(Icons.add),
        tooltip: 'Create Training Program',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Training Programs Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Create your first training program to get started',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openProgramBuilder(context),
            icon: Icon(Icons.add),
            label: Text('Create Program'),
          ),
        ],
      ),
    );
  }

  void _openProgramBuilder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramBuilderWebView(),
        fullscreenDialog: true,
      ),
    );
  }

  void _viewProgram(TrainingProgram program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgramDetailScreen(program: program),
      ),
    );
  }

  void _deleteProgram(TrainingProgram program) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Program'),
        content: Text('Are you sure you want to delete "${program.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true && program.id != null) {
      final success = await _programService.deleteProgram(program.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Program deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete program')),
        );
      }
    }
  }
}
```

### WebView for Program Builder

```dart
// lib/screens/program_builder_webview.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProgramBuilderWebView extends StatefulWidget {
  @override
  _ProgramBuilderWebViewState createState() => _ProgramBuilderWebViewState();
}

class _ProgramBuilderWebViewState extends State<ProgramBuilderWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            
            // Auto-open the training builder
            controller.runJavaScript('openTrainingBuilder()');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://your-domain.com/TrainingProgramBuilder.html'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Training Program'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
```

### Program Card Widget

```dart
// lib/widgets/program_card.dart
import 'package:flutter/material.dart';
import '../models/training_program.dart';

class ProgramCard extends StatelessWidget {
  final TrainingProgram program;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProgramCard({
    Key? key,
    required this.program,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      program.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (program.description.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  program.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    context,
                    Icons.schedule,
                    program.durationDisplay,
                  ),
                  _buildChip(
                    context,
                    Icons.fitness_center,
                    program.frequencyDisplay,
                  ),
                  _buildChip(
                    context,
                    Icons.category,
                    program.trainingStyle.replaceAll('_', ' ').toUpperCase(),
                  ),
                  _buildChip(
                    context,
                    Icons.format_list_numbered,
                    '${program.totalExercises} exercises',
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4),
                  Text(
                    program.trainingDays.map((day) => 
                        day.substring(0, 3).toUpperCase()).join(', '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Spacer(),
                  Text(
                    'Created ${_formatDate(program.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
```

## 🔧 Setup Instructions

1. **Add Dependencies** to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  webview_flutter: ^4.4.2
```

2. **Initialize Firebase** in your `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

3. **Configure WebView** permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

4. **Update iOS Configuration** in `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

This integration allows your Flutter app to:
- Display training programs created via the web builder
- Open the web builder in a WebView for program creation
- Manage and delete programs
- Show detailed program information
- Search and filter programs

The web builder handles the complex program creation UI while Flutter provides the native mobile experience for viewing and managing programs.

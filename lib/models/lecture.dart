import 'package:cloud_firestore/cloud_firestore.dart';

class Lecture {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final int orderIndex;
  final Duration? duration;

  const Lecture({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.orderIndex,
    this.duration,
  });

  factory Lecture.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Lecture(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      orderIndex: data['orderIndex'] ?? 0,
      duration: data['durationSeconds'] != null
          ? Duration(seconds: data['durationSeconds'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'orderIndex': orderIndex,
      if (duration != null) 'durationSeconds': duration!.inSeconds,
    };
  }
}
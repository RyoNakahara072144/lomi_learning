import 'package:cloud_firestore/cloud_firestore.dart';
import 'section.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String instructorName;
  final List<Section> sections;
  final DateTime? updatedAt;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.instructorName,
    required this.sections,
    this.updatedAt,
  });

  factory Course.fromFirestore(DocumentSnapshot doc, List<Section> sections) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      instructorName: data['instructorName'] ?? '',
      sections: sections,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'instructorName': instructorName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  List<dynamic> get allLectures =>
      sections.expand((s) => s.lectures).toList();
}
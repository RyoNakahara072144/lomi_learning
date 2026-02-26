import 'package:cloud_firestore/cloud_firestore.dart';
import 'lecture.dart';

class Section {
  final String id;
  final String title;
  final int orderIndex;
  final List<Lecture> lectures;

  const Section({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.lectures,
  });

  factory Section.fromFirestore(DocumentSnapshot doc, List<Lecture> lectures) {
    final data = doc.data() as Map<String, dynamic>;
    return Section(
      id: doc.id,
      title: data['title'] ?? '',
      orderIndex: data['orderIndex'] ?? 0,
      lectures: lectures,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'orderIndex': orderIndex,
    };
  }
}
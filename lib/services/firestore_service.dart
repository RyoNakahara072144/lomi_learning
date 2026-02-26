import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/section.dart';
import '../models/lecture.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// コース一覧を取得
  Stream<List<Course>> watchCourses() {
    return _db.collection('courses').snapshots().asyncMap((snapshot) async {
      final futures = snapshot.docs.map((doc) => _buildCourse(doc));
      return Future.wait(futures);
    });
  }

  /// 特定コースを取得
  Stream<Course?> watchCourse(String courseId) {
    return _db
        .collection('courses')
        .doc(courseId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) return null;
      return _buildCourse(doc);
    });
  }

  /// コースにセクション・講座を付けて構築
  Future<Course> _buildCourse(DocumentSnapshot courseDoc) async {
    final sectionsSnap = await _db
        .collection('courses')
        .doc(courseDoc.id)
        .collection('sections')
        .orderBy('orderIndex')
        .get();

    final sectionFutures = sectionsSnap.docs.map((sectionDoc) async {
      final lecturesSnap = await _db
          .collection('courses')
          .doc(courseDoc.id)
          .collection('sections')
          .doc(sectionDoc.id)
          .collection('lectures')
          .orderBy('orderIndex')
          .get();

      final lectures =
          lecturesSnap.docs.map((l) => Lecture.fromFirestore(l)).toList();
      return Section.fromFirestore(sectionDoc, lectures);
    });

    final sections = await Future.wait(sectionFutures);
    return Course.fromFirestore(courseDoc, sections);
  }

  /// ブックマーク追加/削除
  Future<void> toggleBookmark({
    required String userId,
    required String courseId,
    required String lectureId,
    required bool isBookmarked,
  }) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc('${courseId}_$lectureId');

    if (isBookmarked) {
      await ref.delete();
    } else {
      await ref.set({
        'courseId': courseId,
        'lectureId': lectureId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// ブックマーク一覧を取得
  Stream<Set<String>> watchBookmarks(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }
}
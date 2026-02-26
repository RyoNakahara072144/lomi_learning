import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/course.dart';
import '../models/lecture.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

/// コース一覧
final coursesProvider = StreamProvider<List<Course>>((ref) {
  return ref.watch(firestoreServiceProvider).watchCourses();
});

/// 特定コース
final courseProvider =
    StreamProvider.family<Course?, String>((ref, courseId) {
  return ref.watch(firestoreServiceProvider).watchCourse(courseId);
});

/// 選択中のコースID
final selectedCourseIdProvider = StateProvider<String?>((ref) => null);

/// 選択中の講座
final selectedLectureProvider = StateProvider<Lecture?>((ref) => null);

/// セクション開閉状態
final sectionExpandedProvider =
    StateProvider.family<bool, String>((ref, sectionId) => true);

/// ブックマーク一覧
final bookmarksProvider = StreamProvider.family<Set<String>, String>(
    (ref, userId) {
  return ref.watch(firestoreServiceProvider).watchBookmarks(userId);
});
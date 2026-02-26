import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/lecture.dart';
import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/section_sidebar.dart';
import '../../widgets/lecture_video_player.dart';
import '../../widgets/learning_support_fab.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _sidebarVisible = true;

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseProvider(widget.courseId));
    final selectedLecture = ref.watch(selectedLectureProvider);

    return courseAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
      data: (course) {
        if (course == null) {
          return const Center(child: Text('コースが見つかりません'));
        }

        // 最初の講座を自動選択
        final currentLecture = selectedLecture ??
            (course.sections.isNotEmpty &&
                    course.sections.first.lectures.isNotEmpty
                ? course.sections.first.lectures.first
                : null);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 768;

            if (isWide) {
              return _WideLayout(
                course: course,
                selectedLecture: currentLecture,
                onLectureSelected: (l) =>
                    ref.read(selectedLectureProvider.notifier).state = l,
              );
            } else {
              return _NarrowLayout(
                course: course,
                selectedLecture: currentLecture,
                onLectureSelected: (l) =>
                    ref.read(selectedLectureProvider.notifier).state = l,
                sidebarVisible: _sidebarVisible,
                onToggleSidebar: () =>
                    setState(() => _sidebarVisible = !_sidebarVisible),
              );
            }
          },
        );
      },
    );
  }
}

// ─── Wide layout (PC) ────────────────────────────────────────────────────────

class _WideLayout extends ConsumerWidget {
  final Course course;
  final Lecture? selectedLecture;
  final ValueChanged<Lecture> onLectureSelected;

  const _WideLayout({
    required this.course,
    required this.selectedLecture,
    required this.onLectureSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Sidebar
        SizedBox(
          width: 240,
          child: Column(
            children: [
              Expanded(
                child: SectionSidebar(
                  course: course,
                  selectedLecture: selectedLecture,
                  onLectureSelected: onLectureSelected,
                ),
              ),
            ],
          ),
        ),

        // Divider
        VerticalDivider(width: 1, color: Colors.grey.shade200),

        // Main content
        Expanded(
          child: _MainContent(
            course: course,
            selectedLecture: selectedLecture,
          ),
        ),
      ],
    );
  }
}

// ─── Narrow layout (Mobile) ──────────────────────────────────────────────────

class _NarrowLayout extends ConsumerWidget {
  final Course course;
  final Lecture? selectedLecture;
  final ValueChanged<Lecture> onLectureSelected;
  final bool sidebarVisible;
  final VoidCallback onToggleSidebar;

  const _NarrowLayout({
    required this.course,
    required this.selectedLecture,
    required this.onLectureSelected,
    required this.sidebarVisible,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Toggle button
        InkWell(
          onTap: onToggleSidebar,
          child: Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.menu_book_outlined,
                    size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sidebarVisible ? '目次を閉じる' : '目次を開く',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(
                  sidebarVisible
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade200),

        // Sidebar (collapsible)
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: sidebarVisible ? 240 : 0,
          child: SectionSidebar(
            course: course,
            selectedLecture: selectedLecture,
            onLectureSelected: (l) {
              onLectureSelected(l);
              // Auto-close sidebar on mobile after selection
            },
          ),
        ),

        if (sidebarVisible) Divider(height: 1, color: Colors.grey.shade200),

        // Main content
        Expanded(
          child: _MainContent(
            course: course,
            selectedLecture: selectedLecture,
          ),
        ),
      ],
    );
  }
}

// ─── Main content ────────────────────────────────────────────────────────────

class _MainContent extends ConsumerWidget {
  final Course course;
  final Lecture? selectedLecture;

  const _MainContent({required this.course, required this.selectedLecture});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).when(
      data: (u) => u,
      loading: () => null,
      error: (_, __) => null,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: const LearningSupportFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: selectedLecture == null
          ? _buildEmpty(context)
          : _buildContent(context, ref, selectedLecture!, user?.uid),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library_outlined,
              size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text(
            '講座を選択してください',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF64748B),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, Lecture lecture, String? userId) {
    final bookmarksAsync =
        userId != null ? ref.watch(bookmarksProvider(userId)) : null;
    final bookmarkKey = '${course.id}_${lecture.id}';
    final isBookmarked = bookmarksAsync?.when(
          data: (set) => set.contains(bookmarkKey),
          loading: () => false,
          error: (_, __) => false,
        ) ??
        false;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video player
          LectureVideoPlayer(lecture: lecture),

          // Content area - padded from FAB
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 16, 80, 32), // right for FAB
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        lecture.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bookmark button
                    if (userId != null)
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(firestoreServiceProvider)
                              .toggleBookmark(
                                userId: userId,
                                courseId: course.id,
                                lectureId: lecture.id,
                                isBookmarked: isBookmarked,
                              );
                        },
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 18,
                          color: isBookmarked
                              ? const Color(0xFF2563EB)
                              : null,
                        ),
                        label: Text(
                          'ブックマーク',
                          style: TextStyle(
                            fontSize: 12,
                            color: isBookmarked
                                ? const Color(0xFF2563EB)
                                : null,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          side: BorderSide(
                            color: isBookmarked
                                ? const Color(0xFF2563EB)
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                if (lecture.description.isNotEmpty) ...[
                  Text(
                    lecture.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Course info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_outlined,
                          size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        course.instructorName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/course.dart';
import '../../models/lecture.dart';
import '../../providers/course_provider.dart';

class SectionSidebar extends ConsumerWidget {
  final Course course;
  final Lecture? selectedLecture;
  final ValueChanged<Lecture> onLectureSelected;

  const SectionSidebar({
    super.key,
    required this.course,
    required this.selectedLecture,
    required this.onLectureSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course overview
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'コース概要',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),

          // Sections
          Expanded(
            child: ListView.builder(
              itemCount: course.sections.length,
              itemBuilder: (context, i) {
                final section = course.sections[i];
                return _SectionTile(
                  section: section,
                  selectedLecture: selectedLecture,
                  onLectureSelected: onLectureSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends ConsumerWidget {
  final dynamic section;
  final Lecture? selectedLecture;
  final ValueChanged<Lecture> onLectureSelected;

  const _SectionTile({
    required this.section,
    required this.selectedLecture,
    required this.onLectureSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sectionExpandedProvider(section.id));

    return Column(
      children: [
        // Section header
        InkWell(
          onTap: () => ref
              .read(sectionExpandedProvider(section.id).notifier)
              .state = !isExpanded,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),

        // Lectures
        if (isExpanded)
          ...section.lectures.map<Widget>((lecture) {
            final isSelected = selectedLecture?.id == lecture.id;
            return InkWell(
              onTap: () => onLectureSelected(lecture),
              child: Container(
                padding: const EdgeInsets.only(
                    left: 28, right: 16, top: 10, bottom: 10),
                color: isSelected
                    ? const Color(0xFFEFF6FF)
                    : Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      size: 14,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lecture.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF475569),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}
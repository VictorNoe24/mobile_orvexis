class ProjectActivityItem {
  const ProjectActivityItem({
    required this.title,
    required this.caption,
    required this.detail,
    this.isHighlighted = false,
  });

  final String title;
  final String caption;
  final String detail;
  final bool isHighlighted;
}

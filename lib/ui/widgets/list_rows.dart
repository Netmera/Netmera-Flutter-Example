import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';
import 'package:netmera_flutter_example/ui/app_theme.dart';

class InsetDivider extends StatelessWidget {
  const InsetDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(indent: 16);
}

/// Title/subtitle row used by the home menu and sub menus.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.rowTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTextStyles.rowSubtitle),
                  ],
                ],
              ),
            ),
            if (showDivider) const InsetDivider(),
          ],
        ),
      ),
    );
  }
}

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.switchTitle),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: AppTextStyles.caption),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(value: value, onChanged: onChanged),
                ],
              ),
            ),
          ),
          if (showDivider) const InsetDivider(),
        ],
      ),
    );
  }
}

/// Read-only row that shows a value, e.g. a permission status in green or red.
class StatusRow extends StatelessWidget {
  const StatusRow({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.valueColor = AppColors.label,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final String value;
  final Color valueColor;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.rowTitle),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: AppTextStyles.rowSubtitle),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.statusValue.copyWith(
                        color: valueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showDivider) const InsetDivider(),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.groupedBackground,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(text, style: AppTextStyles.sectionHeader),
    );
  }
}

class SectionFooter extends StatelessWidget {
  const SectionFooter(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.groupedBackground,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Text(text, style: AppTextStyles.caption),
    );
  }
}

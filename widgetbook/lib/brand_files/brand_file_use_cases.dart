import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'brand_file_loader.dart';

/// The "Brand files" category: a token preview for each valid brand file and
/// a problem report for each invalid one.
abstract final class BrandFileUseCases {
  /// Returns the category for [brands].
  static WidgetbookCategory category(WidgetbookBrands brands) =>
      WidgetbookCategory(
        name: 'Brand files',
        children: [
          for (final file in brands.files)
            if (file.brand case final brand?)
              WidgetbookComponent(
                name: brand.name,
                useCases: [
                  WidgetbookUseCase(
                    name: 'Tokens',
                    builder: (_) => BrandTokenPreview(brand: brand),
                  ),
                ],
              )
            else
              WidgetbookComponent(
                name: '⚠ ${file.fileName}',
                useCases: [
                  WidgetbookUseCase(
                    name: 'Problems',
                    builder: (_) => BrandProblemReport(file: file),
                  ),
                ],
              ),
        ],
      );
}

/// Preview of every token of one brand: its color scales, its semantic roles
/// in light and dark mode, its type scale, spacing, and radii.
final class BrandTokenPreview extends StatelessWidget {
  /// Creates a token preview.
  const BrandTokenPreview({super.key, required this.brand});

  /// The brand to preview.
  final DsBrand brand;

  @override
  Widget build(BuildContext context) {
    final colors = brand.colors;
    return DsBrandScope(
      brand: brand,
      child: Builder(
        builder: (context) => ColoredBox(
          color: context.dsColors.background,
          child: ListView(
            padding: context.dsSpacing.all(DsSpacingStep.lg),
            children: [
              _Heading('${brand.name} · ${brand.id}'),
              const _Heading('Color scales'),
              _ScaleRow('brand', [
                ('50', colors.brand.shade50),
                ('100', colors.brand.shade100),
                ('200', colors.brand.shade200),
                ('300', colors.brand.shade300),
                ('400', colors.brand.shade400),
                ('500', colors.brand.shade500),
                ('600', colors.brand.shade600),
                ('700', colors.brand.shade700),
                ('800', colors.brand.shade800),
                ('900', colors.brand.shade900),
              ]),
              _ScaleRow('neutral', [
                ('0', colors.neutral.shade0),
                ('50', colors.neutral.shade50),
                ('100', colors.neutral.shade100),
                ('200', colors.neutral.shade200),
                ('300', colors.neutral.shade300),
                ('400', colors.neutral.shade400),
                ('500', colors.neutral.shade500),
                ('600', colors.neutral.shade600),
                ('700', colors.neutral.shade700),
                ('800', colors.neutral.shade800),
                ('900', colors.neutral.shade900),
              ]),
              for (final (name, scale) in [
                ('success', colors.success),
                ('warning', colors.warning),
                ('error', colors.error),
                ('info', colors.info),
              ])
                _ScaleRow(name, [
                  ('100', scale.shade100),
                  ('500', scale.shade500),
                  ('700', scale.shade700),
                ]),
              const _Heading('Semantic roles'),
              _RoleTable(brand: brand),
              const _Heading('Type scale'),
              const _TypeScale(),
              const _Heading('Spacing'),
              for (final step in DsSpacingStep.values) _SpacingBar(step),
              const _Heading('Corner radius'),
              const _RadiusRow(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Report of every exception that rejected one brand file.
final class BrandProblemReport extends StatelessWidget {
  /// Creates a problem report.
  const BrandProblemReport({super.key, required this.file});

  /// The rejected file.
  final WidgetbookBrandFile file;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    final typography = context.dsTypography;
    return ColoredBox(
      color: colors.background,
      child: ListView(
        padding: context.dsSpacing.all(DsSpacingStep.lg),
        children: [
          _Heading(
            '${file.fileName}: ${file.exceptions.length} problem(s). '
            'It is left out of the brand switcher.',
          ),
          for (final exception in file.exceptions)
            Padding(
              padding: context.dsSpacing.only(bottom: DsSpacingStep.sm),
              child: DsInlineMessage(
                tone: DsMessageTone.error,
                title:
                    '${exception.path.isEmpty ? '(whole file)' : exception.path}'
                    ' · ${exception.type.name}',
                message: exception.message,
              ),
            ),
          Text(
            'Fix the file, then restart the Widgetbook.',
            style: typography.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

final class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.dsSpacing.only(
      top: DsSpacingStep.lg,
      bottom: DsSpacingStep.sm,
    ),
    child: Text(
      text,
      style: context.dsTypography.title.copyWith(
        color: context.dsColors.textPrimary,
      ),
    ),
  );
}

final class _ScaleRow extends StatelessWidget {
  const _ScaleRow(this.name, this.steps);

  final String name;
  final List<(String, Color)> steps;

  @override
  Widget build(BuildContext context) {
    final caption = context.dsTypography.caption.copyWith(
      color: context.dsColors.textSecondary,
    );
    return Padding(
      padding: context.dsSpacing.only(bottom: DsSpacingStep.sm),
      child: Row(
        children: [
          SizedBox(width: 72, child: Text(name, style: caption)),
          for (final (step, color) in steps)
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: context.dsColors.border),
                    ),
                  ),
                  Text(step, style: caption),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

final class _RoleTable extends StatelessWidget {
  const _RoleTable({required this.brand});

  final DsBrand brand;

  @override
  Widget build(BuildContext context) {
    final light = DsTokens.resolve(brand, Brightness.light).colors;
    final dark = DsTokens.resolve(brand, Brightness.dark).colors;
    final caption = context.dsTypography.caption.copyWith(
      color: context.dsColors.textSecondary,
    );
    return Column(
      children: [
        for (final role in DsColorRole.values)
          Row(
            children: [
              Expanded(child: Text(role.name, style: caption)),
              _Swatch(light.role(role), 'light'),
              _Swatch(dark.role(role), 'dark'),
            ],
          ),
      ],
    );
  }
}

final class _Swatch extends StatelessWidget {
  const _Swatch(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Container(
      width: 64,
      height: 20,
      margin: context.dsSpacing.all(DsSpacingStep.xxs),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: context.dsColors.border),
      ),
    ),
  );
}

final class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final typography = context.dsTypography;
    final color = context.dsColors.textPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style) in [
          ('display', typography.display),
          ('headline', typography.headline),
          ('title', typography.title),
          ('body', typography.body),
          ('bodyStrong', typography.bodyStrong),
          ('label', typography.label),
          ('caption', typography.caption),
        ])
          Text(
            '$name · ${style.fontSize?.toStringAsFixed(0)} · '
            '${style.fontFamily ?? 'platform font'}',
            style: style.copyWith(color: color),
          ),
      ],
    );
  }
}

final class _SpacingBar extends StatelessWidget {
  const _SpacingBar(this.step);

  final DsSpacingStep step;

  @override
  Widget build(BuildContext context) {
    final size = context.dsSpacing[step];
    return Padding(
      padding: context.dsSpacing.only(bottom: DsSpacingStep.xxs),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '${step.name} ${size.toStringAsFixed(0)}',
              style: context.dsTypography.caption.copyWith(
                color: context.dsColors.textSecondary,
              ),
            ),
          ),
          Container(
            width: size,
            height: 12,
            color: context.dsColors.actionPrimary,
          ),
        ],
      ),
    );
  }
}

final class _RadiusRow extends StatelessWidget {
  const _RadiusRow();

  @override
  Widget build(BuildContext context) {
    final radius = context.dsRadius;
    return Wrap(
      spacing: context.dsSpacing.md,
      children: [
        for (final (name, value) in [
          ('sm', radius.sm),
          ('md', radius.md),
          ('lg', radius.lg),
          ('pill', radius.pill),
        ])
          Container(
            width: 96,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.dsColors.surfaceVariant,
              borderRadius: BorderRadius.circular(value),
              border: Border.all(color: context.dsColors.border),
            ),
            child: Text(
              name,
              style: context.dsTypography.label.copyWith(
                color: context.dsColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

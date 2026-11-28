import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_case_frame.dart';

/// Use cases of the atoms: DsButton, DsTextField, and DsLoadingIndicator.
abstract final class AtomUseCases {
  /// Use cases of [DsButton], one per variant and state.
  static List<WidgetbookUseCase> get button => [
    WidgetbookUseCase(
      name: 'Primary',
      builder: (_) => const _ButtonUseCase(variant: DsButtonVariant.primary),
    ),
    WidgetbookUseCase(
      name: 'Secondary',
      builder: (_) => const _ButtonUseCase(variant: DsButtonVariant.secondary),
    ),
    WidgetbookUseCase(
      name: 'Tertiary',
      builder: (_) => const _ButtonUseCase(variant: DsButtonVariant.tertiary),
    ),
    WidgetbookUseCase(
      name: 'With icon',
      builder: (_) => const _ButtonUseCase(withIcon: true),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (_) => const _ButtonUseCase(enabled: false),
    ),
    WidgetbookUseCase(
      name: 'Loading',
      builder: (_) => const _ButtonUseCase(isLoading: true),
    ),
    WidgetbookUseCase(
      name: 'Expanded',
      builder: (_) => const _ButtonUseCase(expand: true),
    ),
  ];

  /// Use cases of [DsTextField], one per state.
  static List<WidgetbookUseCase> get textField => [
    WidgetbookUseCase(
      name: 'Label only',
      builder: (_) => const _TextFieldUseCase(),
    ),
    WidgetbookUseCase(
      name: 'Hint and helper',
      builder: (_) => const _TextFieldUseCase(
        hint: 'name@example.com',
        helperText: 'We send the receipt here.',
      ),
    ),
    WidgetbookUseCase(
      name: 'Error',
      builder: (_) =>
          const _TextFieldUseCase(errorText: 'Enter a valid email address.'),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (_) => const _TextFieldUseCase(enabled: false),
    ),
    WidgetbookUseCase(
      name: 'Obscured',
      builder: (_) =>
          const _TextFieldUseCase(label: 'Password', obscureText: true),
    ),
  ];

  /// Use cases of [DsLoadingIndicator].
  static List<WidgetbookUseCase> get loadingIndicator => [
    WidgetbookUseCase(
      name: 'Default',
      builder: (_) => const _LoadingIndicatorUseCase(),
    ),
    WidgetbookUseCase(
      name: 'Custom size',
      builder: (_) => const _LoadingIndicatorUseCase(size: 48),
    ),
  ];
}

final class _ButtonUseCase extends StatelessWidget {
  const _ButtonUseCase({
    this.variant = DsButtonVariant.primary,
    this.enabled = true,
    this.withIcon = false,
    this.isLoading = false,
    this.expand = false,
  });

  final DsButtonVariant variant;
  final bool enabled;
  final bool withIcon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final knobs = context.knobs;
    return UseCaseFrame(
      child: DsButton(
        label: knobs.string(label: 'label', initialValue: 'Transfer'),
        variant: knobs.object.dropdown(
          label: 'variant',
          options: DsButtonVariant.values,
          initialOption: variant,
          labelBuilder: (value) => value.name,
        ),
        icon: knobs.boolean(label: 'icon', initialValue: withIcon)
            ? Icons.send
            : null,
        isLoading: knobs.boolean(label: 'isLoading', initialValue: isLoading),
        expand: knobs.boolean(label: 'expand', initialValue: expand),
        onPressed: knobs.boolean(label: 'enabled', initialValue: enabled)
            ? () {}
            : null,
      ),
    );
  }
}

final class _TextFieldUseCase extends StatelessWidget {
  const _TextFieldUseCase({
    this.label = 'Email',
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final knobs = context.knobs;
    return UseCaseFrame(
      child: DsTextField(
        label: knobs.string(label: 'label', initialValue: label),
        hint: knobs.stringOrNull(label: 'hint', initialValue: hint),
        helperText: knobs.stringOrNull(
          label: 'helperText',
          initialValue: helperText,
        ),
        errorText: knobs.stringOrNull(
          label: 'errorText',
          initialValue: errorText,
        ),
        enabled: knobs.boolean(label: 'enabled', initialValue: enabled),
        obscureText: knobs.boolean(
          label: 'obscureText',
          initialValue: obscureText,
        ),
      ),
    );
  }
}

final class _LoadingIndicatorUseCase extends StatelessWidget {
  const _LoadingIndicatorUseCase({this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final knobs = context.knobs;
    final custom = size;
    return UseCaseFrame(
      child: DsLoadingIndicator(
        semanticsLabel: knobs.string(
          label: 'semanticsLabel',
          initialValue: 'Loading accounts',
        ),
        size: custom == null
            ? null
            : knobs.double.slider(
                label: 'size',
                initialValue: custom,
                min: 16,
                max: 96,
              ),
      ),
    );
  }
}

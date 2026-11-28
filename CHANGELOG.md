# Changelog

All notable changes to the `design_system` package. The package follows
semantic versioning; Foundations' changelog states which version it delivers.

## [Unreleased]

The `0.2.0` release: multi-brand theming. **Breaking**: read Migration
before upgrading.

**Brand-schema versions accepted: 1** (`DsBrandParser.supportedSchemaVersions`).
Version 1 requires 59 token paths, listed under "What a brand file must
contain" in `doc/brand-files.md`.

### Added

- Brands as data: `DsBrand` holds primitive tokens only (`DsBrandColors`
  with brand, neutral, success, warning, error, and info scales;
  `DsBrandTypography`; `DsSpacing`; `DsRadius`; `DsBorderWidths`;
  `DsOpacities`; `DsIconSizes`), and the built-in `DsBrand.whiteLabel`.
- Brand files: `DsBrandParser.parseJson` and `parseMap` read a W3C Design
  Tokens (DTCG) file and return a `DsBrandParseResult`: a
  `DsBrandParseSuccess`, or a `DsBrandParseFailure` that lists every
  problem as a `DsBrandParseException` with its `DsBrandParseExceptionType`.
  Bad input never throws. The designer guide is `doc/brand-files.md`.
- `DsBrandScope` rebrands a subtree. The nearest brand wins, dialogs and
  sheets keep it, and it follows the app's light or dark mode.
- `DsTokens`, the theme extension that holds the resolved tokens, and the
  `context.ds*` getters of `DsThemeContext`: `dsBrand`, `dsColors`,
  `dsTypography`, `dsSpacing`, `dsRadius`, `dsBorderWidths`, `dsOpacities`,
  and `dsIconSizes`. With no theme above, they fall back to the white label
  and print one debug warning.
- `DsColorRole`, the 20 semantic color roles, including the new info roles.
- `DsGap(DsSpacingStep.<step>)`, a gap of one spacing step of the nearest
  brand.
- `DsContrastGate.check(brand)`, which returns a `DsContrastReport` of
  `DsContrastViolation`s for every semantic pair below its required
  contrast in light or dark mode. In debug builds, placing a failing brand
  prints one warning.
- QA identifiers: every component takes an optional `qaIdentifier`, exposed
  to UI automation only in builds made with
  `--dart-define=DS_QA_IDENTIFIERS=true` (`DsQaIdentifiers`).
- `DsGuidelines`, the developer overlay that outlines components by atomic
  level and tints `DsGap`s. It turns on with the widget or
  `--dart-define=DS_GUIDELINES=true`, and never shows in release builds.
- Component metadata: `static const DsComponentInfo info` on every
  component (`DsComponentLevel`, `DsComponentStatus`), listed by
  `DsComponentCatalog.all`. All eight components are `stable` since
  `0.1.0`.
- `widgetbook/`, an internal Widgetbook that shows every component in
  every brand file, mode, and viewport, with the guidelines toggle.
- Golden images of every component state, brand, and mode, compared with a
  5% tolerance so they pass on macOS and Linux.
- `lints/`, the `design_system_lints` analyzer plugin, which reports
  literal colors and spacing, and literal icon sizes, border widths,
  opacities, and primitive brand colors inside components.
- The component agent and its checklist, for building new components.

### Changed

- Every component reads its colors, text styles, spacing, radius, border
  widths, opacities, and icon sizes from the nearest brand, and only
  through semantic roles. Changing the brand restyles every component.
- Semantic colors come straight from the brand's scales, in light and
  dark. The design system no longer adjusts brand colors to reach
  contrast. The contrast gate reports a failing brand instead.
- Brand and mode switches are instant. The App Shell passes
  `themeAnimationStyle: AnimationStyle.noAnimation` to `MaterialApp`, and
  `DsTokens.lerp` snaps instead of blending.
- `DsTheme.light`, `DsTheme.dark`, and the new `DsTheme.forBrightness` build
  a full `ThemeData` from the brand: color scheme, text theme, cursor, and
  selection colors.
- `DsCard.padding` is `EdgeInsetsGeometry?`. Null means the brand's medium
  spacing step on every side.
- `DsLoadingIndicator.size` is `double?`. Null means the brand's regular
  icon size, `context.dsIconSizes.md`.
- Component files moved to `lib/src/components/<level>/`. The public names
  are unchanged.
- `DsBrand` is no longer `DsBrand(primary:, fontFamily:)`: see Migration.

### Deprecated

- `DsBrand.standard`: use `DsBrand.whiteLabel`. Removed in 0.3.0. It now
  names the white label, whose brand blue differs from the 0.1.0
  `standard` primary color.

### Removed

- `DsBrand(primary:, fontFamily:)`.
- `DsPalette`.
- The static spacing and radius constants, such as `DsSpacing.md` and
  `DsRadius.md`. `DsSpacing` and `DsRadius` are now the brand's value
  classes.
- `DsColors` and `DsTypography` as `ThemeExtension`s:
  `Theme.of(context).extension<DsColors>()` returns null.
- The `example/` gallery app, replaced by `widgetbook/`.

### Migration

**A brand from a primary color.** Export the brand as a brand file and
parse it, or build a full `DsBrand`.

```dart
// Before
final theme = DsTheme.light(
  brand: const DsBrand(primary: Color(0xFF0B6E4F), fontFamily: 'Forest Sans'),
);

// After
final brand = switch (DsBrandParser.parseJson(brandJson)) {
  DsBrandParseSuccess(:final brand) => brand,
  DsBrandParseFailure() => DsBrand.whiteLabel,
};
final theme = DsTheme.light(brand: brand);
```

**`DsPalette`.** Screens use semantic roles. Primitive scales are still
readable from the brand.

```dart
// Before
Container(color: DsPalette.neutral100);

// After
ColoredBox(color: context.dsColors.surface);
// Only when a primitive is really needed:
final neutral100 = context.dsBrand.colors.neutral.shade100;
```

**Static spacing.** Read the nearest brand's scale, or use `DsGap` between
children.

```dart
// Before
Padding(padding: const EdgeInsets.all(DsSpacing.md), child: content);
const SizedBox(height: DsSpacing.md);

// After
Padding(padding: context.dsSpacing.all(DsSpacingStep.md), child: content);
const DsGap(DsSpacingStep.md);
```

**Static radius.**

```dart
// Before
BorderRadius.circular(DsRadius.md);

// After
BorderRadius.circular(context.dsRadius.md);
```

**`DsColors` and `DsTypography` as theme extensions.**

```dart
// Before
final colors = Theme.of(context).extension<DsColors>()!;
final typography = Theme.of(context).extension<DsTypography>()!;

// After
final colors = context.dsColors;
final typography = context.dsTypography;
// Or, from a ThemeData:
final tokens = theme.extension<DsTokens>()!;
```

**`DsCard.padding`.** The default now follows the brand. Code that passed
a padding keeps working. To keep the old fixed 16:

```dart
// Before
const DsCard(child: content); // always 16 on every side

// After
const DsCard(child: content); // the brand's medium step (16 in the white label)
DsCard(padding: const EdgeInsets.all(16), child: content); // a fixed value
```

**`DsLoadingIndicator.size`.** The default now follows the brand's icon
size.

```dart
// Before
const DsLoadingIndicator(semanticsLabel: 'Loading'); // always 24

// After
const DsLoadingIndicator(semanticsLabel: 'Loading'); // the brand's md icon size (24 in the white label)
DsLoadingIndicator(semanticsLabel: 'Loading', size: context.dsIconSizes.lg);
```

**Instant brand and mode switches.** Turn off the theme animation in the
App Shell, so a switch shows the new brand in one frame.

```dart
// Before
MaterialApp(theme: DsTheme.light(), darkTheme: DsTheme.dark());

// After
MaterialApp(
  theme: DsTheme.light(brand: brand),
  darkTheme: DsTheme.dark(brand: brand),
  themeAnimationStyle: AnimationStyle.noAnimation,
);
```

**`DsBrand.standard`.** It still compiles with a deprecation warning.

```dart
// Before
DsTheme.light(brand: DsBrand.standard);

// After
DsTheme.light(brand: DsBrand.whiteLabel); // or DsTheme.light()
```

## 0.1.1

Moved to its own repository. No API or behavior change.

## 0.1.0

First interim release, delivered through Foundations.

- Primitive tokens: `DsPalette` (neutral, success, warning, and error
  scales), `DsSpacing` (4 · 8 · 12 · 16 · 24 · 32 · 48), and `DsRadius`
  (4 · 8 · 16 · pill).
- Semantic tokens as `ThemeExtension`s: `DsColors` and `DsTypography`, read
  with `context.dsColors` and `context.dsTypography`.
- One brand configuration, `DsBrand(primary, fontFamily)`, and the themes
  `DsTheme.light` and `DsTheme.dark` derived from it. Text roles reach at
  least 4.5:1 contrast, and the action color reaches at least 4.5:1 against
  the page, for any brand color.
- Atoms: `DsButton` (primary, secondary, and tertiary; loading; disabled),
  `DsTextField` (label, hint, helper, error, disabled), and
  `DsLoadingIndicator`.
- Molecules: `DsCard`, `DsListTile`, `DsInlineMessage` with `DsMessageTone`,
  and `DsEmptyState`.
- Template: `DsPageScaffold`.
- Every component is tested for tap targets, labels, and text contrast in
  both themes, and for layout at 200% text size on a 320-wide screen.

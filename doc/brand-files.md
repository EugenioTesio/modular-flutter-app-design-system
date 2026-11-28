# Brand files: a guide for designers

A brand file describes one brand: its colors, type scale, spacing, corner radii, border widths, state opacities, and icon sizes. The design system turns it into a brand, and every component then draws with it. No code changes are needed.

## The format

Brand files use the **W3C Design Tokens format** (version 2025.10), which design tools export directly:

- **Figma Variables**: export as Design Tokens (DTCG).
- **Tokens Studio**: use the DTCG format setting.

Start from [`widgetbook/brands/white_label.json`](../widgetbook/brands/white_label.json). It is the reference file: it holds every token a brand needs, with the white label's values.

## What a brand file must contain

Every token below is required. A file that misses one is rejected, and the report names it.

| Group | Token names | Type |
|-------|-------------|------|
| Brand color scale | `color.brand.50` … `color.brand.900` (10 steps) | `color` |
| Neutral scale | `color.neutral.0`, `color.neutral.50` … `color.neutral.900` (11 steps) | `color` |
| Status scales | `color.success`, `color.warning`, `color.error`, `color.info`, each with `100`, `500`, `700` | `color` |
| Type scale | `typography.display`, `headline`, `title`, `body`, `bodyStrong`, `label`, `caption` | `typography` |
| Spacing | `spacing.xxs`, `xs`, `sm`, `md`, `lg`, `xl`, `xxl` | `dimension` |
| Corner radius | `radius.sm`, `md`, `lg`, `pill` | `dimension` |
| Border widths | `borderWidth.thin`, `thick` | `dimension` |
| State opacities | `opacity.hovered`, `focused`, `pressed` (from 0 to 1) | `number` |
| Icon sizes | `iconSize.sm`, `md`, `lg` | `dimension` |

The file also names the brand, in the root `$extensions`:

```json
{
  "$extensions": {
    "com.github.eugeniotesio.design_system": {
      "id": "forest",
      "name": "Forest",
      "schemaVersion": 1
    }
  }
}
```

- `id`: lowercase letters, digits, and underscores. Keep it unique among the brands an app uses.
- `name`: the display name, shown in the Widgetbook's brand switcher.
- `schemaVersion`: the brand-schema version the file targets. This release accepts version **1**.

Other tokens in the file, such as shadows or extra colors, are ignored.

## Export settings that work

- **Colors**: export sRGB, or include the `hex` fallback. Colors in other color spaces without `hex` are rejected.
- **Sizes**: use `px`. `rem` also works and counts as 16 px.
- **Types**: set `$type` on each group, as the reference file does. A token with no type is rejected; types are never guessed.
- **References**: aliases such as `"{font.family.base}"` are fine, as are `$ref` pointers, `$extends`, and `$root`. A reference to something that doesn't exist, or a loop of references, is rejected.
- **Fonts**: name the family the app will bundle, such as `["Inter", "system-ui"]`. `system-ui` and `sans-serif` mean the platform font. A family the app doesn't bundle falls back to the platform font.

## Light and dark mode

A brand file holds one set of colors. The design system derives the light and dark looks from it: for example, actions use `color.brand.600` in light mode and `color.brand.300` in dark mode. Brand files can't override those roles. Pick scale steps that read well on light and on dark backgrounds.

## Previewing a brand

1. Drop the file into `widgetbook/brands/`.
2. Restart the Widgetbook (`cd widgetbook && flutter run -d macos`).
3. Pick the brand in the brand switcher, and look at every component in light and dark mode.

If the file has problems, the brand is left out of the switcher, and "Brand files" lists each problem with its token path, its type, and what to fix.

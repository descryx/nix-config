# Community Umbriel shaders

Selected runtime files from
[noctalia-dev/community-umbriel-shaders](https://github.com/noctalia-dev/community-umbriel-shaders)
at commit `3ae677854bb4fa309fd3bd9260a4a92a12a58920` (2026-11-24).

These four presets were chosen with the Noctalia Umbriel Shaders plugin. Only
their `effect.toml` and `shader.glsl` are vendored, plus the licence files they
reference. The rest of the upstream collection is not copied here.

| Preset | Directory | Licence |
| --- | --- | --- |
| `panel-glide` | `animation/panel-glide/` | MIT (Barrulus) |
| `arcane.smuggled-signal` | `animation/arcane-smuggled-signal/` | MIT (Barrulus) |
| `workspace-wipe` | `animation/workspace-wipe/` | MIT (Barrulus, Noctalia) |
| `tv-glitch` | `animation/tv-glitch/` | GPL-3.0-or-later |

`animation/tv-glitch` is ported from Simon Schneegans's Burn-My-Windows; see
`LICENSES/BurnMyWindows-GPL-3.0-or-later.txt`. The other notices are in
`LICENSES/`.

To change the selection, use the plugin again and transfer the generated
`noctalia-shaders.toml` selectors into `animation.toml`/`shaders.toml`, then
replace the vendored directories here. The plugin's own generated files are not
included in this configuration.

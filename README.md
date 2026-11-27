# Build a Nuraghe (prototype v0.1.0)

A phone game for public outreach: gather builders and ox teams, choose a quarry and hauling and lifting methods
(each tagged MODEL / DEMONSTRATED / HYPOTHESIS / WHAT-IF), ask neighbouring villages for help, and finish the nuraghe
before the seasons run out. Labour numbers and the help/trust rule come from the simulation (see DESIGN.md).
Prototype.

- `DESIGN.md`: rules, game variable -> model parameter table, every number with its source or "game rule", balance.

**Play:** open the game's web page on a phone (or computer) and, if you like, "Add to Home Screen" to install it. No data is collected and it works offline once loaded.

## Layout
```
project.godot, main.tscn, export_presets.cfg   Godot 4 project (GL Compatibility renderer, portrait)
scripts/numbers.gd      every constant (MODEL or GAME rule), the levels and the evidence tags
scripts/sim.gd          game state, daily step, help/trust rule, strategy record
scripts/main.gd         screens and touch UI (all text through tr())
scripts/site_view.gd    the drawn site: quarry, haul path, sledges, tower rising course by course
i18n/strings.csv        strings table: en, it (Italian is a draft)
icons/                  app / PWA icons
tools/                  scripts that derive the labour numbers from the simulation's config and build the strings
tests/                  headless balance run and phone-browser test
docs/                   the web (PWA) build served as the game's web page
```

## Build
Godot 4.7 (MIT): open `project.godot`, then Project > Export > Web (or Android). The web build in `docs/` was exported with the preset in `export_presets.cfg`.

## Credits
Site data: Nurnet. Based on an agent-based simulation of nuraghe construction (Repast4Py; Collier & Ozik 2022, WSC, doi:10.1109/WSC57314.2022.10015389). Engine: Godot (MIT). Assets and licences: `ASSETS.md`.

Prototype v0.1.0. Licence: to be set by the repository owner.

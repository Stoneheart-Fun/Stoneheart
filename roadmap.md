# Roadmap

## Goal

Build `Smart Local AI` into a safe, compatibility-first Stonehearth ACE mod that improves performance by reducing bad candidate selection before expensive global search and filtering paths dominate.

## Current Project Direction

- keep the mod focused on early candidate reduction
- prefer AI action and small patch integration over broad service replacement
- use local reference files in `game_files/` for research, not as part of the Git-tracked mod
- compare behavior against existing performance mods where useful, but avoid copying incompatible assumptions blindly

## Already In Place

- local settings file with radius, fallback, debug, and restock controls
- staged local search action for reachable entities by type
- fetch-style search flow with local, expanded, and fallback stages
- pickup-related action wiring that uses the local search action
- server-side restock director patch for disabling or throttling restock errands
- basic project structure for a standalone mod

## Next Priorities

1. Audit all currently overridden and aliased actions against live ACE references in `game_files/`.
2. Verify which hauling, fetching, and restock paths are already affected and which still use vanilla global search.
3. Add targeted debug logs that clearly show stage, candidate source, chosen entity, and fallback usage.
4. Validate whether the current restock approach should stay as throttle-only, remain optional, or be split into a separate module.
5. Inspect external performance-oriented mods in `game_files/` and extract safe ideas, especially around search reduction, task suppression, and compatibility patterns.
6. Build a repeatable in-game test checklist for near-vs-far item choice, storage access, and failure fallback.

## Planned Milestones

## Milestone 1: Stabilize Current Search Logic

- confirm the current local search action works reliably for common pickup and fetch paths
- remove dead paths, mismatched settings, or partially wired actions
- improve documentation so current behavior is obvious

## Milestone 2: Expand Safe Coverage

- extend local-first logic to more hauling and fetch scenarios
- evaluate whether stockpile and container searches need separate tuning
- keep fallback behavior intact in every path

## Milestone 3: Smarter Prioritization

- move from simple stage-only selection toward better distance-aware utility scoring
- prefer nearest practical item instead of just first acceptable item when safe
- keep result quality high without increasing scan cost too much

## Milestone 4: Performance Validation

- test with larger towns and item-heavy maps
- compare behavior with and without other performance mods
- identify cases where the mod reduces work and where it merely changes selection order

## Research Sources

- `game_files/stonehearth`
- `game_files/radiant`
- `game_files/stonehearth_ace`
- local reference mods added for performance study, if present in `game_files/`

## Non-Goals For Now

- rewriting core inventory service end-to-end
- rewriting core storage service end-to-end
- broad monkey-patching without narrow justification
- solving every AI or simulation performance issue in one mod

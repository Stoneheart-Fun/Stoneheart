# Changelog

## Unreleased

## Documentation

- rewrote `README.md` into a user-facing mod description instead of a technical task brief
- added `roadmap.md` to track project direction, priorities, and milestones
- added `changelog.md` to record current implementation state and future updates

## Repository Setup

- standardized the local reference directory as `game_files/`
- configured `game_files/` to stay local-only and out of Git tracking

## Implemented Mod Features

- added staged local search behavior through `smart_local_ai:find_best_local_reachable_entity_by_type`
- added radius-based search settings with local, expanded, and fallback stages
- added optional debug toggle in settings
- added pickup and fetch-related action overrides or replacements that use local-first search behavior
- added a server patch for restock errand suppression or throttling
- added a custom `rest_when_injured` override currently present in the manifest

## Current Settings Surface

- `local_radius`
- `expanded_radius`
- `global_fallback`
- `debug_enabled`
- `enable_for_hauling`
- `enable_for_fetching`
- `enable_for_restocking`
- `disable_restock_errands`
- `enable_restock_throttle`
- `max_concurrent_restock_errands`
- `restock_workers_per_errand`
- `min_concurrent_restock_errands`

## Known Gaps

- current coverage still needs precise validation against actual ACE call paths
- the effect of the restock-related logic should be reviewed separately from local item search
- external reference mods for performance comparison still need structured analysis

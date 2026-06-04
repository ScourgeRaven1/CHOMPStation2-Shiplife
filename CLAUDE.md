# Brood of Stars — Project Notes & Change Log

This is a CHOMPStation2 (Space Station 13 / BYOND) server fork. This file documents what
was changed and how the project is set up, so anyone (human or AI) can pick it up quickly.

## Goal
Run the **Stellar Delight** ship map — renamed **"Brood of Stars"** — as the active map.
It's a flyable overmap vessel (the whole ship flies) with planets/POIs to explore.
Owner ckey: **shadcat**.

## Build & run (IMPORTANT)
- Compiler: `C:\Program Files (x86)\BYOND\bin\dm.exe`. Build from repo root: `dm.exe vorestation.dme` (~30s).
- **Fully close the game (Dream Daemon + Dream Seeker) before compiling.** If it's running, `vorestation.rsc`
  is locked and the build fails with a *fake* error: `maps\offmap_vr\...\cruiser.dm:143: 'cruiser.dmi': cannot find file`.
  That error is ONLY the lock — close the game and it compiles clean.
- Persistence (material storage, graffiti, etc.) saves at **round end / reboot**, NOT on server stop.

## Git / updating from upstream
- This repo is a fork. `origin` = your fork; `upstream` = original CHOMPStation2.
- PortableGit at `C:\PortableGit\bin`. In PowerShell: `$env:PATH += ";C:\PortableGit\bin"`.
- To pull updates: `git fetch upstream` then `git merge upstream/master`, resolve conflicts.
- The "Group B" shared-file edits below are the most likely to conflict on update.

## Active map
- `modular_chomp/maps/~map_system/_map_selection.dm` — `USE_MAP_STELLAR_DELIGHT` enabled (Southern Cross commented out).
- Renamed to "Brood of Stars" in display only (internal id stays `stellar_delight`):
  `stellar_delight_defines.dm` (full_name/station_name/station_short) and the overmap ship marker in
  `maps/common/common_defines.dm` (`/obj/effect/overmap/visitable/ship/stellar_delight`).

## CHOMP compatibility shims — `maps/stellar_delight/stellar_delight_compat_ch.dm` (NEW, included from stellar_delight.dm)
Stellar Delight is an upstream map that drifted from CHOMP; this file fixes it:
- Stubs for 7 missing types so it compiles (hidden shuttle firedoor, fancy_shuttle/low wall,
  panic_button/small, ml3m medical briefcases, fancy_shuttle decorators).
- `sd_shuttle` fancy decorator self-deletes → the Starstuff boat hull walls render instead of going invisible.
- **Cargo shuttle** fix: `landmark_offsite = "supply_cc"` (CHOMP `common_shuttles.dm` had overridden it to the
  Southern Cross tag `supply_offsite`, breaking the Supply console).
- **Emergency/evac shuttle** fix: `shuttle_area = /area/shuttle/escape` + `landmark_offsite = "escape_cc"`
  (same kind of CHOMP override broke round-end evac).
- `stellar_delight.dm`: the `stellar_delight_events.dm` include is commented out (it duplicate-defined the
  event config that CHOMP provides in `modular_chomp/code/modules/event/event_container_ch.dm`).

## Map content changes — `maps/stellar_delight/stellar_delight1.dmm`, `2.dmm`, `3.dmm`
Goal: replace the old "bay"/"eris" art with Southern Cross sprites.
- **Walls:** bay steel + colored bay walls → SC steel (`/turf/simulated/wall`, `/wall/r_wall`). `stripe_color` vars stripped.
- **Floors:** eris floor set → SC tiled (white/dark/plain; `eris/dark/techfloor_grid` → `tiled/techfloor/grid`).
- **Wall machines:** angled_bay APCs / air alarms / fire alarms → standard SC types.
- **Windows:** bay windows (`window/bay` + `low_wall/bay`) → SC `/obj/effect/wingrille_spawn/reinforced` (137 tiles).
  Starstuff boat fancy windows → `window/reinforced/full`.
- **Starstuff boat hull:** fancy_shuttle walls → `r_wall`, then changed to **titanium** (`/turf/simulated/wall/titanium`).
- **Doors:** the whole `angled_bay` door set → SC airlocks, department-mapped from req_access
  (research/medical/security/engineering/command/mining; doubles → `multi_tile`; externals → `glass_external`;
  neutral → gray). `door_color`/`fill_color`/`fill_type` vars stripped.
  - Per-coordinate color corrections applied: science (8), medical (4), security (2), command (8).
  - **KNOWN ISSUE:** the `multi_tile` (double) doors orient opposite to the original `angled_bay/double`
    (their dir logic is inverted). A rotation fix (dir 1->4, 4->2, 2->8, 8->1; no-dir → 8) was applied so
    they sit correctly. The owner was verifying/hand-tuning doors, so some doors may have further manual edits.
    If a wide door still looks wrong, check its `dir` and the multi_tile vs angled_bay orientation.

## Gameplay tweaks (Group B — shared files; re-apply by hand on upstream merges)
- `code/modules/resleeving/autoresleever.dm` — resleeve wait: vore **2 min**, normal **10 min** (was 5/30).
- `code/modules/persistence/storage/smartfridge.dm` — `sheet_storage/lossy` retention **80%** (was 50%).
- `code/__defines/research.dm` — `TECHWEB_SINGLE_SERVER_INCOME` = **4.0**/sec (was 0.4).
- `maps/stellar_delight/stellar_delight_defines.dm` — Gateway destinations swapped to the Southern Cross set
  (snow field, madness lab, abandoned city, skyscraper, hidden eclipse). Also the display-name rename.
- `code/modules/overmap/sectors.dm` — added a hook in `/obj/effect/overmap/visitable/Initialize()` so maps
  that preset `overmap_z` (like this one) still spawn the dynamic POI generator. Without it, **zero overmap
  POIs spawned** (~39 spawn per round when working). POIs appear as "bluespace static" sensor contacts —
  the ship's sensors must be powered + in vacuum + ranged up to detect them.

## Whitelist
- `config/alienwhitelist.txt`: `species - shadcat - All` (whitelists shadcat for every whitelisted species).
  Format is `species - <ckey> - <SpeciesName>`; `All` is a wildcard. Config loads at round start (no compile needed).

## Possible follow-ups / not done
- Optional: show the emergency shuttle ETA on the in-game **Status tab** the instant it's called (currently it
  appears once the shuttle is in transit). Would edit `get_status_panel_eta()` in
  `code/controllers/emergency_shuttle_controller.dm` (shared code, affects all maps).
- Verify lateloaded planets/redgate/gateway destinations at runtime.

## Backups
In the older folder `CHOMPStation2-master`, the deck .dmm files have restore points:
`.bak` (pristine, pre-any-change), `.winbak` (pre-window), `.doorbak` (pre-door), `.floorbak` (pre-floor),
`.scibak`, `.titbak`.

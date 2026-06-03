// CHOMP compatibility shims for the Stellar Delight map.
//
// The upstream Stellar Delight .dmm files reference a handful of VOREStation object
// types that do not exist (under these paths) in CHOMPStation. We define them here as
// thin subtypes of their nearest CHOMP equivalent so the map compiles and loads.
// Appearances/contents can be refined later if desired.

// Hidden firedoor variant used on the shuttle decks.
/obj/machinery/door/firedoor/glass/hidden/shuttle

// "Low" fancy-shuttle hull wall variant (renders as standard fancy hull).
/turf/simulated/wall/fancy_shuttle/low

// Fancy-shuttle wall decorator for the Starstuff/sdboat shuttle.
// CHOMP has no "sdboat" hull artwork, so the split-art system left every one of the boat's
// hull walls blank (invisible in-game, present on right-click). We make this decorator
// self-delete instead of registering: with no art helper found, the boat's fancy_shuttle
// walls fall back to their built-in solid "hull" texture and become visible. This is keyed
// to the "sdboat" tag via the decorator, so ONLY the Starstuff shuttle is affected.
/obj/effect/fancy_shuttle/sd_shuttle
	fancy_shuttle_tag = "sd_shuttle"

/obj/effect/fancy_shuttle/sd_shuttle/Initialize(mapload)
	return INITIALIZE_HINT_QDEL

// Floor preview marker (self-deletes on init regardless).
/obj/effect/fancy_shuttle_floor_preview/sd_shuttle

// Small panic button variant.
/obj/structure/panic_button/small

// Medical briefcase packs (spawn as empty secure briefcases for now).
/obj/item/storage/secure/briefcase/ml3m_pack_med
/obj/item/storage/secure/briefcase/ml3m_pack_cmo

// --- Supply/cargo shuttle fix ---
// CHOMP's modular_chomp/maps/common/common_shuttles.dm overrides the cargo shuttle's
// landmark_offsite to the Southern Cross tag "supply_offsite". Stellar Delight's offsite
// supply depot landmark is tagged "supply_cc" (the engine/base default), so on this map the
// shuttle couldn't find its offsite dock -> Supply Control Console couldn't order or call it.
// This file compiles after common_shuttles.dm (only when Stellar Delight is the active map),
// so restoring the correct tag here fixes cargo without affecting other maps.
/datum/shuttle/autodock/ferry/supply/cargo
	landmark_offsite = "supply_cc"

// --- Emergency evacuation shuttle fix ---
// Same problem as cargo: common_shuttles.dm overrides the escape shuttle to Southern Cross
// values (shuttle_area = /area/shuttle/escape/centcom, landmark_offsite = "escape_offsite"),
// neither of which exist on Stellar Delight. The base/engine definition already matches this
// ship (/area/shuttle/escape + "escape_cc"), so we restore those here. Compiled after
// common_shuttles.dm, so only Stellar Delight is affected; round-end evac now works.
/datum/shuttle/autodock/ferry/emergency/escape
	shuttle_area = /area/shuttle/escape
	landmark_offsite = "escape_cc"

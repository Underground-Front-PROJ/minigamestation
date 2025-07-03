/obj/item/re13/ammo
	name = "PLACEHOLDER"
	desc = "PLACEHOLDER"
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "lizard_package"

	var/stored = 1
	var/used_by = "pistol"

/obj/item/re13/ammo/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/re13/ammo/process(seconds_per_tick)

	if(stored <= 0)
		qdel(src)

/obj/item/re13/ammo/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/re13/ammo))
		var/obj/item/re13/ammo/A = attacking_item
		if(A.used_by != used_by)
			balloon_alert(user, "[A] can't be combined with [src]!")
			return
		stored += A.stored
		A.stored = 0

/obj/item/re13/ammo/examine(mob/living/user)
	. = ..()
	. += span_info("[span_big("INSIDE:")]")
	. += span_info("[span_boldwarning("[stored]")] ammo for [span_boldwarning("[used_by]")]")

/obj/item/re13/medkit
	name = "PLACEHOLDER"
	desc = "PLACEHOLDER"
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "brutebox_f"

	var/heal_count = 3

/obj/structure/re13/ground_item/medkit
	name = "Medkit"
	desc = "For healing your wounds"
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "brutebox_f"

	stored_item = /obj/item/re13/medkit


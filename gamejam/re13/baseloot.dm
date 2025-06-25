/obj/structure/re13/lootcrates
	name = "PLACEHOLDER"
	desc = "PLACEHOLDER"
	icon = 'icons/obj/storage/crates.dmi'
	icon_state = "cargo_secure"
	var/list/possible_item = list(/obj/structure/re13/ground_item/pistol_ammo)
	var/chance_for_something = 50

	density = TRUE
	anchored = TRUE

/obj/structure/re13/lootcrates/proc/spawn_loot()
	if(prob(chance_for_something))
		var/item_to_spawn = pick(possible_item)
		new item_to_spawn(get_turf(src))

	spawn(5)
		qdel(src)

/obj/structure/re13/lootcrates/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()

	if(istype(attacking_item, /obj/item/knife/combat/survival/re13))
		spawn_loot()

/obj/structure/re13/ground_item
	name = "PLACEHOLDER"
	desc = "PLACEHOLDER"

	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "skeleton_key"

	density = FALSE
	anchored = TRUE

	var/stored_item = null

/obj/structure/re13/ground_item/Initialize(mapload)
	. = ..()

	make_shiny()

/obj/structure/re13/ground_item/proc/make_shiny()
	new /obj/effect/temp_visual/block(get_turf(src))
	spawn(2 SECONDS)
		make_shiny()

/obj/structure/re13/ground_item/attack_hand(mob/living/basic/re13_player/user, list/modifiers)
	if(isnull(stored_item))
		qdel(src)

	else
		new stored_item(get_turf(src))
		user.put_in_hands(stored_item, del_on_fail = FALSE)
		spawn(5)
			qdel(src)

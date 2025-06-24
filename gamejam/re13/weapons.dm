/obj/item/knife/combat/survival/re13
	name = "combat knife"
	desc = "A hunting grade survival knife."
	icon_state = "survivalknife"
	worn_icon_state = "survivalknife"
	embed_type = /datum/embedding/combat_knife/none
	force = 5
	throwforce = 5

	var/uses = 5

/datum/embedding/combat_knife/none
	embed_chance = 0

/obj/item/knife/combat/survival/re13/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)

	. = ..()
	if(istype(target_mob, /mob/living/basic/re13_enemy))
		var/mob/living/basic/re13_enemy/E = target_mob
		uses -= 1
		if(uses <= 0)
			qdel(src)
		E.current_hitpoints -= 1
		if(istype(user, /mob/living/basic/re13_player))
			var/mob/living/basic/re13_player/P = user
			if(P.stunned)
				P.stunned = FALSE
				P.remove_filter("re13_grab")
				P.remove_offsets(GRABBING_TRAIT)
				E.no_walk = TRUE
				E.no_walk_for -= 5
				E.current_hitpoints -= 2
				qdel(src)

/obj/item/knife/combat/survival/re13
	name = "combat knife"
	desc = "A hunting grade survival knife."
	icon_state = "buckknife"
	worn_icon_state = "buckknife"
	embed_type = /datum/embedding/combat_knife/none
	force = 5
	throwforce = 5

	var/uses = 5 // Нож - расходник. Его можно использовать для ломания коробок(бесплатно), или же для того, чтобы к примеру выбраться из вражеского захвата
	var/durability_indicator

/datum/embedding/combat_knife/none
	embed_chance = 0

/obj/item/knife/combat/survival/re13/Initialize(mapload)
	. = ..()

	var/mutable_appearance/durability_icon = mutable_appearance('gamejam/re13/effects.dmi', "durability_[uses]", SCREENTIP_LAYER, HUD_PLANE)
	durability_icon.pixel_y -= 18
	durability_indicator = durability_icon
	add_overlay(durability_indicator)


/obj/item/knife/combat/survival/re13/proc/reset_overlay()

	var/mutable_appearance/durability_icon = mutable_appearance('gamejam/re13/effects.dmi', "durability_[uses]", SCREENTIP_LAYER, HUD_PLANE)
	durability_icon.pixel_y -= 18
	durability_indicator = durability_icon
	add_overlay(durability_indicator)

/obj/item/knife/combat/survival/re13/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)

	. = ..()

	if(istype(target_mob, /mob/living/basic/re13_enemy))
		var/mob/living/basic/re13_enemy/E = target_mob
		uses -= 1

		cut_overlay(durability_indicator)
		reset_overlay()

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

// Код оружия спизжен с билда лоботомки

/obj/projectile/bullet/re13
	var/real_damage = 1

/obj/projectile/bullet/re13/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()

	if(istype(target, /mob/living/basic/re13_enemy))
		var/mob/living/basic/re13_enemy/E = target
		E.current_hitpoints -= real_damage

/obj/item/gun/re13
	var/obj/item/ammo_casing/ammo_type
	var/autofire
	var/shotsleft
	var/reloadtime
	var/is_reloading

	var/gun_category = "unknown"

/obj/item/gun/re13/Initialize()
	. = ..()
	chambered = new ammo_type(src)
	if(autofire)
		AddComponent(/datum/component/automatic_fire, autofire)

/obj/item/gun/re13/examine(mob/user)
	. = ..()
	if(reloadtime)
		. += "Ammo Counter: [shotsleft]/[initial(shotsleft)]."
	else
		. += "This weapon has unlimited ammo."

	if(reloadtime)
		switch(reloadtime)
			if(0 to 0.71 SECONDS)
				. += "<span class='notice'>This weapon has a very fast reload.</span>"
			if(0.71 SECONDS to 1.21 SECONDS)
				. += "<span class='notice'>This weapon has a fast reload.</span>"
			if(1.21 SECONDS to 1.71 SECONDS)
				. += "<span class='notice'>This weapon has a normal reload speed.</span>"
			if(1.71 SECONDS to 2.51 SECONDS)
				. += "<span class='notice'>This weapon has a slow reload.</span>"
			if(2.51 to INFINITY)
				. += "<span class='notice'>This weapon has an extremely slow reload.</span>"

	switch(weapon_weight)
		if(WEAPON_HEAVY)
			. += "<span class='notice'>This weapon requires both hands to fire.</span>"
		if(WEAPON_MEDIUM)
			. += "<span class='notice'>This weapon can be fired with one hand.</span>"
		if(WEAPON_LIGHT)
			. += "<span class='notice'>This weapon can be dual wielded.</span>"

	if(!autofire)
		switch(fire_delay)
			if(0 to 5)
				. += "<span class='notice'>This weapon fires fast.</span>"
			if(6 to 10)
				. += "<span class='notice'>This weapon fires at a normal speed.</span>"
			if(11 to 15)
				. += "<span class='notice'>This weapon fires slightly slower than usual.</span>"
			if(16 to 20)
				. += "<span class='notice'>This weapon fires slowly.</span>"
			else
				. += "<span class='notice'>This weapon fires extremely slowly.</span>"
	else
		//Give it to 'em in true rounds per minute, accurate to the 5s
		var/rpm = 600 / autofire
		rpm = round(rpm,5)
		. += "<span class='notice'>This weapon is automatic.</span>"
		. += "<span class='notice'>This weapon fires at [rpm] rounds per minute.</span>"

/obj/item/gun/re13/can_shoot()
	if(reloadtime)
		if(!shotsleft)
			playsound(src, dry_fire_sound, 30, TRUE)
			return FALSE
	if(is_reloading)
		return FALSE

	return TRUE

/obj/item/gun/re13/process_chamber()

	if(reloadtime && shotsleft)
		shotsleft-=1

	if(chambered && !chambered.loaded_projectile)
		recharge_newshot()

/obj/item/gun/re13/recharge_newshot()
	if(chambered)
		chambered.newshot()

/obj/item/gun/re13/before_firing(atom/target,mob/user)
	if(QDELETED(chambered))
		chambered = new ammo_type(src)
	return

/obj/item/gun/re13/shoot_with_empty_chamber(mob/living/user)
	before_firing(user = user)
	return ..()

/obj/item/gun/re13/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/re13/ammo/))
		var/obj/item/re13/ammo/A = attacking_item
		if(A.used_by != gun_category)
			balloon_alert(user, "[A] can't be loaded in [src]!")
			return
		if(reloadtime && !is_reloading)
			is_reloading = TRUE
			balloon_alert(user, "You start loading a new magazine.")
			playsound(src, 'sound/items/weapons/gun/general/bolt_drop.ogg', 50, TRUE)
			if(do_after(user, reloadtime, src, timed_action_flags = IGNORE_USER_LOC_CHANGE)) //gotta reload
				playsound(src, 'sound/items/weapons/gun/general/bolt_rack.ogg', 50, TRUE)
				var/need_to_refill = initial(shotsleft) - shotsleft
				if(A.stored < need_to_refill)
					shotsleft += A.stored
					A.stored = 0
					is_reloading = FALSE
					return
				else
					A.stored -= need_to_refill
					shotsleft += need_to_refill
					is_reloading = FALSE
					return

/obj/item/ammo_casing/re13/pistol
	name = "9mm bullet casing"
	desc = "A 9mm bullet casing."
	caliber = CALIBER_9MM
	projectile_type = /obj/projectile/bullet/re13/pistol
	newtonian_force = 0.75

/obj/projectile/bullet/re13/pistol
	name = "9mm bullet"

/obj/item/ammo_casing/re13/shotgun
	name = "12g bullet casing"
	desc = "A 12g bullet casing."
	caliber = CALIBER_SHOTGUN
	projectile_type = /obj/projectile/bullet/re13/shotgun
	pellets = 3
	variance = 15
	randomspread = TRUE
	newtonian_force = 0.75

/obj/projectile/bullet/re13/shotgun
	real_damage = 3

/obj/item/gun/re13/pistol
	name = "pistol"
	desc = "An simple spec-ops pistol."

	icon_state = "pistol_evil_fisher"

	weapon_weight = WEAPON_MEDIUM
	fire_delay = 1 SECONDS
	ammo_type = /obj/item/ammo_casing/re13/pistol
	autofire = FALSE
	shotsleft = 7
	reloadtime = 2 SECONDS
	gun_category = "pistol"

/obj/item/re13/ammo/pistol
	stored = 14
	used_by = "pistol"

/obj/structure/re13/ground_item/pistol_ammo
	name = "Ammo"
	desc = "Pistol ammo"

	icon = 'icons/obj/storage/box.dmi'
	icon_state = "lizard_package"

	stored_item = /obj/item/re13/ammo/pistol

/obj/item/gun/re13/shotgun
	name = "shotgun"
	desc = "An heavy-breach tactical shotgun."

	icon_state = "cshotgun"

	weapon_weight = WEAPON_HEAVY
	fire_delay = 2 SECONDS
	ammo_type = /obj/item/ammo_casing/re13/shotgun
	autofire = FALSE
	shotsleft = 4
	reloadtime = 4 SECONDS
	gun_category = "shotgun"

/obj/item/re13/ammo/shotgun
	stored = 12
	used_by = "shotgun"

/obj/structure/re13/ground_item/shotgun_ammo
	name = "Ammo"
	desc = "Shotgun ammo"

	icon = 'icons/obj/storage/box.dmi'
	icon_state = "lizard_package"

	stored_item = /obj/item/re13/ammo/shotgun

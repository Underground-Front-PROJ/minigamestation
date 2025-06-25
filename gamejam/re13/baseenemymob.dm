/**
 * Get a list of turfs in a line from `M` to `N`.
 *
 * Uses the ultra-fast [Bresenham Line-Drawing Algorithm](https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
 */
/proc/getline(atom/M,atom/N)
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs = abs(dx)//Absolute value of x distance
	var/dyabs = abs(dy)
	var/sdx = SIGN(dx)	//Sign of x distance (+ or -)
	var/sdy = SIGN(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

/mob/living/basic/re13_enemy
	name = "enemy"
	icon = 'gamejam/re13/zombie_s.dmi'
	icon_state = "standart"
	icon_living = "standart"
	icon_dead = "standart_dead"

	health = 900000 // Фейковое ХП
	maxHealth = 900000 // Фейковое ХП

	attack_sound = 'sound/effects/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_PUNCH
	combat_mode = TRUE

	melee_damage_lower = 1
	melee_damage_upper = 2
	melee_attack_cooldown = 20 SECONDS
	speed = 4

	attack_verb_continuous = "grabs"
	attack_verb_simple = "grab"

	var/current_hitpoints = 3

	var/no_walk_for = 10
	var/no_walk = FALSE

	var/hitpoints_indicator
	var/max_hitpoints = 3

	var/attack_cooldown
	var/attack_cooldown_time = 10 SECONDS
	var/attack_range = 2
	var/chances_for_success = 50

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0

	faction = list("re13_enemy")
	ai_controller = /datum/ai_controller/basic_controller/zombie/stupid

	var/strange_overlay

/obj/effect/temp_visual/security_holosign/lesser
	duration = 10

/mob/living/basic/re13_enemy/Initialize(mapload)
	. = ..()

	add_filter("strange_blur", 1, list("type" = "blur", "size" = 0.5))
	var/mutable_appearance/strange_icon = mutable_appearance('icons/effects/effects.dmi', "curse", ABOVE_MOB_LAYER)
	strange_overlay = strange_icon
	add_overlay(strange_overlay)

/mob/living/basic/re13_enemy/proc/actual_attack(target)
	if(attack_cooldown > world.time)
		return

	no_walk = TRUE
	attack_cooldown = world.time + attack_cooldown_time
	var/turf/slash_start = get_turf(src)
	var/turf/slash_end = get_ranged_target_turf_direct(slash_start, target, attack_range)
	var/list/hitline = getline(slash_start, slash_end)
	face_atom(target)
	for(var/turf/T in hitline)
		new /obj/effect/temp_visual/security_holosign/lesser(T)
	spawn(1 SECONDS)
		for(var/turf/T in hitline)
			new /obj/effect/temp_visual/kinetic_blast(T)
			for(var/mob/living/basic/re13_player/P in T)
				if(P.currently_blocking)
					new /obj/effect/temp_visual/block(get_turf(P))
					to_chat(P, span_userdanger("You parried the attack!"))
					if(P.stunned)
						P.stunned = FALSE
						P.remove_filter("re13_grab")
						P.remove_offsets(GRABBING_TRAIT)
				else
					to_chat(P, span_userdanger("[src] quickly bites you!"))
					P.current_hitpoints -= 1
					P.damage_recieved()

		playsound(src, attack_sound, 50, FALSE, 4)
		no_walk = FALSE // Слегка ускорим процесс выхода из стана

/mob/living/basic/re13_enemy/grab(mob/living/target)
	return FALSE

/mob/living/basic/re13_enemy/Move()
	if(no_walk)
		return FALSE
	. = ..()

/mob/living/basic/re13_enemy/Life()
	. = ..()

	if(current_hitpoints <= 0)
		cut_overlay(strange_overlay)
		death()

	if(prob(chances_for_success) && !(attack_cooldown > world.time) && stat != DEAD)
		for(var/mob/living/basic/re13_player/P in oview(2,src))
			if(P.stunned)
				var/actual_target = P
				actual_attack(actual_target)
				chances_for_success = initial(chances_for_success)
			else
				var/list/bite_targets = list()
				bite_targets += P
				var/actual_target = pick(bite_targets)
				actual_attack(actual_target)
				chances_for_success = initial(chances_for_success)

	if(no_walk)
		no_walk_for -= 1

	if(no_walk_for <= 0)
		no_walk = FALSE
		no_walk_for = initial(no_walk_for)

/mob/living/basic/re13_enemy/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(istype(target, /mob/living/basic/re13_player))
		var/mob/living/basic/re13_player/P = target
		no_walk = TRUE

		if(P.dir == NORTH)
			P.add_offsets(GRABBING_TRAIT, x_add = 0, y_add = GRAB_PIXEL_SHIFT_PASSIVE, animate = TRUE)
		if(P.dir == SOUTH)
			P.add_offsets(GRABBING_TRAIT, x_add = 0, y_add = -GRAB_PIXEL_SHIFT_PASSIVE, animate = TRUE)
		if(P.dir == EAST)
			P.add_offsets(GRABBING_TRAIT, x_add = GRAB_PIXEL_SHIFT_PASSIVE, y_add = 0, animate = TRUE)
		if(P.dir == WEST)
			P.add_offsets(GRABBING_TRAIT, x_add = -GRAB_PIXEL_SHIFT_PASSIVE, y_add = 0, animate = TRUE)

		P.add_filter("re13_grab", 2, list("type" = "outline", "color" = "#f130007a", "size" = 2))
		P.stunned_for = 8
		P.stunned = TRUE
		chances_for_success += 50

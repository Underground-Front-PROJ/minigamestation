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
	melee_attack_cooldown = 14 SECONDS
	speed = 4

	attack_verb_continuous = "grabs"
	attack_verb_simple = "grab"

	var/current_hitpoints = 3
	var/charged_for = 0 // Процент зарядки
	var/attack_at = 10 // Сколько необходимо

	var/no_walk_for = 10
	var/no_walk = FALSE

	var/after_attack_stun = 10 // Сколько мы спим после совершения настоящей атаки
	var/stunned = FALSE // Спим ли мы

	var/hitpoints_indicator
	var/max_hitpoints = 3

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0

	faction = list("re13_enemy")
	ai_controller = /datum/ai_controller/basic_controller/zombie/stupid

/mob/living/basic/re13_enemy/Move()
	if(no_walk)
		return FALSE
	. = ..()

/mob/living/basic/re13_enemy/Life()
	. = ..()

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

		P.stunned_for = 8
		P.stunned = TRUE

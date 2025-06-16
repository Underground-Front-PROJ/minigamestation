/mob/living/basic/re13_player
	name = "player"
	hud_type = /datum/hud/dextrous
	icon = 'gamejam/re13/operator.dmi'
	icon_state = "operator"
	icon_living = "operator"
	icon_dead = "operator_dead"

	health = 900000 // Фейковое ХП
	maxHealth = 900000 // Фейковое ХП

	var/current_hitpoints = 5 // Настоящее ХП
	var/current_infestation = 0
	var/current_stam = 3

	var/hitpoints_indicator
	var/stam_indicator

	var/max_hitpoints = 5 // Настоящее максимальное ХП
	var/max_infestation = 10 // Максимальное значение инфекции. Достигнув его - игрок гарантированно станет монстром
	var/max_stam = 3 // Максимальное значение применимой стамины. Используется для дэшей и прочих активностей

/mob/living/basic/re13_player/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP), ROUNDSTART_TRAIT)
	AddElement(/datum/element/dextrous, hud_type = hud_type, can_throw = TRUE)
	AddComponent(/datum/component/basic_inhands)

/mob/living/basic/re13_player/MouseEntered(location, control, params)
	var/mutable_appearance/health_icon = mutable_appearance('gamejam/re13/operator.dmi', "health[current_hitpoints]", SCREENTIP_LAYER)
	health_icon.pixel_y += 20
	hitpoints_indicator = health_icon

	var/mutable_appearance/stamina_icon = mutable_appearance('gamejam/re13/operator.dmi', "stamina[current_stam]", SCREENTIP_LAYER)
	stamina_icon.pixel_y -= 16
	stam_indicator = stamina_icon

	add_overlay(hitpoints_indicator)
	add_overlay(stam_indicator)

/mob/living/basic/re13_player/MouseExited(location, control, params)
	cut_overlay(hitpoints_indicator)
	cut_overlay(stam_indicator)

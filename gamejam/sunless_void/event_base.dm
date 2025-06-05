// Основа взята из анимации смерти боргов. Комментарии смотреть там

#define BASIC_EVENT(text) ("<font color='#d1824e'>" + text + "</font>")

/atom/movable/screen/sunvoid_event
	screen_loc = "CENTER"
	maptext_width = 300
	maptext_height = 1000
	maptext_y = 0

	VAR_PRIVATE/time_per_message = 2 SECONDS
	VAR_PRIVATE/list/messages = list(
		BASIC_EVENT("Тест Тест Тест"),
		BASIC_EVENT("Тест Тест Тест Тест.")
	)

/atom/movable/screen/sunvoid_event/Initialize(mapload, datum/hud/hud_owner)
	. = ..()

/atom/movable/screen/sunvoid_event/proc/run_animation()
	set waitfor = FALSE

	var/mob/living/basic/sunvoid_ship/ship = hud.mymob

	for(var/msg in messages)
		maptext += MAPTEXT_PIXELLARI(msg) + "<br>"
		maptext_y -= 14
		sleep(time_per_message)
		if(QDELETED(src))
			if(!QDELETED(ship))
				ship.clear_fullscreen(type)
			return

	sleep(0.5 SECONDS)
	if(QDELETED(src))
		if(!QDELETED(ship))
			ship.clear_fullscreen(type, 1.5 SECONDS)
		return

	invisibility = INVISIBILITY_ABSTRACT
	sleep(1.5 SECONDS)
	if(!QDELETED(ship))
		ship.clear_fullscreen(type)

#undef BASIC_EVENT

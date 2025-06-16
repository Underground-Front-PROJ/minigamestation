/mob/living/basic/sunvoid_ship
	name = "IPV 'Turtle'"
	desc = "Старый карговоз, явно видавший дни и получше."

	icon = 'gamejam/sunless_void/overmap.dmi'
	icon_state = "htu_cruiser"
	pressure_resistance = 200
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500

	speed = 2

	var/hull_health = 5 // Корабль окончательно погибает, если равняется нулю
	var/max_hull = 5

	var/pilot_health = 3 // Здоровье пилота корабля
	var/pilot_health_max = 3
	var/pilot_stamina = 4 // Стамина пилота корабля
	var/pilot_stamina_max = 4

	var/thrusters_fuel = 100 // Тратится по единице за движение. Когда достигает нуля - активирует режим "stranded_in_space",
	// в котором игроку остаётся надеяться на рандомные ивенты

	var/stranded_in_space = FALSE
	var/next_stranded_event = 60 // Время между ивентами потерянного в космосе

	var/next_random_event = 60 // Время до следующего случайного ивента во время полёта

	var/stop_movement = FALSE // Останавливает корабль, когда у нас разыгрывается ивент

	var/int_stat = 1 // Характеристика влияет на успех интеллектуального подхода
	var/imp_stat = 1 // Характеристика влияет на успех импровизированного подхода
	var/str_stat = 1 // Характеристика влияет на успех силового подхода

	var/stat_choice // Как мы решим текущую проблему?

	var/current_event = /obj/structure/sunvoid/event_controller

/mob/living/basic/sunvoid_ship/examine(mob/living/user)
	. = ..()
	. += span_info("[span_big("ХАРАКТЕРИСТИКИ КОРАБЛЯ:")]")
	. += span_info("|Корпус| - [span_boldnicegreen("[hull_health]/[max_hull]")]")
	. += span_info("|Топливо| - [span_boldnicegreen("[thrusters_fuel]")]")
	. += span_info("")
	. += span_info("[span_big("ХАРАКТЕРИСТИКИ ПИЛОТА:")]")
	. += span_info("|Здоровье| - [span_boldnicegreen("[pilot_health]/[pilot_health_max]")]")
	. += span_info("|Стамина| - [span_boldnicegreen("[pilot_stamina]/[pilot_stamina_max]")]")
	. += span_info("")
	. += span_info("|Интеллект| - [span_boldnicegreen("[int_stat]")]")
	. += span_info("|Импровизация| - [span_boldnicegreen("[imp_stat]")]")
	. += span_info("|Сила| - [span_boldnicegreen("[str_stat]")]")

/mob/living/basic/sunvoid_ship/Initialize(mapload, mob/tamer)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT) //Need to set before init cause if we init in hyperspace we get dragged before the trait can be added
	. = ..()
	add_traits(list(TRAIT_SPACEWALK), INNATE_TRAIT)

/mob/living/basic/sunvoid_ship/Move()
	if(stranded_in_space) // Мы не можем двигаться, если нет топлива
		return FALSE

	if(stop_movement)
		return FALSE

	. = ..()

	if(thrusters_fuel > 0) // Движение тратит топливо
		thrusters_fuel -= 1
	if(next_random_event > 0) // Движение перематывает время вперёд
		next_random_event -= 1

/mob/living/basic/sunvoid_ship/Life(seconds_per_tick, times_fired)
	. = ..()

	if(thrusters_fuel <= 0 && !stranded_in_space) // Ноль топлива - означает то что мы потерялись в космосе
		stranded_in_space = TRUE

	if(thrusters_fuel > 0 && stranded_in_space) // Если топливо пополнено и больше не равно нулю, то мы наконец снова в игре и не потеряны в космосе
		stranded_in_space = FALSE
		next_stranded_event = initial(next_stranded_event)

	if(stranded_in_space)
		next_stranded_event -= 1

	if(stranded_in_space && next_stranded_event <= 0) // Мы пикаем рандомный ивент каждые 60 тиков
		//pick_stranded_event() // Пока что этот прок отсутствует
		next_stranded_event = initial(next_stranded_event)

	if(next_random_event <= 0)
		stop_movement = TRUE
		pick_random_event()
		next_random_event = initial(next_random_event)

/mob/living/basic/sunvoid_ship/proc/att_choice(mob/living/basic/sunvoid_ship/user) // Выводится тогда, когда нам нужно выбрать определённый подход к решению возникшей ситуации
	var/list/att_list = list(
		"With INT" = image(icon = 'icons/hud/guardian.dmi', icon_state = "fuck"),
		"With IMP" = image(icon = 'icons/hud/guardian.dmi', icon_state = "fuck"),
		"With STR" = image(icon = 'icons/hud/guardian.dmi', icon_state = "fuck")
		)
	var/picked_att = show_radial_menu(user, src, att_list, radius = 48, require_near = TRUE)
	if(!picked_att)
		stat_choice = pick("INT", "IMP", "STR") // Не выбрали ничего - решит рандом
	switch(picked_att)
		if("With INT")
			stat_choice = "INT"
			return TRUE
		if("With IMP")
			stat_choice = "IMP"
			return TRUE
		if("With STR")
			stat_choice = "STR"
			return TRUE

/mob/living/basic/sunvoid_ship/proc/pick_random_event()
	current_event = pick(GLOB.random_sunvoid_events)
	new current_event(get_turf(src))

/obj/structure/sunvoid/overmap_sector
	name = "Basic sector"
	desc = "Should be filled with important info."

	icon = 'gamejam/sunless_void/overmap.dmi'
	icon_state = "field"


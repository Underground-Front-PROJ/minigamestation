GLOBAL_LIST_INIT(random_sunvoid_events, list(/obj/structure/sunvoid/event_controller/random_event/carps, /obj/structure/sunvoid/event_controller/random_event/escape_pod))

/obj/structure/sunvoid/event_controller
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "questionmark"
	invisibility = 50

/obj/structure/sunvoid/event_controller/Initialize(mapload)
	. = ..()
	run_event()

/obj/structure/sunvoid/event_controller/proc/run_event()
	for(var/mob/living/basic/sunvoid_ship/ship in get_turf(src))
		INVOKE_ASYNC(ship, TYPE_PROC_REF(/mob/living/basic/sunvoid_ship, att_choice), ship)
		qdel(src)

/obj/structure/sunvoid/event_controller/test1/run_event()
	for(var/mob/living/basic/sunvoid_ship/ship in get_turf(src))
		to_chat(ship, span_notice("Тест 1."))
		INVOKE_ASYNC(ship, TYPE_PROC_REF(/mob/living/basic/sunvoid_ship, att_choice), ship)
		qdel(src)

/obj/structure/sunvoid/event_controller/test2/run_event()
	for(var/mob/living/basic/sunvoid_ship/ship in get_turf(src))
		to_chat(ship, span_notice("Тест 2."))
		INVOKE_ASYNC(ship, TYPE_PROC_REF(/mob/living/basic/sunvoid_ship, att_choice), ship)
		qdel(src)

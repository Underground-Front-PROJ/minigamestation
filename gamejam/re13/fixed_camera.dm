/area/re13
	name = "RE13 base area"
	icon = 'icons/area/areas_misc.dmi'
	icon_state = "unknown"

	area_flags = VALID_TERRITORY | UNIQUE_AREA | CULT_PERMITTED | BLOCK_SUICIDE | EVENT_PROTECTED

	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY

/area/re13/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	if(istype(arrived, /mob/living/basic/re13_player))
		var/mob/living/basic/re13_player/enterer = arrived
		var/area/area = get_area(src)
		var/obj/structure/camera_controller/view_point = locate() in area
		if(view_point)
			enterer.client.set_eye(view_point)

/obj/structure/camera_controller
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "questionmark"
	invisibility = 50

/area/re13/test1
/area/re13/test2
/area/re13/test3

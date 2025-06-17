// KEYBINDS

/datum/keybinding/living/kick
	hotkey_keys = list("R")
	name = "kick"
	full_name = "Kick"
	description = "Kick close-range enemies in 1-tile radius"
	keybind_signal = COMSIG_KB_LIVING_KICK_DOWN

/datum/keybinding/living/kick/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	if(istype(living_mob, /mob/living/basic/re13_player))
		var/mob/living/basic/re13_player/P = living_mob
		P.combat_kick()
		return TRUE

/datum/keybinding/living/dash
	hotkey_keys = list("Space")
	name = "dash"
	full_name = "Dash"
	description = "Jump in the faced direction"
	keybind_signal = COMSIG_KB_LIVING_DASH_DOWN

/datum/keybinding/living/dash/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	if(istype(living_mob, /mob/living/basic/re13_player))
		var/mob/living/basic/re13_player/P = living_mob
		P.perform_dash()
		return TRUE

// HUD STUFF

/datum/hud/re13_player/New(mob/living/owner)
	..()
	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance()
	pull_icon.screen_loc = ui_drone_pull
	static_inventory += pull_icon

	build_hand_slots()

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_re13slot1
	inv_box.slot_id = ITEM_SLOT_RE13_STORAGE1
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_re13slot2
	inv_box.slot_id = ITEM_SLOT_RE13_STORAGE2
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_re13slot3
	inv_box.slot_id = ITEM_SLOT_RE13_STORAGE3
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_re13slot4
	inv_box.slot_id = ITEM_SLOT_RE13_STORAGE4
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_re13slot5
	inv_box.slot_id = ITEM_SLOT_RE13_STORAGE5
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_re13slot6
	inv_box.slot_id = ITEM_SLOT_RE13_STORAGE6
	static_inventory += inv_box

	using = new /atom/movable/screen/drop(null, src)
	using.icon = ui_style
	using.screen_loc = ui_swaphand_position(owner, 1)
	static_inventory += using

	using = new /atom/movable/screen/swap_hand(null, src)
	using.icon = ui_style
	using.icon_state = "act_swap"
	using.screen_loc = ui_swaphand_position(owner, 2)
	static_inventory += using

	action_intent = new /atom/movable/screen/combattoggle/flashy(null, src)
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_movi
	static_inventory += action_intent

	floor_change = new /atom/movable/screen/floor_changer(null, src)
	floor_change.icon = 'icons/hud/screen_midnight.dmi'
	static_inventory += floor_change

	if(HAS_TRAIT(owner, TRAIT_CAN_THROW_ITEMS))
		throw_icon = new /atom/movable/screen/throw_catch(null, src)
		throw_icon.icon = ui_style
		throw_icon.screen_loc = ui_drop_throw
		static_inventory += throw_icon

	zone_select = new /atom/movable/screen/zone_sel(null, src)
	zone_select.icon = ui_style
	zone_select.update_appearance()
	static_inventory += zone_select

	mymob.canon_client?.clear_screen()

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()

/datum/hud/re13_player/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/D = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in D.held_items)
			I.screen_loc = ui_hand_position(D.get_held_index_of_item(I))
			D.client.screen += I
	else
		for(var/obj/item/I in D.held_items)
			I.screen_loc = null
			D.client.screen -= I

/datum/element/re13_player

/datum/element/re13_player/Attach(datum/target, hands_count = 2, hud_type = /datum/hud/re13_player, can_throw = FALSE)
	. = ..()
	if (!isliving(target) || iscarbon(target))
		return ELEMENT_INCOMPATIBLE // Incompatible with the carbon typepath because that already has its own hand handling and doesn't need hand holding

	var/mob/living/mob_parent = target
	set_available_hands(mob_parent, hands_count)
	if(can_throw)
		ADD_TRAIT(target, TRAIT_CAN_THROW_ITEMS, REF(src)) // need to add before hud setup
	mob_parent.hud_type = hud_type
	if (mob_parent.hud_used)
		mob_parent.set_hud_used(new hud_type(target))
		mob_parent.hud_used.show_hud(mob_parent.hud_used.hud_version)
	ADD_TRAIT(target, TRAIT_CAN_HOLD_ITEMS, REF(src))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_hand_clicked))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))

/datum/element/re13_player/Detach(datum/source)
	. = ..()
	var/mob/living/mob_parent = source
	set_available_hands(mob_parent, initial(mob_parent.default_num_hands))
	var/initial_hud = initial(mob_parent.hud_type)
	mob_parent.hud_type = initial_hud
	if (mob_parent.hud_used)
		mob_parent.set_hud_used(new initial_hud(source))
		mob_parent.hud_used.show_hud(mob_parent.hud_used.hud_version)
	REMOVE_TRAIT(source, TRAIT_CAN_HOLD_ITEMS, REF(src))
	UnregisterSignal(source, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_UNARMED_ATTACK,
	))

/datum/element/re13_player/proc/set_available_hands(mob/living/hand_owner, hands_count)
	hand_owner.drop_all_held_items()
	var/held_items = list()
	for (var/i in 1 to hands_count)
		held_items += null
	hand_owner.held_items = held_items
	hand_owner.set_num_hands(hands_count)
	hand_owner.set_usable_hands(hands_count)

/datum/element/re13_player/proc/on_death(mob/living/died, gibbed)
	SIGNAL_HANDLER
	died.drop_all_held_items()

/datum/element/re13_player/proc/on_hand_clicked(mob/living/hand_haver, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if (!proximity && target.loc != hand_haver)
		var/obj/item/obj_item = target
		if (istype(obj_item) && !obj_item.atom_storage && !(obj_item.item_flags & IN_STORAGE))
			return NONE
	if (!isitem(target) && hand_haver.combat_mode)
		return NONE
	if (LAZYACCESS(modifiers, RIGHT_CLICK))
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attack_hand_secondary), hand_haver, modifiers)
	else
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attack_hand), hand_haver, modifiers)
	INVOKE_ASYNC(hand_haver, TYPE_PROC_REF(/mob, update_held_items))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Tell people what we are holding
/datum/element/re13_player/proc/on_examined(mob/living/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER
	for(var/obj/item/held_item in examined.held_items)
		if((held_item.item_flags & (ABSTRACT|HAND_ITEM)) || HAS_TRAIT(held_item, TRAIT_EXAMINE_SKIP))
			continue
		examine_list += span_info("[examined.p_They()] [examined.p_have()] [held_item.examine_title(user)] in [examined.p_their()] \
			[examined.get_held_index_name(examined.get_held_index_of_item(held_item))].")

// MOB STUFF

/mob/living/basic/re13_player
	name = "player"
	hud_type = /datum/hud/re13_player
	icon = 'gamejam/re13/operator.dmi'
	icon_state = "operator"
	icon_living = "operator"
	icon_dead = "operator_dead"

	health = 900000 // Фейковое ХП
	maxHealth = 900000 // Фейковое ХП

	var/current_hitpoints = 5 // Настоящее ХП
	var/current_infestation = 0

	var/current_stam = 3
	var/stam_regen = 10

	var/hitpoints_indicator
	var/stam_indicator

	var/max_hitpoints = 5 // Настоящее максимальное ХП
	var/max_infestation = 10 // Максимальное значение инфекции. Достигнув его - игрок гарантированно станет монстром
	var/max_stam = 3 // Максимальное значение применимой стамины. Используется для дэшей и прочих активностей

	var/stunned = FALSE
	var/stunned_for = 0

	combat_mode = TRUE

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0

	// Костыльная реализация инвентаря

	var/obj/item/internal_storage1
	var/obj/item/internal_storage2
	var/obj/item/internal_storage3
	var/obj/item/internal_storage4
	var/obj/item/internal_storage5
	var/obj/item/internal_storage6

/mob/living/basic/re13_player/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP), ROUNDSTART_TRAIT)
	AddElement(/datum/element/re13_player, hud_type = hud_type, can_throw = TRUE)
	AddComponent(/datum/component/basic_inhands)

/mob/living/basic/re13_player/Life()
	. = ..()

	if(current_stam < max_stam && !stunned)
		stam_regen -= 1

	if(stam_regen <= 0)
		current_stam += 1
		stam_regen = initial(stam_regen)

	if(stunned)

		var/mob/living/basic/re13_enemy/E = locate() in orange(1,src) // Проверяем, держат ли нас вообще

		if(stunned_for > 0)
			if(!E) // Если вокруг нас нет ни единого противника - мы моментально возвращаемся в игру
				stunned_for = 0
				stunned = FALSE
				remove_filter("re13_grab")
				remove_offsets(GRABBING_TRAIT)
			else
				stunned_for -= 1
		else
			stunned = FALSE
			remove_filter("re13_grab")
			remove_offsets(GRABBING_TRAIT)

/mob/living/basic/re13_player/grab(mob/living/target)
	return FALSE

/mob/living/basic/re13_player/Move()
	if(stunned)
		return FALSE
	. = ..()

/mob/living/basic/re13_player/MouseEntered(location, control, params)
	if(usr == src)
		var/mutable_appearance/health_icon = mutable_appearance('gamejam/re13/operator.dmi', "health[current_hitpoints]", SCREENTIP_LAYER, HUD_PLANE)
		health_icon.pixel_y += 20
		hitpoints_indicator = health_icon

		var/mutable_appearance/stamina_icon = mutable_appearance('gamejam/re13/operator.dmi', "stamina[current_stam]", SCREENTIP_LAYER, HUD_PLANE)
		stamina_icon.pixel_y -= 16
		stam_indicator = stamina_icon

		add_overlay(hitpoints_indicator)
		add_overlay(stam_indicator)

/mob/living/basic/re13_player/MouseExited(location, control, params)
	if(usr == src)
		cut_overlay(hitpoints_indicator)
		cut_overlay(stam_indicator)

/mob/living/basic/re13_player/proc/combat_kick()
	if(current_stam <= 0)
		return

	current_stam -= 1
	animate(src, pixel_y = 12, time = 0.8 SECONDS, easing = QUAD_EASING | EASE_OUT)
	animate(pixel_y = 0, time = 0.3 SECONDS, easing = QUAD_EASING | EASE_IN)
	spawn(1.2 SECONDS)
		spin(4, 1)

	for(var/mob/living/basic/re13_enemy/E in orange(1,src))

		if(E.no_walk)
			E.no_walk = FALSE
			E.no_walk_for = initial(E.no_walk_for)

		var/relative_direction = get_cardinal_dir(src, E)
		var/atom/throw_target = get_edge_target_turf(E, relative_direction)

		E.throw_at(throw_target, rand(3,6), 5, src, spin = TRUE)

/mob/living/basic/re13_player/proc/perform_dash()
	if(current_stam <= 0 || stunned)
		return

	current_stam -= 1

	var/relative_direction = dir
	var/atom/throw_target = get_edge_target_turf(src, relative_direction)
	throw_at(throw_target, 3, 1, src, spin = FALSE, gentle = TRUE)

// Код инвентаря

/mob/living/basic/re13_player/doUnEquip(obj/item/item_dropping, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(..())
		update_held_items()
		if(item_dropping == internal_storage1)
			internal_storage1 = null
			update_inv_internal_storage()
		if(item_dropping == internal_storage2)
			internal_storage2 = null
			update_inv_internal_storage()
		if(item_dropping == internal_storage3)
			internal_storage3 = null
			update_inv_internal_storage()
		if(item_dropping == internal_storage4)
			internal_storage4 = null
			update_inv_internal_storage()
		if(item_dropping == internal_storage5)
			internal_storage5 = null
			update_inv_internal_storage()
		if(item_dropping == internal_storage6)
			internal_storage6 = null
			update_inv_internal_storage()
		return TRUE
	return FALSE


/mob/living/basic/re13_player/can_equip(obj/item/item, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	switch(slot)
		if(ITEM_SLOT_RE13_STORAGE1)
			if(internal_storage1)
				return FALSE
			return TRUE
		if(ITEM_SLOT_RE13_STORAGE2)
			if(internal_storage2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_RE13_STORAGE3)
			if(internal_storage3)
				return FALSE
			return TRUE
		if(ITEM_SLOT_RE13_STORAGE4)
			if(internal_storage4)
				return FALSE
			return TRUE
		if(ITEM_SLOT_RE13_STORAGE5)
			if(internal_storage5)
				return FALSE
			return TRUE
		if(ITEM_SLOT_RE13_STORAGE6)
			if(internal_storage6)
				return FALSE
			return TRUE
	..()


/mob/living/basic/re13_player/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_RE13_STORAGE1)
			return internal_storage1
		if(ITEM_SLOT_RE13_STORAGE2)
			return internal_storage2
		if(ITEM_SLOT_RE13_STORAGE3)
			return internal_storage3
		if(ITEM_SLOT_RE13_STORAGE4)
			return internal_storage4
		if(ITEM_SLOT_RE13_STORAGE5)
			return internal_storage5
		if(ITEM_SLOT_RE13_STORAGE6)
			return internal_storage6

	return ..()

/mob/living/basic/re13_player/get_slot_by_item(obj/item/looking_for)
	if(internal_storage1 == looking_for)
		return ITEM_SLOT_RE13_STORAGE1
	if(internal_storage2 == looking_for)
		return ITEM_SLOT_RE13_STORAGE2
	if(internal_storage3 == looking_for)
		return ITEM_SLOT_RE13_STORAGE3
	if(internal_storage4 == looking_for)
		return ITEM_SLOT_RE13_STORAGE4
	if(internal_storage5 == looking_for)
		return ITEM_SLOT_RE13_STORAGE5
	if(internal_storage6 == looking_for)
		return ITEM_SLOT_RE13_STORAGE6
	return ..()

/mob/living/basic/re13_player/equip_to_slot(obj/item/equipping, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
	if(!slot)
		return
	if(!istype(equipping))
		return

	var/index = get_held_index_of_item(equipping)
	if(index)
		held_items[index] = null
	update_held_items()

	if(equipping.pulledby)
		equipping.pulledby.stop_pulling()

	equipping.screen_loc = null // will get moved if inventory is visible
	equipping.forceMove(src)
	SET_PLANE_EXPLICIT(equipping, ABOVE_HUD_PLANE, src)

	switch(slot)
		if(ITEM_SLOT_RE13_STORAGE1)
			internal_storage1 = equipping
			update_inv_internal_storage()
		if(ITEM_SLOT_RE13_STORAGE2)
			internal_storage2 = equipping
			update_inv_internal_storage()
		if(ITEM_SLOT_RE13_STORAGE3)
			internal_storage3 = equipping
			update_inv_internal_storage()
		if(ITEM_SLOT_RE13_STORAGE4)
			internal_storage4 = equipping
			update_inv_internal_storage()
		if(ITEM_SLOT_RE13_STORAGE5)
			internal_storage5 = equipping
			update_inv_internal_storage()
		if(ITEM_SLOT_RE13_STORAGE6)
			internal_storage6 = equipping
			update_inv_internal_storage()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
			return

	//Call back for item being equipped to drone
	equipping.on_equipped(src, slot)

/mob/living/basic/re13_player/proc/update_inv_internal_storage()
	if(internal_storage1 && client && hud_used?.hud_shown)
		internal_storage1.screen_loc = ui_re13slot1
		client.screen += internal_storage1
	if(internal_storage2 && client && hud_used?.hud_shown)
		internal_storage2.screen_loc = ui_re13slot2
		client.screen += internal_storage2
	if(internal_storage3 && client && hud_used?.hud_shown)
		internal_storage3.screen_loc = ui_re13slot3
		client.screen += internal_storage3
	if(internal_storage4 && client && hud_used?.hud_shown)
		internal_storage4.screen_loc = ui_re13slot4
		client.screen += internal_storage4
	if(internal_storage5 && client && hud_used?.hud_shown)
		internal_storage5.screen_loc = ui_re13slot5
		client.screen += internal_storage5
	if(internal_storage6 && client && hud_used?.hud_shown)
		internal_storage6.screen_loc = ui_re13slot6
		client.screen += internal_storage6

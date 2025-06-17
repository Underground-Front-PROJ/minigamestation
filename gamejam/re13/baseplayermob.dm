
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
	inv_box.name = "first pocket"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = ITEM_SLOT_LPOCKET
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "second pocket"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = ITEM_SLOT_RPOCKET
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "third pocket"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_storage3
	inv_box.slot_id = ITEM_SLOT_RPOCKET2
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "fourth pocket"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_storage4
	inv_box.slot_id = ITEM_SLOT_RPOCKET3
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "fifth pocket"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_storage5
	inv_box.slot_id = ITEM_SLOT_LPOCKET2
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "sixth pocket"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_storage6
	inv_box.slot_id = ITEM_SLOT_LPOCKET3
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

/mob/living/basic/re13_player/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP), ROUNDSTART_TRAIT)
	AddElement(/datum/element/re13_player, hud_type = hud_type, can_throw = TRUE)
	AddComponent(/datum/component/basic_inhands)

/mob/living/basic/re13_player/Life()
	. = ..()

	if(stunned)

		var/mob/living/basic/re13_enemy/E = locate() in orange(1,src) // Проверяем, держат ли нас вообще

		if(stunned_for > 0)
			if(!E) // Если вокруг нас нет ни единого противника - мы моментально возвращаемся в игру
				stunned_for = 0
				stunned = FALSE
			else
				stunned_for -= 1
		else
			stunned = FALSE

/mob/living/basic/re13_player/Move()
	if(stunned)
		return FALSE
	. = ..()

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

//Generic system for picking up mobs.
//Currently works for head and hands.
/obj/item/clothing/head/mob_holder
	name = "bugged mob"
	desc = ""
	icon = null
	icon_state = ""
	item_flags = DROPDEL
	var/mob/living/held_mob
	var/can_head = TRUE
	var/destroying = FALSE
	grid_width = 64
	grid_height = 96

/obj/item/clothing/head/mob_holder/Initialize(mapload, mob/living/M, _worn_state, head_icon, lh_icon, rh_icon, _can_head = TRUE)
	. = ..()
	can_head = _can_head
	if(head_icon)
		mob_overlay_icon = head_icon
	if(_worn_state)
		item_state = _worn_state
	if(lh_icon)
		lefthand_file = lh_icon
	if(rh_icon)
		righthand_file = rh_icon
	if(!can_head)
		slot_flags = NONE
	deposit(M)

/obj/item/clothing/head/mob_holder/Destroy()
	destroying = TRUE
	if(held_mob)
		release(FALSE)
	return ..()

/obj/item/clothing/head/mob_holder/proc/deposit(mob/living/L)
	if(!istype(L))
		return FALSE
	L.setDir(SOUTH)
	update_visuals(L)
	held_mob = L
	L.forceMove(src)
	name = L.name
	desc = L.desc
	return TRUE

/obj/item/clothing/head/mob_holder/proc/update_visuals(mob/living/L)
	appearance = L.appearance

/obj/item/clothing/head/mob_holder/proc/release(del_on_release = TRUE)
	if(!held_mob)
		if(del_on_release && !destroying)
			qdel(src)
		return FALSE
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_warning("[held_mob] wriggles free!"))
		L.dropItemToGround(src)
	held_mob.forceMove(get_turf(held_mob))
	held_mob.reset_perspective()
	held_mob.setDir(SOUTH)
	held_mob.visible_message(span_warning("[held_mob] uncurls!"))
	held_mob = null
	if(del_on_release && !destroying)
		qdel(src)
	return TRUE

/obj/item/clothing/head/mob_holder/relaymove(mob/user)
	release()

/obj/item/clothing/head/mob_holder/container_resist()
	release()

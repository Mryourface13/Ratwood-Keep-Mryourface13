/obj/item/rogueore
	name = "ore"
	icon = 'icons/roguetown/items/ore.dmi'
	icon_state = "ore"
	w_class = WEIGHT_CLASS_NORMAL
	grid_width = 32
	grid_height = 32

/obj/item/rogueore/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rogueweapon/tongs))
		if(!length(I.contents))
			forceMove(I)
			user.visible_message(span_warning("[user] picks up \the [name] with \the [I.name]"))
			I.update_icon()
	. = ..()
	

/obj/item/rogueore/gold
	name = "raw gold"
	desc = "A clump of dirty lustrous nuggets!"
	icon_state = "oregold1"
	smeltresult = /obj/item/ingot/gold
	grind_results = list(/datum/reagent/gold = 15)
	sellprice = 10

/obj/item/rogueore/gold/Initialize()
	icon_state = "oregold[rand(1,3)]"
	. = ..()


/obj/item/rogueore/silver
	name = "raw silver"
	desc = "A gleaming ore of moonlight hue."
	icon_state = "oresilv1"
	smeltresult = /obj/item/ingot/silver
	grind_results = list(/datum/reagent/silver = 15)
	sellprice = 8

/obj/item/rogueore/silver/Initialize()
	icon_state = "oresilv[rand(1,3)]"
	. = ..()


/obj/item/rogueore/iron
	name = "raw iron"
	desc = "A dark ore of rugged strength."
	icon_state = "oreiron1"
	smeltresult = /obj/item/ingot/iron
	grind_results = list(/datum/reagent/iron = 15)
	sellprice = 5

/obj/item/rogueore/iron/Initialize()
	icon_state = "oreiron[rand(1,3)]"
	. = ..()


/obj/item/rogueore/copper
	name = "raw copper"
	desc = "A burnished ore with reddish gleams."
	icon_state = "orecop1"
	smeltresult = /obj/item/ingot/copper
	grind_results = list(/datum/reagent/copper = 15)
	sellprice = 3

/obj/item/rogueore/copper/Initialize()
	icon_state = "orecop[rand(1,3)]"
	return ..()

/obj/item/rogueore/tin
	name = "raw tin"
	desc = "A mass of soft, almost malleable white ore."
	icon_state = "oretin1"
	smeltresult = /obj/item/ingot/tin
	sellprice = 4

/obj/item/rogueore/tin/Initialize()
	icon_state = "oretin[rand(1,3)]"
	..()

/obj/item/rogueore/coal
	name = "coal"
	desc = "Dark lumps that become smoldering embers later in life."
	icon_state = "orecoal1"
	firefuel = 30 MINUTES
	smeltresult = /obj/item/rogueore/coal
	grind_results = list(/datum/reagent/fuel/oil = 15)
	sellprice = 1

/obj/item/rogueore/coal/Initialize()
	icon_state = "orecoal[rand(1,3)]"
	return ..()

/obj/item/rogueore/cinnabar
	name = "cinnabar"
	desc = "Red gems that contain the essence of quicksilver."
	icon_state = "orecinnabar"
	grind_results = list(/datum/reagent/mercury = 15)
	sellprice = 5

/obj/item/ingot
	name = "ingot"
	icon = 'icons/roguetown/items/ore.dmi'
	icon_state = "ingot"
	w_class = WEIGHT_CLASS_NORMAL
	smeltresult = null
	var/ishot = FALSE
	var/datum/anvil_recipe/currecipe
	grid_width = 64
	grid_height = 32

/obj/item/ingot/proc/heat(value)
	ishot = TRUE
	addtimer(CALLBACK(src, PROC_REF(cool)), value)
	update_icon()

/obj/item/ingot/proc/cool()
	ishot = FALSE
	update_icon()

/obj/item/ingot/update_icon()
	. = ..()
	if(ishot)
		icon_state = "ingot_hot"
	else
		icon_state = initial(icon_state)
	
	var/obj/item/place = loc
	if(istype(place, /obj/item/rogueweapon/tongs) || istype(loc, /obj/machinery/anvil))
		place.update_icon()

/obj/item/ingot/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(ishot)
			var/index = H.active_hand_index
			var/bp = H.get_bodypart(BODY_ZONE_PRECISE_L_HAND)
			if(index == 2)
				bp = H.get_bodypart(BODY_ZONE_PRECISE_R_HAND)
			H.apply_damage(20, BRUTE, bp)
			H.emote("scream")
			H.Stun(20)
			H.visible_message(span_warn("[H.name] burns [user.p_their()] hand on the [name]!"))
			return
	. = ..()
	

/obj/item/ingot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rogueweapon/tongs))
		if(!length(I.contents))
			forceMove(I)
			I.update_icon()
	..()

/obj/item/ingot/Destroy()
	if(currecipe)
		QDEL_NULL(currecipe)
	if(istype(loc, /obj/machinery/anvil))
		var/obj/machinery/anvil/A = loc
		A.update_icon()
	return ..()

/obj/item/ingot/gold
	name = "gold bar"
	desc = "Solid wealth in your hands."
	icon_state = "ingotgold"
	smeltresult = /obj/item/ingot/gold
	grind_results = list(/datum/reagent/gold = 15)
	sellprice = 100

/obj/item/ingot/iron
	name = "iron bar"
	desc = "Forged strength. Essential for crafting."
	icon_state = "ingotiron"
	smeltresult = /obj/item/ingot/iron
	grind_results = list(/datum/reagent/iron = 15)
	sellprice = 20

/obj/item/ingot/copper
	name = "copper bar"
	desc = "This bar causes a gentle tingling sensation when touched."
	icon_state = "ingotcop"
	smeltresult = /obj/item/ingot/copper
	grind_results = list(/datum/reagent/copper = 15)
	sellprice = 20

/obj/item/ingot/tin
	name = "tin bar"
	desc = "An ingot of strangely soft and malleable essence."
	icon_state = "ingottin"
	smeltresult = /obj/item/ingot/tin
	sellprice = 20

/obj/item/ingot/bronze
	name = "bronze bar"
	desc = "A hard and durable alloy favored by engineers and followers of Malum alike."
	icon_state = "ingotbronze"
	smeltresult = /obj/item/ingot/bronze
	sellprice = 30

/obj/item/ingot/silver
	name = "silver bar"
	desc = "This bar radiates purity. Treasured by the realms."
	icon_state = "ingotsilv"
	smeltresult = /obj/item/ingot/silver
	grind_results = list(/datum/reagent/silver = 15)
	sellprice = 60
	
/obj/item/ingot/steel
	name = "steel bar"
	desc = "This ingot is a stalwart defender of the kingdom."
	icon_state = "ingotsteel"
	smeltresult = /obj/item/ingot/steel
	sellprice = 30

/obj/item/ingot/blacksteel
	name = "blacksteel bar"
	desc = "Sacrificing the holy elements of silver for raw strength, this strange and powerful ingot's origin carries dark rumors.."
	icon_state = "ingotblacksteel"
	smeltresult = /obj/item/ingot/blacksteel
	sellprice = 90

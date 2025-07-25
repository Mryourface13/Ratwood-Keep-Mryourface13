/* * * * * * * * * * * **
 *						*	-Cooking based on slapcrafting
 *		 NeuFood		*	-Uses defines to track nutrition
 *						*	-Meant to replace menu crafting completely for foods
 *						*
 * * * * * * * * * * * **/

/* For reference only
/*	........   Nutrition defines   ................ */

/*	ALREADY DEFINED, SEE code\__DEFINES\roguetown.dm

#define MEAL_FILLING 30
#define MEAL_GOOD 24
#define MEAL_AVERAGE 18
#define MEAL_MEAGRE 15
#define SNACK_NUTRITIOUS 9
#define SNACK_DECENT 6
#define SNACK_POOR 3

*/

/*	........   Rotting defines   ................ */
#define SHELFLIFE_EXTREME 270 MINUTES
#define SHELFLIFE_LONG 135 MINUTES
#define SHELFLIFE_DECENT 75 MINUTES
#define SHELFLIFE_SHORT 45 MINUTES
#define SHELFLIFE_TINY 30 MINUTES
*/


/*	........   Templates / Base items   ................ */
/obj/item/reagent_containers // added vars used in neu cooking, might be used for other things too in the future. How it works is in each items attackby code.
	var/short_cooktime = FALSE  // based on cooking skill
	var/long_cooktime = FALSE

/obj/item/reagent_containers/food/snacks/rogue // base food type, for icons and cooktime, and to make it work with processes like pie making
	icon = 'modular/Neu_Food/icons/food.dmi'
	desc = ""
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtype = GRAIN
	drop_sound = 'sound/foley/dropsound/gen_drop.ogg'
	cooktime = 30 SECONDS
	var/process_step // used for pie making and other similar modular foods

/obj/item/reagent_containers/food/snacks/rogue/Initialize()
	. = ..()
	eatverb = pick("bite","chew","nibble","gobble","chomp")
	
/obj/item/reagent_containers/food/snacks/rogue/foodbase // root item for uncooked food thats disgusting when raw
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	bitesize = 3
	eat_effect = /datum/status_effect/debuff/uncookedfood

/obj/item/reagent_containers/food/snacks/rogue/foodbase/New() // disables the random placement on creation for this object MAYBE OBSOLETE?
	..()
	pixel_x = 0
	pixel_y = 0

/obj/item/reagent_containers/food/snacks/rogue/preserved // just convenient way to group food with long rotprocess
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	rotprocess = SHELFLIFE_EXTREME

/obj/item/reagent_containers/food/snacks
	var/chopping_sound = FALSE // does it play a choppy sound when batch sliced?
	var/slice_sound = FALSE // does it play the slice sound when sliced?

/obj/effect/decal/cleanable/food/mess // decal applied when throwing minced meat for example
	name = "mess"
	desc = ""
	color = "#ab9d9d"
	icon_state = "tomato_floor1"
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")


// While I would usually call the parent procs food doesn't seem to benefit at all 
// I checked all the parent procs...There's nothing from what I can tell that matters
/*======
attackby
======*/
/obj/item/reagent_containers/food/snacks/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(!found_table)
		return //tables are needed for now.

	/* Special code for slicing because right now I don't want to deal with this
	   right now and it's already done in a way I can tolerate */
	if(user.used_intent.blade_class == slice_bclass && I.wlength == WLENGTH_SHORT)
		if(slice_bclass == BCLASS_CHOP)
			user.visible_message("<span class='notice'>[user] chops [src]!</span>")
			slice(I, user)
			return 1
		else if(slice(I, user))
			return 1

	//Otherwise we try to get an interaction
	var/obj/item/inactive = user.get_inactive_held_item()
	var/list/to_check = list(I, src) 
	if(inactive)
		to_check += inactive
	var/interaction_status = food_handle_interaction(src, user, to_check, FOOD_INTERACTION_ITEM)
	if(!interaction_status)
		..() //If we failed everything see what parent procs think.

/obj/item/reagent_containers/food/snacks/attack_hand(mob/user)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(!found_table)
		return ..()
	
	var/list/to_check = list(src) 
	var/interaction_status = food_handle_interaction(src, user, to_check, FOOD_INTERACTION_HAND)
	if(!interaction_status)
		..() //If we failed everything see what parent procs think.
	

/*	........   Kitchen tools / items   ................ */
/obj/item/kitchen/spoon
	name = "wooden spoon"
	desc = "Traditional utensil for shoveling soup into your mouth, or to churn butter with."
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	icon_state = "spoon"
	force = 0
	w_class = WEIGHT_CLASS_TINY

/obj/item/kitchen/ironspoon
	name = "iron spoon"
	desc = "Traditional utensil for shoveling soup into your mouth, now made with iron for that metallic taste!"
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	icon_state = "spoon_iron"
	force = 0
	w_class = WEIGHT_CLASS_TINY

/obj/item/kitchen/ironspoon/pewter
	name = "pewter spoon"
	desc = "Traditional utensil for shoveling soup into your mouth, made from Pewter alloy for fancyness."
	icon_state = "spoon_pewter"
	sellprice = 10

/obj/item/kitchen/ironspoon/silver
	name = "silver spoon"
	desc = "Traditional utensil for shoveling soup into your mouth. There are tales of noblemen growing up with these in their mouths."
	icon_state = "spoon_silver"
	sellprice = 30
	var/last_used = 0

/obj/item/kitchen/fork
	name = "wooden fork"
	desc = "Traditional utensil for stabbing your food in order to shove it into your mouth."
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	icon_state = "fork"
	force = 0
	w_class = WEIGHT_CLASS_TINY

/obj/item/kitchen/ironfork
	name = "iron fork"
	desc = "Traditional utensil for stabbing your food, now made with iron for extra stabbiness!"
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	icon_state = "fork_iron"
	force = 0
	w_class = WEIGHT_CLASS_TINY

/obj/item/kitchen/ironfork/pewter
	name = "pewter fork"
	desc = "Traditional utensil for stabbing your food, this one looks fancy!"
	icon_state = "fork_pewter"
	sellprice = 10

/obj/item/kitchen/ironfork/silver
	name = "silver fork"
	desc = "Traditional utensil for stabbing your food. The opposite of a silver spoon?"
	icon_state = "fork_silver"
	sellprice = 30
	var/last_used = 0

/obj/item/kitchen/rollingpin
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	experimental_inhand = FALSE

/obj/item/rogueweapon/huntingknife/cleaver
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	item_state = "cleav"
	experimental_inhand = FALSE
	experimental_onhip = FALSE
	experimental_onback = FALSE

/obj/item/reagent_containers/glass/bowl
	name = "wooden bowl"
	desc = "It is the empty space that makes the bowl useful."
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	icon_state = "bowl"
	force = 5
	throwforce = 5
	reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 7
	possible_transfer_amounts = list(7)
	dropshrink = 0.8
	w_class = WEIGHT_CLASS_NORMAL
	volume = 33
	obj_flags = CAN_BE_HIT
	sellprice = 1
	drinksounds = list('sound/items/drink_cup (1).ogg','sound/items/drink_cup (2).ogg','sound/items/drink_cup (3).ogg','sound/items/drink_cup (4).ogg','sound/items/drink_cup (5).ogg')
	fillsounds = list('sound/items/fillcup.ogg')
	var/in_use // so you can't spam eating with spoon

/obj/item/reagent_containers/glass/bowl/iron
	icon_state = "bowl_iron"

/obj/item/reagent_containers/glass/bowl/silver
	name = "silver bowl"
	desc = "It is the empty space that makes the bowl useful. Made with fancy silver!"
	icon_state = "bowl_silver"
	sellprice = 30
	var/last_used = 0

/obj/item/reagent_containers/glass/bowl/pewter
	name = "pewter bowl"
	desc = "It is the empty space that makes the bowl useful. Decorated and made with pewter!"
	icon_state = "bowl_pewter"
	sellprice = 10

/obj/item/reagent_containers/glass/bowl/update_icon()
	cut_overlays()
	icon_state = "bowl" //reset this every time I guess.
	if(reagents)
		if(reagents.total_volume > 0) 
			if(reagents.total_volume <= 11) 
				var/mutable_appearance/filling = mutable_appearance('modular/Neu_Food/icons/cooking.dmi', "bowl_low")
				filling.color = mix_color_from_reagents(reagents.reagent_list)
				add_overlay(filling)
		if(reagents.total_volume > 11) 
			if(reagents.total_volume <= 22) 
				var/mutable_appearance/filling = mutable_appearance('modular/Neu_Food/icons/cooking.dmi', "bowl_half")
				filling.color = mix_color_from_reagents(reagents.reagent_list)
				add_overlay(filling)
		if(reagents.total_volume > 22) 
			if(reagents.has_reagent(/datum/reagent/consumable/soup/oatmeal, 10)) 
				var/mutable_appearance/filling = mutable_appearance('modular/Neu_Food/icons/cooking.dmi', "bowl_oatmeal")
				filling.color = mix_color_from_reagents(reagents.reagent_list)
				add_overlay(filling)
			if(reagents.has_reagent(/datum/reagent/consumable/soup/veggie/cabbage, 17) || reagents.has_reagent(/datum/reagent/consumable/soup/veggie/onion, 17) || reagents.has_reagent(/datum/reagent/consumable/soup/veggie/onion, 17))
				var/mutable_appearance/filling = mutable_appearance('modular/Neu_Food/icons/cooking.dmi', "bowl_full")
				filling.color = mix_color_from_reagents(reagents.reagent_list)
				icon_state = "bowl_steam"
				add_overlay(filling)
			if(reagents.has_reagent(/datum/reagent/consumable/soup/stew/chicken, 17) || reagents.has_reagent(/datum/reagent/consumable/soup/stew/meat, 17) || reagents.has_reagent(/datum/reagent/consumable/soup/stew/fish, 17))
				var/mutable_appearance/filling = mutable_appearance('modular/Neu_Food/icons/cooking.dmi', "bowl_stew")
				filling.color = mix_color_from_reagents(reagents.reagent_list)
				icon_state = "bowl_steam"
				add_overlay(filling)
			else 
				var/mutable_appearance/filling = mutable_appearance('modular/Neu_Food/icons/cooking.dmi', "bowl_full")
				filling.color = mix_color_from_reagents(reagents.reagent_list)
				add_overlay(filling)
	else
		icon_state = "bowl"

/obj/item/reagent_containers/glass/bowl/on_reagent_change(changetype)
	..()
	update_icon()

/obj/item/reagent_containers/glass/bowl/attackby(obj/item/I, mob/living/user, params) // lets you eat with a spoon from a bowl
	if(istype(I, /obj/item/kitchen/spoon))
		if(reagents.total_volume > 0)
			beingeaten()
			playsound(src,'sound/misc/eat.ogg', rand(30,60), TRUE)
			visible_message("<span class='info'>[user] eats from [src].</span>")
			if(do_after(user,1 SECONDS, target = src))
				addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, trans_to), user, min(amount_per_transfer_from_this,5), TRUE, TRUE, FALSE, user, FALSE, INGEST), 5)
		return TRUE
				
/obj/item/reagent_containers/glass/bowl/proc/beingeaten()
	in_use = TRUE
	sleep(10)
	in_use = FALSE

/obj/item/reagent_containers/glass/cup
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	experimental_inhand = FALSE

/obj/item/reagent_containers/glass/cup/pewter
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	experimental_inhand = FALSE

/obj/item/cooking/pan
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	experimental_inhand = FALSE

/obj/item/reagent_containers/peppermill // new with some animated art
	name = "pepper mill"
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	icon_state = "peppermill"
	layer = CLOSED_BLASTDOOR_LAYER // obj layer + a little, small obj layering above convenient
	drop_sound = 'sound/foley/dropsound/gen_drop.ogg'
	list_reagents = list(/datum/reagent/consumable/blackpepper = 5)
	reagent_flags = TRANSPARENT

/obj/item/cooking/platter
	name = "platter"
	desc = "Made from fired clay."
	icon = 'modular/Neu_Food/icons/cooking.dmi'
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	icon_state = "platter"
	resistance_flags = NONE
	drop_sound = 'sound/foley/dropsound/gen_drop.ogg'
	experimental_inhand = FALSE
	grid_width = 32
	grid_height = 32
	var/datum/platter_sprites/sprite_choice = new /datum/platter_sprites/

/obj/item/cooking/platter/pewter
	name = "pewter platter"
	desc = "Made from an alloy of tin and mercury. Rolls off the tongue quite nicely."
	icon_state = "p_platter"
	sellprice = 10

/obj/item/cooking/platter/silver
	name = "silver platter"
	desc = "Made from polished silver. Fancy!"
	icon_state = "s_platter"
	sellprice = 30
	var/last_used = 0

/obj/item/book/rogue/yeoldecookingmanual // new book with some tips to learn
	name = "Ye olde ways of cookinge"
	desc = "Penned by Svend Fatbeard, butler in the fourth generation"
	icon_state ="book8_0"
	base_icon_state = "book8"
	bookfile = "Neu_cooking.json"

/obj/item/storage/foodbag
	name = "food pouch"
	desc = "A small pouch for carrying handfuls of food items."
	icon_state = "sack_rope"
	item_state = "sack_rope"
	icon = 'icons/roguetown/items/misc.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_HIP
	resistance_flags = NONE
	max_integrity = 300

/obj/item/storage/foodbag/examine(mob/user)
	. = ..()
	var/amount = length(contents)
	if(amount)
		. += span_notice("[amount] thing\s in the sack.")

/obj/item/storage/foodbag/attack_right(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	testing("yea144")
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	var/list/things = STR.contents()
	if(things.len)
		testing("yea64")
		var/obj/item/I = pick(things)
		STR.remove_from_storage(I, get_turf(user))
		user.put_in_hands(I)

/obj/item/storage/foodbag/update_icon()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	var/list/things = STR.contents()
	if(things.len)
		icon_state = "sack_rope"
		w_class = WEIGHT_CLASS_NORMAL
	else
		icon_state = "sack_rope"
		w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/foodbag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 20
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_items = 5
	STR.set_holdable(list(
		/obj/item/reagent_containers/food/snacks/rogue/berrycandy,
		/obj/item/reagent_containers/food/snacks/rogue/applecandy,
		/obj/item/reagent_containers/food/snacks/rogue/raisins,
		/obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw/cooked
		))
	STR.click_gather = TRUE
	STR.attack_hand_interact = FALSE
	STR.collection_mode = COLLECT_EVERYTHING
	STR.dump_time = 0
	STR.allow_quick_gather = TRUE
	STR.allow_quick_empty = TRUE
	STR.allow_look_inside = FALSE
	STR.allow_dump_out = TRUE
	STR.display_numerical_stacking = TRUE


/* * * * * * * * * * * * * * *	*
 *								*
 *		Reagents     			*
 *					 			*
 *								*
 * * * * * * * * * * * * * * * 	*/

/// These are for the pot, if more vegetables are added and need to be integrated into the pot brewing you need to add them here
/datum/reagent/consumable/soup // so you get hydrated without the flavor system messing it up. Works like water with less hydration
	var/hydration = 6
/datum/reagent/consumable/soup/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NOHUNGER))
			H.adjust_hydration(hydration)
		if(M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume = min(M.blood_volume+10, BLOOD_VOLUME_NORMAL)
	..()

/datum/reagent/consumable/soup/oatmeal
	name = "oatmeal"
	description = "Fitting for a peasant."
	reagent_state = LIQUID
	color = "#c38553"
	nutriment_factor = 7
	metabolization_rate = 0.5 // half as fast as normal, last twice as long
	taste_description = "oatmeal"
	taste_mult = 5
	hydration = 2

/datum/reagent/consumable/soup/porridge
	name = "porridge"
	description = "Fitting for a peasant."
	reagent_state = LIQUID
	color = "#ddd190"
	nutriment_factor = 7
	metabolization_rate = 0.5 // half as fast as normal, last twice as long
	taste_description = "oatmeal"
	taste_mult = 5
	hydration = 2


/datum/reagent/consumable/soup/veggie
	name = "vegetable soup"
	description = ""
	reagent_state = LIQUID
	nutriment_factor = 5
	taste_mult = 6
	hydration = 8

/datum/reagent/consumable/soup/veggie/potato
	color = "#869256"
	taste_description = "potato broth"

/datum/reagent/consumable/soup/veggie/onion
	color = "#a6b457"
	taste_description = "boiled onions"

/datum/reagent/consumable/soup/veggie/cabbage
	color = "#859e56"
	taste_description = "watery cabbage"

/datum/reagent/consumable/soup/veggie/beet
	color = "#8E3A59"
	taste_description = "watery beets"

/datum/reagent/consumable/soup/stew
	name = "thick stew"
	description = "All manners of edible bits went into this."
	reagent_state = LIQUID
	nutriment_factor = 10
	taste_mult = 8

/datum/reagent/consumable/soup/stew/chicken
	color = "#baa21c"
	taste_description = "chicken"

/datum/reagent/consumable/soup/stew/meat
	color = "#80432a"
	taste_description = "meat stew"

/datum/reagent/consumable/soup/stew/fish
	color = "#c7816e"
	taste_description = "fish"

/datum/reagent/consumable/soup/stew/yucky
	color = "#9e559c"
	taste_description = "something rancid"


/* * * * * * * * * * * * * * *	*
 *								*
 *		Powder & Salt			*
 *					 			*
 *								*
 * * * * * * * * * * * * * * * 	*/

// -------------- POWDER (flour) -----------------
/obj/item/reagent_containers/powder/flour
	name = "powder"
	desc = "With this ambition, we build an empire."
	gender = PLURAL
	icon_state = "flour"
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1
	sellprice = 0
	var/water_added
/obj/item/reagent_containers/powder/flour/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	new /obj/effect/decal/cleanable/food/flour(get_turf(src))
	..()
	qdel(src)

/obj/item/reagent_containers/powder/flour/attackby(obj/item/I, mob/living/user, params)
	//Otherwise we try to get an interaction
	var/obj/item/inactive = user.get_inactive_held_item()
	var/list/to_check = list(I, src) 
	if(inactive)
		to_check += inactive
	var/interaction_status = food_handle_interaction(src, user, to_check, FOOD_INTERACTION_ITEM)
	if(!interaction_status)
		..() //If we failed everything see what parent procs think.

/obj/item/reagent_containers/powder/flour/attack_hand(mob/living/user)
	var/found_table = locate(/obj/structure/table) in (loc)
	if(!found_table)
		return ..()

	var/list/to_check = list(src) 
	var/interaction_status = food_handle_interaction(src, user, to_check, FOOD_INTERACTION_HAND)
	if(!interaction_status)
		..() //If we failed everything see what parent procs think.

// -------------- SALT -----------------
/obj/item/reagent_containers/powder/salt
	name = "salt"
	desc = ""
	gender = PLURAL
	icon_state = "salt"
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1
	sellprice = 0

/obj/item/reagent_containers/powder/salt/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	new /obj/effect/decal/cleanable/food/flour(get_turf(src))
	..()
	qdel(src)

/*	..................   Food platter   ................... */
/*
NEW SYSTEM
What it does:
	- [X] The platter stays intact, adds object on top of it. 
	- [X] Examining the platter tells you what is on the platter
	- [X] Adds food overlay to the platre
	- [X] Can remove item with right click
	- [X] using it will eat the food on it
	- Add 'smash' option to hit people with platters?
		- If so does the food fly off it?
	- [TO DO] Falling with / throwing a platter should make the food fall off?
	- [X] Use initial[name] to revert platter back to being its original name once the food is removed
*/

// food paths as keys and the platter sprite they use
// These are listed in the food.dmi (I don't want to have to add icon logic too... just keep it all in food.dmi...)
// You can name them whatever you want I just did _platter to help distinguish from _plated which uses full sprites
// Keep the list alphabetical if you add to it.
/datum/platter_sprites/
	var/list/check_sprite = list(
		/obj/item/reagent_containers/food/snacks/rogue/bun_grenz = "grenzbun_platter",
		/obj/item/reagent_containers/food/snacks/rogue/friedegg/tiberian = "omelette_platter",
		/obj/item/reagent_containers/food/snacks/rogue/frybirdtato = "frybirdtato_platter",
		/obj/item/reagent_containers/food/snacks/rogue/friedrat = "cookedrat_platter",
		/obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked = "roastchicken_platter",
		/obj/item/reagent_containers/food/snacks/rogue/peppersteak = "peppersteak_platter",
		/obj/item/reagent_containers/food/snacks/rogue/wienercabbage = "wienercabbage_platter",
		/obj/item/reagent_containers/food/snacks/rogue/wienerpotato = "wienerpotato_platter",
		/obj/item/reagent_containers/food/snacks/rogue/wienerpotatonions = "wpotonion_platter",
	)


/obj/item/cooking/platter/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/kitchen/fork) || istype(I, /obj/item/kitchen/ironfork))
		if(do_after(user, 0.5 SECONDS))
			attack(user, user, user.zone_selected)
			return TRUE

	var/found_table = locate(/obj/structure/table) in get_turf(src)
	if(istype(I, /obj/item/reagent_containers/food/snacks))
		if(isturf(loc) && found_table)
			var/obj/item/first_item = locate() in src
			if (first_item)
				to_chat(user, span_info("Something is already on this [initial(name)]! Remove it first."))
				return TRUE
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user, 2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.4)
				to_chat(user, span_info("I add \the [I] to \the [src]."))
				I.forceMove(src)
				update_icon()
			return TRUE
	return ..()	


/obj/item/cooking/platter/attack(mob/living/M, mob/living/user, def_zone)
	if(user.used_intent.type == INTENT_HARM)
		return ..()
	var/obj/item/first_item = locate() in src
	if(first_item)
		first_item.attack(M,user,def_zone)
		update_icon()


/obj/item/cooking/platter/update_icon()
	var/obj/item/first_item = locate() in src
	if(first_item)
		var/i
		var/has_sprite = FALSE
		// Checks the datum list for any sprite states.
		for(i = 1, i <= sprite_choice.check_sprite.len, i++ )
			if(sprite_choice.check_sprite[i] == first_item.type) //Does this have to use type? Not sure but it works.
				first_item.icon_state = sprite_choice.check_sprite[first_item.type]
				has_sprite = TRUE
				break

		if (!has_sprite) // If we don't have a platter sprite shrink sprite down and move it up a bit on the platter
			var/matrix/M = new
			M.Scale(0.8,0.8)
			first_item.transform = M
			first_item.pixel_y = 3

		first_item.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
		vis_contents += first_item
		name = "platter of [first_item.name]"
		desc = first_item.desc
		// Sometimes food that's been eaten produces an item, so we have to typecast
		if(istype(first_item,  /obj/item/reagent_containers/food/snacks))
			var/obj/item/reagent_containers/food/snacks/first_snack = first_item
			//Need something better than this in future like a buff
			//NOTE: This may actually lower the bonus reagents of some foods, but
			//I'm not sure this even works currently? Won't this only work if it hasn't been cooked yet?
			first_snack.bonus_reagents = list(/datum/reagent/consumable/nutriment = 2)
	else
		vis_contents.Cut()
		name = initial(name)
		desc = initial(desc)


/obj/item/cooking/platter/attack_right(mob/user)
	if(user.get_active_held_item())
		to_chat(user, span_info("I can't do that with my hand full!"))
		return

	var/obj/item/first_item = locate() in src
	if(first_item)
		if(do_after(user, 2 SECONDS, target = src))
			first_item.vis_flags = 0
			//No need to change scale since and pixel_y I think all food already resets that when you grab it
			first_item.icon_state = initial(first_item.icon_state)
			//sometimes food puts an item in its place!!
			if(istype(first_item, /obj/item/reagent_containers/food/snacks))
				var/obj/item/reagent_containers/food/snacks/first_snack = first_item
				// Does this even do anything if the food's been cooked?
				first_snack.bonus_reagents = list()
			to_chat(user, span_info("I remove \the [first_item] from \the [initial(name)]"))
			if(!user.put_in_hands(first_item))
				first_item.forceMove(get_turf(src))

	update_icon()


/*
	var/found_table = locate(/obj/structure/table) in (loc)
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/meat/poultry/baked/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/peppersteak))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/peppersteak/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/onionsteak))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/onionsteak/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/friedegg/tiberian))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/friedegg/tiberian/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/friedrat))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/friedrat/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/hcakeslice))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/hcakeslice/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/ccakeslice))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/ccakeslice/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/bun_grenz))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/bun_grenz/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/fryfish/carp))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/fryfish/carp/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/fryfish/clownfish))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/fryfish/clownfish/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/fryfish/angler))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/fryfish/angler/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/fryfish/eel))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/fryfish/eel/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/wienercabbage))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/wienercabbage/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/wienerpotato))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/wienerpotato/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/wieneronions))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/wieneronions/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/wienerpotatonions))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/wienerpotatonions/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/frybirdtato))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			if(do_after(user,2 SECONDS, target = src))
				user.mind.add_sleep_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
				new /obj/item/reagent_containers/food/snacks/rogue/frybirdtato/plated(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a table to work on it.</span>")
	else
		return ..()	
*/
/* ###########################################
		Silver Cutlery interactions with deadites
   ########################################### */

// This is definitely better done as a datum.
// Because this is the same for all silver items, I will only comment for the platter.
/obj/item/cooking/platter/silver/funny_attack_effects(mob/living/target, mob/living/user = usr, nodmg)
	if(world.time < src.last_used + 12 SECONDS) // Can only be applied every 12 seconds.
		to_chat(user, span_notice("The silver effect is on cooldown."))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				H.adjustFireLoss(10) // 10 points of burn damage
				H.fire_act(1,10)     // 1 stack of fire added, up to a maximum of 10?
				to_chat(H, span_userdanger("I'm hit with my BANE!"))
				src.last_used = world.time
				return
		if(target.mind && target.mind.has_antag_datum(/datum/antagonist/vampirelord))
			var/datum/antagonist/vampirelord/VD = target.mind.has_antag_datum(/datum/antagonist/vampirelord)
			if(!VD.disguised)
				H.adjustFireLoss(10)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I'm hit with my BANE!"))
				src.last_used = world.time
				return

/obj/item/cooking/platter/silver/pickup(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	var/datum/antagonist/vampirelord/V_lord = H.mind.has_antag_datum(/datum/antagonist/vampirelord/)
	var/datum/antagonist/werewolf/W = H.mind.has_antag_datum(/datum/antagonist/werewolf/)
	if(ishuman(H))
		if(H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(10)
			H.Paralyze(10)
			H.adjustFireLoss(25)
			H.fire_act(1,10)
		if(V_lord)
			if(V_lord.vamplevel < 4 && !H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				H.Knockdown(10)
				H.adjustFireLoss(25)
		if(W && W.transformed == TRUE)
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(10)
			H.Paralyze(10)
			H.adjustFireLoss(25)
			H.fire_act(1,10)

/obj/item/cooking/platter/silver/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				M.Knockdown(10)
				M.Paralyze(10)
				M.adjustFireLoss(25)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				return FALSE
	if(M.mind && M.mind.has_antag_datum(/datum/antagonist/vampirelord))
		M.adjustFireLoss(25)
		M.fire_act(1,10)
		to_chat(M, span_userdanger("I can't pick up the silver, it is my BANE!"))
		return FALSE

/obj/item/reagent_containers/glass/bowl/silver/funny_attack_effects(mob/living/target, mob/living/user = usr, nodmg)
	if(world.time < src.last_used + 12 SECONDS)
		to_chat(user, span_notice("The silver effect is on cooldown."))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				H.adjustFireLoss(10)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I'm hit with my BANE!"))
				src.last_used = world.time
				return
		if(target.mind && target.mind.has_antag_datum(/datum/antagonist/vampirelord))
			var/datum/antagonist/vampirelord/VD = target.mind.has_antag_datum(/datum/antagonist/vampirelord)
			if(!VD.disguised)
				H.adjustFireLoss(10)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I'm hit with my BANE!"))
				src.last_used = world.time
				return

/obj/item/reagent_containers/glass/bowl/silver/pickup(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	var/datum/antagonist/vampirelord/V_lord = H.mind.has_antag_datum(/datum/antagonist/vampirelord/)
	var/datum/antagonist/werewolf/W = H.mind.has_antag_datum(/datum/antagonist/werewolf/)
	if(ishuman(H))
		if(H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(10)
			H.Paralyze(10)
			H.adjustFireLoss(25)
			H.fire_act(1,10)
		if(V_lord)
			if(V_lord.vamplevel < 4 && !H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				H.Knockdown(10)
				H.adjustFireLoss(25)
		if(W && W.transformed == TRUE)
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(10)
			H.Paralyze(10)
			H.adjustFireLoss(25)
			H.fire_act(1,10)

/obj/item/reagent_containers/glass/bowl/silver/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				M.Knockdown(10)
				M.Paralyze(10)
				M.adjustFireLoss(25)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				return FALSE
	if(M.mind && M.mind.has_antag_datum(/datum/antagonist/vampirelord))
		M.adjustFireLoss(25)
		M.fire_act(1,10)
		to_chat(M, span_userdanger("I can't pick up the silver, it is my BANE!"))
		return FALSE
/obj/item/kitchen/ironfork/silver/funny_attack_effects(mob/living/target, mob/living/user = usr, nodmg)
	if(world.time < src.last_used + 12 SECONDS)
		to_chat(user, span_notice("The silver effect is on cooldown."))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				H.adjustFireLoss(10)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I'm hit with my BANE!"))
				src.last_used = world.time
				return
		if(target.mind && target.mind.has_antag_datum(/datum/antagonist/vampirelord))
			var/datum/antagonist/vampirelord/VD = target.mind.has_antag_datum(/datum/antagonist/vampirelord)
			if(!VD.disguised)
				H.adjustFireLoss(10)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I'm hit with my BANE!"))
				src.last_used = world.time
				return

/obj/item/kitchen/ironfork/silver/pickup(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	var/datum/antagonist/vampirelord/V_lord = H.mind.has_antag_datum(/datum/antagonist/vampirelord/)
	var/datum/antagonist/werewolf/W = H.mind.has_antag_datum(/datum/antagonist/werewolf/)
	if(ishuman(H))
		if(H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(10)
			H.Paralyze(10)
			H.adjustFireLoss(25)
			H.fire_act(1,10)
		if(V_lord)
			if(V_lord.vamplevel < 4 && !H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				H.Knockdown(10)
				H.adjustFireLoss(25)
		if(W && W.transformed == TRUE)
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(10)
			H.Paralyze(10)
			H.adjustFireLoss(25)
			H.fire_act(1,10)

/obj/item/kitchen/ironfork/silver/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				M.Knockdown(10)
				M.Paralyze(10)
				M.adjustFireLoss(25)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				return FALSE
	if(M.mind && M.mind.has_antag_datum(/datum/antagonist/vampirelord))
		M.adjustFireLoss(25)
		M.fire_act(1,10)
		to_chat(M, span_userdanger("I can't pick up the silver, it is my BANE!"))
		return FALSE

/obj/item/kitchen/ironspoon/silver/funny_attack_effects(mob/living/target, mob/living/user = usr, nodmg)
	if(world.time < src.last_used + 12 SECONDS)
		to_chat(user, span_notice("The silver effect is on cooldown."))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				H.adjustFireLoss(10)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I'm hit with my BANE!"))
				src.last_used = world.time
				return
		if(target.mind && target.mind.has_antag_datum(/datum/antagonist/vampirelord))
			var/datum/antagonist/vampirelord/VD = target.mind.has_antag_datum(/datum/antagonist/vampirelord)
			if(!VD.disguised)
				H.adjustFireLoss(10)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I'm hit with my BANE!"))
				src.last_used = world.time
				return

/obj/item/kitchen/ironspoon/silver/pickup(mob/user)
	. = ..()
	var/mob/living/carbon/human/H = user
	var/datum/antagonist/vampirelord/V_lord = H.mind.has_antag_datum(/datum/antagonist/vampirelord/)
	var/datum/antagonist/werewolf/W = H.mind.has_antag_datum(/datum/antagonist/werewolf/)
	if(ishuman(H))
		if(H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(10)
			H.Paralyze(10)
			H.adjustFireLoss(25)
			H.fire_act(1,10)
		if(V_lord)
			if(V_lord.vamplevel < 4 && !H.mind.has_antag_datum(/datum/antagonist/vampirelord/lesser))
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				H.Knockdown(10)
				H.adjustFireLoss(25)
		if(W && W.transformed == TRUE)
			to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
			H.Knockdown(10)
			H.Paralyze(10)
			H.adjustFireLoss(25)
			H.fire_act(1,10)

/obj/item/kitchen/ironspoon/silver/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna && H.dna.species)
			if(istype(H.dna.species, /datum/species/werewolf))
				M.Knockdown(10)
				M.Paralyze(10)
				M.adjustFireLoss(25)
				H.fire_act(1,10)
				to_chat(H, span_userdanger("I can't pick up the silver, it is my BANE!"))
				return FALSE
	if(M.mind && M.mind.has_antag_datum(/datum/antagonist/vampirelord))
		M.adjustFireLoss(25)
		M.fire_act(1,10)
		to_chat(M, span_userdanger("I can't pick up the silver, it is my BANE!"))
		return FALSE

/* * * * * * * * * * * **
 *						*
 *	 Food Rotting		*	- Just lists as it stands on 2024-07-16
 *						*
 * * * * * * * * * * * **/

/*	.................   Never spoils   ................... *//*

* Hardtack
* Toast
* Salted fish
* Frybread
* Unbitten handpies
* Biscuit
* Prezzel
* Cheese wheel/wedges
* Salo
* Copiette
* Salumoi
* Uncut pie
* Raw potato, onion, cabbage

/*	.................   Long shelflife   ................... */

* Uncut bread loaf
* Uncut raisin bread
* Uncut cake
* Pastry
* Bun
* Most plated dishes
* Most cooked veggies
* Cooked sausage
* Pie slice
* Bread slice

/*	.................   Decent shelflife   ................... */

* Fresh cheese
* Mixed dishes with meats 
* Fried meats & eggs

/*	.................   Short shelflife   ................... */

* Raw meat
* Berries

/*	.................   Tiny shelflife   ................... */

* Minced meat

*/

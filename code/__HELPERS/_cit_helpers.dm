//THIS FILE CONTAINS CONSTANTS, PROCS, AND OTHER THINGS//
/////////////////////////////////////////////////////////
	//Genitals and Arousal Lists
GLOBAL_LIST_EMPTY(genitals_list)
GLOBAL_LIST_EMPTY(cock_shapes_list)
GLOBAL_LIST_EMPTY(balls_shapes_list)
GLOBAL_LIST_EMPTY(breasts_shapes_list)
GLOBAL_LIST_EMPTY(vagina_shapes_list)
//longcat memes.
GLOBAL_LIST_INIT(dick_nouns, list("phallus", "willy", "dick", "prick", "member", "tool", "gentleman's organ", "cock", "wang", "knob", "dong", "joystick", "pecker", "johnson", "weenie", "tadger", "schlong", "thirsty ferret", "One eyed trouser trout", "Ding dong", "ankle spanker", "Pork sword", "engine cranker", "Harry hot dog", "Davy Crockett", "Kidney cracker", "Heat seeking moisture missile", "Giggle stick", "love whistle", "Tube steak", "Uncle Dick", "Purple helmet warrior"))

GLOBAL_LIST_INIT(genitals_visibility_toggles, list(GEN_VISIBLE_ALWAYS, GEN_VISIBLE_NO_CLOTHES, GEN_VISIBLE_NO_UNDIES, GEN_VISIBLE_NEVER))

GLOBAL_LIST_INIT(dildo_shapes, list(
		"Human"		= "human",
		"Knotted"	= "knotted",
		"Plain"		= "plain",
		"Flared"	= "flared"
		))
GLOBAL_LIST_INIT(dildo_sizes, list(
		"Small"		= 1,
		"Medium"	= 2,
		"Big"		= 3
		))
GLOBAL_LIST_INIT(dildo_colors, list(//mostly neon colors
		"Cyan"		= "#00f9ff",//cyan
		"Green"		= "#49ff00",//green
		"Pink"		= "#ff4adc",//pink
		"Yellow"	= "#fdff00",//yellow
		"Blue"		= "#00d2ff",//blue
		"Lime"		= "#89ff00",//lime
		"Black"		= "#101010",//black
		"Red"		= "#ff0000",//red
		"Orange"	= "#ff9a00",//orange
		"Purple"	= "#e300ff"//purple
		))

/mob/living/carbon/proc/is_groin_exposed(list/L)
	// Underwear
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.underwear > 1) // 1 is naked, anything higher is covered
			return FALSE

	// Clothing
	if(!L)
		L = get_equipped_items()
	for(var/A in L)
		var/obj/item/I = A
		if(istype(I) && (I.flags_armor_protection & GROIN))
			return FALSE
	return TRUE

/mob/living/carbon/proc/is_chest_exposed(list/L)
	// Underwear
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.undershirt > 1 || H.underwear > 1) // Same as above
			return FALSE

	// Clothing
	if(!L)
		L = get_equipped_items()
	for(var/A in L)
		var/obj/item/I = A
		if(istype(I) && (I.flags_armor_protection & CHEST))
			return FALSE
	return TRUE

////////////////////////
//DANGER | DEBUG PROCS//
////////////////////////

/client/verb/give_genitals()
	set name = "Give Genitals"
	set category = "Debug"
	if(mob && ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(!locate(/datum/internal_organ/genital) in H.internal_organs)
			H.give_genitals(TRUE)
			to_chat(src, "<span class='notice'>Genitals given!</span>")
		else
			to_chat(src, "<span class='warning'>You've already got genitals!</span>")

/client/proc/give_humans_genitals()
	set name = "Mass Give Genitals"
	set category = "Debug"
	set desc = "Gives every human mob genitals for testing purposes. WARNING: NOT FOR LIVE SERVER USAGE!!"

	log_admin("[src] gave everyone genitals.")
	message_admins("[src] gave everyone genitals.")
	for(var/mob/living/carbon/human/H in GLOB.mob_list)
		H.give_genitals(TRUE)

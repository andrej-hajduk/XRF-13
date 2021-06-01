/obj/item/organ/genital/breasts
	name = "breasts"
	desc = "Female milk producing organs."
	icon_state = "breasts"
	icon = 'modular_skyrat/icons/obj/genitals/breasts.dmi'


/datum/internal_organ/genital/breasts
	name = "breasts"
	masturbation_verb = "massage"
	arousal_verb = "Your breasts start feeling sensitive"
	unarousal_verb = "Your breasts no longer feel sensitive"
	orgasm_verb = "leaking"
	parent_limb = "chest"
	organ_id = ORGAN_BREASTS
	genital_flags = CAN_MASTURBATE_WITH|CAN_CLIMAX_WITH|GENITAL_CAN_AROUSE|GENITAL_FLUID_PRODUCTION|UPDATE_OWNER_APPEARANCE|GENITAL_UNDIES_HIDDEN
	fluid_transfer_factor = 0.5
	shape = DEF_BREASTS_SHAPE
	//fluid_id = /datum/reagent/consumable/milk
	removed_type = /obj/item/organ/genital/breasts

	var/static/list/breast_values = list("flat" = 0, "a" =  1, "b" = 2, "c" = 3, "d" = 4, "e" = 5, "f" = 6, "g" = 7, "h" = 8, "i" = 9, "j" = 10, "k" = 11, "l" = 12, "m" = 13, "n" = 14, "o" = 15, "huge" = 16)
	var/cached_size //these two vars pertain size modifications and so should be expressed in NUMBERS.
	var/prev_size //former cached_size value, to allow update_size() to early return should be there no significant changes.

/datum/internal_organ/genital/breasts/New(mob/living/carbon/M, do_update = TRUE)
	if(do_update)
		cached_size = breast_values[size]
		prev_size = cached_size
	return ..()

/datum/internal_organ/genital/breasts/genital_examine(mob/user)
	. = ..()
	var/text = "<span class='notice'>You see a pair of breasts."
	if(size == "huge")
		text = "<span class='notice'>You see [pick("some serious honkers", "a real set of badonkers", "some dobonhonkeros", "massive dohoonkabhankoloos", "two big old tonhongerekoogers", "a couple of giant bonkhonagahoogs", "a pair of humongous hungolomghnonoloughongous")]. Their volume is way beyond cupsize now, measuring in about [round(cached_size)]cm in diameter."
	else
		if(size == "flat")
			text += " They're very small and flatchested, however."
		else
			text += " You estimate that they're [uppertext(size)]-cups."
	if((genital_flags & GENITAL_FLUID_PRODUCTION) && aroused_state)
		var/datum/reagent/R = GLOB.chemical_reagents_list[fluid_id]
		if(R)
			text += " They're leaking [lowertext(R.name)]."
	text += "</span>"
	return text

/obj/item/organ/genital/penis
	name = "penis"
	desc = "A male reproductive organ."
	icon_state = "penis"
	icon = 'modular_skyrat/icons/obj/genitals/penis.dmi'
	organ_type = /datum/internal_organ/genital/penis


/datum/internal_organ/genital/penis
	name = "penis"
	masturbation_verb = "stroke"
	arousal_verb = "You pop a boner"
	unarousal_verb = "Your boner goes down"
	organ_id = ORGAN_PENIS
	linked_organ_slot = ORGAN_TESTICLES
	genital_flags = CAN_MASTURBATE_WITH|CAN_CLIMAX_WITH|GENITAL_CAN_AROUSE|UPDATE_OWNER_APPEARANCE|GENITAL_UNDIES_HIDDEN|GENITAL_CAN_TAUR
	fluid_transfer_factor = 0.5
	shape = DEF_COCK_SHAPE
	size = 2 //arbitrary value derived from length and diameter for sprites.
	removed_type = /obj/item/organ/genital/penis

	var/length = 6 //inches
	var/prev_length = 6
	var/diameter = 4.38
	var/diameter_ratio = COCK_DIAMETER_RATIO_DEF //0.25; check citadel_defines.dm

/datum/internal_organ/genital/penis/genital_examine(mob/user)
	var/lowershape = lowertext(shape)
	var/round_L = round(length)
	var/round_D = round(diameter)
	return "<span class='notice'>You see [aroused_state ? "an erect" : "a flaccid"] [lowershape] [name]. You estimate it's about [round_L] inch[round_L != 1 ? "es" : ""] long and [round_D] inch[round_D != 1 ? "es" : ""] in diameter.</span>"

/datum/emote/living/carbon/human/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	emote_type = EMOTE_AUDIBLE


/datum/emote/living/carbon/human/scream/run_emote(mob/living/user, params)
	. = ..()
	if(!.)
		return
	var/image/scream = image('icons/mob/talk.dmi', user, icon_state = "scream")
	user.add_emote_overlay(scream)

/datum/emote/living/carbon/human/scream/get_sound(mob/living/carbon/human/user)
	if(ismonkey(user))
		return 'sound/voice/skyrat_screams/scream_monkey.ogg'
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isnull(H.selected_scream)) //For things that don't have a selected scream(npcs)
			if(user.species.screams[user.gender])
				return user.species.screams[user.gender]
			if(user.species.screams[NEUTER])
				return user.species.screams[NEUTER]
		if(user.gender == MALE || !LAZYLEN(H.selected_scream.female_screamsounds))
			return pick(H.selected_scream.male_screamsounds)
		else
			return pick(H.selected_scream.female_screamsounds)

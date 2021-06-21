/datum/preferences/proc/randomize_appearance_for(mob/living/carbon/human/H)
	gender = pick(MALE, FEMALE)
	species = pick(get_playable_species())
	synthetic_type = pick(SYNTH_TYPES)
	ethnicity = random_ethnicity()
	body_type = random_body_type()

	h_style = random_hair_style(gender, species)
	f_style = random_facial_hair_style(gender, species)
	grad_style = pick(GLOB.hair_gradients_list)
	good_eyesight = pick(list(FALSE, TRUE))
	citizenship = pick(CITIZENSHIP_CHOICES)
	religion = pick(RELIGION_CHOICES)
	nanotrasen_relation = pick(CORP_RELATIONS)
	randomize_hair_color("hair")
	randomize_hair_color("grad")
	randomize_hair_color("facial")
	randomize_eyes_color()
	randomize_species_specific()
	underwear = rand(1, GLOB.underwear_m.len)
	undershirt = rand(1, GLOB.undershirt_t.len)
	backpack = 2
	age = rand(AGE_MIN,AGE_MAX)
	if(H)
		copy_to(H, TRUE)


/datum/preferences/proc/randomize_hair_color(target = "hair")
	if(prob (75) && target == "facial")
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		return

	var/red
	var/green
	var/blue

	switch(pick(15;"black", 15;"grey", 15;"brown", 15;"lightbrown", 5;"white", 15;"blonde", 10;"red"))
		if("black")
			red = 10
			green = 10
			blue = 10
		if("grey")
			red = 50
			green = 50
			blue = 50
		if("brown")
			red = 70
			green = 35
			blue = 0
		if("lightbrown")
			red = 100
			green = 50
			blue = 0
		if("white")
			red = 235
			green = 235
			blue = 235
		if("blonde")
			red = 240
			green = 240
			blue = 0
		if("red")
			red = 128
			green = 0
			blue = 0

	red = clamp(red + rand(-25, 25), 0, 255)
	green = clamp(green + rand(-25, 25), 0, 255)
	blue = clamp(blue + rand(-25, 25), 0, 255)

	switch(target)
		if("hair")
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue
		if("grad")
			r_grad = red
			g_grad = green
			b_grad = blue

/datum/preferences/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	switch(pick(15;"black", 15;"green", 15;"brown", 15;"blue", 15;"lightblue", 5;"red"))
		if("black")
			red = 10
			green = 10
			blue = 10
		if("green")
			red = 200
			green = 0
			blue = 0
		if("brown")
			red = 100
			green = 50
			blue = 0
		if("blue")
			red = 0
			green = 0
			blue = 200
		if("lightblue")
			red = 0
			green = 150
			blue = 255
		if("red")
			red = 220
			green = 0
			blue = 0

	red = clamp(red + rand(-25, 25), 0, 255)
	green = clamp(green + rand(-25, 25), 0, 255)
	blue = clamp(blue + rand(-25, 25), 0, 255)

	r_eyes = red
	g_eyes = green
	b_eyes = blue


/datum/preferences/proc/update_preview_icon()
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highest_pref = JOBS_PRIORITY_NEVER
	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	if(!previewJob)
		var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
		if(preview_pref == PREVIEW_PREF_NAKED)
			mannequin.show_underwear = FALSE
		else
			mannequin.show_underwear = TRUE
		mannequin.bodyparts_render_key = ""
		mannequin.mutant_parts_render_key = ""
		copy_to(mannequin)
		COMPILE_OVERLAYS(mannequin)
		parent.show_character_previews(new /mutable_appearance(mannequin))
		unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
		return

	if(previewJob.handle_special_preview(parent))
		return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin)

	if(previewJob && preview_pref == PREVIEW_PREF_JOB)
		mannequin.job = previewJob
		previewJob.equip_dummy(mannequin, preference_source = parent)

	if(preview_pref == PREVIEW_PREF_NAKED)
		mannequin.show_underwear = FALSE
	else
		mannequin.show_underwear = TRUE

	mannequin.bodyparts_render_key = ""
	mannequin.mutant_parts_render_key = ""
	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)


/datum/preferences/proc/randomize_species_specific()
	var/datum/species/S = GLOB.all_species[species]
	features = S.get_random_features()
	mutant_bodyparts = S.get_random_mutant_bodyparts(features)
	body_markings = S.get_random_body_markings(features)


/datum/preferences/proc/copy_to(mob/living/carbon/human/character, safety = FALSE, is_synth = FALSE)
	character.set_species(species, pref_load = src)
	if(random_name)
		character.real_name = character.species.random_name(gender)
		character.name = character.real_name

	if(!good_eyesight)
		ENABLE_BITFIELD(character.disabilities, NEARSIGHTED)

	character.update_body()
	character.update_hair()

	if(is_synth)
		character.make_synth_fake()

/datum/preferences/proc/random_character()
	gender = pick(MALE, FEMALE)
	var/speciestype = pick(GLOB.roundstart_species)
	var/datum/species/S = GLOB.roundstart_species[speciestype]
	species = S.name
	real_name = S.random_name(gender)
	age = rand(AGE_MIN, AGE_MAX)
	h_style = pick("Crewcut", "Bald", "Short Hair")

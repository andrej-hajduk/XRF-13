/datum/xeno_caste/king
	caste_name = "King"
	display_name = "King"
	caste_type_path = /mob/living/carbon/xenomorph/king
	caste_desc = "A primordial creature, evolved to smash the hardiest of defences and hunt the hardiest of prey."

	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_BASETYPE
	wound_type = "king" //used to match appropriate wound overlays

	// *** Melee Attacks *** //
	melee_damage = 20

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 1000 //Bumped up
	plasma_gain = 80 //Bumped up

	// *** Health *** //
	max_health = 400 //Bumped down to T3 crusher levels, though rises up

	// *** Evolution *** //
	upgrade_threshold = 250 //Bumped down so they're more useful

	// *** Flags *** //
	caste_flags = CASTE_DECAY_PROOF

	// *** Defense *** //
	soft_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = XENO_BOMB_RESIST_3, "bio" = 45, "rad" = 45, "fire" = 100, "acid" = 45)

	// *** Pheromones *** //
	aura_strength = 4



	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/psychic_whisper,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/nightfall,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/activable/nightfall/lesser,
		/datum/action/xeno_action/activable/rally_hive,
	)


/datum/xeno_caste/king/young
	upgrade = XENO_UPGRADE_ZERO

/datum/xeno_caste/king/mature
	caste_desc = "The biggest and baddest xeno, crackling with psychic energy."

	upgrade = XENO_UPGRADE_ONE

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 1200 //Bumped up
	plasma_gain = 100 //Bump

	// *** Health *** //
	max_health = 650

	// *** Evolution *** //
	upgrade_threshold = 400 //Bumped down

	// *** Defense *** //
	soft_armor = list("melee" = 55, "bullet" = 55, "laser" = 55, "energy" = 55, "bomb" = XENO_BOMB_RESIST_3, "bio" = 50, "rad" = 50, "fire" = 100, "acid" = 50)

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/nightfall/lesser,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/nightfall,
		/datum/action/xeno_action/activable/gravity_crush,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/activable/rally_hive,
	)


/datum/xeno_caste/king/elder
	caste_desc = "An unstoppable being only whispered about in legends."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Tackle *** //
	tackle_damage = 28

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 1600
	plasma_gain = 120 //Faster

	// *** Health *** //
	max_health = 750

	// *** Evolution *** //
	upgrade_threshold = 600 //Bumped down

	// *** Defense *** //
	soft_armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = XENO_BOMB_RESIST_3, "bio" = 55, "rad" = 55, "fire" = 100, "acid" = 55)

	// *** Pheromones *** //
	aura_strength = 4 //Weaker.

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/nightfall/lesser,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/nightfall,
		/datum/action/xeno_action/activable/gravity_crush,
		/datum/action/xeno_action/psychic_summon,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/activable/rally_hive,
	)

/datum/xeno_caste/king/ancient
	caste_desc = "Harbinger of doom."
	ancient_message = "We are the end."
	upgrade = XENO_UPGRADE_THREE

	// *** Melee Attacks *** //
	melee_damage = 23

	// *** Tackle *** //
	tackle_damage = 28

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 2000
	plasma_gain = 180

	// *** Health *** //
	max_health = 900

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	soft_armor = list("melee" = 65, "bullet" = 65, "laser" = 65, "energy" = 65, "bomb" = XENO_BOMB_RESIST_4, "bio" = 60, "rad" = 60, "fire" = 100, "acid" = 60)

	// *** Ranged Attack *** //
	spit_delay = 1.1 SECONDS

	// *** Pheromones *** //
	aura_strength = 8 //Primordial king.

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/activable/psydrain,
		/datum/action/xeno_action/activable/headbite,
		/datum/action/xeno_action/activable/devour,
		/datum/action/xeno_action/activable/cocoon,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/nightfall/lesser,
		/datum/action/xeno_action/activable/corrosive_acid/strong,
		/datum/action/xeno_action/activable/nightfall,
		/datum/action/xeno_action/activable/gravity_crush,
		/datum/action/xeno_action/psychic_summon,
		/datum/action/xeno_action/toggle_pheromones,
		/datum/action/xeno_action/activable/rally_hive,
	)

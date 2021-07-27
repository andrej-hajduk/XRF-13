GLOBAL_LIST_EMPTY(scream_types)

/datum/scream_type
	var/name
	var/list/male_screamsounds
	var/list/female_screamsounds
	var/restricted_species_type

/datum/scream_type/none //Why would you want this?
	name = "No Scream"
	male_screamsounds = null
	female_screamsounds = null

/datum/scream_type/human
	name = "Human Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/scream_m1.ogg', 'sound/voice/skyrat_screams/scream_m2.ogg')
	female_screamsounds = list('sound/voice/skyrat_screams/scream_f1.ogg', 'sound/voice/skyrat_screams/scream_f2.ogg')

/*
/datum/scream_type/robotic
	name = "Robotic Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/scream_silicon.ogg')
	female_screamsounds = null
	restricted_species_type = /datum/species/robotic
*/

/datum/scream_type/lizard
	name = "Lizard Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/lizard_scream_1.ogg', 'sound/voice/skyrat_screams/lizard_scream_2.ogg', 'sound/voice/skyrat_screams/lizard_scream_3.ogg')
	female_screamsounds = null

/datum/scream_type/lizard2
	name = "Lizard Scream 2"
	male_screamsounds = list('sound/voice/skyrat_screams/scream_lizard.ogg')
	female_screamsounds = null

/datum/scream_type/moth
	name = "Moth Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/scream_moth.ogg')
	female_screamsounds = null

/datum/scream_type/jelly
	name = "Jelly Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/jelly_scream.ogg')
	female_screamsounds = null

/datum/scream_type/vox
	name = "Vox Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/voxscream.ogg')
	female_screamsounds = null

/datum/scream_type/tajaran
	name = "Cat Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/cat_scream.ogg')
	female_screamsounds = null

/* mmmm no, very unwise
/datum/scream_type/xeno
	name = "Xeno Scream"
	male_screamsounds = list('sound/voice/hiss6.ogg')
	female_screamsounds = null
*/

/datum/scream_type/raptor //This is the Teshari scream ported from CitRP which was a cockatoo scream edited by BlackMajor.
	name = "Raptor Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/raptorscream.ogg')
	female_screamsounds = null

/datum/scream_type/rodent //Ported from Polaris/Virgo.
	name = "Rodent Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/rodentscream.ogg')
	female_screamsounds = null

//DONATOR SCREAMS
/* no
/datum/scream_type/zombie
	name = "Zombie Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/zombie_scream.ogg')
	female_screamsounds = null
	donator_only = TRUE
/datum/scream_type/monkey
	name = "Monkey Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/scream_monkey.ogg')
	female_screamsounds = null
	donator_only = TRUE
/datum/scream_type/gorilla
	name = "Gorilla Scream"
	male_screamsounds = list('sound/creatures/gorilla.ogg')
	female_screamsounds = null
	donator_only = TRUE
/datum/scream_type/skeleton
	name = "Skeleton Scream"
	male_screamsounds = list('sound/voice/skyrat_screams/scream_skeleton.ogg')
	female_screamsounds = null
	donator_only = TRUE
*/

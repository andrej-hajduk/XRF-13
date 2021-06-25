/datum/job/service
	job_category = JOB_CAT_SERVICE
	supervisors = "the captain"
	selection_color = "#D1FFD4"
	exp_type_department = EXP_TYPE_SERVICE


/datum/job/terragov/squad/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.hud_set_job(faction)
	C.set_nutrition(rand(60, 250))
	if(!ishuman(C))
		return

//JANITOR
/datum/job/terragov/service/janitor
	title = JANITOR
	comm_title = "Jan"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	display_order = JOB_DISPLAY_ORDER_JANITOR
	outfit = /datum/outfit/job/janitor
	total_positions = 1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Easy<br /><br />
		<b>You answer to the</b> captain<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Distress<br /><br /><br />
		TerraGov’s Squad Marines make up the bread and butter of Terra's fighting forces. They are fitted with the standard arsenal that the TGMC offers, and they can take up a variety of roles, being a sniper, a pyrotechnician, a machinegunner, rifleman and more. They’re often high in numbers and divided into squads, but they’re the lowest ranking individuals, with a low degree of skill, not adapt to engineering or medical roles. Still, they are not limited to the arsenal they can take on the field to deal whatever threat that lurks against Terra.
		<br /><br />
		<b>Duty</b>: Carry out orders made by your acting Squad Leader, deal with any threats that oppose the TGMC.
	"}
	minimap_icon = "private"

/datum/job/terragov/service/janitor/standard/rebel
	faction = FACTION_TERRAGOV_REBEL
	access = list(ACCESS_IFF_MARINE_REBEL, ACCESS_MARINE_PREP_REBEL)
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner/rebel = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic/rebel = SYNTH_POINTS_REGULAR,
	)


/datum/job/terragov/squad/standard/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a rank-and-file soldier of the TGMC, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the corps. Ooh-rah!"})


/datum/outfit/job/janitor
	name = JANITOR
	jobtype = /datum/outfit/job/janitor

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack

/datum/outfit/job/janitor/standard/equipped
	name = "Janitor (Equipped)"

	ears = /obj/item/radio/headset/mainship/serv
	w_uniform = /obj/item/clothing/under/rank/civilian/janitor
	wear_suit = /obj/item/clothing/suit/storage/marine/harness
	shoes = /obj/item/clothing/shoes/marine/full
	gloves =/obj/item/clothing/gloves/marine
	l_store = /obj/item/storage/pouch/firstaid/full
	r_hand = /obj/item/portable_vendor/marine/squadmarine

/datum/outfit/job/marine/standard/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)

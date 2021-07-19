/datum/job/survivor
	title = "Colonist"
	supervisors = "anyone who might rescue you"
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_CIVILIAN_MEDICAL, ACCESS_NT_PMC_GREEN)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_CIVILIAN_MEDICAL, ACCESS_NT_PMC_GREEN)
	display_order = JOB_DISPLAY_ORDER_SURVIVOR
	skills_type = /datum/skills/civilian
	outfit = /datum/outfit/job/survivor
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_NOHEADSET|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_LATEJOINABLE
	faction = FACTION_TERRAGOV

/datum/job/survivor/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()

	switch(M.client.prefs.survivor)
		if("Civilian") //Basically the damsel in distress role. Completely useless
			C.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(C), SLOT_W_UNIFORM)
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(C), SLOT_BACK)
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(C), SLOT_SHOES)
			C.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(C), SLOT_R_STORE)
		if("Salesman") //Similar to Civilian but different starting clothes
			C.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(C), SLOT_W_UNIFORM)
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(C), SLOT_BACK)
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(C), SLOT_SHOES)
			C.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(C), SLOT_R_STORE)
		if("Janitor") //A civilian role that still gets some okay skills and cleaning supplies
			C.skills = getSkillsType(/datum/skills/civilian/survivor)
			C.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(C), SLOT_W_UNIFORM)
			C.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/hazardvest(C), SLOT_WEAR_SUIT)
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(C), SLOT_BACK)
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/galoshes(C), SLOT_SHOES)
			C.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(C), SLOT_R_STORE)
			C.equip_to_slot_or_del(new /obj/item/lightreplacer(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/storage/bag/trash(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/tool/wet_sign(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/tool/wet_sign(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/tool/soap/deluxe(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/tool/mop(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/cleaner(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/cleaner(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/clothing/head/beret/jan(C), SLOT_HEAD)
		if("Miner") //Similar to Janitor except starts with mining equipment instead
			C.skills = getSkillsType(/datum/skills/civilian/survivor/miner)
			C.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson(C), SLOT_GLASSES)
			C.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(C), SLOT_W_UNIFORM)
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/eng(C), SLOT_BACK)
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(C), SLOT_SHOES)
			C.equip_to_slot_or_del(new /obj/item/tool/pickaxe/plasmacutter(C), SLOT_BELT)
			C.equip_to_slot_or_del(new /obj/item/analyzer(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/storage/bag/ore(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/flashlight/lantern(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(C), SLOT_R_STORE)
			C.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/rugged(C), SLOT_HEAD)
		if("Militia") //Closest to old survivor. Has armor, gun, and decent all-round skills
			C.skills = getSkillsType(/datum/skills/civilian/survivor/militia)
			C.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/corp(C), SLOT_W_UNIFORM)
			C.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/rugged(C), SLOT_WEAR_SUIT)
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/ruggedboot(C), SLOT_SHOES)
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec(C), SLOT_BACK)
			var/weapons = pick(SURVIVOR_WEAPONS)
			var/obj/item/weapon/W = weapons[1]
			var/obj/item/ammo_magazine/A = weapons[2]
			C.equip_to_slot_or_del(new /obj/item/belt_harness(C), SLOT_BELT)
			C.put_in_hands(new W(C))
			C.equip_to_slot_or_del(new A(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new A(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new A(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(C), SLOT_R_STORE)
			C.equip_to_slot_or_del(new /obj/item/clothing/head/helmet(C), SLOT_HEAD)
		if("Doctor") //Medical equipment, supplies, and skills to match
			C.skills = getSkillsType(/datum/skills/civilian/survivor/doctor)
			C.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(C), SLOT_W_UNIFORM)
			C.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(C), SLOT_WEAR_SUIT)
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/corpsman/survivor(C), SLOT_BACK)
			C.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit/full(C), SLOT_R_STORE)
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(C), SLOT_SHOES)
			C.equip_to_slot_or_del(new /obj/item/storage/belt/medical(C), SLOT_BELT)
			C.equip_to_slot_or_del(new /obj/item/tweezers(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/imidazoline(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/alkysine(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat(C), SLOT_IN_BACKPACK)
		if("Engineer") //Engineer skills and additional equipment and supplies
			C.skills = getSkillsType(/datum/skills/civilian/survivor/engineer)
			C.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson(C), SLOT_GLASSES)
			C.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(C), SLOT_W_UNIFORM)
			C.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/hazardvest(C), SLOT_WEAR_SUIT)
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/industrial(C), SLOT_BACK)
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(C), SLOT_SHOES)
			C.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(C), SLOT_BELT)
			C.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(C), SLOT_R_STORE)
			C.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding/superior(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/stack/sheet/metal(C, 50), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel(C, 30), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/rugged(C), SLOT_HEAD)
		if("Merchant Captain") //Captain of a civilian merchant, inspired by Firefly. Some unique gear and a lot of skills, but starts with mostly nothing
			C.skills = getSkillsType(/datum/skills/civilian/survivor/captain)
			C.equip_to_slot_or_del(new /obj/item/clothing/under/marine/commissar(C), SLOT_W_UNIFORM)
			C.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(C), SLOT_WEAR_SUIT)
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/captain/civilian(C), SLOT_BACK)
			C.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(C), SLOT_SHOES)
			C.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(C), SLOT_R_STORE)
			C.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/formalcaptain(C), SLOT_HEAD)
			C.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/c99(C), SLOT_BELT)
			C.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(C), SLOT_IN_BACKPACK)
			C.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99(C), SLOT_IN_BACKPACK)

	C.equip_to_slot_or_del(new /obj/item/clothing/gloves/ruggedgloves(C), SLOT_GLOVES)
	C.equip_to_slot_or_del(new /obj/item/storage/pouch/survival/full(C), SLOT_L_STORE)
	C.equip_to_slot_or_del(new /obj/item/weapon/combat_knife(C), SLOT_IN_BACKPACK)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
		C.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka(C), SLOT_HEAD)
		C.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/snow_suit(C), SLOT_WEAR_SUIT)
		C.equip_to_slot_or_del(new /obj/item/clothing/mask/rebreather(C), SLOT_WEAR_MASK)
		C.equip_to_slot_or_del(new /obj/item/clothing/shoes/snow(C), SLOT_SHOES)
		C.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(C), SLOT_GLOVES)

	switch(SSmapping.configs[GROUND_MAP].map_name)
		if(MAP_PRISON_STATION)
			to_chat(M, "<span class='notice'>You are a [M.client.prefs.survivor] on Fiorina Orbital Penitentiary. You infiltrated on the prison station, and managed to avoid the chaos... until now.</span>")
		if(MAP_ICE_COLONY)
			to_chat(M, "<span class='notice'>You are a [M.client.prefs.survivor] on the ice habitat. You infiltrated on the colony, and managed to avoid the anarchy... until now.</span>")
		if(MAP_BIG_RED)
			to_chat(M, "<span class='notice'>You are a [M.client.prefs.survivor] for the colony. You infiltrated in the archaeology colony, and managed to avoid the downfall... until now.</span>")
		if(MAP_LV_624)
			to_chat(M, "<span class='notice'>You are a [M.client.prefs.survivor] on the colony. You suspected something was wrong and tried to call for help, but it was too late...</span>")
		if(MAP_ICY_CAVES)
			to_chat(M, "<span class='notice'>You are a [M.client.prefs.survivor] on the icy cave system. You infiltrated on the site, and managed to avoid the chaoss... until now.</span>")
		if(MAP_BARRENQUILLA_MINING)
			to_chat(M, "<span class='notice'>You are a [M.client.prefs.survivor] on the facility. The site manager's greed caught up to him, and you're caught in the crossfire...</span>")
		if(MAP_RESEARCH_OUTPOST)
			to_chat(M, "<span class='notice'>You are a [M.client.prefs.survivor] on the outpost. But you question yourself: are you truely safe now?</span>")
		if(MAP_MAGMOOR_DIGSITE)
			to_chat(M, "<span class='notice'>You are a [M.client.prefs.survivor] on the Magmoor Digsite IV. infiltrated on the digsite, and managed to avoid the anarchy... until now.</span>")
		else
			to_chat(M, "<span class='notice'>Through a miracle you managed to survive the chaos. But are you truly safe now?</span>")

/datum/job/survivor/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are a colonist who lives at this colony having either, through either luck or choice, missed the evacuation of the colony due to a detected strain of Xenos in the area.
So far, there have been no attacks, but in the chaos of the evacuation there may have been looters or other opportunists who ransacked the colony. A marine force is approaching the area to restore order.
Good luck."})

/datum/outfit/job/survivor
	name = "Colonist"
	jobtype = /datum/job/survivor


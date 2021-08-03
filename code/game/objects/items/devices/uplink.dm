/obj/item/uplink_tablet
	name = "uplink tablet"
	desc = "A basic skeleton of a mobile shop."
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "radio"
	flags_equip_slot = ITEM_SLOT_POCKET
	w_class = WEIGHT_CLASS_SMALL

	interaction_flags = INTERACT_MACHINE_TGUI
	///How much credits the tablet starts with
	var/credits = 0
	///If the vendor is ready to vend.
	var/vend_ready = TRUE
	///How long it takes to vend an item, vend_ready is false during that.
	var/vend_delay = 10
	/// A /datum/vending_product instance of what we're paying for right now.
	var/datum/vending_product/currently_vending = null

	/// Normal products that are always available on the vendor.
	var/list/products = list()
	/// Prices for each item, list(/type/path = price), items not in the list don't have a price.
	var/list/prices = list()
	///list of /datum/vending_product's that are always available on the vendor
	var/list/product_records = list()
	///Who owns this tablet
	var/registered_name = null

/obj/item/uplink_tablet/Initialize(mapload)
	. = ..()
	build_inventory(products)
	products = null
	prices = null

///Builds a vending machine inventory from the given list into their records depending of category.
/obj/item/uplink_tablet/proc/build_inventory(list/productlist, category = CAT_NORMAL)
	var/list/recordlist = product_records

	for(var/entry in productlist)
		//if this is true then this is supposed to be tab dependant.
		if(islist(productlist[entry]))
			for(var/subentry in productlist[entry])
				var/amount = productlist[entry][subentry]
				if(isnull(amount))
					amount = 1
				var/datum/vending_product/record = new(typepath = subentry, product_amount = amount, product_price = prices[entry][subentry], category = category, tab = entry)
				recordlist += record
			continue
		//This item is not tab dependent
		var/amount = productlist[entry]
		if(isnull(amount))
			amount = 1
		var/datum/vending_product/record = new(typepath = entry, product_amount = amount, product_price = prices[entry], category = category)
		recordlist += record

/obj/item/uplink_tablet/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/I = W
		if(!I || !I.registered_name)
			return
		else if(!src.registered_name)
			src.registered_name = I.registered_name
			src.desc += " Owned by [I.registered_name]."
			to_chat(user, "You insert your ID into [src], registering it to yourself.")
		else
			to_chat(user, span_warning("[src] already has a registered owner."))
		return
	if(istype(W, /obj/item/spacecash))
		var/obj/item/spacecash/I = W
		credits += I.worth
		to_chat(user, "You insert \the [I] into \the [src]. You have [credits] on your account.")
		qdel(I)
	else
		return ..()

/obj/item/uplink_tablet/proc/transfer_and_vend()
	var/transaction_amount = currently_vending.price
	if(transaction_amount > credits)
		to_chat(usr, "[icon2html(src, usr)][span_warning("You don't have that much money!")]")
		return

	//transfer the money
	credits -= transaction_amount

	// Vend the item
	vend(currently_vending, usr)
	currently_vending = null

/obj/item/uplink_tablet/interact(mob/user)
	var/obj/item/card/id/I = user.get_idcard()
	if(!src.registered_name || (istype(I) && (src.registered_name == I.registered_name)))
		return ..()
	else
		to_chat(user, span_warning("Access denied, unauthorized user."))
		return TRUE

/obj/item/uplink_tablet/ui_interact(mob/user, datum/tgui/ui)
	// Update UI
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Uplink", name)
		ui.open()

/obj/item/uplink_tablet/ui_static_data(mob/user)
	. = list()
	.["vendor_name"] = name
	.["displayed_records"] = list()
	.["tabs"] = list()

	for(var/datum/vending_product/R AS in product_records)
		if(R.tab && !(R.tab in .["tabs"]))
			.["tabs"] += R.tab
		.["displayed_records"] += list(MAKE_VENDING_RECORD_DATA(R))

/obj/item/uplink_tablet/ui_data(mob/user)
	. = list()
	.["stock"] = list()
	.["price"] = list()
	.["credits"] = credits

	for(var/datum/vending_product/R AS in product_records)
		.["stock"][R.product_name] = R.amount

	for(var/datum/vending_product/R AS in product_records)
		.["price"][R.product_name] = R.price

	if(currently_vending)
		.["currently_vending"] = MAKE_VENDING_RECORD_DATA(currently_vending)

/obj/item/uplink_tablet/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "vend")
		var/datum/vending_product/R = locate(params["vend"]) in product_records
		if(!istype(R) || !R.product_path || R.amount == 0)
			return
		if(R.price == null)
			vend(R, usr)
		else
			currently_vending = R
			transfer_and_vend()
		. = TRUE

	updateUsrDialog()

/obj/item/uplink_tablet/proc/vend(datum/vending_product/R, mob/user)
	vend_ready = 0 //One thing at a time!!
	R.amount--

	var/obj/item/new_item = release_item(R, vend_delay)
	if(istype(new_item))
		user.put_in_any_hand_if_possible(new_item, warning = FALSE)
	vend_ready = 1
	updateUsrDialog()

/obj/item/uplink_tablet/proc/release_item(datum/vending_product/R, delay_vending = 0, dump_product = 0)
	if(delay_vending)
		sleep(delay_vending)
	SSblackbox.record_feedback("tally", "vendored", 1, R.product_name)
	if(ispath(R.product_path,/obj/item/weapon/gun))
		return new R.product_path(get_turf(src), 1)
	else
		return new R.product_path(get_turf(src))

/obj/item/uplink_tablet/captain
	name = "captains tablet"
	desc = "This tablet lets a captain communicate with their ship in orbit. It can use bluespace technology to transfer resources to the ship, and recieve small packages in return."
	products = list(
		"Magazines" = list(
			/obj/item/ammo_magazine/pistol/m1911 = -1,
			/obj/item/ammo_magazine/pistol/m1911/polymer = -1,
			/obj/item/ammo_magazine/pistol/g22 = -1,
			/obj/item/ammo_magazine/pistol/g22tranq = -1,
			/obj/item/ammo_magazine/pistol/heavy = -1,
			/obj/item/ammo_magazine/pistol/c99 = -1,
			/obj/item/ammo_magazine/pistol/c99t = -1,
			/obj/item/ammo_magazine/pistol/holdout = -1,
			/obj/item/ammo_magazine/pistol/highpower = -1,
			/obj/item/ammo_magazine/pistol/vp78 = -1,
			/obj/item/ammo_magazine/pistol/auto9 = -1,
			/obj/item/ammo_magazine/revolver/upp = -1,
			/obj/item/ammo_magazine/revolver/small = -1,
			/obj/item/ammo_magazine/revolver/cmb = -1,
			/obj/item/ammo_magazine/revolver = -1,
			/obj/item/ammo_magazine/revolver/polymer = -1,
			/obj/item/ammo_magazine/revolver/marksman = -1,
			/obj/item/ammo_magazine/revolver/heavy = -1,
			/obj/item/ammo_magazine/smg/m25 = -1,
			/obj/item/ammo_magazine/smg/m25/ap = -1,
			/obj/item/ammo_magazine/smg/m25/extended = -1,
			/obj/item/ammo_magazine/smg/mp7 = -1,
			/obj/item/ammo_magazine/smg/skorpion = -1,
			/obj/item/ammo_magazine/smg/ppsh = -1,
			/obj/item/ammo_magazine/smg/ppsh/extended = -1,
			/obj/item/ammo_magazine/smg/uzi = -1,
			/obj/item/ammo_magazine/smg/uzi/extended = -1,
			/obj/item/ammo_magazine/rifle = -1,
			/obj/item/ammo_magazine/rifle/polymer = -1,
			/obj/item/ammo_magazine/rifle/extended = -1,
			/obj/item/ammo_magazine/rifle/incendiary = -1,
			/obj/item/ammo_magazine/rifle/ap = -1,
			/obj/item/ammo_magazine/rifle/m41a = -1,
			/obj/item/ammo_magazine/rifle/ak47 = -1,
			/obj/item/ammo_magazine/rifle/ak47/extended = -1,
			/obj/item/ammo_magazine/rifle/m16 = -1,
			/obj/item/ammo_magazine/rifle/famas = -1,
			/obj/item/ammo_magazine/rifle/type71 = -1,
			/obj/item/ammo_magazine/sniper/svd = -1,
			/obj/item/ammo_magazine/rifle/pepperball = -1,
		),
		"Ammunition" = list(
			/obj/item/ammo_magazine/box9mm = -1,
			/obj/item/ammo_magazine/box9mm/polymer = -1,
			/obj/item/ammo_magazine/acp = -1,
			/obj/item/ammo_magazine/acp/polymer = -1,
			/obj/item/ammo_magazine/magnum = -1,
			/obj/item/ammo_magazine/magnum/polymer = -1,
			/obj/item/ammo_magazine/box10x24mm = -1,
			/obj/item/ammo_magazine/box10x24mm/polymer = -1,
			/obj/item/ammo_magazine/box10x26mm = -1,
			/obj/item/ammo_magazine/box10x26mm/polymer = -1,
			/obj/item/ammo_magazine/shotgun/beanbag/large = -1,
			/obj/item/ammo_magazine/shotgun = -1,
			/obj/item/ammo_magazine/shotgun/incendiary = -1,
			/obj/item/ammo_magazine/shotgun/buckshot = -1,
			/obj/item/ammo_magazine/shotgun/flechette = -1,
			/obj/item/ammo_magazine/shotgun/beanbag = -1,
			/obj/item/ammo_magazine/rifle/bolt = -1,
			/obj/item/ammo_magazine/rifle/martini = -1,
			/obj/item/ammo_magazine/shotgun/mbx900 = -1,
			/obj/item/ammo_magazine/shotgun/mbx900/buckshot = -1,
			/obj/item/ammo_magazine/shotgun/mbx900/tracking = -1,
			/obj/item/ammo_magazine/sentry = -1,
			/obj/item/ammo_magazine/minisentry = -1,
		),
		"Armor" = list(
			/obj/item/clothing/suit/armor/vest/dutch = -1,
			/obj/item/clothing/suit/armor/vest/pilot = -1,
			/obj/item/clothing/head/helmet/marine/pilot = -1,
			/obj/item/clothing/head/helmet/marine/pilot/green = -1,
			/obj/item/clothing/suit/armor/bulletproof = -1,
			/obj/item/clothing/head/helmet = -1,
			/obj/item/clothing/suit/armor/riot = -1,
			/obj/item/clothing/head/helmet/riot = -1,
			/obj/item/clothing/under/marine/veteran/PMC = -1,
			/obj/item/clothing/suit/storage/marine/veteran/PMC = -1,
			/obj/item/clothing/head/helmet/marine/veteran/PMC = -1,
			/obj/item/clothing/under/marine/veteran/mercenary/miner = -1,
			/obj/item/clothing/suit/storage/marine/veteran/mercenary/miner = -1,
			/obj/item/clothing/head/helmet/marine/veteran/mercenary/miner = -1,
			/obj/item/clothing/under/marine/veteran/mercenary/engineer = -1,
			/obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer = -1,
			/obj/item/clothing/head/helmet/marine/veteran/mercenary/engineer = -1,
			/obj/item/clothing/shoes/marine/imperial = -1,
			/obj/item/clothing/shoes/marine/som = -1,
			/obj/item/clothing/shoes/swat = -1,
			/obj/item/clothing/mask/gas = -1,
			/obj/item/clothing/mask/gas/tactical = -1,
			/obj/item/clothing/mask/gas/tactical/coif = -1,
			/obj/item/clothing/mask/rebreather = -1,
			/obj/item/clothing/mask/rebreather/scarf = -1,
		),
		"Medical" = list(
			/obj/item/healthanalyzer = -1,
			/obj/item/reagent_containers/syringe = -1,
			/obj/item/stack/medical/ointment = -1,
			/obj/item/stack/medical/bruise_pack = -1,
			/obj/item/stack/medical/advanced/bruise_pack = -1,
			/obj/item/stack/medical/advanced/ointment = -1,
			/obj/item/stack/medical/splint = -1,
			/obj/item/clothing/glasses/hud/health = -1,
			/obj/item/clothing/glasses/hud/medgoggles = -1,
			/obj/item/storage/pill_bottle/bicaridine = -1,
			/obj/item/storage/pill_bottle/kelotane = -1,
			/obj/item/storage/pill_bottle/tramadol = -1,
			/obj/item/storage/pill_bottle/tricordrazine = -1,
			/obj/item/storage/pill_bottle/inaprovaline = -1,
			/obj/item/storage/pill_bottle/dexalin = -1,
			/obj/item/storage/pill_bottle/dylovene = -1,
			/obj/item/storage/pill_bottle/spaceacillin = -1,
			/obj/item/storage/pill_bottle/alkysine = -1,
			/obj/item/storage/pill_bottle/imidazoline = -1,
			/obj/item/storage/pill_bottle/peridaxon = -1,
			/obj/item/storage/pill_bottle/quickclot = -1,
			/obj/item/storage/pill_bottle/hypervene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/isotonic = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclot = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = -1,
			/obj/item/storage/belt/medical = -1,
			/obj/item/storage/belt/combatLifesaver/upp = -1,
			/obj/item/storage/belt/combatLifesaver/som = -1,
			/obj/item/storage/firstaid/regular = -1,
			/obj/item/storage/firstaid/fire = -1,
			/obj/item/storage/firstaid/toxin = -1,
			/obj/item/storage/firstaid/o2 = -1,
			/obj/item/storage/firstaid/adv = -1,
			/obj/item/storage/firstaid/rad = -1,
			/obj/item/bodybag/cryobag = -1,
			/obj/item/tweezers = -1,
			/obj/item/reagent_containers/blood/OMinus = -1,
			/obj/item/clothing/tie/storage/white_vest/surgery = -1,
			/obj/item/stack/nanopaste = -1,
			/obj/item/reagent_containers/hypospray/advanced/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/advanced/combat = -1,
			/obj/item/reagent_containers/glass/beaker/large = -1,
		),
		"Engineering" = list(
			/obj/item/stack/sheet/metal/medium_stack = -1,
			/obj/item/stack/sheet/metal/large_stack = -1,
			/obj/item/stack/sheet/plasteel/medium_stack = -1,
			/obj/item/stack/sheet/plasteel/large_stack = -1,
			/obj/item/stack/sheet/mineral/phoron/small_stack = -1,
			/obj/item/stack/sheet/mineral/phoron/medium_stack = -1,
			/obj/item/stack/sheet/glass/large_stack = -1,
			/obj/item/stack/sheet/wood/large_stack = -1,
			/obj/item/storage/belt/utility/full = -1,
			/obj/item/clothing/glasses/meson = -1,
			/obj/item/circuitboard/airlock = -1,
			/obj/item/circuitboard/apc = -1,
			/obj/item/circuitboard/airalarm = -1,
			/obj/item/circuitboard/general = -1,
			/obj/item/storage/toolbox/mechanical = -1,
			/obj/item/storage/toolbox/electrical = -1,
			/obj/item/storage/toolbox/emergency = -1,
			/obj/item/cell/apc = -1,
			/obj/item/cell/high = -1,
			/obj/item/cell/super = -1,
			/obj/item/tool/weldingtool = -1,
			/obj/item/tool/weldingtool/largetank = -1,
			/obj/item/tool/weldingtool/hugetank = -1,
			/obj/item/tool/weldpack = -1,
			/obj/item/tool/wirecutters = -1,
			/obj/item/tool/wrench = -1,
			/obj/item/tool/screwdriver = -1,
			/obj/item/tool/crowbar = -1,
			/obj/item/analyzer = -1,
			/obj/item/multitool = -1,
			/obj/item/clothing/head/welding = -1,
			/obj/item/clothing/glasses/welding = -1,
			/obj/item/storage/box/minisentry = -1,
			/obj/item/tool/pickaxe/plasmacutter = -1,
			/obj/item/explosive/plastique = -1,
			/obj/item/quikdeploy/cade = -1,
			/obj/item/storage/briefcase/inflatable = -1,
			/obj/item/storage/box/lights/mixed = -1,
		),
		"Rations" = list(
			/obj/item/reagent_containers/food/snacks/upp = -1,
			/obj/item/storage/box/MRE = -1,
			/obj/item/reagent_containers/food/snacks/packaged_burger = -1,
			/obj/item/reagent_containers/food/snacks/packaged_burrito = -1,
			/obj/item/reagent_containers/food/snacks/packaged_hdogs = -1,
			/obj/item/reagent_containers/food/snacks/kepler_crisps = -1,
			/obj/item/reagent_containers/food/snacks/enrg_bar = -1,
			/obj/item/reagent_containers/food/snacks/wrapped/booniebars = -1,
			/obj/item/reagent_containers/food/snacks/wrapped/chunk = -1,
			/obj/item/reagent_containers/food/snacks/wrapped/barcardine = -1,
			/obj/item/pizzabox/margherita = -1,
			/obj/item/pizzabox/vegetable = -1,
			/obj/item/pizzabox/mushroom = -1,
			/obj/item/pizzabox/meat = -1,
			/obj/item/storage/box/combat_lolipop = -1,
			/obj/item/storage/box/combat_lolipop/tricord = -1,
			/obj/item/storage/box/combat_lolipop/tramadol = -1,
			/obj/item/reagent_containers/food/drinks/coffee = -1,
			/obj/item/reagent_containers/food/drinks/coffee/cafe_latte = -1,
			/obj/item/reagent_containers/food/drinks/tea = -1,
			/obj/item/reagent_containers/food/drinks/h_chocolate = -1,
			/obj/item/reagent_containers/food/drinks/cans/souto = -1,
			/obj/item/reagent_containers/food/drinks/cans/souto/diet = -1,
			/obj/item/reagent_containers/food/drinks/cans/souto/cherry = -1,
			/obj/item/reagent_containers/food/drinks/cans/souto/cherry/diet = -1,
			/obj/item/reagent_containers/food/drinks/cans/souto/lime = -1,
			/obj/item/reagent_containers/food/drinks/cans/souto/lime/diet = -1,
			/obj/item/reagent_containers/food/drinks/cans/souto/grape = -1,
			/obj/item/reagent_containers/food/drinks/cans/souto/grape/diet = -1,
			/obj/item/reagent_containers/food/drinks/cans/waterbottle = -1,
			/obj/item/reagent_containers/food/drinks/cans/cola = -1,
		),
		"Kitchen" = list(
			/obj/item/reagent_containers/food/condiment/enzyme = -1,
			/obj/item/reagent_containers/food/condiment/sugar = -1,
			/obj/item/reagent_containers/food/condiment/saltshaker = -1,
			/obj/item/reagent_containers/food/condiment/peppermill = -1,
			/obj/item/reagent_containers/food/drinks/milk = -1,
			/obj/item/reagent_containers/food/drinks/soymilk = -1,
			/obj/item/storage/fancy/egg_box = -1,
			/obj/item/portablecrate/dinnerware = -1,
			/obj/item/portablecrate/cow = -1,
			/obj/item/portablecrate/goat = -1,
			/obj/item/portablecrate/chick = -1,
			/obj/item/portablecrate/hydroponics = -1,
			/obj/item/portablecrate/hydronutrients = -1,
			/obj/item/portablecrate/hydroseeds = -1,
			/obj/item/reagent_containers/food/drinks/flask/barflask = -1,
			/obj/item/reagent_containers/food/drinks/flask/detflask = -1,
			/obj/item/reagent_containers/food/drinks/flask/vacuumflask = -1,
		),
		"Equipment" = list(
			/obj/item/radio = -1,
			/obj/item/radio/headset = -1,
			/obj/item/flashlight = -1,
			/obj/item/flashlight/lantern = -1,
			/obj/item/flashlight/flare = -1,
			/obj/item/storage/box/m94 = -1,
			/obj/item/explosive/grenade/smokebomb = -1,
			/obj/item/explosive/grenade/chem_grenade/cleaner = -1,
			/obj/item/explosive/grenade/chem_grenade/metalfoam = -1,
			/obj/item/clothing/glasses/night/imager_goggles = -1,
			/obj/item/clothing/glasses/night/m56_goggles = -1,
			/obj/item/binoculars = -1,
			/obj/item/motiondetector = -1,
			/obj/item/bodybag/tarp = -1,
			/obj/item/tool/soap/deluxe = -1,
			/obj/item/clock = -1,
			/obj/item/storage/bag/trash = -1,
			/obj/item/lightreplacer = -1,
			/obj/item/storage/box/matches = -1,
			/obj/item/storage/box/engineer = 1,
			/obj/item/storage/bible = 1,
			/obj/item/storage/bible/koran = 1,
			/obj/item/minerupgrade/reinforcement = -1,
			/obj/item/minerupgrade/overclock = -1,
			/obj/item/storage/box/monkeycubes = -1,
			/obj/item/storage/box/monkeycubes/farwacubes = -1,
			/obj/item/storage/box/monkeycubes/stokcubes = -1,
			/obj/item/storage/box/monkeycubes/neaeracubes = -1,
			/obj/item/spacecash/c500 = -1,
		),
		"Pouches" = list(
			/obj/item/storage/pouch/general/som = -1,
			/obj/item/storage/pouch/general/medium = -1,
			/obj/item/storage/pouch/general/large = -1,
			/obj/item/storage/pouch/bayonet = -1,
			/obj/item/storage/pouch/pistol = -1,
			/obj/item/storage/pouch/explosive = -1,
			/obj/item/storage/pouch/magazine = -1,
			/obj/item/storage/pouch/magazine/large = -1,
			/obj/item/storage/pouch/magazine/pistol = -1,
			/obj/item/storage/pouch/magazine/pistol/large = -1,
			/obj/item/storage/pouch/shotgun = -1,
			/obj/item/storage/pouch/firstaid/som = -1,
			/obj/item/storage/pouch/medical = -1,
			/obj/item/storage/pouch/syringe = -1,
			/obj/item/storage/pouch/medkit = -1,
			/obj/item/storage/pouch/autoinjector = -1,
			/obj/item/storage/pouch/radio = -1,
			/obj/item/storage/pouch/flare = -1,
			/obj/item/storage/pouch/survival = -1,
			/obj/item/storage/pouch/document = -1,
			/obj/item/storage/pouch/electronics = -1,
			/obj/item/storage/pouch/tools = -1,
			/obj/item/storage/pouch/construction = -1,
			/obj/item/storage/pouch/field_pouch = -1,
			/obj/item/clothing/tie/storage/webbing = -1,
			/obj/item/clothing/tie/storage/black_vest = -1,
			/obj/item/clothing/tie/storage/brown_vest = -1,
			/obj/item/clothing/tie/storage/white_vest/medic = -1,
		),
		"Crates" = list(
			/obj/item/portablecrate/beerkeg = -1,
			/obj/item/portablecrate/watertank = -1,
			/obj/item/portablecrate/fueltank = -1,
			/obj/item/portablecrate/pacman = -1,
			/obj/item/portablecrate/autolathe = -1,
			/obj/item/portablecrate/cigarette = -1,
			/obj/item/portablecrate/boozeomat = -1,
			/obj/item/portablecrate/coffee = -1,
			/obj/item/portablecrate/snack = -1,
			/obj/item/portablecrate/cola = -1,
			/obj/item/portablecrate/cigarette = -1,
			/obj/item/portablecrate/medical = -1,
			/obj/item/portablecrate/phoronresearch = -1,
			/obj/item/portablecrate/security = -1,
			/obj/item/portablecrate/sovietsoda = -1,
			/obj/item/portablecrate/tool = -1,
			/obj/item/portablecrate/engivend = -1,
			/obj/item/portablecrate/robotics = -1,
			/obj/item/portablecrate/kink = -1,
			/obj/item/portablecrate/puppy = -1,
			/obj/item/portablecrate/kitten = -1,
		),
		"Prototypes" = list(
			/obj/item/storage/firstaid/combat = 1,
			/obj/item/storage/pouch/hypospray/corps/full = 1,
			/obj/item/portablecrate/autoinjector = 3,
			/obj/item/reagent_containers/hypospray/advanced/big = 1,
			/obj/item/reagent_containers/hypospray/advanced/combat_advanced = 2,
			/obj/item/reagent_containers/glass/bottle/dermaline = 2,
			/obj/item/reagent_containers/glass/bottle/meraderm = 2,
			/obj/item/reagent_containers/glass/bottle/nanoblood = 2,
			/obj/item/reagent_containers/hypospray/autoinjector/neuraline = 1,
			/obj/item/reagent_containers/glass/beaker/noreact = 3,
			/obj/item/reagent_containers/glass/beaker/bluespace = 2,
			/obj/item/cell/hyper = 4,
			/obj/item/tool/weldingtool/experimental = 1,
			/obj/item/clothing/glasses/welding/superior = 3,
			/obj/item/clothing/glasses/hud/xenohud = 2,
			/obj/item/clothing/glasses/hud/painhud = 2,
			/obj/item/clothing/glasses/night/tx8 = 2,
			/obj/item/clothing/glasses/night/m42_night_goggles/upp = 1,
			/obj/item/clothing/glasses/thermal/m64_thermal_goggles = 1,
			/obj/item/motiondetector/scout = 3,
			/obj/item/storage/box/visual/grenade/cloak = 1,
			/obj/item/storage/box/visual/grenade/drain = 1,
			/obj/item/storage/box/visual/grenade/razorburn = 1,
			/obj/item/storage/box/visual/grenade/teargas = 1,
			/obj/item/storage/box/sentry = 2,
			/obj/item/encryptionkey/mcom = 1,
			/obj/item/clothing/under/marine/veteran/freelancer = 2,
			/obj/item/clothing/suit/storage/faction/freelancer = 2,
			/obj/item/clothing/under/marine/veteran/mercenary = 1,
			/obj/item/clothing/suit/storage/marine/veteran/mercenary = 1,
			/obj/item/clothing/head/helmet/marine/veteran/mercenary = 1,
			/obj/item/clothing/under/marine/veteran/PMC/leader = 1,
			/obj/item/clothing/suit/storage/marine/veteran/PMC/leader = 1,
			/obj/item/clothing/head/helmet/marine/veteran/PMC/leader = 1,
			/obj/item/clothing/under/marine/veteran/PMC/commando = 1,
			/obj/item/clothing/suit/storage/marine/veteran/PMC/sniper = 1,
			/obj/item/clothing/head/helmet/marine/veteran/PMC/sniper = 1,
			/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC = 1,
			/obj/item/clothing/head/helmet/marine/veteran/PMC/gunner = 1,
			/obj/item/clothing/under/marine/veteran/wolves = 1,
			/obj/item/clothing/suit/storage/marine/veteran/wolves = 1,
			/obj/item/clothing/head/helmet/marine/veteran/wolves = 1,
			/obj/item/clothing/under/marine/veteran/dutch/ranger = 1,
			/obj/item/clothing/suit/storage/marine/veteran/dutch = 1,
			/obj/item/clothing/head/helmet/marine/veteran/dutch = 1,
			/obj/item/clothing/head/helmet/HoS/dermal = 1,
			/obj/item/clothing/mask/gas/PMC = 2,
			/obj/item/clothing/mask/gas/PMC/leader = 1,
			/obj/item/clothing/mask/gas/wolves = 1,
		),
	)
	prices = list(
		"Magazines" = list(
			/obj/item/ammo_magazine/pistol/m1911 = 10,
			/obj/item/ammo_magazine/pistol/m1911/polymer = 10,
			/obj/item/ammo_magazine/pistol/g22 = 10,
			/obj/item/ammo_magazine/pistol/g22tranq = 10,
			/obj/item/ammo_magazine/pistol/heavy = 15,
			/obj/item/ammo_magazine/pistol/c99 = 10,
			/obj/item/ammo_magazine/pistol/c99t = 20,
			/obj/item/ammo_magazine/pistol/holdout = 5,
			/obj/item/ammo_magazine/pistol/highpower = 15,
			/obj/item/ammo_magazine/pistol/vp78 = 15,
			/obj/item/ammo_magazine/pistol/auto9 = 15,
			/obj/item/ammo_magazine/revolver/upp = 10,
			/obj/item/ammo_magazine/revolver/small = 10,
			/obj/item/ammo_magazine/revolver/cmb = 10,
			/obj/item/ammo_magazine/revolver = 10,
			/obj/item/ammo_magazine/revolver/polymer = 10,
			/obj/item/ammo_magazine/revolver/marksman = 15,
			/obj/item/ammo_magazine/revolver/heavy = 15,
			/obj/item/ammo_magazine/smg/m25 = 10,
			/obj/item/ammo_magazine/smg/m25/ap = 15,
			/obj/item/ammo_magazine/smg/m25/extended = 15,
			/obj/item/ammo_magazine/smg/mp7 = 10,
			/obj/item/ammo_magazine/smg/skorpion = 10,
			/obj/item/ammo_magazine/smg/ppsh = 10,
			/obj/item/ammo_magazine/smg/ppsh/extended = 15,
			/obj/item/ammo_magazine/smg/uzi = 10,
			/obj/item/ammo_magazine/smg/uzi/extended = 15,
			/obj/item/ammo_magazine/rifle = 25,
			/obj/item/ammo_magazine/rifle/polymer = 25,
			/obj/item/ammo_magazine/rifle/extended = 30,
			/obj/item/ammo_magazine/rifle/incendiary = 30,
			/obj/item/ammo_magazine/rifle/ap = 30,
			/obj/item/ammo_magazine/rifle/m41a = 25,
			/obj/item/ammo_magazine/rifle/ak47 = 25,
			/obj/item/ammo_magazine/rifle/ak47/extended = 30,
			/obj/item/ammo_magazine/rifle/m16 = 25,
			/obj/item/ammo_magazine/rifle/famas = 25,
			/obj/item/ammo_magazine/rifle/type71 = 25,
			/obj/item/ammo_magazine/sniper/svd = 25,
			/obj/item/ammo_magazine/rifle/pepperball = 15,
		),
		"Ammunition" = list(
			/obj/item/ammo_magazine/box9mm = 5,
			/obj/item/ammo_magazine/box9mm/polymer = 5,
			/obj/item/ammo_magazine/acp = 5,
			/obj/item/ammo_magazine/acp/polymer = 5,
			/obj/item/ammo_magazine/magnum = 5,
			/obj/item/ammo_magazine/magnum/polymer = 5,
			/obj/item/ammo_magazine/box10x24mm = 10,
			/obj/item/ammo_magazine/box10x24mm/polymer = 10,
			/obj/item/ammo_magazine/box10x26mm = 10,
			/obj/item/ammo_magazine/box10x26mm/polymer = 10,
			/obj/item/ammo_magazine/shotgun/beanbag/large = 5,
			/obj/item/ammo_magazine/shotgun = 5,
			/obj/item/ammo_magazine/shotgun/incendiary = 10,
			/obj/item/ammo_magazine/shotgun/buckshot = 10,
			/obj/item/ammo_magazine/shotgun/flechette = 10,
			/obj/item/ammo_magazine/shotgun/beanbag = 5,
			/obj/item/ammo_magazine/rifle/bolt = 5,
			/obj/item/ammo_magazine/rifle/martini = 5,
			/obj/item/ammo_magazine/shotgun/mbx900 = 5,
			/obj/item/ammo_magazine/shotgun/mbx900/buckshot = 10,
			/obj/item/ammo_magazine/sentry = 80,
			/obj/item/ammo_magazine/minisentry = 40,
		),
		"Armor" = list(
			/obj/item/clothing/suit/armor/vest/dutch = 500,
			/obj/item/clothing/suit/armor/vest/pilot = 1000,
			/obj/item/clothing/head/helmet/marine/pilot = 1000,
			/obj/item/clothing/head/helmet/marine/pilot/green = 1000,
			/obj/item/clothing/suit/armor/bulletproof = 500,
			/obj/item/clothing/head/helmet = 500,
			/obj/item/clothing/suit/armor/riot = 500,
			/obj/item/clothing/head/helmet/riot = 500,
			/obj/item/clothing/under/marine/veteran/PMC = 200,
			/obj/item/clothing/suit/storage/marine/veteran/PMC = 5000,
			/obj/item/clothing/head/helmet/marine/veteran/PMC = 2500,
			/obj/item/clothing/under/marine/veteran/mercenary/miner = 200,
			/obj/item/clothing/suit/storage/marine/veteran/mercenary/miner = 5000,
			/obj/item/clothing/head/helmet/marine/veteran/mercenary/miner = 2500,
			/obj/item/clothing/under/marine/veteran/mercenary/engineer = 200,
			/obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer = 5500,
			/obj/item/clothing/head/helmet/marine/veteran/mercenary/engineer = 2700,
			/obj/item/clothing/shoes/marine/imperial = 1000,
			/obj/item/clothing/shoes/marine/som = 1000,
			/obj/item/clothing/shoes/swat = 1000,
			/obj/item/clothing/mask/gas = 100,
			/obj/item/clothing/mask/gas/tactical = 150,
			/obj/item/clothing/mask/gas/tactical/coif = 200,
			/obj/item/clothing/mask/rebreather = 50,
			/obj/item/clothing/mask/rebreather/scarf = 50,
		),
		"Medical" = list(
			/obj/item/healthanalyzer = 5,
			/obj/item/reagent_containers/syringe = 5,
			/obj/item/stack/medical/ointment = 5,
			/obj/item/stack/medical/bruise_pack = 5,
			/obj/item/stack/medical/advanced/bruise_pack = 10,
			/obj/item/stack/medical/advanced/ointment = 10,
			/obj/item/stack/medical/splint = 10,
			/obj/item/clothing/glasses/hud/health = 5,
			/obj/item/clothing/glasses/hud/medgoggles = 20,
			/obj/item/storage/pill_bottle/bicaridine = 20,
			/obj/item/storage/pill_bottle/kelotane = 20,
			/obj/item/storage/pill_bottle/tramadol = 25,
			/obj/item/storage/pill_bottle/tricordrazine = 10,
			/obj/item/storage/pill_bottle/inaprovaline = 10,
			/obj/item/storage/pill_bottle/dexalin = 20,
			/obj/item/storage/pill_bottle/dylovene = 20,
			/obj/item/storage/pill_bottle/spaceacillin = 25,
			/obj/item/storage/pill_bottle/alkysine = 30,
			/obj/item/storage/pill_bottle/imidazoline = 30,
			/obj/item/storage/pill_bottle/peridaxon = 30,
			/obj/item/storage/pill_bottle/quickclot = 30,
			/obj/item/storage/pill_bottle/hypervene = 30,
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = 15,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = 15,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = 15,
			/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 15,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/dexalinplus = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 30,
			/obj/item/storage/belt/medical = 2000,
			/obj/item/storage/belt/combatLifesaver/upp = 5000,
			/obj/item/storage/belt/combatLifesaver/som = 5000,
			/obj/item/storage/firstaid/regular = 500,
			/obj/item/storage/firstaid/fire = 1000,
			/obj/item/storage/firstaid/toxin = 1000,
			/obj/item/storage/firstaid/o2 = 1000,
			/obj/item/storage/firstaid/adv = 1500,
			/obj/item/storage/firstaid/rad = 1000,
			/obj/item/bodybag/cryobag = 500,
			/obj/item/tweezers = 5000,
			/obj/item/reagent_containers/blood/OMinus = 500,
			/obj/item/clothing/tie/storage/white_vest/surgery = 2500,
			/obj/item/stack/nanopaste = 1000,
			/obj/item/reagent_containers/hypospray/advanced/tricordrazine = 500,
			/obj/item/reagent_containers/hypospray/advanced/combat = 1500,
			/obj/item/reagent_containers/glass/beaker/large = 100,
		),
		"Engineering" = list(
			/obj/item/stack/sheet/metal/medium_stack = 500,
			/obj/item/stack/sheet/metal/large_stack = 830,
			/obj/item/stack/sheet/plasteel/medium_stack = 1000,
			/obj/item/stack/sheet/plasteel/large_stack = 1600,
			/obj/item/stack/sheet/mineral/phoron/small_stack = 1000,
			/obj/item/stack/sheet/mineral/phoron/medium_stack = 3000,
			/obj/item/stack/sheet/glass/large_stack = 500,
			/obj/item/stack/sheet/wood/large_stack = 100,
			/obj/item/storage/belt/utility/full = 2000,
			/obj/item/clothing/glasses/meson = 50,
			/obj/item/circuitboard/airlock = 50,
			/obj/item/circuitboard/apc = 50,
			/obj/item/circuitboard/airalarm = 50,
			/obj/item/circuitboard/general = 50,
			/obj/item/storage/toolbox/mechanical = 1500,
			/obj/item/storage/toolbox/electrical = 1500,
			/obj/item/storage/toolbox/emergency = 100,
			/obj/item/cell/apc = 400,
			/obj/item/cell/high = 1000,
			/obj/item/cell/super = 1500,
			/obj/item/tool/weldingtool = 200,
			/obj/item/tool/weldingtool/largetank = 600,
			/obj/item/tool/weldingtool/hugetank = 1000,
			/obj/item/tool/weldpack = 1000,
			/obj/item/tool/wirecutters = 200,
			/obj/item/tool/wrench = 200,
			/obj/item/tool/screwdriver = 200,
			/obj/item/tool/crowbar = 200,
			/obj/item/analyzer = 200,
			/obj/item/multitool = 200,
			/obj/item/clothing/head/welding = 100,
			/obj/item/clothing/glasses/welding = 400,
			/obj/item/storage/box/minisentry = 2500,
			/obj/item/tool/pickaxe/plasmacutter = 2500,
			/obj/item/explosive/plastique = 1000,
			/obj/item/quikdeploy/cade = 500,
			/obj/item/storage/briefcase/inflatable = 500,
			/obj/item/storage/box/lights/mixed = 100,
		),
		"Rations" = list(
			/obj/item/reagent_containers/food/snacks/upp = 0,
			/obj/item/storage/box/MRE = 5,
			/obj/item/reagent_containers/food/snacks/packaged_burger = 5,
			/obj/item/reagent_containers/food/snacks/packaged_burrito = 5,
			/obj/item/reagent_containers/food/snacks/packaged_hdogs = 5,
			/obj/item/reagent_containers/food/snacks/kepler_crisps = 5,
			/obj/item/reagent_containers/food/snacks/enrg_bar = 5,
			/obj/item/reagent_containers/food/snacks/wrapped/booniebars = 5,
			/obj/item/reagent_containers/food/snacks/wrapped/chunk = 5,
			/obj/item/reagent_containers/food/snacks/wrapped/barcardine = 5,
			/obj/item/pizzabox/margherita = 100,
			/obj/item/pizzabox/vegetable = 100,
			/obj/item/pizzabox/mushroom = 100,
			/obj/item/pizzabox/meat = 100,
			/obj/item/storage/box/combat_lolipop = 10,
			/obj/item/storage/box/combat_lolipop/tricord = 10,
			/obj/item/storage/box/combat_lolipop/tramadol = 10,
			/obj/item/reagent_containers/food/drinks/coffee = 5,
			/obj/item/reagent_containers/food/drinks/coffee/cafe_latte = 5,
			/obj/item/reagent_containers/food/drinks/tea = 5,
			/obj/item/reagent_containers/food/drinks/h_chocolate = 5,
			/obj/item/reagent_containers/food/drinks/cans/souto = 5,
			/obj/item/reagent_containers/food/drinks/cans/souto/diet = 5,
			/obj/item/reagent_containers/food/drinks/cans/souto/cherry = 5,
			/obj/item/reagent_containers/food/drinks/cans/souto/cherry/diet = 5,
			/obj/item/reagent_containers/food/drinks/cans/souto/lime = 5,
			/obj/item/reagent_containers/food/drinks/cans/souto/lime/diet = 5,
			/obj/item/reagent_containers/food/drinks/cans/souto/grape = 5,
			/obj/item/reagent_containers/food/drinks/cans/souto/grape/diet = 5,
			/obj/item/reagent_containers/food/drinks/cans/waterbottle = 0,
			/obj/item/reagent_containers/food/drinks/cans/cola = 5,
		),
		"Kitchen" = list(
			/obj/item/reagent_containers/food/condiment/enzyme = 20,
			/obj/item/reagent_containers/food/condiment/sugar = 5,
			/obj/item/reagent_containers/food/condiment/saltshaker = 5,
			/obj/item/reagent_containers/food/condiment/peppermill = 5,
			/obj/item/reagent_containers/food/drinks/milk = 5,
			/obj/item/reagent_containers/food/drinks/soymilk = 5,
			/obj/item/storage/fancy/egg_box = 5,
			/obj/item/portablecrate/dinnerware = 1000,
			/obj/item/portablecrate/cow = 100,
			/obj/item/portablecrate/goat = 100,
			/obj/item/portablecrate/chick = 100,
			/obj/item/portablecrate/hydroponics = 500,
			/obj/item/portablecrate/hydronutrients = 1000,
			/obj/item/portablecrate/hydroseeds = 1000,
			/obj/item/reagent_containers/food/drinks/flask/barflask = 5,
			/obj/item/reagent_containers/food/drinks/flask/detflask = 10,
			/obj/item/reagent_containers/food/drinks/flask/vacuumflask = 5,
		),
		"Equipment" = list(
			/obj/item/radio = 0,
			/obj/item/radio/headset = 0,
			/obj/item/flashlight = 5,
			/obj/item/flashlight/lantern = 5,
			/obj/item/flashlight/flare = 0,
			/obj/item/storage/box/m94 = 10,
			/obj/item/explosive/grenade/smokebomb = 5,
			/obj/item/explosive/grenade/chem_grenade/cleaner = 5,
			/obj/item/explosive/grenade/chem_grenade/metalfoam = 10,
			/obj/item/clothing/glasses/night/imager_goggles = 1000,
			/obj/item/clothing/glasses/night/m56_goggles = 2500,
			/obj/item/binoculars = 1000,
			/obj/item/motiondetector = 1000,
			/obj/item/bodybag/tarp = 2500,
			/obj/item/tool/soap/deluxe = 5,
			/obj/item/clock = 5,
			/obj/item/storage/bag/trash = 5,
			/obj/item/lightreplacer = 500,
			/obj/item/storage/box/matches = 10,
			/obj/item/storage/box/engineer = 2500,
			/obj/item/storage/bible = 2500,
			/obj/item/storage/bible/koran = 2500,
			/obj/item/minerupgrade/reinforcement = 2000,
			/obj/item/minerupgrade/overclock = 2000,
			/obj/item/storage/box/monkeycubes = 1000,
			/obj/item/storage/box/monkeycubes/farwacubes = 1000,
			/obj/item/storage/box/monkeycubes/stokcubes = 1000,
			/obj/item/storage/box/monkeycubes/neaeracubes = 1000,
			/obj/item/spacecash/c500 = 500,
		),
		"Pouches" = list(
			/obj/item/storage/pouch/general/som = 200,
			/obj/item/storage/pouch/general/medium = 500,
			/obj/item/storage/pouch/general/large = 800,
			/obj/item/storage/pouch/bayonet = 400,
			/obj/item/storage/pouch/pistol = 400,
			/obj/item/storage/pouch/explosive = 400,
			/obj/item/storage/pouch/magazine = 200,
			/obj/item/storage/pouch/magazine/large = 500,
			/obj/item/storage/pouch/magazine/pistol = 200,
			/obj/item/storage/pouch/magazine/pistol/large = 500,
			/obj/item/storage/pouch/shotgun = 400,
			/obj/item/storage/pouch/firstaid/som = 200,
			/obj/item/storage/pouch/medical = 200,
			/obj/item/storage/pouch/syringe = 200,
			/obj/item/storage/pouch/medkit = 200,
			/obj/item/storage/pouch/autoinjector = 200,
			/obj/item/storage/pouch/radio = 200,
			/obj/item/storage/pouch/flare = 200,
			/obj/item/storage/pouch/survival = 1000,
			/obj/item/storage/pouch/document = 200,
			/obj/item/storage/pouch/electronics = 200,
			/obj/item/storage/pouch/tools = 200,
			/obj/item/storage/pouch/construction = 200,
			/obj/item/storage/pouch/field_pouch = 200,
			/obj/item/clothing/tie/storage/webbing = 100,
			/obj/item/clothing/tie/storage/black_vest = 500,
			/obj/item/clothing/tie/storage/brown_vest = 500,
			/obj/item/clothing/tie/storage/white_vest/medic = 500,
		),
		"Crates" = list(
			/obj/item/portablecrate/beerkeg = 1000,
			/obj/item/portablecrate/watertank = 1000,
			/obj/item/portablecrate/fueltank = 1000,
			/obj/item/portablecrate/pacman = 4000,
			/obj/item/portablecrate/autolathe = 4000,
			/obj/item/portablecrate/cigarette = 1000,
			/obj/item/portablecrate/boozeomat = 1500,
			/obj/item/portablecrate/coffee = 1500,
			/obj/item/portablecrate/snack = 1500,
			/obj/item/portablecrate/cola = 1500,
			/obj/item/portablecrate/medical = 2500,
			/obj/item/portablecrate/phoronresearch = 1500,
			/obj/item/portablecrate/security = 2500,
			/obj/item/portablecrate/sovietsoda = 500,
			/obj/item/portablecrate/tool = 2500,
			/obj/item/portablecrate/engivend = 2500,
			/obj/item/portablecrate/robotics = 2500,
			/obj/item/portablecrate/kink = 1000,
			/obj/item/portablecrate/puppy = 1500,
			/obj/item/portablecrate/kitten = 1500,
		),
		"Prototypes" = list(
			/obj/item/storage/firstaid/combat = 10000,
			/obj/item/storage/pouch/hypospray/corps/full = 7500,
			/obj/item/portablecrate/autoinjector = 4500,
			/obj/item/reagent_containers/hypospray/advanced/big = 5000,
			/obj/item/reagent_containers/hypospray/advanced/combat_advanced = 2500,
			/obj/item/reagent_containers/glass/bottle/dermaline = 5000,
			/obj/item/reagent_containers/glass/bottle/meraderm = 5000,
			/obj/item/reagent_containers/glass/bottle/nanoblood = 5000,
			/obj/item/reagent_containers/hypospray/autoinjector/neuraline = 2500,
			/obj/item/reagent_containers/glass/beaker/noreact = 1000,
			/obj/item/reagent_containers/glass/beaker/bluespace = 1500,
			/obj/item/cell/hyper = 2500,
			/obj/item/tool/weldingtool/experimental = 7500,
			/obj/item/clothing/glasses/welding/superior = 7500,
			/obj/item/clothing/glasses/hud/xenohud = 5000,
			/obj/item/clothing/glasses/hud/painhud = 1500,
			/obj/item/clothing/glasses/night/tx8 = 7500,
			/obj/item/clothing/glasses/night/m42_night_goggles/upp = 10000,
			/obj/item/clothing/glasses/thermal/m64_thermal_goggles = 10000,
			/obj/item/motiondetector/scout = 3000,
			/obj/item/storage/box/visual/grenade/cloak = 2500,
			/obj/item/storage/box/visual/grenade/drain = 2500,
			/obj/item/storage/box/visual/grenade/razorburn = 2500,
			/obj/item/storage/box/visual/grenade/teargas = 2500,
			/obj/item/storage/box/sentry = 5000,
			/obj/item/encryptionkey/mcom = 7500,
			/obj/item/clothing/under/marine/veteran/freelancer = 500,
			/obj/item/clothing/suit/storage/faction/freelancer = 7500,
			/obj/item/clothing/under/marine/veteran/mercenary = 500,
			/obj/item/clothing/suit/storage/marine/veteran/mercenary = 7500,
			/obj/item/clothing/head/helmet/marine/veteran/mercenary = 7500,
			/obj/item/clothing/under/marine/veteran/PMC/leader = 500,
			/obj/item/clothing/suit/storage/marine/veteran/PMC/leader = 7500,
			/obj/item/clothing/head/helmet/marine/veteran/PMC/leader = 7500,
			/obj/item/clothing/under/marine/veteran/PMC/commando = 1000,
			/obj/item/clothing/suit/storage/marine/veteran/PMC/sniper = 7500,
			/obj/item/clothing/head/helmet/marine/veteran/PMC/sniper = 7500,
			/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC = 7500,
			/obj/item/clothing/head/helmet/marine/veteran/PMC/gunner = 7500,
			/obj/item/clothing/under/marine/veteran/wolves = 500,
			/obj/item/clothing/suit/storage/marine/veteran/wolves = 7500,
			/obj/item/clothing/head/helmet/marine/veteran/wolves = 7500,
			/obj/item/clothing/under/marine/veteran/dutch/ranger = 500,
			/obj/item/clothing/suit/storage/marine/veteran/dutch = 7500,
			/obj/item/clothing/head/helmet/marine/veteran/dutch = 7500,
			/obj/item/clothing/head/helmet/HoS/dermal = 5000,
			/obj/item/clothing/mask/gas/PMC = 2500,
			/obj/item/clothing/mask/gas/PMC/leader = 2500,
			/obj/item/clothing/mask/gas/wolves = 1500,
		),
	)

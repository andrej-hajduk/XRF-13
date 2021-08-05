/obj/item/portablecrate
	name = "large case"
	desc = "A hefty wooden case. This one has handles for carrying."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "case"
	density = TRUE
	anchored = FALSE
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 100
	hit_sound = 'sound/effects/woodhit.ogg'
	var/spawn_type
	var/spawn_amount
	w_class = WEIGHT_CLASS_BULKY


/obj/item/portablecrate/deconstruct(disassembled = TRUE)
	spawn_stuff()
	return ..()


/obj/item/portablecrate/examine(mob/user)
	. = ..()
	to_chat(user, span_notice("You need a crowbar to pry this open!"))


/obj/item/portablecrate/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return TRUE

	if(istype(I, /obj/item/powerloader_clamp))
		return

	return attack_hand(user)


/obj/item/portablecrate/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	user.visible_message(span_notice("[user] pries \the [src] open."),
		span_notice("You pry open \the [src]."),
		span_notice("You hear splitting wood."))
	new /obj/item/stack/sheet/wood(loc)
	deconstruct(TRUE)
	return TRUE


/obj/item/portablecrate/proc/spawn_stuff()
	var/turf/T = get_turf(src)
	if(spawn_type && spawn_amount)
		for(var/i in 1 to spawn_amount)
			new spawn_type(T)
	for(var/obj/O in contents)
		O.forceMove(loc)

/obj/item/portablecrate/cow
	name = "cow case"
	spawn_type = /mob/living/simple_animal/cow
	spawn_amount = 1

/obj/item/portablecrate/goat
	name = "goat case"
	spawn_type = /mob/living/simple_animal/hostile/retaliate/goat
	spawn_amount = 1

/obj/item/portablecrate/chick
	name = "chicken case"
	spawn_type = /mob/living/simple_animal/chick
	spawn_amount = 4

/obj/item/portablecrate/puppy
	name = "puppy case"
	spawn_type = /mob/living/simple_animal/corgi/puppy
	spawn_amount = 1

/obj/item/portablecrate/kitten
	name = "kitten case"
	spawn_type = /mob/living/simple_animal/cat/kitten
	spawn_amount = 1

/obj/item/portablecrate/kink
	name = "kinkmate case"
	spawn_type = /obj/machinery/vending/kink
	spawn_amount = 1

/obj/item/portablecrate/robotics
	name = "robotech case"
	spawn_type = /obj/machinery/vending/robotics
	spawn_amount = 1

/obj/item/portablecrate/engivend
	name = "engivend case"
	spawn_type = /obj/machinery/vending/engivend
	spawn_amount = 1

/obj/item/portablecrate/tool
	name = "youtool case"
	spawn_type = /obj/machinery/vending/tool
	spawn_amount = 1

/obj/item/portablecrate/sovietsoda
	name = "boda case"
	spawn_type = /obj/machinery/vending/sovietsoda
	spawn_amount = 1

/obj/item/portablecrate/dinnerware
	name = "dinnerware case"
	spawn_type = /obj/machinery/vending/dinnerware
	spawn_amount = 1

/obj/item/portablecrate/hydroseeds
	name = "hydroseeds case"
	spawn_type = /obj/machinery/vending/hydroseeds
	spawn_amount = 1

/obj/item/portablecrate/hydronutrients
	name = "hydronutrients case"
	spawn_type = /obj/machinery/vending/hydronutrients
	spawn_amount = 1

/obj/item/portablecrate/security
	name = "sectech case"
	spawn_type = /obj/machinery/vending/security
	spawn_amount = 1

/obj/item/portablecrate/phoronresearch
	name = "toximate case"
	spawn_type = /obj/machinery/vending/phoronresearch
	spawn_amount = 1

/obj/item/portablecrate/medical
	name = "nanotrasenmed case"
	spawn_type = /obj/machinery/vending/medical
	spawn_amount = 1

/obj/item/portablecrate/cigarette
	name = "cigarette machine case"
	spawn_type = /obj/machinery/vending/cigarette/colony
	spawn_amount = 1

/obj/item/portablecrate/cola
	name = "softdrinks machine case"
	spawn_type = /obj/machinery/vending/cola
	spawn_amount = 1

/obj/item/portablecrate/snack
	name = "hotfoods machine case"
	spawn_type = /obj/machinery/vending/snack
	spawn_amount = 1

/obj/item/portablecrate/coffee
	name = "coffee machine case"
	spawn_type = /obj/machinery/vending/coffee
	spawn_amount = 1

/obj/item/portablecrate/boozeomat
	name = "boozeomat machine case"
	spawn_type = /obj/machinery/vending/boozeomat
	spawn_amount = 1

/obj/item/portablecrate/cigarette
	name = "cigarette machine case"
	spawn_type = /obj/machinery/vending/cigarette/colony
	spawn_amount = 1

/obj/item/portablecrate/autolathe
	name = "autolathe case"
	spawn_type = /obj/machinery/autolathe
	spawn_amount = 1

/obj/item/portablecrate/pacman
	name = "pacman case"
	spawn_type = /obj/machinery/power/port_gen/pacman
	spawn_amount = 1

/obj/item/portablecrate/fueltank
	name = "fuel tank case"
	spawn_type = /obj/structure/reagent_dispensers/fueltank
	spawn_amount = 1

/obj/item/portablecrate/watertank
	name = "water tank case"
	spawn_type = /obj/structure/reagent_dispensers/watertank
	spawn_amount = 1

/obj/item/portablecrate/beerkeg
	name = "beer keg case"
	spawn_type = /obj/structure/reagent_dispensers/beerkeg
	spawn_amount = 1

/obj/item/portablecrate/hydroponics
	name = "hydroponics case"
	spawn_type = /obj/machinery/portable_atmospherics/hydroponics
	spawn_amount = 1

/obj/item/portablecrate/lightuav
	name = "light uav case"
	spawn_type = /obj/vehicle/unmanned
	spawn_amount = 1

/obj/item/portablecrate/autoinjector
	name = "auto-injector case"
	desc = "A hefty wooden case. This one has handles for carrying. This one contains a shipment of emergency medicine."
	spawn_type = /obj/item/storage/pouch/autoinjector/advanced/full
	spawn_amount = 1

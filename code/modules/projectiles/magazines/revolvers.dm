
//external magazines

/obj/item/ammo_magazine/revolver
	name = "\improper M-44 magnum speed loader (.44)"
	desc = "A revolver speed loader."
	default_ammo = /datum/ammo/bullet/revolver
	flags_equip_slot = NONE
	caliber = CALIBER_44
	icon_state = "m44"
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/m44
	icon_state_mini = "mag_revolver"

/obj/item/ammo_magazine/revolver/polymer
	name = "\improper M-44 magnum PGR speed loader (.44)"
	desc = "A .44 caliber speedloader designed to hold nonlethal polymer gel rounds. Do not consume."
	default_ammo = /datum/ammo/bullet/revolver/polymer
	flags_equip_slot = NONE
	caliber = CALIBER_44
	icon_state = "m44_polymer"
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/m44
	icon_state_mini = "mag_revolver"

/obj/item/ammo_magazine/revolver/marksman
	name = "\improper M-44 marksman speed loader (.44)"
	default_ammo = /datum/ammo/bullet/revolver/marksman
	caliber = CALIBER_44
	icon_state = "m_m44"

/obj/item/ammo_magazine/revolver/heavy
	name = "\improper M-44 PW-MX speed loader (.44)"
	default_ammo = /datum/ammo/bullet/revolver/heavy
	caliber = CALIBER_44
	icon_state = "h_m44"

/obj/item/ammo_magazine/revolver/standard_revolver
	name = "\improper TP-44 magnum speed loader (.44)"
	desc = "A revolver speed loader."
	default_ammo = /datum/ammo/bullet/revolver/tp44
	flags_equip_slot = NONE
	caliber = CALIBER_44
	icon_state = "tp44"
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/standard_revolver

/obj/item/ammo_magazine/revolver/standard_revolver/polymer
	name = "\improper TP-44 magnum PGR speed loader (.44)"
	desc = "A .44 caliber speedloader designed to hold nonlethal polymer gel rounds. Do not consume."
	default_ammo = /datum/ammo/bullet/revolver/polymer
	flags_equip_slot = NONE
	caliber = CALIBER_44
	icon_state = "tp44_polymer"
	w_class = WEIGHT_CLASS_SMALL
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/standard_revolver

/obj/item/ammo_magazine/revolver/upp
	name = "\improper N-Y speed loader (7.62x38mmR)"
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = CALIBER_762X38
	icon_state = "ny762"
	gun_type = /obj/item/weapon/gun/revolver/upp


/obj/item/ammo_magazine/revolver/small
	name = "\improper S&W speed loader (.357)"
	default_ammo = /datum/ammo/bullet/revolver/ricochet/four
	caliber = CALIBER_357
	icon_state = "sw357"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/small


/obj/item/ammo_magazine/revolver/mateba
	name = "\improper Mateba speed loader (.454)"
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = CALIBER_454
	icon_state = "mateba"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/mateba

/obj/item/ammo_magazine/revolver/mateba/polymer
	name = "\improper Mateba PGR speed loader (.454)"
	desc = "A magazine loaded with heavy .454 caliber 'nonlethal' polymer gel revolver rounds."
	default_ammo = /datum/ammo/bullet/revolver/highimpact/polymer
	caliber = CALIBER_454
	icon_state = "mateba_polymer"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/mateba

/obj/item/ammo_magazine/revolver/cmb
	name = "\improper CMB revolver speed loader (.357)"
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = CALIBER_357
	icon_state = "cmb"
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/cmb

<<<<<<< HEAD
=======
//a very literal box of ammunition.
/obj/item/ammo_magazine/magnum
	name = "packet of .44 magnum"
	icon_state = "box_44mag" //Maybe change this
	default_ammo = /datum/ammo/bullet/revolver
	caliber = CALIBER_44
	current_rounds = 49
	max_rounds = 49
	icon_state_mini = "ammo_packet"

/obj/item/ammo_magazine/magnum/polymer
	name = "packet of .44 magnum PGR"
	desc = "A box of .44 magnum nonlethal polymer gel rounds."
	icon_state = "box_44mag_polymer"
	default_ammo = /datum/ammo/bullet/revolver/polymer
	caliber = CALIBER_44
	current_rounds = 49
	max_rounds = 49
	icon_state_mini = "ammo_packet"

/obj/item/ammo_magazine/mateba
	name = "packet of .454 caliber bullets"
	desc = "A box of .454 caliber revolver rounds. Lethal."
	icon_state = "box_mateba"
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = CALIBER_454
	current_rounds = 42
	max_rounds = 42
	icon_state_mini = "ammo_packet"

/obj/item/ammo_magazine/mateba/polymer
	name = "packet of .454 caliber PGR"
	desc = "A box of .454 caliber 'nonlethal' polymer gel rounds."
	icon_state = "box_mateba_polymer"
	default_ammo = /datum/ammo/bullet/revolver/highimpact/polymer
	caliber = CALIBER_454
	current_rounds = 42
	max_rounds = 42
	icon_state_mini = "ammo_packet"
>>>>>>> master

//INTERNAL MAGAZINES

//---------------------------------------------------

/obj/item/ammo_magazine/internal/revolver
	name = "revolver cylinder"
	default_ammo = /datum/ammo/bullet/revolver
	max_rounds = 6

//-------------------------------------------------------

//TP-44 COMBAT REVOLVER //

/obj/item/ammo_magazine/internal/revolver/standard_revolver
	caliber = CALIBER_44
	default_ammo = /datum/ammo/bullet/revolver/tp44
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/standard_revolver

//-------------------------------------------------------
//M44 MAGNUM REVOLVER //

/obj/item/ammo_magazine/internal/revolver/m44
	caliber = CALIBER_44
	max_rounds = 6
	gun_type = /obj/item/weapon/gun/revolver/m44

//-------------------------------------------------------
//RUSSIAN REVOLVER //

/obj/item/ammo_magazine/internal/revolver/upp
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = CALIBER_762X38
	max_rounds = 7
	gun_type = /obj/item/weapon/gun/revolver/upp

//-------------------------------------------------------
//357 REVOLVER //

/obj/item/ammo_magazine/internal/revolver/small
	default_ammo = /datum/ammo/bullet/revolver/ricochet/four
	caliber = CALIBER_357
	gun_type = /obj/item/weapon/gun/revolver/small

//-------------------------------------------------------
//BURST REVOLVER //
/obj/item/ammo_magazine/internal/revolver/mateba
	default_ammo = /datum/ammo/bullet/revolver/highimpact
	caliber = CALIBER_454
	gun_type = /obj/item/weapon/gun/revolver/mateba

/obj/item/ammo_magazine/internal/revolver/mateba/polymer
	default_ammo = /datum/ammo/bullet/revolver/highimpact/polymer
	caliber = CALIBER_454
	gun_type = /obj/item/weapon/gun/revolver/mateba

//-------------------------------------------------------
//MARSHALS REVOLVER //

/obj/item/ammo_magazine/internal/revolver/cmb
	default_ammo = /datum/ammo/bullet/revolver/small
	caliber = CALIBER_357
	gun_type = /obj/item/weapon/gun/revolver/cmb


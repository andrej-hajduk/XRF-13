/obj/item/electropack
	name = "electropack"
	desc = "Dance my monkeys! DANCE!!!"
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "electropack0"
	item_state = "electropack"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE

	materials = list(/datum/material/metal = 10000, /datum/material/glass = 2500)

	var/on = TRUE
	var/code = 2
	var/frequency = FREQ_ELECTROPACK
	var/shock_cooldown = FALSE
	var/tagname = null

/obj/item/electropack/Initialize()
	. = ..()
	SSradio.add_object(src, frequency, RADIO_SIGNALER)


/obj/item/electropack/Destroy()
	SSradio.remove_object(src, frequency)
	return ..()


//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/electropack/attack_hand(mob/living/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.back == src)
			to_chat(user, span_warning("You need help taking this off!"))
			return TRUE
	return ..()


/obj/item/electropack/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["freq"])
		SSradio.remove_object(src, frequency)
		frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
		SSradio.add_object(src, frequency, RADIO_SIGNALER)

	else if(href_list["code"])
		code += text2num(href_list["code"])
		code = round(code)
		code = min(100, code)
		code = max(1, code)

	else if(href_list["power"])
		on = !on
		icon_state = "electropack[on]"

	updateUsrDialog()


/obj/item/electropack/receive_signal(datum/signal/signal)
	if(!signal || signal.data["code"] != code)
		return

	if(isliving(loc) && on)
		var/mob/living/L = loc
		to_chat(L, span_danger("You feel a sharp shock!"))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, L)
		s.start()

		L.Paralyze(20 SECONDS)

	if(master)
		master.receive_signal()


/obj/item/electropack/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.back == src)
			return FALSE

	return TRUE


/obj/item/electropack/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = {"
Turned [on ? "On" : "Off"] -
<A href='?src=[REF(src)];power=1'>Toggle</A><BR>
<B>Frequency/Code</B> for electropack:<BR>
Frequency:
<A href='byond://?src=[REF(src)];freq=-10'>-</A>
<A href='byond://?src=[REF(src)];freq=-2'>-</A> [format_frequency(frequency)]
<A href='byond://?src=[REF(src)];freq=2'>+</A>
<A href='byond://?src=[REF(src)];freq=10'>+</A><BR>

Code:
<A href='byond://?src=[REF(src)];code=-5'>-</A>
<A href='byond://?src=[REF(src)];code=-1'>-</A> [code]
<A href='byond://?src=[REF(src)];code=1'>+</A>
<A href='byond://?src=[REF(src)];code=5'>+</A><BR>
"}

	var/datum/browser/popup = new(user, "electropack")
	popup.set_content(dat)
	popup.open()

/obj/item/electropack/tie/shockcollar
	name = "shock collar"
	desc = "A reinforced metal collar. It seems to have some form of wiring near the front. Strange.."
	icon = 'icons/obj/clothing/cit_neck.dmi'
	icon_state = "shockcollar"
	item_state = "shockcollar"
	flags_equip_slot = NONE   //no more pocket shockers
	w_class = WEIGHT_CLASS_SMALL

/obj/item/electropack/shockcollar/attack_hand(mob/user)
	if(loc == user /*&& user.get_item_by_slot(SLOT_NECK)*/)
		to_chat(user, "<span class='warning'>The collar is fastened tight! You'll need help taking this off!</span>")
		return
	return ..()

/obj/item/electropack/shockcollar/receive_signal(datum/signal/signal)
	if(!signal || signal.data["code"] != code)
		return

	if(isliving(loc) && on)
		if(shock_cooldown == TRUE)
			return
		shock_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, shock_cooldown, FALSE), 100)
		var/mob/living/L = loc
		step(L, pick(GLOB.cardinals))

		to_chat(L, "<span class='danger'>You feel a sharp shock from the collar!</span>")
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, L)
		s.start()

		L.Paralyze(20 SECONDS)

	if(master)
		master.receive_signal()
	return

/obj/item/electropack/shockcollar/attackby(obj/item/W, mob/user, params) //moves it here because on_click is being bad
	if(istype(W, /obj/item/tool/hand_labeler))
		var/t = stripped_input(user, "Would you like to change the name on the tag?", "Name your new pet", tagname ? tagname : "Spot", MAX_NAME_LEN)
		if(t)
			tagname = t
			name = "[initial(name)] - [t]"
	else
		return ..()

/obj/item/electropack/shockcollar/ui_interact(mob/user) //on_click calls this
	var/dat = {"
<TT>
<B>Frequency/Code</B> for shock collar:<BR>
Frequency:
[format_frequency(src.frequency)]
<A href='byond://?src=[REF(src)];set=freq'>Set</A><BR>
Code:
[src.code]
<A href='byond://?src=[REF(src)];set=code'>Set</A><BR>
</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

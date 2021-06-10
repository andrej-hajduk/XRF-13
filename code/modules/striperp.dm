/*
   .---.  .---.           ,---. _______ .-. .-.,-..-. .-.  ,--,    .-.  .-.,-.  ,--,  ,-. .-.,---.   ,'|"\
  ( .-._)/ .-. ) |\    /| | .-'|__   __|| | | ||(||  \| |.' .'     | |/\| ||(|.' .')  | |/ / | .-'   | |\ \
 (_) \   | | |(_)|(\  / | | `-.  )| |   | `-' |(_)|   | ||  |  __  | /  \ |(_)|  |(_) | | /  | `-.   | | \ \
 _  \ \  | | | | (_)\/  | | .-' (_) |   | .-. || || |\  |\  \ ( _) |  /\  || |\  \    | | \  | .-'   | |  \ \
( `-'  ) \ `-' / | \  / | |  `--. | |   | | |)|| || | |)| \  `-) ) |(/  \ || | \  `-. | |) \ |  `--. /(|`-' /
 `----'   )---'  | |\/| | /( __.' `-'   /(  (_)`-'/(  (_) )\____/  (_)   \|`-'  \____\|((_)-'/( __.'(__)`--'
         (_)     '-'  '-'(__)          (__)      (__)    (__)                         (_)   (__)



 _______ .-. .-.,-.   .---.  .-.  .-.  .--..-.   .-.   ,--,  .-. .-.           .---.
|__   __|| | | ||(|  ( .-._) | |/\| | / /\ \\ \_/ )/ .' .')  | | | ||\    /|  ( .-._)
  )| |   | `-' |(_) (_) \    | /  \ |/ /__\ \\   (_) |  |(_) | | | ||(\  / | (_) \
 (_) |   | .-. || | _  \ \   |  /\  ||  __  | ) (    \  \    | | | |(_)\/  | _  \ \
   | |   | | |)|| |( `-'  )  |(/  \ || |  |)| | |     \  `-. | `-')|| \  / |( `-'  )
   `-'   /(  (_)`-' `----'   (_)   \||_|  (_)/(_|      \____\`---(_)| |\/| | `----'
        (__)                                (__)                    '-'  '-'

*/

//So below is the actual menu that shows up when you click forbidden fruit in strip menu. I shall dub the system, striperp - Wel

/mob/living/carbon/human/erp_menu(mob/living/user) //this is the menu that pops up for forbidden fruits. Make edits here. The href's are in human.dm as I don't wanna move the whole topic and break something
	user.set_interaction(src)
	var/dat = {"
	<BR><A href='?src=[REF(src)];slapass=1'>Slap Ass</A>
	<BR><A href='?src=[REF(src)];fondlechest=1'>Fondle Chest</A>
	<BR>"}


	var/datum/browser/browser = new(user, "mob[name]", "<div align='center'>[name]</div>", 380, 540)
	browser.set_content(dat)
	browser.open(FALSE)


//This is the auto-coom proc, straight forward, it'll be called in the actual menu with if statements

/mob/living/carbon/proc/auto_coom()
	if(src.gender == MALE)
		if(lust >= 100 && male_cd <= 15)
			new /obj/effect/decal/cleanable/semen(src.loc)
			visible_message("[src] can't take it anymore! They begin to ejaculate!")
			src.male_cd = 25 //this shouldn't take super long to go down, can be adjusted as needed.
		else
			to_chat(src, "You've only just recently cum! You need to give your body a moment to replenish your stores!")
	else
		if(lust >= 100)
			new /obj/effect/decal/cleanable/femcum(src.loc)
			visible_message("[src]s' body begins to shake as she goes into an orgasm!")
			female_moan = pick('sound/voice/sexymoan_female1.ogg','sound/voice/sexymoan_female2.ogg','sound/voice/sexymoan_female3.ogg','sound/voice/sexymoan_female4.ogg','sound/voice/sexymoan_female5.ogg','sound/voice/sexymoan_female6.ogg','sound/voice/sexymoan_female7.ogg',)
			playsound(loc, female_moan, 70, 1, 1)
			return

/mob/living/carbon/Stat() //Displays current lust in status tab, had to grab usual stat stuff to not override.
	if(statpanel("Status"))
		if(GLOB.round_id)
			stat("Round ID:", GLOB.round_id)
		stat("Operation Time:", stationTimestamp("hh:mm"))
		stat("Current Map:", length(SSmapping.configs) ? SSmapping.configs[GROUND_MAP].map_name : "Loading...")
		stat("Current Ship:", length(SSmapping.configs) ? SSmapping.configs[SHIP_MAP].map_name : "Loading...")
		stat("Game Mode:", "[GLOB.master_mode]")
		if(max_lust > 0)
			stat("Arousal:", "[lust]/[max_lust]")

/mob/living/carbon/proc/handle_moans() //This just makes checking for moans easier. We'll do by gender for now. Uses carbon defines for the var, then pick procs fill it below to add randomness.
	if(src.gender == MALE)
		if(prob(30))
			male_moan = pick('sound/voice/sexymoan_male1.ogg','sound/voice/sexymoan_male2.ogg','sound/voice/sexymoan_male3.ogg','sound/voice/sexymoan_male4.ogg','sound/voice/sexymoan_male5.ogg',)
			playsound(loc, male_moan, 70, 1, 1)
	else
		if(prob(30))
			female_moan = pick('sound/voice/sexymoan_female1.ogg','sound/voice/sexymoan_female2.ogg','sound/voice/sexymoan_female3.ogg','sound/voice/sexymoan_female4.ogg','sound/voice/sexymoan_female5.ogg','sound/voice/sexymoan_female6.ogg','sound/voice/sexymoan_female7.ogg',)
			playsound(loc, female_moan, 70, 1, 1)


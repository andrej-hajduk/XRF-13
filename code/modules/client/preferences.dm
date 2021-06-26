GLOBAL_LIST_EMPTY(preferences_datums)

#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='14%'>"
#define MAX_MUTANT_ROWS 4

/datum/preferences
	var/client/parent

	//Basics
	var/path
	var/default_slot = 1
	var/savefile_version = 0

	//Admin
	var/muted = NONE
	var/last_ip
	var/last_id
	var/updating_icon = FALSE

	//Game preferences
	var/lastchangelog = ""	//Hashed changelog
	var/ooccolor = "#b82e00"
	var/be_special = BE_SPECIAL_DEFAULT	//Special role selection
	var/ui_style = "Midnight"
	var/ui_style_color = "#ffffff"
	var/ui_style_alpha = 230
	var/tgui_fancy = TRUE
	var/tgui_lock = FALSE
	var/toggles_deadchat = TOGGLES_DEADCHAT_DEFAULT
	var/toggles_chat = TOGGLES_CHAT_DEFAULT
	var/toggles_sound = TOGGLES_SOUND_DEFAULT
	var/toggles_gameplay = TOGGLES_GAMEPLAY_DEFAULT

	var/ghost_hud = TOGGLES_GHOSTHUD_DEFAULT
	var/ghost_vision = TRUE
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_form = GHOST_DEFAULT_FORM
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/observer_actions = TRUE

	var/show_typing = TRUE
	var/windowflashing = TRUE
	var/focus_chat = FALSE
	var/clientfps = 0

	// Custom Keybindings
	var/list/key_bindings = null

	// Custom emotes list
	var/list/custom_emotes = list()

	///Saves chemical recipes based on client so they persist through games
	var/list/chem_macros = list()

	//Synthetic specific preferences
	var/synthetic_name = "David"
	var/synthetic_type = "Synthetic"

	//Xenomorph specific preferences
	var/xeno_name = "Undefined"

	//AI specific preferences
	var/ai_name = "ARES v3.2"

	//Character preferences
	var/real_name = ""
	var/random_name = FALSE
	var/gender = MALE
	var/age = 20
	var/species = "Human"
	var/ethnicity = "Western"
	var/body_type = "Mesomorphic (Average)"
	var/good_eyesight = TRUE
	var/preferred_squad = "None"
	var/alternate_option = RETURN_TO_LOBBY
	var/preferred_slot = SLOT_S_STORE
	var/list/gear = list()
	var/list/job_preferences = list()

	//Clothing
	var/underwear = 1
	var/undershirt = 1
	var/backpack = 2

	//Hair style
	var/h_style = "Bald"
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0

	var/grad_style = "None"
	var/r_grad = 0
	var/g_grad = 0
	var/b_grad = 0

	//Facial hair
	var/f_style = "Shaved"
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0

	//Eyes
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0

	//Lore
	var/citizenship = "TerraGov"
	var/religion = "None"
	var/nanotrasen_relation = "Neutral"
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""
	var/xeno_desc = ""

	var/list/exp = list()
	var/list/menuoptions = list()

	// Hud tooltip
	var/tooltips = TRUE

	///Whether to mute goonchat combat messages when we are the source, such as when we are shot.
	var/mute_self_combat_messages = FALSE
	///Whether to mute goonchat combat messages from others, such as when they are shot.
	var/mute_others_combat_messages = FALSE
	///Whether to mute xeno health alerts from when other xenos are badly hurt.
	var/mute_xeno_health_alert_messages = TRUE

	/// Chat on map
	var/chat_on_map = TRUE
	var/see_chat_non_mob = FALSE
	var/max_chat_length = CHAT_MESSAGE_MAX_LENGTH
	///Whether emotes will be displayed on runechat. Requires chat_on_map to have effect.
	var/see_rc_emotes = TRUE

	var/auto_fit_viewport = TRUE

	///The loadout manager
	var/datum/loadout_manager/loadout_manager
	/// New TGUI Preference preview
	var/map_name = "player_pref_map"
	var/obj/screen/map_view/screen_main
	var/obj/screen/background/screen_bg

	var/current_tab = 0
	var/character_tab = 0

	var/list/features = MANDATORY_FEATURE_LIST

	var/list/list/mutant_bodyparts = list()
	var/list/list/body_markings = list()

	var/color_customization = FALSE
	var/mismatched_parts = FALSE

	var/preview_pref = PREVIEW_PREF_JOB
	var/datum/scream_type/pref_scream = new /datum/scream_type/human() //Scream type
	var/scream_id

/datum/preferences/New(client/C)
	if(!istype(C))
		return

	parent = C

	// Initialize map objects
	screen_main = new
	screen_main.name = "screen"
	screen_main.assigned_map = map_name
	screen_main.del_on_map_removal = FALSE
	screen_main.screen_loc = "[map_name]:1,1"

	screen_bg = new
	screen_bg.assigned_map = map_name
	screen_bg.del_on_map_removal = FALSE
	screen_bg.icon_state = "clear"
	screen_bg.fill_rect(1, 1, 4, 1)

	if(!IsGuestKey(C.key))
		load_path(C.ckey)
		if(!load_loadout_manager())
			loadout_manager = new 
		if(load_preferences() && load_character())
			return

	// We don't have a savefile or we failed to load them
	SetSpecies("Human")
	random_character()
	menuoptions = list()
	key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key) // give them default keybinds and update their movement keys
	for(var/i in 1 to CUSTOM_EMOTE_SLOTS)
		var/datum/custom_emote/emote = new
		emote.id = i
		custom_emotes += emote
	C.update_movement_keys(src)
	loadout_manager = new


/datum/preferences/can_interact(mob/user)
	return TRUE


/datum/preferences/proc/ShowChoices(mob/user)
	if(!user?.client)
		return

	update_preview_icon()
	
	var/dat

	dat += {"
	<style>
	.column {
		float: left;
		width: 50%;
	}
	.row:after {
		content: "";
		display: table;
		clear: both;
	}
	</style>
	"}

	dat += "<center>"

	if(!path)
		dat += "<div class='notice'>Please create an account to save your preferences.</div>"

	dat += "</center>"

	if(path)
		var/savefile/S = new (path)
		if(S)
			dat += "<center>"
			var/name
			var/unspaced_slots = 0
			for(var/i = 1, i <= MAX_SAVE_SLOTS, i++)
				unspaced_slots++
				if(unspaced_slots > 4)
					dat += "<br>"
					unspaced_slots = 0
				S.cd = "/character[i]"
				S["real_name"] >> name
				if(!name)
					name = "Character[i]"
				dat += "<a style='white-space:nowrap;' href='?_src_=prefs;preference=changeslot;num=[i];' [i == default_slot ? "class='linkOn'" : ""]>[name]</a> "
			dat += "</center>"

	dat += "<style>span.color_holder_box{display: inline-block; width: 20px; height: 8px; border:1px solid #000; padding: 0px;}</style>"

	dat += "<HR><center>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>Game Preferences</a>"
	dat += "<HR></center>"

	switch(current_tab)
		if(0) //Character Settings
			dat += "<center><a href='?_src_=prefs;preference=character_tab;tab=0' [character_tab == 0 ? "class='linkOn'" : ""]>General</a>"
			dat += "<a href='?_src_=prefs;preference=character_tab;tab=1' [character_tab == 1 ? "class='linkOn'" : ""]>Appearances</a>"
			dat += "<a href='?_src_=prefs;preference=character_tab;tab=2' [character_tab == 2 ? "class='linkOn'" : ""]>Body Markings</a>"
			dat += "<HR>"
			dat += "<table width='100%'>"
			dat += "<tr>"
			dat += "<td width=35%>"
			dat += "Preview:"
			dat += "<a href='?_src_=prefs;preference=character_preview;tab=[PREVIEW_PREF_JOB]' [preview_pref == PREVIEW_PREF_JOB ? "class='linkOn'" : ""]>[PREVIEW_PREF_JOB]</a>"
			dat += "<a href='?_src_=prefs;preference=character_preview;tab=[PREVIEW_PREF_UNDERWEAR]' [preview_pref == PREVIEW_PREF_UNDERWEAR ? "class='linkOn'" : ""]>[PREVIEW_PREF_UNDERWEAR]</a>"
			dat += "<a href='?_src_=prefs;preference=character_preview;tab=[PREVIEW_PREF_NAKED]' [preview_pref == PREVIEW_PREF_NAKED ? "class='linkOn'" : ""]>[PREVIEW_PREF_NAKED]</a>"
			dat += "</td>"
			dat += "<td width=35%>"
			dat += "<b>Mismatched parts:</b> <a href='?_src_=prefs;preference=mismatch'>[(mismatched_parts) ? "Enabled" : "Disabled"]</a>"
			dat += "</td>"

			dat += "<td width=30%>"
			dat += "<b> Color customization:</b> <a href='?_src_=prefs;preference=adv_colors'>[(color_customization) ? "Enabled" : "Disabled"]</a>"
			if(color_customization)
				dat += "<a href='?_src_=prefs;preference=change_bodypart;task=reset_all_colors'>Reset colors</a><BR>"
			dat += "</td>"

			dat += "</tr>"
			dat += "</table>"
			dat += "</center>"
			dat += "<HR>"
			switch(character_tab)
				if(0) //General
					dat += "<center>"
					dat += "<a href='?_src_=prefs;preference=jobmenu'>Set Role Preferences</a><br>"
					dat += "<a href='?_src_=prefs;preference=keybindings_menu'>Keybindings</a>"
					dat += "</center>"

					dat += "<div class='row'>"
					dat += "<div class='column'>"



					dat += "<h2>Identity</h2>"

					if(is_banned_from(user.ckey, "Appearance"))
						dat += "You are banned from using custom names and appearances.<br>"

					dat += "<b>Name:</b> "
					dat += "<a href='?_src_=prefs;preference=name_real'><b>[real_name]</b></a>"
					dat += "<a href='?_src_=prefs;preference=randomize_name'>(R)</a>"
					dat += "<br>"
					dat += "Always Pick Random Name: <a href='?_src_=prefs;preference=random_name'>[random_name ? "Yes" : "No"]</a>"
					dat += "<br><br>"
					dat += "<b>Synthetic Name:</b>"
					dat += "<a href='?_src_=prefs;preference=synth_name'>[synthetic_name]</a>"
					dat += "<br>"
					dat += "<b>Synthetic Type:</b>"
					dat += "<a href='?_src_=prefs;preference=synth_type'>[synthetic_type]</a>"
					dat += "<br>"
					dat += "<b>Xenomorph name:</b>"
					dat += "<a href='?_src_=prefs;preference=xeno_name'>[xeno_name]</a>"
					dat += "<br>"
					dat += "<b>AI name:</b>"
					dat += "<a href='?_src_=prefs;preference=ai_name'>[ai_name]</a>"
					dat += "<br><br>"



					dat += "<h2>Body</h2>"

					dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age'>[age]</a><br>"
					dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[gender == MALE ? MALE : FEMALE]</a><br>"
					dat += "<b>Ethnicity:</b> <a href='?_src_=prefs;preference=ethnicity'>[ethnicity]</a><br>"
					dat += "<b>Species:</b> <a href='?_src_=prefs;preference=species'>[species]</a><br>"
					dat += "<b>Scream:</b><a href='?_src_=prefs;preference=scream;task=input'>[pref_scream.name]</a><BR>"
					dat += "<b>Body Type:</b> <a href='?_src_=prefs;preference=body_type'>[body_type]</a><br>"
					dat += "<b>Good Eyesight:</b> <a href='?_src_=prefs;preference=eyesight'>[good_eyesight ? "Yes" : "No"]</a><br>"
					dat += "<br>"

					var/datum/species/current_species = GLOB.all_species[species]
					if(current_species.preferences)
						for(var/preference_id in current_species.preferences)
							dat += "<b>[current_species.preferences[preference_id]]:</b> <a href='?_src_=prefs;preference=[preference_id]'><b>[vars[preference_id]]</b></a><br>"

					dat += "<a href='?_src_=prefs;preference=random'>Randomize</a>"



					dat += "<h2>Occupation Choices:</h2>"

					for(var/role in BE_SPECIAL_FLAGS)
						var/n = BE_SPECIAL_FLAGS[role]
						var/ban_check_name

						switch(role)
							if("Xenomorph")
								ban_check_name = ROLE_XENOMORPH

							if("Xeno Queen")
								ban_check_name = ROLE_XENO_QUEEN

						if(is_banned_from(user.ckey, ban_check_name))
							dat += "<b>[role]:</b> <a href='?_src_=prefs;preference=bancheck;role=[role]'>BANNED</a><br>"
						else
							dat += "<b>[role]:</b> <a href='?_src_=prefs;preference=be_special;flag=[n]'>[CHECK_BITFIELD(be_special, n) ? "Yes" : "No"]</a><br>"

					dat += "<br><b>Preferred Squad:</b> <a href ='?_src_=prefs;preference=squad'>[preferred_squad]</a><br>"




					dat += "</div>"
					dat += "<div class='column'>"




					dat += "<h2>Marine Gear:</h2>"
					if(gender == MALE)
						dat += "<b>Underwear:</b> <a href ='?_src_=prefs;preference=underwear'>[GLOB.underwear_m[underwear]]</a><br>"
					else
						dat += "<b>Underwear:</b> <a href ='?_src_=prefs;preference=underwear'>[GLOB.underwear_f[underwear]]</a><br>"

					dat += "<b>Undershirt:</b> <a href='?_src_=prefs;preference=undershirt'>[GLOB.undershirt_t[undershirt]]</a><br>"

					dat += "<b>Backpack Type:</b> <a href ='?_src_=prefs;preference=backpack'>[GLOB.backpacklist[backpack]]</a><br>"

					dat += "<b>Custom Loadout:</b> "
					var/total_cost = 0

					if(!islist(gear))
						gear = list()

					if(length(gear))
						dat += "<br>"
						for(var/i in GLOB.gear_datums)
							var/datum/gear/G = GLOB.gear_datums[i]
							if(!G || !gear.Find(i))
								continue
							total_cost += G.cost
							dat += "[i] ([G.cost] points) <a href ='?_src_=prefs;preference=loadoutremove;gear=[i]'>\[remove\]</a><br>"

						dat += "<b>Used:</b> [total_cost] points."
					else
						dat += "None"

					if(total_cost < MAX_GEAR_COST)
						dat += " <a href ='?_src_=prefs;preference=loadoutadd'>\[add\]</a>"
						if(length(gear))
							dat += " <a href ='?_src_=prefs;preference=loadoutclear'>\[clear\]</a>"



					dat += "<h2>Background Information:</h2>"

					dat += "<b>Citizenship</b>: <a href ='?_src_=prefs;preference=citizenship'>[citizenship]</a><br/>"
					dat += "<b>Religion</b>: <a href ='?_src_=prefs;preference=religion'>[religion]</a><br/>"
					dat += "<b>Corporate Relation:</b> <a href ='?_src_=prefs;preference=corporation'>[nanotrasen_relation]</a><br>"
					dat += "<br>"

					dat += "<a href ='?_src_=prefs;preference=records'>Character Records</a><br>"

					dat += "<a href ='?_src_=prefs;preference=flavor_text'>Character Description</a><br>"

				if(1) //Appearances
					dat += "<table width='100%'><tr><td width='17%' valign='top'>"

					dat += "<h3>Hair</h3> <a href='?_src_=prefs;preference=hairstyle'>[h_style]</a><BR><a href='?_src_=prefs;preference=haircolor'><span class='color_holder_box' style='background-color:#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]'></span></a><BR>"

					dat += "<h3>Gradient</h3> <a href='?_src_=prefs;preference=grad_style'>[grad_style]</a><BR><a href='?_src_=prefs;preference=grad_color'><span class='color_holder_box' style='background-color:#[num2hex(r_grad, 2)][num2hex(g_grad, 2)][num2hex(b_grad)]'></span></a><BR>"

					dat += "<h3>Facial Hair</h3> <a href='?_src_=prefs;preference=facialstyle'>[f_style]</a><BR><a href='?_src_=prefs;preference=facialcolor'><span class='color_holder_box' style='background-color:#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]'></span></a><BR>"

					dat += "<h3>Eyes</h3> <a href='?_src_=prefs;preference=eyecolor'><span class='color_holder_box' style='background-color:#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]'></span></a><BR>"

					dat += APPEARANCE_CATEGORY_COLUMN

					dat += "<h3>Primary Color</h3>"
					dat += "<a href='?_src_=prefs;preference=mutant_color'><span class='color_holder_box' style='background-color:#[features["mcolor"]]'></span></a><BR>"

					dat += "<h3>Secondary Color</h3>"
					dat += "<a href='?_src_=prefs;preference=mutant_color2'><span class='color_holder_box' style='background-color:#[features["mcolor2"]]'></span></a><BR>"

					dat += "<h3>Tertiary Color</h3>"
					dat += "<a href='?_src_=prefs;preference=mutant_color3'><span class='color_holder_box' style='background-color:#[features["mcolor3"]]'></span></a><BR>"

					var/mutant_category = 0
					var/list/generic_cache = GLOB.generic_accessories
					for(var/key in mutant_bodyparts)
						if(!generic_cache[key]) //This means that we have a mutant bodypart that shouldnt be bundled here
							continue
						if(!mutant_category)
							dat += APPEARANCE_CATEGORY_COLUMN

						dat += "<h3>[generic_cache[key]]</h3>"

						dat += print_bodypart_change_line(key)

						dat += "<BR>"

						mutant_category++
						if(mutant_category >= MAX_MUTANT_ROWS)
							dat += "</td>"
							mutant_category = 0
					dat += "</tr></table>"

					dat += "<table width='100%'><tr><td width='24%' valign='top'>"
					dat += "</td>"
					dat += "</tr></table>"
				if(2) //Body Markings
					dat += "Use a <b>markings preset</b>: <a href='?_src_=prefs;preference=change_marking;task=use_preset'>Choose</a>  "
					dat += "<table width='100%' align='center'>"
					dat += " Primary:<span style='border: 1px solid #161616; background-color: #[features["mcolor"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color'>Change</a>"
					dat += " Secondary:<span style='border: 1px solid #161616; background-color: #[features["mcolor2"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color2'>Change</a>"
					dat += " Tertiary:<span style='border: 1px solid #161616; background-color: #[features["mcolor3"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color3'>Change</a>"
					dat += "</table>"
					dat += "<table width='100%'>"
					dat += "<td valign='top' width='50%'>"
					var/iterated_markings = 0
					for(var/zone in GLOB.marking_zones)
						var/named_zone = " "
						switch(zone)
							if(BODY_ZONE_R_ARM)
								named_zone = "Right Arm"
							if(BODY_ZONE_L_ARM)
								named_zone = "Left Arm"
							if(BODY_ZONE_HEAD)
								named_zone = "Head"
							if(BODY_ZONE_CHEST)
								named_zone = "Chest"
							if(BODY_ZONE_R_LEG)
								named_zone = "Right Leg"
							if(BODY_ZONE_L_LEG)
								named_zone = "Left Leg"
							if(BODY_ZONE_PRECISE_R_HAND)
								named_zone = "Right Hand"
							if(BODY_ZONE_PRECISE_L_HAND)
								named_zone = "Left Hand"
						dat += "<center><h3>[named_zone]</h3></center>"
						dat += "<table align='center'; width='100%'; height='100px'; style='background-color:#13171C'>"
						dat += "<tr style='vertical-align:top'>"
						dat += "<td width=10%><font size=2> </font></td>"
						dat += "<td width=6%><font size=2> </font></td>"
						dat += "<td width=25%><font size=2> </font></td>"
						dat += "<td width=44%><font size=2> </font></td>"
						dat += "<td width=15%><font size=2> </font></td>"
						dat += "</tr>"

						if(body_markings[zone])
							for(var/key in body_markings[zone])
								var/datum/body_marking/BD = GLOB.body_markings[key]
								var/can_move_up = " "
								var/can_move_down = " "
								var/color_line = " "
								var/current_index = LAZYFIND(body_markings[zone], key)
								if(BD.always_color_customizable || color_customization)
									var/color = body_markings[zone][key]
									color_line = "<a href='?_src_=prefs;name=[key];key=[zone];preference=change_marking;task=reset_color'>R</a>"
									color_line += "<a href='?_src_=prefs;name=[key];key=[zone];preference=change_marking;task=change_color'><span class='color_holder_box' style='background-color:["#[color]"]'></span></a>"
								if(current_index < length(body_markings[zone]))
									can_move_down = "<a href='?_src_=prefs;name=[key];key=[zone];preference=change_marking;task=marking_move_down'>Down</a>"
								if(current_index > 1)
									can_move_up = "<a href='?_src_=prefs;name=[key];key=[zone];preference=change_marking;task=marking_move_up'>Up</a>"
								dat += "<tr style='vertical-align:top;'>"
								dat += "<td>[can_move_up]</td>"
								dat += "<td>[can_move_down]</td>"
								dat += "<td><a href='?_src_=prefs;name=[key];key=[zone];preference=change_marking;task=change_marking'>[key]</a></td>"
								dat += "<td>[color_line]</td>"
								dat += "<td><a href='?_src_=prefs;name=[key];key=[zone];preference=change_marking;task=remove_marking'>Remove</a></td>"
								dat += "</tr>"

						if(!(body_markings[zone]) || body_markings[zone].len < MAXIMUM_MARKINGS_PER_LIMB)
							dat += "<tr style='vertical-align:top;'>"
							dat += "<td> </td>"
							dat += "<td> </td>"
							dat += "<td> </td>"
							dat += "<td> </td>"
							dat += "<td><a href='?_src_=prefs;key=[zone];preference=change_marking;task=add_marking'>Add</a></td>"
							dat += "</tr>"

						dat += "</table>"

						iterated_markings += 1
						if(iterated_markings >= 4)
							dat += "<td valign='top' width='50%'>"
							iterated_markings = 0

					dat += "</tr></table>"

		if(1) //Game Preferences
			dat += "<h2>Game Settings:</h2>"
			dat += "<b>Window Flashing:</b> <a href='?_src_=prefs;preference=windowflashing'>[windowflashing ? "Yes" : "No"]</a><br>"
			dat += "<b>Focus chat:</b> <a href='?_src_=prefs;preference=focus_chat'>[(focus_chat) ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Tooltips:</b> <a href='?_src_=prefs;preference=tooltips'>[(tooltips) ? "Shown" : "Hidden"]</a><br>"
			dat += "<b>FPS:</b> <a href='?_src_=prefs;preference=clientfps'>[clientfps]</a><br>"
			dat += "<b>Fit Viewport:</b> <a href='?_src_=prefs;preference=auto_fit_viewport'>[auto_fit_viewport ? "Auto" : "Manual"]</a><br>"

			dat += "<h2>Chat Message Settings:</h2>"
			dat += "<b>Mute self combat messages:</b> <a href='?_src_=prefs;preference=mute_self_combat_messages'>[mute_self_combat_messages ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Mute others combat messages:</b> <a href='?_src_=prefs;preference=mute_others_combat_messages'>[mute_others_combat_messages ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Mute xeno health alert messages:</b> <a href='?_src_=prefs;preference=mute_xeno_health_alert_messages'>[mute_xeno_health_alert_messages ? "Yes" : "No"]</a><br>"

			dat += "<h2>Runechat Settings:</h2>"
			dat += "<b>Show Runechat Chat Bubbles:</b> <a href='?_src_=prefs;preference=chat_on_map'>[chat_on_map ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Runechat message char limit:</b> <a href='?_src_=prefs;preference=max_chat_length;task=input'>[max_chat_length]</a><br>"
			dat += "<b>See Runechat for non-mobs:</b> <a href='?_src_=prefs;preference=see_chat_non_mob'>[see_chat_non_mob ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>See Runechat emotes:</b> <a href='?_src_=prefs;preference=see_rc_emotes'>[see_rc_emotes ? "Enabled" : "Disabled"]</a><br>"

			dat += "<h2>UI Customization:</h2>"
			dat += "<b>Style:</b> <a href='?_src_=prefs;preference=ui'>[ui_style]</a><br>"
			dat += "<b>Color</b>: <a href='?_src_=prefs;preference=uicolor'>[ui_style_color]</a> <table style='display:inline;' bgcolor='[ui_style_color]'><tr><td>__</td></tr></table><br>"
			dat += "<b>Alpha</b>: <a href='?_src_=prefs;preference=uialpha'>[ui_style_alpha]</a>"



	dat += "</div></div>"


	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_browser", "<div align='center'>Character Setup</div>", 640, 770)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "preferences_window", src)


/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs, widthPerColumn = 305, height = 620)
	if(!SSjob)
		return

	//limit - The amount of jobs allowed per column.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.

	var/width = widthPerColumn

	var/HTML = "<center>"
	if(!length(SSjob.joinable_occupations))
		HTML += "The job subsystem hasn't initialized yet, please try again later."
		HTML += "<center><a href='?_src_=prefs;preference=jobclose'>Done</a></center><br>" // Easier to press up here.

	else
		HTML += "<b>Choose role preferences.</b><br>"
		HTML += "<div align='center'>Left-click to raise the preference, right-click to lower it.<br></div>"
		HTML += "<center><a href='?_src_=prefs;preference=jobclose'>Done</a></center><br>" // Easier to press up here.
		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, job) { window.location.href='?_src_=prefs;preference=jobselect;level=' + level + ';job=' + encodeURIComponent(job); return false; }</script>"
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		for(var/j in SSjob.joinable_occupations)
			var/datum/job/job = j
			index += 1
			if(index >= limit || (job.title in splitJobs))
				width += widthPerColumn
				if(index < limit && !isnull(lastJob))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank = job.title
			lastJob = job
			if(is_banned_from(user.ckey, rank))
				HTML += "<font color=red>[rank]</font></td><td><a href='?_src_=prefs;preference=bancheck;role=[rank]'> BANNED</a></td></tr>"
				continue
			var/required_playtime_remaining = job.required_playtime_remaining(user.client)
			if(required_playtime_remaining)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[ [get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()] \] </font></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if(job.job_flags & JOB_FLAG_BOLD_NAME_ON_SELECTION)
				HTML += "<b><span class='dark'>[rank]</span></b>"
			else
				HTML += "<span class='dark'>[rank]</span>"

			HTML += "</td><td width='40%'>"

			var/prefLevelLabel = "NEVER"
			var/prefLevelColor = "red"
			var/prefUpperLevel = JOBS_PRIORITY_LOW // level to assign on left click
			var/prefLowerLevel = JOBS_PRIORITY_HIGH // level to assign on right click

			switch(job_preferences[job.title])
				if(JOBS_PRIORITY_HIGH)
					prefLevelLabel = "High"
					prefLevelColor = "slateblue"
					prefUpperLevel = JOBS_PRIORITY_NEVER
					prefLowerLevel = JOBS_PRIORITY_MEDIUM
				if(JOBS_PRIORITY_MEDIUM)
					prefLevelLabel = "Medium"
					prefLevelColor = "green"
					prefUpperLevel = JOBS_PRIORITY_HIGH
					prefLowerLevel = JOBS_PRIORITY_LOW
				if(JOBS_PRIORITY_LOW)
					prefLevelLabel = "Low"
					prefLevelColor = "orange"
					prefUpperLevel = JOBS_PRIORITY_MEDIUM
					prefLowerLevel = JOBS_PRIORITY_NEVER

			HTML += "<a class='white' href='?_src_=prefs;preference=jobselect;level=[prefUpperLevel];job=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

			HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
			HTML += "</a></td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		HTML += "</td'></tr></table>"
		HTML += "</center></table>"

		var/message
		switch(alternate_option)
			if(BE_OVERFLOW)
				message = "Be [ispath(SSjob.overflow_role) ? initial(SSjob.overflow_role.title) : SSjob.overflow_role.title] if preferences unavailable"
			if(GET_RANDOM_JOB)
				message = "Get random job if preferences unavailable"
			if(RETURN_TO_LOBBY)
				message = "Return to lobby if preferences unavailable"

		HTML += "<center><br><a href='?_src_=prefs;preference=jobalternative'>[message]</a></center>"
		HTML += "<center><a href='?_src_=prefs;preference=jobreset'>Reset Preferences</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(FALSE)


/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"
	HTML += "<center>"
	HTML += "<b>Set Character Records</b><br>"

	HTML += "<a href ='?_src_=prefs;preference=med_record'>Medical Records</a><br>"

	HTML += TextPreview(med_record, 40)

	HTML += "<br><br><a href ='?_src_=prefs;preference=gen_record'>Employment Records</a><br>"

	HTML += TextPreview(gen_record, 40)

	HTML += "<br><br><a href ='?_src_=prefs;preference=sec_record'>Security Records</a><br>"

	HTML += TextPreview(sec_record, 40)

	HTML += "<br><br><a href ='?_src_=prefs;preference=exploit_record'>Exploit Record</a><br>"

	HTML += TextPreview(exploit_record, 40)

	HTML += "<br>"
	HTML += "<a href ='?_src_=prefs;preference=recordsclose'>Done</a>"
	HTML += "</center>"


	winshow(user, "records", TRUE)
	var/datum/browser/popup = new(user, "records", "<div align='center'>Character Records</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "records", src)



/datum/preferences/proc/ShowKeybindings(mob/user)
	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for(var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)

	var/list/kb_categories = list()
	// Group keybinds by category
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		kb_categories[kb.category] += list(kb)

	var/HTML = "<style>label { display: inline-block; width: 200px; }</style><body>"
	HTML += "<br>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_done'>Close</a>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_reset'>Reset to default</a>"
	HTML += "<br><br>"
	for(var/category in kb_categories)
		HTML += "<h3>[category]</h3>"
		for(var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			if(!length(user_binds[kb.name]))
				HTML += "<label>[kb.full_name]</label> <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=["Unbound"]'>Unbound</a>"
				var/list/default_keys = focus_chat ? kb.hotkey_keys : kb.classic_keys
				if(LAZYLEN(default_keys))
					HTML += "| Default: [default_keys.Join(", ")]"
				HTML += "<br>"
			else
				var/bound_key = user_binds[kb.name][1]
				HTML += "<label>[kb.full_name]</label> <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
				for(var/bound_key_index in 2 to length(user_binds[kb.name]))
					bound_key = user_binds[kb.name][bound_key_index]
					HTML += " | <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
				if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
					HTML += "| <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name]'>Add Secondary</a>"
				var/list/default_keys = focus_chat ? kb.hotkey_keys : kb.classic_keys
				if(LAZYLEN(default_keys))
					HTML += "| Default: [default_keys.Join(", ")]"
				HTML += "<br>"

	HTML += "<br><br>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_done'>Close</a>"
	HTML += "<a href ='?_src_=prefs;preference=keybindings_reset'>Reset to default</a>"
	HTML += "</body>"

	winshow(user, "keybindings", TRUE)
	var/datum/browser/popup = new(user, "keybindings", "<div align='center'>Keybindings</div>", 500, 900)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "keybindings", src)

/datum/preferences/proc/CaptureKeybinding(mob/user, datum/keybinding/kb, old_key)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var url = 'byond://?_src_=prefs;preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];clear_key='+escPressed+';key='+e.key+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)


/datum/preferences/Topic(href, href_list, hsrc)
	. = ..()
	if(.)
		return
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()


/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!istype(user) || !length(href_list))
		return

	switch(href_list["preference"])
		if("change_marking")
			var/datum/species/current_species = GLOB.all_species[species]
			switch(href_list["task"])
				if("use_preset")
					var/action = alert(user, "Are you sure you want to use a preset (This will clear your existing markings)?", "", "Yes", "No")
					if(action && action == "Yes")
						var/list/candidates = get_body_marking_sets_for_species(current_species, mismatched_parts)
						if(length(candidates) == 0)
							return
						var/desired_set = input(user, "Choose your new body markings:", "Character Preference") as null|anything in candidates
						if(desired_set)
							var/datum/body_marking_set/BMS = GLOB.body_marking_sets[desired_set]
							body_markings = assemble_body_markings_from_set(BMS, features, current_species)

				if("reset_color")
					var/zone = href_list["key"]
					var/name = href_list["name"]
					if(!body_markings[zone] || !body_markings[zone][name])
						return
					var/datum/body_marking/BM = GLOB.body_markings[name]
					body_markings[zone][name] = BM.get_default_color(features, current_species)
				if("change_color")
					var/zone = href_list["key"]
					var/name = href_list["name"]
					if(!body_markings[zone] || !body_markings[zone][name])
						return
					var/color = body_markings[zone][name]
					var/new_color = input(user, "Choose your markings color:", "Character Preference","#[color]") as color|null
					if(new_color)
						if(!body_markings[zone] || !body_markings[zone][name])
							return
						body_markings[zone][name] = sanitize_hexcolor(new_color, 6)
				if("marking_move_up")
					var/zone = href_list["key"]
					var/name = href_list["name"]
					var/list/marking_list = LAZYACCESS(body_markings, zone)
					var/current_index = LAZYFIND(marking_list, name)
					if(!current_index || --current_index < 1)
						return
					var/marking_content = marking_list[name]
					marking_list -= name
					marking_list.Insert(current_index, name)
					marking_list[name] = marking_content
				if("marking_move_down")
					var/zone = href_list["key"]
					var/name = href_list["name"]
					var/list/marking_list = LAZYACCESS(body_markings, zone)
					var/current_index = LAZYFIND(marking_list, name)
					if(!current_index || ++current_index > length(marking_list))
						return
					var/marking_content = marking_list[name]
					marking_list -= name
					marking_list.Insert(current_index, name)
					marking_list[name] = marking_content
				if("add_marking")
					var/zone = href_list["key"]
					if(!GLOB.body_markings_per_limb[zone])
						return
					var/list/possible_candidates = get_limb_markings_for_species(current_species, zone, mismatched_parts)
					if(body_markings[zone])
						//To prevent exploiting hrefs to bypass the marking limit
						if(body_markings[zone].len >= MAXIMUM_MARKINGS_PER_LIMB)
							return
						//Remove already used markings from the candidates
						for(var/list/this_list in body_markings[zone])
							possible_candidates -= this_list[MUTANT_INDEX_NAME]

					if(possible_candidates.len == 0)
						return
					var/desired_marking = input(user, "Choose your new marking to add:", "Character Preference") as null|anything in possible_candidates
					if(desired_marking)
						var/datum/body_marking/BD = GLOB.body_markings[desired_marking]
						if(!body_markings[zone])
							body_markings[zone] = list()
						body_markings[zone][BD.name] = BD.get_default_color(features, current_species)

				if("remove_marking")
					var/zone = href_list["key"]
					var/name = href_list["name"]
					if(!body_markings[zone] || !body_markings[zone][name])
						return
					body_markings[zone] -= name
					if(body_markings[zone].len == 0)
						body_markings -= zone
				if("change_marking")
					var/zone = href_list["key"]
					var/changing_name = href_list["name"]

					var/list/possible_candidates = get_limb_markings_for_species(current_species, zone, mismatched_parts)
					if(body_markings[zone])
						//Remove already used markings from the candidates
						for(var/keyed_name in body_markings[zone])
							possible_candidates -= keyed_name
					if(possible_candidates.len == 0)
						return
					var/desired_marking = input(user, "Choose a marking to change the current one to:", "Character Preference") as null|anything in possible_candidates
					if(desired_marking)
						if(!body_markings[zone] || !body_markings[zone][changing_name])
							return
						var/held_index = LAZYFIND(body_markings[zone], changing_name)
						body_markings[zone] -= changing_name
						var/datum/body_marking/BD = GLOB.body_markings[desired_marking]
						var/marking_content = BD.get_default_color(features, current_species)
						body_markings[zone].Insert(held_index, desired_marking)
						body_markings[zone][desired_marking] = marking_content
		if("mismatch")
			mismatched_parts = !mismatched_parts
		if("character_preview")
			preview_pref = href_list["tab"]
		if("adv_colors")
			if(color_customization)
				var/action = alert(user, "Are you sure you want to disable color customization (This will reset your colors back to default)?", "", "Yes", "No")
				if(action && action != "Yes")
					return
			color_customization = !color_customization
			if(!color_customization)
				reset_mutantparts_colors()
		if("change_bodypart")
			var/datum/species/current_species = GLOB.all_species[species]
			switch(href_list["task"])
				if("change_color")
					var/key = href_list["key"]
					if(!mutant_bodyparts[key])
						return
					var/list/colorlist = mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST]
					var/index = text2num(href_list["color_index"])
					if(colorlist.len < index)
						return
					var/new_color = input(user, "Choose your character's [key] color:", "Character Preference","#[colorlist[index]]") as color|null
					if(new_color)
						colorlist[index] = sanitize_hexcolor(new_color,6)
				if("reset_color")
					var/key = href_list["key"]
					if(!mutant_bodyparts[key])
						return
					var/datum/mutant_accessory/SA = GLOB.mutant_accessories[key][mutant_bodyparts[key][MUTANT_INDEX_NAME]]
					mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(features, current_species)
				if("reset_all_colors")
					var/action = alert(user, "Are you sure you want to reset all colors?", "", "Yes", "No")
					if(action == "Yes")
						reset_mutantparts_colors()
				if("change_name")
					var/key = href_list["key"]
					if(!mutant_bodyparts[key])
						return
					var/new_name
					new_name = tgui_input_list(user, "Choose your character's [key]:", "Character Preference", GetMutantpartList(current_species, key, mismatched_parts))
					if(new_name && mutant_bodyparts[key])
						mutant_bodyparts[key][MUTANT_INDEX_NAME] = new_name
						if(!color_customization)
							var/datum/mutant_accessory/SA = GLOB.mutant_accessories[key][new_name]
							mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(features, current_species)
						else
							validate_color_keys_for_part(key)

		if("mutant_color")
			var/new_mutantcolor = input(user, "Choose your character's primary color:", "Character Preference","#"+features["mcolor"]) as color|null
			if(new_mutantcolor)
				features["mcolor"] = sanitize_hexcolor(new_mutantcolor, 6)
			if(!color_customization)
				reset_mutantparts_colors()

		if("mutant_color2")
			var/new_mutantcolor = input(user, "Choose your character's secondary color:", "Character Preference","#"+features["mcolor2"]) as color|null
			if(new_mutantcolor)
				features["mcolor2"] = sanitize_hexcolor(new_mutantcolor, 6)
			if(!color_customization)
				reset_mutantparts_colors()

		if("mutant_color3")
			var/new_mutantcolor = input(user, "Choose your character's tertiary color:", "Character Preference","#"+features["mcolor3"]) as color|null
			if(new_mutantcolor)
				features["mcolor3"] = sanitize_hexcolor(new_mutantcolor, 6)
			if(!color_customization)
				reset_mutantparts_colors()

		if("tab")
			current_tab = text2num(href_list["tab"])

		if("character_tab")
			character_tab = text2num(href_list["tab"])

		if("changeslot")
			if(!load_character(text2num(href_list["num"])))
				random_character()
				real_name = random_unique_name(gender)
				save_character()
			ShowChoices(user)
			return TRUE

		if("synth_name")
			var/newname = input(user, "Choose your Synthetic's name:", "Synthetic Name")
			newname = reject_bad_name(newname, TRUE)
			if(!newname)
				to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				return
			synthetic_name = newname

		if("synth_type")
			var/new_synth_type = tgui_input_list(user, "Choose your model of synthetic:", "Synthetic Model", SYNTH_TYPES)
			if(!new_synth_type)
				return
			synthetic_type = new_synth_type

		if("xeno_name")
			var/newname = input(user, "Choose your Xenomorph name:", "Xenomorph Name")
			if(newname == "")
				xeno_name = "Undefined"
			else
				newname = reject_bad_name(newname)
				if(!newname)
					to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
					return
				xeno_name = newname

		if("ai_name")
			var/newname = input(user, "Choose your AI name:", "AI Name")
			if(newname == "")
				ai_name = "ARES v3.2"
			else
				newname = reject_bad_name(newname, TRUE)
				if(!newname)
					to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
					return
				ai_name = newname

		if("name_real")
			var/newname = input(user, "Choose your character's name:", "Character Name")
			newname = reject_bad_name(newname, TRUE)
			if(!newname)
				to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				return
			real_name = newname

		if("randomize_name")
			var/datum/species/S = GLOB.all_species[species]
			real_name = S.random_name(gender)

		if("random_name")
			random_name = !random_name

		if("random")
			randomize_appearance_for()

		if("age")
			var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Age") as num|null
			if(!isnum(new_age))
				return
			new_age = round(new_age)
			age = clamp(new_age, AGE_MIN, AGE_MAX)

		if("gender")
			if(gender == MALE)
				gender = FEMALE
				f_style = "Shaved"
			else
				gender = MALE
				underwear = 1

		if("ethnicity")
			var/new_ethnicity = tgui_input_list(user, "Choose your character's ethnicity:", "Ethnicity", GLOB.ethnicities_list)
			if(!new_ethnicity)
				return
			ethnicity = new_ethnicity

		if("scream")
			var/list/available_screams = list()
			var/datum/species/current_species = GLOB.all_species[species]
			for(var/spath in subtypesof(/datum/scream_type)) //We need to build a custom list of available screams! //this could be global but I cba to change it
				var/datum/scream_type/scream = spath
				if(initial(scream.restricted_species_type))
					if(!istype(current_species, initial(scream.restricted_species_type)))
						continue
				/* no donator only stuff thx
				if(initial(scream.donator_only) && !GLOB.donator_list[parent.ckey] && !check_rights(R_ADMIN, FALSE))
					continue no donator only stuff thx
				*/
				available_screams[initial(scream.name)] = spath
			var/new_scream_id = input(user, "Choose your character's scream:", "Character Scream")  as null|anything in available_screams
			var/datum/scream_type/scream = available_screams[new_scream_id]
			if(scream)
				pref_scream = new scream
				SEND_SOUND(user, pick(pref_scream.male_screamsounds))


		if("species")
			var/new_species = tgui_input_list(user, "Choose your species:", "Species", GLOB.roundstart_species)
			if(!new_species)
				return
			SetSpecies(new_species)

		if("body_type")
			var/new_body_type = tgui_input_list(user, "Choose your character's body type:", "Body Type", GLOB.body_types_list)
			if(!new_body_type)
				return
			body_type = new_body_type

		if("eyesight")
			good_eyesight = !good_eyesight

		if("be_special")
			var/flag = text2num(href_list["flag"])
			TOGGLE_BITFIELD(be_special, flag)

		if("jobmenu")
			SetChoices(user)
			return

		if("jobclose")
			user << browse(null, "window=mob_occupation")

		if("jobselect")
			UpdateJobPreference(user, href_list["job"], text2num(href_list["level"]))
			return

		if("jobalternative")
			if(alternate_option == GET_RANDOM_JOB)
				alternate_option = BE_OVERFLOW
			else if(alternate_option == BE_OVERFLOW)
				alternate_option = RETURN_TO_LOBBY
			else if(alternate_option == RETURN_TO_LOBBY)
				alternate_option = GET_RANDOM_JOB
			SetChoices(user)
			return

		if("jobreset")
			job_preferences = list()
			SetChoices(user)
			return


		if("underwear")
			var/list/underwear_options
			if(gender == MALE)
				underwear_options = GLOB.underwear_m
			else
				underwear_options = GLOB.underwear_f

			var/new_underwear = tgui_input_list(user, "Choose your character's underwear:", "Underwear", underwear_options)
			if(!new_underwear)
				return
			underwear = underwear_options.Find(new_underwear)

		if("undershirt")
			var/new_undershirt = tgui_input_list(user, "Choose your character's undershirt:", "Undershirt", GLOB.undershirt_t)
			if(!new_undershirt)
				return
			undershirt = GLOB.undershirt_t.Find(new_undershirt)

		if("backpack")
			var/new_backpack = tgui_input_list(user, "Choose your character's style of a backpack:", "Backpack Style", GLOB.backpacklist)
			if(!new_backpack)
				return
			backpack = GLOB.backpacklist.Find(new_backpack)

		if("loadoutadd")
			var/choice = tgui_input_list(user, "Select gear to add: ", "Custom Loadout", GLOB.gear_datums)
			if(!choice)
				return

			var/total_cost = 0
			var/datum/gear/C = GLOB.gear_datums[choice]

			if(!C)
				return

			if(length(gear))
				for(var/gear_name in gear)
					if(GLOB.gear_datums[gear_name])
						var/datum/gear/G = GLOB.gear_datums[gear_name]
						total_cost += G.cost

			total_cost += C.cost
			if(total_cost <= MAX_GEAR_COST)
				if(!islist(gear))
					gear = list()
				gear += choice
				to_chat(user, "<span class='notice'>Added '[choice]' for [C.cost] points ([MAX_GEAR_COST - total_cost] points remaining).</span>")
			else
				to_chat(user, "<span class='warning'>Adding '[choice]' will exceed the maximum loadout cost of [MAX_GEAR_COST] points.</span>")

		if("loadoutremove")
			gear.Remove(href_list["gear"])
			if(!islist(gear))
				gear = list()

		if("loadoutclear")
			gear.Cut()
			if(!islist(gear))
				gear = list()

		if("ui")
			var/choice = tgui_input_list(user, "Please choose an UI style.", "UI Style", UI_STYLES)
			if(!choice)
				return
			ui_style = choice

		if("uicolor")
			var/ui_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!", "UI Color") as null|color
			if(!ui_style_color_new)
				return
			ui_style_color = ui_style_color_new

		if("uialpha")
			var/ui_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 230", "UI Alpha") as null|num
			if(!ui_style_alpha_new)
				return
			ui_style_alpha_new = round(ui_style_alpha_new)
			ui_style_alpha = clamp(ui_style_alpha_new, 55, 230)

		if("hairstyle")
			var/list/valid_hairstyles = list()
			for(var/hairstyle in GLOB.hair_styles_list)
				var/datum/sprite_accessory/S = GLOB.hair_styles_list[hairstyle]
				if(!(species in S.species_allowed))
					continue

				valid_hairstyles[hairstyle] = GLOB.hair_styles_list[hairstyle]

			var/new_h_style = tgui_input_list(user, "Choose your character's hair style:", "Hair Style", valid_hairstyles)
			if(!new_h_style)
				return
			h_style = new_h_style

		if("haircolor")
			var/new_color = input(user, "Choose your character's hair colour:", "Hair Color") as null|color
			if(!new_color)
				return
			r_hair = hex2num(copytext(new_color, 2, 4))
			g_hair = hex2num(copytext(new_color, 4, 6))
			b_hair = hex2num(copytext(new_color, 6, 8))

		if("grad_color")
			var/new_grad = input(user, "Choose your character's secondary hair color:", "Gradient Color") as null|color
			if(!new_grad)
				return
			r_grad = hex2num(copytext(new_grad, 2, 4))
			g_grad = hex2num(copytext(new_grad, 4, 6))
			b_grad = hex2num(copytext(new_grad, 6, 8))

		if("grad_style")
			var/list/valid_grads = list()
			for(var/grad in GLOB.hair_gradients_list)
				valid_grads[grad] = GLOB.hair_gradients_list[grad]

			var/new_grad_style = tgui_input_list(user, "Choose a color pattern for your hair:", "Character Preference", valid_grads)
			if(!new_grad_style)
				return
			grad_style = new_grad_style

		if("facialstyle")
			var/list/valid_facialhairstyles = list()
			for(var/facialhairstyle in GLOB.facial_hair_styles_list)
				var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]
				if(gender != S.gender)
					continue
				if(!(species in S.species_allowed))
					continue

				valid_facialhairstyles[facialhairstyle] = GLOB.facial_hair_styles_list[facialhairstyle]

			var/new_f_style = tgui_input_list(user, "Choose your character's facial-hair style:", "Facial Hair Style", valid_facialhairstyles + "Shaved")
			if(!new_f_style)
				return
			f_style = new_f_style

		if("facialcolor")
			var/facial_color = input(user, "Choose your character's facial-hair colour:", "Facial Hair Color") as null|color
			if(!facial_color)
				return
			r_facial = hex2num(copytext(facial_color, 2, 4))
			g_facial = hex2num(copytext(facial_color, 4, 6))
			b_facial = hex2num(copytext(facial_color, 6, 8))

		if("eyecolor")
			var/eyecolor = input(user, "Choose your character's eye colour:", "Character Preference") as null|color
			if(!eyecolor)
				return
			r_eyes = hex2num(copytext(eyecolor, 2, 4))
			g_eyes = hex2num(copytext(eyecolor, 4, 6))
			b_eyes = hex2num(copytext(eyecolor, 6, 8))

		if("citizenship")
			var/choice = tgui_input_list(user, "Please choose your current citizenship.", null,CITIZENSHIP_CHOICES)
			if(!choice)
				return
			citizenship = choice

		if("religion")
			var/choice = tgui_input_list(user, "Please choose a religion.", null,RELIGION_CHOICES)
			if(!choice)
				return
			religion = choice

		if("corporation")
			var/new_relation = tgui_input_list(user, "Choose your relation to the Nanotrasen company that will appear on background checks.", "Nanotrasen Relation", CORP_RELATIONS)
			if(!new_relation)
				return
			nanotrasen_relation = new_relation

		if("squad")
			var/new_squad = tgui_input_list(user, "Choose your preferred squad.", "Preferred Squad", SELECTABLE_SQUADS)
			if(!new_squad)
				return
			preferred_squad = new_squad

		if("records")
			SetRecords(user)
			return

		if("med_record")
			var/medmsg = stripped_input(user, "Set your medical notes here.", "Medical Records", sanitize(med_record))
			if(!medmsg)
				return

			med_record = medmsg
			SetRecords(user)
			return

		if("sec_record")
			var/secmsg = stripped_input(user,"Set your security notes here.", "Security Records", sanitize(sec_record))
			if(!secmsg)
				return

			sec_record = secmsg
			SetRecords(user)
			return

		if("gen_record")
			var/genmsg = stripped_input(user, "Set your employment notes here.", "Employment Records", sanitize(gen_record))
			if(!genmsg)
				return

			gen_record = genmsg
			SetRecords(user)
			return

		if("exploit_record")
			var/exploit = stripped_input(user, "Enter information that others may want to use against you.", "Exploit Record", sanitize(exploit_record))
			if(!exploit)
				return

			exploit_record = exploit
			SetRecords(user)
			return

		if("recordsclose")
			user << browse(null, "window=records")

		if("flavor_text")
			var/msg = stripped_input(user, "Give a physical description of your character.", "Flavor Text", sanitize(flavor_text))
			if(!msg)
				return
			if(NON_ASCII_CHECK(msg))
				return
			flavor_text = msg

		if("windowflashing")
			windowflashing = !windowflashing

		if("auto_fit_viewport")
			auto_fit_viewport = !auto_fit_viewport
			if(auto_fit_viewport && parent)
				parent.fit_viewport()

		if("focus_chat")
			focus_chat = !focus_chat
			if(focus_chat)
				winset(user, null, "input.focus=true")
			else
				winset(user, null, "map.focus=true")

		if("clientfps")
			var/desiredfps = input(user, "Choose your desired fps. (0 = synced with server tick rate (currently:[world.fps]))", "Character Preference", clientfps)  as null|num
			if(isnull(desiredfps))
				return
			desiredfps = clamp(desiredfps, 0, 240)
			clientfps = desiredfps
			parent.fps = desiredfps

		if("mute_self_combat_messages")
			mute_self_combat_messages = !mute_self_combat_messages

		if("mute_others_combat_messages")
			mute_others_combat_messages = !mute_others_combat_messages

		if("mute_xeno_health_alert_messages")
			mute_xeno_health_alert_messages = !mute_xeno_health_alert_messages

		if("chat_on_map")
			chat_on_map = !chat_on_map

		if ("max_chat_length")
			var/desiredlength = input(user, "Choose the max character length of shown Runechat messages. Valid range is 1 to [CHAT_MESSAGE_MAX_LENGTH] (default: [initial(max_chat_length)]))", "Character Preference", max_chat_length)  as null|num
			if (!isnull(desiredlength))
				max_chat_length = clamp(desiredlength, 1, CHAT_MESSAGE_MAX_LENGTH)

		if("see_chat_non_mob")
			see_chat_non_mob = !see_chat_non_mob

		if("see_rc_emotes")
			see_rc_emotes = !see_rc_emotes

		if("tooltips")
			tooltips = !tooltips
			if(!tooltips)
				closeToolTip(usr)
			else if(!usr.client.tooltips && tooltips)
				usr.client.tooltips = new /datum/tooltip(usr.client)

		if("keybindings_menu")
			ShowKeybindings(user)
			return

		if("keybindings_capture")
			var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
			var/old_key = href_list["old_key"]
			CaptureKeybinding(user, kb, old_key)
			return

		if("keybindings_set")
			var/kb_name = href_list["keybinding"]
			if(!kb_name)
				user << browse(null, "window=capturekeypress")
				ShowKeybindings(user)
				return

			var/clear_key = text2num(href_list["clear_key"])
			var/old_key = href_list["old_key"]
			if(clear_key)
				if(key_bindings[old_key])
					key_bindings[old_key] -= kb_name
					if(!length(key_bindings[old_key]))
						key_bindings -= old_key
				user << browse(null, "window=capturekeypress")
				save_preferences()
				ShowKeybindings(user)
				return

			var/new_key = uppertext(href_list["key"])
			var/AltMod = text2num(href_list["alt"]) ? "Alt" : ""
			var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
			var/ShiftMod = text2num(href_list["shift"]) ? "Shift" : ""
			var/numpad = text2num(href_list["numpad"]) ? "Numpad" : ""
			// var/key_code = text2num(href_list["key_code"])

			if(GLOB._kbMap[new_key])
				new_key = GLOB._kbMap[new_key]

			var/full_key
			switch(new_key)
				if("Alt")
					full_key = "[new_key][CtrlMod][ShiftMod]"
				if("Ctrl")
					full_key = "[AltMod][new_key][ShiftMod]"
				if("Shift")
					full_key = "[AltMod][CtrlMod][new_key]"
				else
					full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
			if(key_bindings[old_key])
				key_bindings[old_key] -= kb_name
				if(!length(key_bindings[old_key]))
					key_bindings -= old_key
			key_bindings[full_key] += list(kb_name)
			key_bindings[full_key] = sortList(key_bindings[full_key])

			user << browse(null, "window=capturekeypress")
			user.client.update_movement_keys()
			save_preferences()
			ShowKeybindings(user)
			return

		if("keybindings_done")
			user << browse(null, "window=keybindings")

		if("keybindings_reset")
			var/choice = tgui_alert(usr, "Would you prefer 'hotkey' or 'classic' defaults?", "Setup keybindings", list("Hotkey", "Classic", "Cancel"))
			if (!choice || choice == "Cancel")
				ShowKeybindings(user)
				return
			focus_chat = (choice == "Classic")
			key_bindings = (!focus_chat) ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)
			user.client.update_movement_keys()
			save_preferences()
			ShowKeybindings(user)
			return

		if("bancheck")
			var/list/ban_details = is_banned_from_with_details(user.ckey, user.client.address, user.client.computer_id, href_list["role"])
			var/admin = FALSE
			if(GLOB.admin_datums[user.ckey] || GLOB.deadmins[user.ckey])
				admin = TRUE
			for(var/i in ban_details)
				if(admin && !text2num(i["applies_to_admins"]))
					continue
				ban_details = i
				break //we only want to get the most recent ban's details
			if(!length(ban_details))
				return

			var/expires = "This is a permanent ban."
			if(ban_details["expiration_time"])
				expires = " The ban is for [DisplayTimeText(text2num(ban_details["duration"]) MINUTES)] and expires on [ban_details["expiration_time"]] (server time)."
			to_chat(user, "<span class='danger'>You, or another user of this computer or connection ([ban_details["key"]]) is banned from playing [href_list["role"]].<br>The ban reason is: [ban_details["reason"]]<br>This ban (BanID #[ban_details["id"]]) was applied by [ban_details["admin_key"]] on [ban_details["bantime"]] during round ID [ban_details["round_id"]].<br>[expires]</span>")

	save_preferences()
	save_character()
	ShowChoices(user)
	return TRUE

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	if(!length(SSjob?.joinable_occupations))
		return

	var/datum/job/job = SSjob.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	SetJobPreferenceLevel(job, desiredLvl)
	SetChoices(user)

	return TRUE


/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if(!job)
		return FALSE

	if(level == JOBS_PRIORITY_HIGH)
		for(var/j in job_preferences)
			if(job_preferences[j] == JOBS_PRIORITY_HIGH)
				job_preferences[j] = JOBS_PRIORITY_MEDIUM

	job_preferences[job.title] = level
	return TRUE

/datum/preferences/proc/SetSpecies(new_species)
	species = new_species
	var/datum/species/current_species = GLOB.all_species[species]
	var/list/new_features = current_species.get_random_features() //We do this to keep unrelated features persistant
	for(var/key in new_features)
		features[key] = new_features[key]
	mutant_bodyparts = current_species.get_random_mutant_bodyparts(features)
	body_markings = current_species.get_random_body_markings(features)

/datum/preferences/proc/reset_mutantparts_colors()
	var/datum/species/current_species = GLOB.all_species[species]
	for(var/key in mutant_bodyparts)
		var/datum/mutant_accessory/MA = GLOB.mutant_accessories[key][mutant_bodyparts[key][MUTANT_INDEX_NAME]]
		mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST] = MA.get_default_color(features, current_species)

/datum/preferences/proc/print_bodypart_change_line(key)
	var/acc_name = mutant_bodyparts[key][MUTANT_INDEX_NAME]
	var/shown_colors = 0
	var/datum/mutant_accessory/SA = GLOB.mutant_accessories[key][acc_name]
	var/dat = ""
	if(SA.color_src == USE_MATRIXED_COLORS)
		shown_colors = 3
	else if (SA.color_src == USE_ONE_COLOR)
		shown_colors = 1
	if((color_customization || SA.always_color_customizable) && shown_colors)
		dat += "<a href='?_src_=prefs;key=[key];task=reset_color;preference=change_bodypart'>R</a>"
	dat += "<a href='?_src_=prefs;key=[key];task=change_name;preference=change_bodypart'>[acc_name]</a>"
	if(color_customization || SA.always_color_customizable)
		if(shown_colors)
			dat += "<BR>"
			var/list/colorlist = mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST]
			for(var/i in 1 to shown_colors)
				dat += "<a href='?_src_=prefs;key=[key];color_index=[i];task=change_color;preference=change_bodypart'><span class='color_holder_box' style='background-color:["#[colorlist[i]]"]'></span></a>"
	return dat

/datum/preferences/proc/validate_color_keys_for_part(key)
	var/datum/species/current_species = GLOB.all_species[species]
	var/datum/mutant_accessory/SA = GLOB.mutant_accessories[key][mutant_bodyparts[key][MUTANT_INDEX_NAME]]
	var/list/colorlist = mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST]
	if(SA.color_src == USE_MATRIXED_COLORS && colorlist.len != 3)
		mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(features, current_species)
	else if (SA.color_src == USE_ONE_COLOR && colorlist.len != 1)
		mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(features, current_species)

#undef APPEARANCE_CATEGORY_COLUMN
#undef MAX_MUTANT_ROWS

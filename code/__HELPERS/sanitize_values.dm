//general stuff
/proc/sanitize_integer(number, min = 0, max = 1, default = 0)
	if(isnum(number))
		number = round(number)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_float(number, min=0, max=1, accuracy=1, default=0)
	if(isnum(number))
		number = round(number, accuracy)
		if(min <= number && number <= max)
			return number
	return default

/proc/sanitize_text(text, default = "")
	if(istext(text))
		return text
	return default


/proc/sanitize_islist(value, default)
	if(length(value))
		return value
	if(default)
		return default

/// Sanitize the custom emote list
/proc/sanitize_is_full_emote_list(value)
	if(length(value) == CUSTOM_EMOTE_SLOTS)
		return value
	if(!value)
		value = list()
	for(var/i in (length(value)+1) to CUSTOM_EMOTE_SLOTS)
		var/datum/custom_emote/emote = new
		emote.id = i
		value += emote
	return value

/proc/sanitize_inlist(value, list/L, default)
	if(value in L)
		return value
	if(default)
		return default
	if(length(L))
		return L[1]


/proc/sanitize_inlist_assoc(value, list/L, default)
	for(var/i in L)
		if(L[i] == value)
			return value
	if(default)
		return default


//more specialised stuff
/proc/sanitize_gender(gender, neuter = FALSE, plural = FALSE, default = MALE)
	switch(gender)
		if(MALE, FEMALE)
			return gender
		if(NEUTER)
			if(neuter)
				return gender
			else
				return default
		if(PLURAL)
			if(plural)
				return gender
			else
				return default
	return default


/proc/sanitize_ethnicity(ethnicity, default = "Western")
	if(ethnicity in GLOB.ethnicities_list)
		return ethnicity

	return default


/proc/sanitize_body_type(body_type, default = "Mesomorphic (Average)")
	if(body_type in GLOB.body_types_list)
		return body_type

	return default


/proc/sanitize_hexcolor(color, desired_format = 3, include_crunch = FALSE, default)
	var/crunch = include_crunch ? "#" : ""
	if(!istext(color))
		color = ""

	var/start = 1 + (text2ascii(color, 1) == 35)
	var/len = length(color)
	var/char = ""
	// Used for conversion between RGBA hex formats.
	var/format_input_ratio = "[desired_format]:[length_char(color)-(start-1)]"

	. = ""
	var/i = start
	while(i <= len)
		char = color[i]
		i += length(char)
		switch(text2ascii(char))
			if(48 to 57) //numbers 0 to 9
				. += char
			if(97 to 102) //letters a to f
				. += char
			if(65 to 70) //letters A to F
				char = lowertext(char)
				. += lowertext(char)
			else
				break
		switch(format_input_ratio)
			if("3:8", "4:8", "3:6", "4:6") //skip next one. RRGGBB(AA) -> RGB(A)
				i += length(color[i])
			if("6:4", "6:3", "8:4", "8:3") //add current char again. RGB(A) -> RRGGBB(AA)
				. += char

	return crunch + .

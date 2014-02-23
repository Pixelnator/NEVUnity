/obj/machinery/computer/navigation
	icon = 'icons/obj/computer.dmi'
	icon_state = "comm_monitor"
	name = "Navigation Console"
	desc = "This console allows you to travel to nearby stars and planets!"
	var/datum/system/cursystem
	var/datum/planet/curplanet

/obj/machinery/computer/navigation/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER)) return
	if(user.stat || user.restrained()) return

	// this is the data which will be sent to the ui
	var/data[0]
	data["systemname1"] = ship.system1.name
	data["systemname2"] = ship.system2.name
	if(cursystem)
		data["systemname"] = cursystem.name
		data["systemtype"] = cursystem.star_type
		data["systemlum"] = cursystem.luminosity
		var/locations[]
		for (var/datum/planet/temps in cursystem.planets)
			if(locations)
				locations.Add(list(list("planet_name" = temps.name, "planet_orbit" = temps.orbit_number)))
			else
				locations = list(list("planet_name" = temps.name, "planet_orbit" = temps.orbit_number))
		data["planets"] = locations
		if(cursystem.luminosity2) //If it's a binary system, more info is needed!
			data["systembinary"] = cursystem.luminosity2
		else
			data["systembinary"] = null
	if(curplanet)
		data["aplanet"] = curplanet.name
		data["p_orb"] = curplanet.orbit_number
		data["p_temp"] = curplanet.temp
		data["p_size"] = curplanet.size
		data["p_rads"] = curplanet.rads
		var/features[]
		for (var/datum/feature/temps in curplanet.features)
			if(features)
				features.Add(list(list("feature" = temps.name)))
			else
				features = list(list("feature" = temps.name))
		data["zones"] = features

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "navigation.tmpl", name, 380, 380)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)
/obj/machinery/computer/navigation/attack_paw(mob/user)
	user << "You are too primitive to use this computer."
	return

/obj/machinery/computer/navigation/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/computer/navigation/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	ui_interact(user)

/obj/machinery/computer/navigation/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 0
	if(href_list["move1"])
		return 0
	if(href_list["move2"])
		return 0
	if(href_list["launchprobe"])
		return 0

/obj/machinery/computer/astronavigation
	icon = 'icons/obj/computer.dmi'
	icon_state = "comm_monitor"
	name = "Astronavigation Console"
	desc = "This console allows you to scan nearby stars and planets!"
	var/datum/system/activesystem
	var/datum/planet/activeplanet
	var/locked // This variable prevents scanning while a scan is in progress
	var/scan_delay = 500 //The delay for scanning. Muliply by three for actual delay. 150 seconds for full scan at 500

/**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  *
  * @return nothing
  */
/obj/machinery/computer/astronavigation/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER)) return
	if(user.stat || user.restrained()) return

	// this is the data which will be sent to the ui
	var/data[0]
	data["systemname1"] = ship.system1.name
	data["systemname2"] = ship.system2.name

	if(activesystem) //Pick a target to scan!

		data["systemname"] = activesystem.name
		data["systemtype"] = activesystem.star_type
		data["systemlum"] = activesystem.luminosity
		var/locations[]
		for (var/datum/planet/temps in activesystem.planets)
			if(locations)
				locations.Add(list(list("planet_name" = temps.name, "planet_orbit" = temps.orbit_number)))
			else
				locations = list(list("planet_name" = temps.name, "planet_orbit" = temps.orbit_number))
		data["planets"] = locations
		if(activesystem.luminosity2) //If it's a binary system, more info is needed!
			data["systembinary"] = activesystem.luminosity2
		else
			data["systembinary"] = null
	else
		data["systemname"] = "No target!"
		data["systemtype"] = "-"
		data["systemlum"] = "-"
		data["systembinary"] = null
	if(activesystem && activeplanet)
		data["aplanet"] = activeplanet.name
		data["p_orb"] = activeplanet.orbit_number
		data["p_temp"] = activeplanet.temp
		data["p_size"] = activeplanet.size
		data["p_rads"] = activeplanet.rads
		var/features[]
		for (var/datum/feature/temps in activeplanet.features)
			if(features)
				features.Add(list(list("feature" = temps.name)))
			else
				features = list(list("feature" = temps.name))
		data["zones"] = features

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "astronav.tmpl", name, 380, 380)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)
/obj/machinery/computer/astronavigation/attack_paw(mob/user)
	user << "You are too primitive to use this computer."
	return

/obj/machinery/computer/astronavigation/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/computer/astronavigation/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	ui_interact(user)

/obj/machinery/computer/astronavigation/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 0
	if(locked)
		src.visible_message("The Terminal Buzzes: Scan already in progress!")
		src.visible_message("\blue \icon[src] buzzes irritably!", 7)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
		return 0
	if(href_list["setarget1"])
		sysscan("System")
		activesystem = ship.system1
	if(href_list["setarget2"])
		sysscan("System")
		usr << "Starting System Scan"
		activesystem = ship.system2
	if(href_list["clear"])
		usr << "Clearing Scans"
		activesystem = null
		activeplanet = null
	if(href_list["setplanet"])
		usr << "Scanning Planet."
		sysscan("Planet")
		var/datum/planet/temp
		for(temp in activesystem.planets)
			if(temp.name == href_list["setplanet"])
				activeplanet = temp


	return 1

/obj/machinery/computer/astronavigation/proc/sysscan(var/scantype)
	if(scantype)
		locked = 1
		src.visible_message("The Terminal States: \"Starting "+ scantype+ " Scan\"")
		src.visible_message("\blue \icon[src] plinks quietly.", 7)
		playsound(src.loc, 'sound/machines/signal.ogg', 50, 1)
		sleep(scan_delay)
		src.visible_message("The Terminal States: \""+ scantype+ " Scan at 33%\"")
		src.visible_message("\blue \icon[src] plinks quietly.", 7)
		playsound(src.loc, 'sound/machines/signal.ogg', 50, 1)
		sleep(scan_delay)
		src.visible_message("The Terminal States: \""+ scantype+ " Scan at 66%\"")
		src.visible_message("\blue \icon[src] plinks quietly.", 7)
		playsound(src.loc, 'sound/machines/signal.ogg', 50, 1)
		sleep(scan_delay)
		src.visible_message("The Terminal Chimes: \""+ scantype+ " Scan Complete\"")
		src.visible_message("\blue \icon[src] chimes!", 7)
		playsound(src.loc, 'sound/machines/chime.ogg', 50, 1)
		locked = 0
	return
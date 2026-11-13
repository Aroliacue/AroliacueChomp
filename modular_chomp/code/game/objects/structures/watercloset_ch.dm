/obj/structure/toilet/item/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/toilet/item/LateInitialize()
	if(istype(loc, /mob/living)) return
	var/obj/item/I
	for(I in loc)
		if(I.density || I.anchored || I == src) continue
		I.forceMove(src)

/obj/structure/biowaste_tank
	name = "Bluespace Bio-Compostor Terminal"
	icon = 'icons/obj/survival_pod_comp.dmi'
	icon_state = "pod_computer"
	desc = "It appears to be a massive sealed container attached to some heavy machinery and thick tubes containing a whole network of interdimensional pipeworks. It appears whatever vanished down the station's toilets ends up in this thing."
	anchored = TRUE
	density = TRUE
	var/muffin_mode = FALSE
	var/mob/living/simple_mob/vore/aggressive/corrupthound/muffinmonster
	var/obj/machinery/recycling/crusher/crusher //Bluespace connection for recyclables

/obj/structure/biowaste_tank/Initialize(mapload)
	muffinmonster = new /mob/living/simple_mob/vore/aggressive/corrupthound/muffinmonster(src)
	muffinmonster.name = "Activate experimental garbage disposal unit"
	muffinmonster.init_vore(TRUE)
	crusher = locate(/obj/machinery/recycling/crusher)
	return ..()

/obj/structure/biowaste_tank/AllowDrop()
	return TRUE

/obj/structure/biowaste_tank/Entered(atom/movable/thing, atom/OldLoc)
	. = ..()
	if(istype(thing, /obj/item/reagent_containers/food))
		qdel(thing)
		return
	if(istype(thing, /obj/item/organ))
		qdel(thing)
		return
	if(istype(thing, /obj/item/storage/vore_egg))
		if(thing.contents.len)
			for(var/atom/movable/C in thing.contents)
				C.forceMove(src)
		qdel(thing)
		return
	if(istype(crusher) && istype(thing, /obj/item/debris_pack))
		crusher.take_item(thing)
		return
	if(muffin_mode)
		if(muffinmonster)
			thing.forceMove(muffinmonster.vore_selected)
		else
			muffin_mode = FALSE

/obj/structure/biowaste_tank/attack_hand(mob/user as mob)
	if(contents.len)
		var/atom/movable/choice = tgui_input_list(usr, "It appears the machine has caught some items in the lost-and-found filter system. Would you like to eject something?", "Item Retrieval Console", contents)
		if(choice)
			if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
				return
			if(choice == muffinmonster && muffinmonster.loc == src)
				muffin_mode = !muffin_mode
				if(muffin_mode)
					muffinmonster.name = "Deactivate experimental garbage disposal unit"
					for(var/atom/movable/C in contents)
						if(C == muffinmonster)
							continue
						C.forceMove(muffinmonster.vore_selected)
				else
					muffinmonster.name = "Activate experimental garbage disposal unit"
					muffinmonster.release_vore_contents(include_absorbed = TRUE, silent = TRUE)
				return
			else
				choice.forceMove(get_turf(src))

/obj/structure/biowaste_tank/emag_act(remaining_charges, mob/user, emag_source)
	if(muffinmonster && muffin_mode)
		muffinmonster.name = "Flayer"
		muffinmonster.forceMove(get_turf(src))
		muffinmonster = null
		muffin_mode = FALSE

/mob/living/simple_mob/vore/aggressive/corrupthound/muffinmonster
	name = "Flayer"
	desc = "While this machine mostly bears a resemblance to the corrupted hound units occasionally found in this locality, this specific one has a very disturbing difference - It's head has been modified into a horrific, person-sized industrial shredder... And it's staring right at you. Oh, fuck."
	icon_state = "muffinmonster"
	icon_living = "muffinmonster"
	icon_dead = "muffinmonster-dead"
	icon_rest = "muffinmonster_rest"
	icon = 'modular_chomp/icons/mob/vore64x32_ch.dmi'
	has_eye_glow = FALSE
	vore_default_item_mode = IM_DIGEST

/mob/living/simple_mob/vore/aggressive/corrupthound/muffinmonster/load_default_bellies()
	. = ..()
	var/obj/belly/B = vore_selected
	B.name = "industrial shredder hopper"
	B.desc = "With a resounding CRUNCH, your form's snagged by the Flayer's rotational interlocking teeth, indiscriminately grinding away at you as you slide deeper into the hopper, shredding it all down into a mulched slurry fine enough to pass through the narrow sewage lines trouble-free..."
	B.mode_flags = DM_FLAG_STRIPPING | DM_FLAG_JAMSENSORS | DM_FLAG_SLOWBODY | DM_FLAG_TURBOMODE
	B.vore_pref_type_flags = VORE_TYPE_FLAG_HARD | VORE_TYPE_FLAG_DIRTY | VORE_TYPE_FLAG_HIGH_DAMAGE
	B.fancy_vore = 1
	B.digest_brute = 20
	B.special_entrance_sound = 'sound/machines/blender.ogg'
	B.recycling = TRUE
	B.digest_messages_prey = list(
		"CLUNK-GRRRRNCCHH. Your body's completely destroyed in the industrial-grade macerator, minced and crushed down into nothing more than an indiscernible amalgamation of soon-to-be waste, intermixing with whatever junk joined you on the trip inwards to become useless station garbage."
		)

	B.emote_lists[DM_DIGEST] = list(
		"More of your body snags on the horrific, unstoppable treads, pulling you further into the cyborg's enormous frontal trash-grinder with a symphony of sick, wet crunching."
		)

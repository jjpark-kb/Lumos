/obj/effect/decal/cleanable/puddle
	name = "puddle"
	desc = "A puddle full of some liquids."
	icon = 'modular_lumos/icons/obj/puddle.dmi'
	icon_state = "puddle_"

/obj/effect/decal/cleanable/puddle/proc/fake_process()
	if(reagents.total_volume >= 50)
		check_puddle_spread()
	if(locate(/mob/living/carbon) in get_turf(src))
		var/mob/living/carbon/C = locate(/mob/living/carbon) in get_turf(src)
		reagents.trans_to(C, 1)
	if(reagents.total_volume <= 0)
		qdel(src)
		return

/obj/effect/decal/cleanable/puddle/Crossed(atom/movable/O)
	. = ..()
	if(iscarbon(O))
		var/mob/living/carbon/C = O
		reagents.trans_to(C, 1)
	if(isliving(O))
		var/watersound = pick(list('sound/effects/footstep/water1.ogg', 'sound/effects/footstep/water2.ogg', 'sound/effects/footstep/water3.ogg', 'sound/effects/footstep/water4.ogg'))
		playsound(src, watersound, 50, TRUE, -1)

/obj/effect/decal/cleanable/puddle/Destroy(force)
	for(var/directions in GLOB.cardinals)
		var/turf/step_turf = get_step(src, directions)
		for(var/obj/effect/decal/cleanable/puddle/puddle in step_turf)
			spawn(1)
				puddle.update_icon()
	..()
	
/obj/effect/decal/cleanable/puddle/update_icon()
	var/turf/north_turf	 = get_step(src, NORTH)
	var/turf/south_turf	 = get_step(src, SOUTH)
	var/turf/east_turf	 = get_step(src, EAST)
	var/turf/west_turf	 = get_step(src, WEST)

	icon_state = "[initial(icon_state)]"

	if(locate(/obj/effect/decal/cleanable/puddle) in north_turf || isclosedturf(north_turf) || locate(/obj/structure/window) in north_turf)
		icon_state = "[icon_state]n"
	if(locate(/obj/effect/decal/cleanable/puddle) in south_turf || isclosedturf(south_turf) || locate(/obj/structure/window) in south_turf)
		icon_state = "[icon_state]s"
	if(locate(/obj/effect/decal/cleanable/puddle) in east_turf || isclosedturf(east_turf) || locate(/obj/structure/window) in east_turf)
		icon_state = "[icon_state]e"
	if(locate(/obj/effect/decal/cleanable/puddle) in west_turf || isclosedturf(west_turf) || locate(/obj/structure/window) in west_turf)
		icon_state = "[icon_state]w"

	color = mix_color_from_reagents(src.reagents.reagent_list)

/obj/effect/decal/cleanable/puddle/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	for(var/directions in GLOB.cardinals)
		var/turf/step_turf = get_step(src, directions)
		for(var/obj/effect/decal/cleanable/puddle/puddle in step_turf)
			puddle.update_icon()
	update_icon()

/obj/effect/decal/cleanable/puddle/proc/check_puddle_spread()
	update_icon()
	if(!(src.reagents.total_volume >= 50))
		return
	for(var/i in 1 to 10)
		if(reagents.total_volume < 50)
			break
		if(src.reagents.total_volume >= 50)
			for(var/directions in GLOB.cardinals)
				var/turf/step_turf = get_step(src, directions)
				if(isclosedturf(step_turf) || isspaceturf(step_turf))
					continue
				if(locate(/obj/machinery/door) in step_turf)
					var/obj/machinery/door/door = locate(/obj/machinery/door) in step_turf
					if(door.density)
						continue
				if(!locate(/obj/effect/decal/cleanable/puddle) in step_turf)
					var/obj/effect/decal/cleanable/puddle/puddle = new /obj/effect/decal/cleanable/puddle(step_turf)
					src.reagents.trans_to(puddle, 10)
					puddle.check_puddle_spread()
					puddle.update_icon()
					continue
				var/obj/effect/decal/cleanable/puddle/npuddle = locate(/obj/effect/decal/cleanable/puddle) in step_turf
				src.reagents.trans_to(npuddle, 10)
				npuddle.check_puddle_spread()
				npuddle.update_icon()
	update_icon()
			

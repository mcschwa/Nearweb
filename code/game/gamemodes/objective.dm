//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
var/global/list/all_objectives = list()

datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = 0					//currently only used for custom objectives.

	New(var/text)
		all_objectives |= src
		if(text)
			explanation_text = text

	Del()
		all_objectives -= src
		..()

	proc/check_completion()
		return completed

	proc/find_target()
		var/list/possible_targets = list()
		for(var/datum/mind/possible_target in ticker.minds)
			if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != 2))
				possible_targets += possible_target
		if(possible_targets.len > 0)
			target = pick(possible_targets)


	proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
				target = possible_target
				break



datum/objective/assassinate
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target


	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || target.current.z > world.maxz || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
				return 1
			return 0
		return 1



datum/objective/mutiny
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey)
				return 1
			var/turf/T = get_turf(target.current)
			if(T && (!(target.current.z in vessel_z)))			//If they leave the station they count as dead for this
				return 2
			return 0
		return 1

datum/objective/mutiny/rp
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate, capture or convert [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate, capture or convert [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	// less violent rev objectives
	check_completion()
		var/rval = 1
		if(target && target.current)
			//assume that only carbon mobs can become rev heads for now
			if(target.current.stat == DEAD || target.current:handcuffed || !ishuman(target.current))
				return 1
			// Check if they're converted
			if(istype(ticker.mode, /datum/game_mode/revolution))
				if(target in ticker.mode:head_revolutionaries)
					return 1
			var/turf/T = get_turf(target.current)
			if(T && (!(target.current.z in vessel_z)))			//If they leave the station they count as dead for this
				rval = 2
			return 0
		return rval

datum/objective/anti_revolution/execute
	find_target()
		..()
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [target.assigned_role] has extracted confidential information above their clearance. Execute \him[target.current]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has extracted confidential information above their clearance. Execute \him[target.current]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current)
			if(target.current.stat == DEAD || !ishuman(target.current))
				return 1
			return 0
		return 1

datum/objective/anti_revolution/brig
	var/already_completed = 0

	find_target()
		..()
		if(target && target.current)
			explanation_text = "Brig [target.current.real_name], the [target.assigned_role] for 20 minutes to set an example."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Brig [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] for 20 minutes to set an example."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(already_completed)
			return 1

		if(target && target.current)
			if(target.current.stat == DEAD)
				return 0
			if(target.is_brigged(10 * 60 * 10))
				already_completed = 1
				return 1
			return 0
		return 0

datum/objective/anti_revolution/demote
	find_target()
		..()
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [target.assigned_role]  has been classified as harmful to NanoTrasen's goals. Demote \him[target.current] to unassigned."
		else
			explanation_text = "Free Objective"
		return target

	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has been classified as harmful to NanoTrasen's goals. Demote \him[target.current]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(target && target.current && istype(target,/mob/living/carbon/human))
			var/obj/item/card/id/I = target.current:wear_id
			if(istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/P = I
				I = P.id

			if(!istype(I)) return 1

			if(I.assignment == "Unassigned")
				return 1
			else
				return 0
		return 1

datum/objective/debrain//I want braaaainssss
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(!target)//If it's a free objective.
			return 1
		if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
			return 0
		if( !target.current || !isbrain(target.current) )
			return 0
		var/atom/A = target.current
		while(A.loc)			//check to see if the brainmob is on our person
			A = A.loc
			if(A == owner.current)
				return 1
		return 0


datum/objective/protect//The opposite of killing a dude.
	find_target()
		..()
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(!target)			//If it's a free objective.
			return 1
		if(target.current)
			if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current))
				return 0
			return 1
		return 0


datum/objective/hijack
	explanation_text = "Hijack the Escape Pod A by escaping alone."

	check_completion()
		if(!owner.current || owner.current.stat)
			return 0
		if(emergency_shuttle.location<2)
			return 0
		if(issilicon(owner.current))
			return 0
		var/area/shuttle = locate(/area/shuttle/escape_pod1/centcom)
		var/list/protected_mobs = list(/mob/living/silicon/ai, /mob/living/silicon/pai)
		for(var/mob/living/player in player_list)
			if(player.type in protected_mobs)	continue
			if (player.mind && (player.mind != owner))
				if(player.stat != DEAD)			//they're not dead!
					if(get_turf(player) in shuttle)
						return 0
		return 1


datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."


	check_completion()
		if(!istype(owner.current, /mob/living/silicon))
			return 0
		if(emergency_shuttle.location<2)
			return 0
		if(!owner.current)
			return 0
		var/area/shuttle = locate(/area/shuttle/escape_pod1/centcom)
		var/area/shuttle2 = locate(/area/shuttle/escape_pod2/centcom)
		var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot)
		for(var/mob/living/player in player_list)
			if(player.type in protected_mobs)	continue
			if (player.mind)
				if (player.stat != 2)
					if (get_turf(player) in shuttle)
						return 0
					if (get_turf(player) in shuttle2)
						return 0
		return 1

datum/objective/silence
	explanation_text = "Do not allow anyone to escape the ship.  Only allow the pods to be sent when everyone is dead and your story is the only one left."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0

		for(var/mob/living/player in player_list)
			if(player == owner.current)
				continue
			if(player.mind)
				if(player.stat != DEAD)
					var/turf/T = get_turf(player)
					if(!T)	continue
					switch(T.loc.type)
						if(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
							return 0
		return 1


datum/objective/escape
	explanation_text = "Escape on an escape pod alive and free."


	check_completion()
		if(issilicon(owner.current))
			return 0
		if(isbrain(owner.current))
			return 0
		if(emergency_shuttle.location<2)
			return 0
		if(!owner.current || owner.current.stat ==2)
			return 0
		var/turf/location = get_turf(owner.current.loc)
		if(!location)
			return 0

//		if(istype(location, /turf/simulated/shuttle/floor4)) // Fails tratiors if they are in the shuttle brig -- Polymorph
		if(istype(owner.current, /mob/living/carbon))
			var/mob/living/carbon/C = owner.current
			if (!C.handcuffed)
				return 1
//		return 0

		var/area/check_area = location.loc
		if(istype(check_area, /area/shuttle/escape/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod1/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod2/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod3/centcom))
			return 1
		if(istype(check_area, /area/shuttle/escape_pod5/centcom))
			return 1
		else
			return 0



datum/objective/survive
	explanation_text = "Survive until the end."

	check_completion()
		if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
			return 0		//Brains no longer win survive objectives. --NEO
		if(issilicon(owner.current) && owner.current != owner.original)
			return 0
		return 1

// Similar to the anti-rev objective, but for traitors
datum/objective/brig
	var/already_completed = 0

	find_target()
		..()
		if(target && target.current)
			explanation_text = "Have [target.current.real_name], the [target.assigned_role] brigged for 10 minutes."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Have [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] brigged for 10 minutes."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(already_completed)
			return 1

		if(target && target.current)
			if(target.current.stat == DEAD)
				return 0
			// Make the actual required time a bit shorter than the official time
			if(target.is_brigged(10 * 60 * 5))
				already_completed = 1
				return 1
			return 0
		return 0

// Harm a crew member, making an example of them
datum/objective/harm
	var/already_completed = 0

	find_target()
		..()
		if(target && target.current)
			explanation_text = "Make an example of [target.current.real_name], the [target.assigned_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Make an example of [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
		else
			explanation_text = "Free Objective"
		return target

	check_completion()
		if(already_completed)
			return 1

		if(target && target.current && istype(target.current, /mob/living/carbon/human))
			if(target.current.stat == DEAD)
				return 0

			var/mob/living/carbon/human/H = target.current
			for(var/datum/organ/external/E in H.organs)
				if(E.status & ORGAN_BROKEN)
					already_completed = 1
					return 1
				if(E.status & ORGAN_DESTROYED && !E.amputated)
					already_completed = 1
					return 1

			var/datum/organ/external/face/F = H.get_organ("face")
			if(F.disfigured)
				return 1
		return 0


datum/objective/nuclear
	explanation_text = "Destroy the ship with a nuclear device."



datum/objective/steal
	var/obj/item/steal_target
	var/target_name

	var/global/possible_items[] = list(
		"the baron's suit" = /obj/item/clothing/suit/baron,
		"the baron's crown" = /obj/item/clothing/head/caphat,
		"a cerberus helmet" = /obj/item/clothing/head/helmet/sechelm,
	)

	var/global/possible_items_special[] = list(
		/*"nuclear authentication disk" = /obj/item/disk/nuclear,*///Broken with the change to nuke disk making it respawn on z level change.
		"the baron's suit" = /obj/item/clothing/suit/baron,
		"the baron's crown" = /obj/item/clothing/head/caphat,
		"a cerberus helmet" = /obj/item/clothing/head/helmet/sechelm,
	)


	proc/set_target(item_name)
		target_name = item_name
		steal_target = possible_items[target_name]
		if (!steal_target )
			steal_target = possible_items_special[target_name]
		explanation_text = "Steal [target_name]."
		return steal_target


	find_target()
		return set_target(pick(possible_items))


	proc/select_target()
		var/list/possible_items_all = possible_items+possible_items_special+"custom"
		var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
		if (!new_target) return
		if (new_target == "custom")
			var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
			if (!custom_target) return
			var/tmp_obj = new custom_target
			var/custom_name = tmp_obj:name
			qdel(tmp_obj)
			custom_name = sanitize(input("Enter target name:", "Objective target", custom_name) as text|null)
			if (!custom_name) return
			target_name = custom_name
			steal_target = custom_target
			explanation_text = "Steal [target_name]."
		else
			set_target(new_target)
		return steal_target

	check_completion()
		if(!steal_target || !owner.current)	return 0
		if(!isliving(owner.current))	return 0
		var/list/all_items = owner.current.get_contents()
		switch (target_name)
			if("28 moles of plasma (full tank)","10 diamonds","50 gold bars","25 refined uranium bars")
				var/target_amount = text2num(target_name)//Non-numbers are ignored.
				var/found_amount = 0.0//Always starts as zero.

				for(var/obj/item/I in all_items) //Check for plasma tanks
					if(istype(I, steal_target))
						found_amount += (target_name=="28 moles of plasma (full tank)" ? (I:air_contents:gas["plasma"]) : (I:amount))
				return found_amount>=target_amount

			if("50 coins (in bag)")
				var/obj/item/moneybag/B = locate() in all_items

				if(B)
					var/target = text2num(target_name)
					var/found_amount = 0.0
					for(var/obj/item/coin/C in B)
						found_amount++
					return found_amount>=target

			else

				for(var/obj/I in all_items) //Check for items
					if(istype(I, steal_target))
						return 1
		return 0



datum/objective/absorb
	proc/gen_amount_goal(var/lowbound = 4, var/highbound = 6)
		target_amount = rand (lowbound,highbound)
		if (ticker)
			var/n_p = 1 //autowin
			if (ticker.current_state == GAME_STATE_SETTING_UP)
				for(var/mob/new_player/P in player_list)
					if(P.client && P.ready && P.mind!=owner)
						n_p ++
			else if (ticker.current_state == GAME_STATE_PLAYING)
				for(var/mob/living/carbon/human/P in player_list)
					if(P.client && !(P.mind in ticker.mode.changelings) && P.mind!=owner)
						n_p ++
			target_amount = min(target_amount, n_p)

		explanation_text = "Absorb [target_amount] compatible genomes."
		return target_amount

	check_completion()
		if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
			return 1
		else
			return 0

/*---------SUCCUBUS----------*/
datum/objective/succubus
	explanation_text = "Corrupt 5 men and consume their souls through a coitus!"

	check_completion()
		if(owner && owner.succubus && owner.succubus.succubusSlaves.len >= 5)
			return 1
		else
			return 0

datum/objective/succubusTwo
	explanation_text = "Ensure that you are the only Succubus in the fortress!"

	check_completion()
		for(var/mob/living/carbon/human/H in mob_list)
			if(H.gender == "female" && !H.isChild() && !H.outsider && H.mind.special_role == "Succubus")
				if(H.stat != DEAD)
					return 0
				else
					return 1

datum/objective/plinio
	explanation_text = "Replace 8 portraits with Plinio Salgaka in total, anauê!"

	check_completion()
		if(plinioposters >= 8)
			return 1
		else
			return 0



/* Isn't suited for global objectives
/*---------CULTIST----------*/

		eldergod
			explanation_text = "Summon Nar-Sie via the use of an appropriate rune. It will only work if nine cultists stand on and around it."

			check_completion()
				if(eldergod) //global var, defined in rune4.dm
					return 1
				return 0

		survivecult
			var/num_cult

			explanation_text = "Our knowledge must live on. Make sure at least 5 acolytes escape on the shuttle to spread their work on an another station."

			check_completion()
				if(emergency_shuttle.location<2)
					return 0

				var/cultists_escaped = 0

				var/area/shuttle/escape/centcom/C = /area/shuttle/escape/centcom
				for(var/turf/T in	get_area_turfs(C.type))
					for(var/mob/living/carbon/H in T)
						if(iscultist(H))
							cultists_escaped++

				if(cultists_escaped>=5)
					return 1

				return 0

		sacrifice //stolen from traitor target objective

			proc/find_target() //I don't know how to make it work with the rune otherwise, so I'll do it via a global var, sacrifice_target, defined in rune15.dm
				var/list/possible_targets = call(/datum/game_mode/cult/proc/get_unconvertables)()

				if(possible_targets.len > 0)
					sacrifice_target = pick(possible_targets)

				if(sacrifice_target && sacrifice_target.current)
					explanation_text = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell join blood) and three acolytes to do so."
				else
					explanation_text = "Free Objective"

				return sacrifice_target

			check_completion() //again, calling on a global list defined in rune15.dm
				if(sacrifice_target.current in sacrificed)
					return 1
				else
					return 0

/*-------ENDOF CULTIST------*/
*/

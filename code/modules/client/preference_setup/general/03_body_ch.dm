// Chomp additions to character load/save logic
// /datum/category_item/player_setup_item/general/body/content cannot be overridden here due to requiring being a cleaned list


/datum/category_item/player_setup_item/general/body/copy_to_mob(var/mob/living/carbon/human/character)
	. = ..()
	if(character.species.digi_allowed)
		character.digitigrade = pref.digitigrade
	else
		character.digitigrade = FALSE

/datum/category_item/player_setup_item/general/body/OnTopic(var/href,var/list/href_list, var/mob/user)
	if(href_list["digitigrade"])
		pref.digitigrade = !pref.digitigrade

		return TOPIC_REFRESH_UPDATE_PREVIEW
	. = ..()

// Savefile additions
// Be careful here
/datum/category_item/player_setup_item/general/body/load_character(var/savefile/S)
	. = ..()
	S["digitigrade"] 	>> pref.digitigrade //CHOMPEdit

/datum/category_item/player_setup_item/general/body/save_character(var/savefile/S)
	. = ..()
	S["digitigrade"]	<< pref.digitigrade //CHOMPEdit
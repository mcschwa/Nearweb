/mob/living/carbon/human/New()
	..()
	if(!client)
		return
	if(donation_30cm.Find(ckey))
		potenzia = rand(30, 32)
//XD
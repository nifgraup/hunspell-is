#Todo:
#	Ekki breyta , í | í texta í svigum, sjá "internet"
#	Flokka eftir [1], [2] etc. (Viljum við gera það ef t.d. eru tvö [1] í sama *heiti eða bara á milli heita?)
#	Bæta við orðskýringum
#		ef þær eru fleiri en ein og eitt orð hver?
#		ef þær eru ekki nafnorð, þ.á.m. sérnöfn, karlmanns- og kvenmannsnöfn, (og fleiri en eitt)?
#	bæta við öðrum stafsetningum, andheitum, yfirheitum, undirheitum, "sjá einnig", (orðtök, "afleiddar merkingar" og orðsifjar).
#	Hvað með orð í fleiri en einum orðflokki, t.d. dýr?

{
	if(match($0, /<title>.*<\/title>/))
	{
		word=substr($0, 12, length($0)-19);
		icelandic=0;
	}
	else if(match($0, /{{-..-}}/))
		if(match($0, /{{-is-}}/))
			icelandic=1;
		else
			icelandic=0;

	if((icelandic == 1) && match($1, /{{-samheiti-}}/))
	{
		nMeanings = 0;
		lines = "";
		getline;
		while(NF > 1)
		{
			thes = $0;
			sub(/:+(\[([[:alnum:]]|,|-)+\])? */, "", thes);
			gsub(/\[(([[:alnum:]]| )*\|)?|\]/, "", thes); #remove links and brackets
			gsub(/ *&lt;[[:alpha:]]+&gt;[^;]*&lt;\/[[:alpha:]]+&gt;/, "", thes); #remove html tags and text inside.
			gsub(/, */, "|", thes); #todo: ekki skipta út í texta sem fer í sviga
			while(match(thes, /\047|{|}|:/))
			{
				sub(/(\047|{)+/, "(", thes);
				sub(/(\047|}|:)+/, ")", thes);
			}
			gsub(/\(+/, "(", thes);
			gsub(/\)+/, ")", thes);

			if(thes != "")
			{
				nMeanings++;
				if(lines == "")
					lines=lines thes;
				else
					lines=lines "\n|"thes;
			}
			getline;
		}
		if(nMeanings > 0)
		{
			print word"|"nMeanings;
			print "|"lines;
		}
	}
}


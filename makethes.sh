#!/bin/sh

TMP=tmp
LANG=is

echo "UTF-8" > dicts/th_is.dat

LC_ALL=is_IS.utf8 gawk -F " " '
{
	if(match($0, /<title>.*<\/title>/))
	{
		title=substr($0, 12, length($0)-19);
		icelandic=0;
	}

	if(match($0, /{{-..-}}/))
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
			nMeanings++;
			thes = $0;
			sub(/:+(\[([[:alnum:]]|,|-)+\])? */, "", thes);
			gsub(/\[\[(([[:alnum:]]| )*\|)?|\]/, "", thes);
			gsub(/, */, "|", thes); #todo: ekki skipta út í texta sem fer í sviga
			while(match(thes, /\047|{|}|:/))
			{
				sub(/(\047|{)+/, "(", thes);
				sub(/(\047|}|:)+/, ")", thes);
			}
			gsub(/\(+/, "(", thes);
			gsub(/\)+/, ")", thes);

			if(lines == "")
				lines=lines thes;
			else
				lines=lines "\n|"thes;
			getline;
		}
		if(nMeanings > 0)
		{
			print title"|"nMeanings;
			print "|"lines;
		}
	}
} ' ${TMP}/${LANG}wiktionary-latest-pages-articles.xml >> dicts/th_is.dat

LC_ALL=is_IS.utf8 /usr/share/mythes/th_gen_idx.pl -o dicts/th_is.idx < dicts/th_is.dat


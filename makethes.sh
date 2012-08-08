
#!/bin/sh

TMP=tmp
LANG=is

gawk -F " " '
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
		nlines = 0;
		lines = "";
		getline;
		while($2 != "")
		{
			nlines++;
			thes = $0;
			sub(/:\[[0-9,-]+\] /, "", thes);
			gsub(/, */, "|", thes);
			gsub(/[\[\]]/, "", thes);
			gsub(/{{/, "(", thes);
			gsub(/}}/, ")", thes);
			gsub(/''\(/, "(", thes);

			if(lines == "")
				lines=lines thes;
			else
				lines=lines "\n"thes;
			getline;
		}
		if(nlines > 0)
		{
			print title"|"nlines;
			print lines;
		}
	}
} ' ${TMP}/${LANG}wiktionary-latest-pages-articles.xml


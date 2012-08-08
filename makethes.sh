#!/bin/sh

gawk -F " " '
{
	if(match($0, /<title>.*<\/title>/))
	{
		title=substr($0, 12, length($0)-19);
		icelandic=0;
	}

	if(match($0, /.*{{-is-}}/))
		icelandic=1;

	if((icelandic == 1) && match($1, /{{-samheiti-}}/))
	{
		lines = 0;
		getline;
		while($2 != "")
		{
			lines++;
			print $0;
			getline;
		}
		if(lines > 0)
		{
			print title"|"lines;
		}
	}
} ' tmp/iswiktionary-latest-pages-articles.xml


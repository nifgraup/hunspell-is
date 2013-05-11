#!/bin/bash

# Author: Björgvin Ragnarsson
# License: Public Domain

#todo:
#
#Invalid entries:
#	Remove words containing {{fornt}}
#		remove skáldamál?
#	rangfærslur á is.wiktionar.org? gera jafn- að -is-forskeyti-, rímnaflæði er hvk
#	check if unconfirmed revision of pages end upp in the dictionary
#Refactoring:
#	move language specific extraction of words to langs/is
#	remove first parameter, $1 of print-dic-entry
#	reorder common rules
#	replace gawk with printf?
#Features:
#	Stúdera samsett orð (COMPOUND* reglurnar)
#	make chrome/opera dictionary packages
#	test print-dic-entry
#Optimizations:
#	bæta bókstöfum við try? - nota nútímalegri texa en snerpu (ath. að wikipedia segir aldrei "ég")
#	profile utf8 vs. iso-8859-1
#	add automatic affix compression (affixcompress, doubleaffixcompress, makealias)
#		- profile automatic affix compression for speed, memory.
#is-extractwords.old
#	tekur of mikið minni (140mb)
#	Raða skilyrðum í röð svo algengustu til að faila komi fyrst. (optimization)


# Check dependencies
for i in hunspell gawk bash ed sort bunzip2; do
  command -v $i &>/dev/null || { echo "I require $i but it's not installed. Aborting." >&2; exit 1; }
done

insertHead() {
  printf '%s\n' H 1i "$1" . w | ed -s "$2"
}

if [ "$1" != "" ]; then
  echo "Extracting valid words from the wiktionary dump..."
  rm -f wiktionary.extracted
  mkdir -p dicts
  cat langs/$1/common-aff.d/*.aff > dicts/$1.aff
  FLAG=`grep -h -o [[:space:]][[:digit:]]*[[:space:]]N[[:space:]] langs/$1/common-aff.d/*.aff  | gawk 'BEGIN {max = 0} {if($1>max) max=$1} END {print max}'`

  #extracting from wiki-templates based on defined rules
  find langs/$1/rules/* -type d | while read i
  do
    FLAG=`expr $FLAG + 1`
    RULE="`basename "$i"`"
   
    if [ -f "$i/aff" ]; then
	    LINECOUNT="`grep -cve '^\s*$' "$i/aff"`"
	    echo "   Extracting rule $RULE"
	    echo "#$RULE" >> dicts/$1.aff
	    echo "SFX $FLAG N $LINECOUNT" >> dicts/$1.aff
	    cat "$i/aff" | sed "s/SFX X/SFX $FLAG/g" >> dicts/$1.aff
    fi

    if [ -e "$i/print-dic-entry" ]; then
        grep -o "^{{$RULE|[^}]\+" ${1}wiktionary-latest-pages-articles.xml.texts | grep -o "|.*" | "./$i/print-dic-entry" $FLAG >> wiktionary.extracted
    else
        grep -o "^{{$RULE|[^}]\+" ${1}wiktionary-latest-pages-articles.xml.texts | grep -o "|.*" | gawk -F "|" '{printf "%s%s%s\n", $1, $2, $3"/"'"$FLAG"'}' >> wiktionary.extracted
    fi
  done

  #extracting abbreviations
  grep -C 3 "{{-is-}}" iswiktionary-latest-pages-articles.xml | grep -C 2 "{{-is-skammstöfun-}}" | grep "'''" | grep -o "[^']*" >> wiktionary.extracted

  #extracting adverbs
  grep -C 3 "{{-is-}}" iswiktionary-latest-pages-articles.xml | grep -C 2 "{{-is-atviksorð-}}" | grep "'''[^ ]*'''$" | grep -o "[^']*" | xargs printf "%s\tpo:a\n" >> wiktionary.extracted

  cp wiktionary.extracted wiktionary.dic
  insertHead `wc -l < wiktionary.dic` wiktionary.dic
  cp dicts/$1.aff wiktionary.aff

  echo "Finding extra words in the wordlist..."
  hunspell -i utf8 -l -d wiktionary < langs/$1/wordlist > wordlist.diff

  echo "Merging the wordlist and the wiktionary words..."
  LC_ALL=$1.UTF-8 sort wiktionary.extracted wordlist.diff | uniq > dicts/$1.dic
  insertHead `wc -l < dicts/$1.dic` dicts/$1.dic

  echo "Done building dictionary, see dicts/$1.dic and dicts/$1.aff."

else
  echo "Usage:"
  echo "        $0 is"
fi


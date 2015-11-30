#!/bin/bash

# Author: Björgvin Ragnarsson
# License: CC0 1.0

#todo:
#
#Invalid entries:
#	Remove words containing {{fornt}}
#		remove skáldamál?
#	rangfærslur á is.wiktionar.org? gera jafn- að -is-forskeyti-, rímnaflæði er hvk
#	check if unconfirmed revision of pages end upp in the dictionary
#Features:
#	Stúdera samsett orð (COMPOUND* reglurnar)
#	make chrome/opera dictionary packages
#	test print-dic-entry
#Optimizations:
#	bæta bókstöfum við try? - nota nútímalegri texa en snerpu (ath. að wikipedia segir aldrei "ég")
#	profile utf8 vs. iso-8859-1
#	add automatic affix compression (affixcompress, doubleaffixcompress, makealias)
#		- profile automatic affix compression for speed, memory.


# Check dependencies
for i in hunspell gawk bash ed sort bunzip2 python3; do
  command -v $i &>/dev/null || { echo "I require $i but it's not installed. Aborting." >&2; exit 1; }
done

insertHead() {
  printf '%s\n' H 1i "$1" . w | ed -s "$2"
}

if [ "$1" != "" ]; then
  echo "Extracting valid words from the wiktionary dump..."
  mkdir -p dicts
  rm -rf wiktionary.dic wiktionary.aff
   # This is where the magic happens
  ./makedict.py ${1}wiktionary-latest-pages-articles.xml wiktionary.dic wiktionary.aff
  echo -e '0r langs/is/common-aff.d/22_fallbeyging_kk.aff\nw' | ed -s wiktionary.aff
  echo -e '0r langs/is/common-aff.d/10_header.aff\nw' | ed -s wiktionary.aff

  FLAG=600 # currently makedict.py extracts 333 rules

  #extracting from wiki-templates based on defined rules
  find langs/$1/rules/* -type d | while read i
  do
    FLAG=`expr $FLAG + 1`
    RULE="`basename "$i"`"
   
    if [ -f "$i/aff" ]; then
           LINECOUNT="`grep -cve '^\s*$' "$i/aff"`"
           echo "   Extracting rule $RULE"
           echo "#$RULE" >> wiktionary.aff
           echo "SFX $FLAG N $LINECOUNT" >> wiktionary.aff
           cat "$i/aff" | sed "s/SFX X/SFX $FLAG/g" >> wiktionary.aff
    fi

    if [ -e "$i/print-dic-entry" ]; then
        grep -o "^{{$RULE|[^}]\+" ${1}wiktionary-latest-pages-articles.xml.texts | grep -o "|.*" | "./$i/print-dic-entry" $FLAG >> wiktionary.dic
    else
        grep -o "^{{$RULE|[^}]\+" ${1}wiktionary-latest-pages-articles.xml.texts | grep -o "|.*" | gawk -F "|" '{printf "%s%s%s\n", $1, $2, $3"/"'"$FLAG"'}' >> wiktionary.dic
    fi
  done

  #extracting abbreviations
  grep -C 3 "{{-is-}}" iswiktionary-latest-pages-articles.xml | grep -C 2 "{{-is-skammstöfun-}}" | grep "'''" | grep -o "[^']*" >> wiktionary.dic

  #extracting adverbs
  grep -C 3 "{{-is-}}" iswiktionary-latest-pages-articles.xml | grep -C 2 "{{-is-atviksorð-}}" | grep "'''[^ ]*'''$" | grep -o "[^']*" | xargs printf "%s\tpo:ao\n" >> wiktionary.dic

  #extracting prepositions
  grep -C 1 "{{-is-forsetning-}}" iswiktionary-latest-pages-articles.xml | grep -o "'''[^ ]*'''" | grep -o "[^']*" | xargs printf "%s\tpo:fs\n" >> wiktionary.dic

  #extracting conjunctions
  grep -C 1 "{{-is-samtenging-}}" iswiktionary-latest-pages-articles.xml | grep -v fornt | tr -d "[]" | grep -o "'''[^ .]*'''" | grep -o "[^']*" | xargs printf "%s\tpo:st\n" >> wiktionary.dic

  ./makealias.py  wiktionary dicts/is
  insertHead `wc -l < wiktionary.dic` wiktionary.dic

  echo "Finding extra words in the wordlist..."
  hunspell -i utf8 -l -d wiktionary < langs/$1/wordlist > wordlist.diff

  echo "Merging the wordlist and the wiktionary words..."
  LC_ALL=$1.UTF-8 sort dicts/$1.dic wordlist.diff -o dicts/$1.dic
  insertHead `wc -l < dicts/$1.dic` dicts/$1.dic

  echo "Done building dictionary, see dicts/$1.dic and dicts/$1.aff."

else
  echo "Usage:"
  echo "        $0 is"
fi


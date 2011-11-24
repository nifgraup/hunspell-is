#!/bin/bash

# Author: Björgvin Ragnarsson
# License: Public Domain

#todo:
#tools/insert-common-rule
#Remove words containing (fornt) and skáldamál
#check if unconfirmed revision of pages end upp in the dictionary
#Stúdera samsett orð (COMPOUND* reglurnar)
#bæta bókstöfum við try? - nota nútímalegri texa en snerpu (ath. að wikipedia segir aldrei "ég")
#profile utf8 vs. iso-8859-1
#replace gawk with printf?
#eð/ cover-ar eða, viljum við halda eða inni sem sér orði? (Sama á við sérnöfn)
#rangfærslur á is.wiktionar.org?
#	gera jafn- að -is-forskeyti-, rímnaflæði er hvk
#add automatic affix compression (affixcompress, doubleaffixcompress, makealias)
#	profile automatic affix compression for speed, memory.
#wget -N does not work on cygwin - downloads every time.
#enforce & print dictionary license
#make firefox/chrome/opera dictionary packages
#is-extractwords.old
#	tekur of mikið minni (140mb)
#	Raða skilyrðum í röð svo algengustu til að faila komi fyrst. (optimization)

# Check dependencies
for i in hunspell gawk bash ed sort bunzip2 iconv wget; do
  command -v $i &>/dev/null || { echo "I require $i but it's not installed. Aborting." >&2; exit 1; }
done

TMP="tmp"
mkdir -p ${TMP}

insertHead() {
  printf '%s\n' H 1i "$1" . w | ed -s "$2"
}

if [ "$1" = "clean" ]; then
  rm -f ${TMP}/wiktionary.dic ${TMP}/wiktionary.aff ${TMP}/wiktionary.extracted ${TMP}/wordlist.diff
  rm -f ${TMP}/huntest.aff ${TMP}/huntest.dic
  rm -f dicts/*.dic dicts/*.aff
#  rm -f ${TMP}/??wiktionary-latest-pages-articles.xml ${TMP}/??wiktionary-latest-pages-articles.xml.texts
  rmdir dicts
  rmdir tmp

elif [ "$1" = "list" ]; then
  for i in $( ls -d langs/*/ ); do
    echo `basename $i`
  done

elif [ "$1" = "test" ]; then
  if [ "$2" = "" ]; then
    echo "Usage: $0 test is"
    exit 1
  fi
  echo "Testing rules..."
  find langs/$2/* -type d | while read i
  do
    cp langs/$2/common-aff ${TMP}/huntest.aff
    LINECOUNT="`grep -cve '^\s*$' "$i/aff"`"
    echo "SFX X N $LINECOUNT" >> ${TMP}/huntest.aff
    cat "$i/aff" >> ${TMP}/huntest.aff
    TESTNAME="`basename "$i"`"
    echo "Testing rule $TESTNAME"
    cp "$i/dic" ${TMP}/huntest.dic
    test -z "`hunspell -l -d ${TMP}/huntest < "$i/good"`" || { echo "Good word test for $TESTNAME failed: `hunspell -l -d ${TMP}/huntest < "$i/good"`"; exit 1; }
    test -z "`hunspell -G -d ${TMP}/huntest < "$i/bad"`" || { echo "Bad word test for $TESTNAME failed: `hunspell -G -d ${TMP}/huntest < "$i/bad"`"; exit 1; }
  done
  echo "All passed."

elif [ "$1" = "packages" ]; then
  if [ "$2" = "" ]; then
    echo "Usage: $0 packages is"
    exit 1
  fi
  echo "Making Libreoffice extension..."
  TODAY=`date +%Y.%m.%d`
  rm -f dicts/hunspell-is-$TODAY.oxt
  rm -rf tmp/libreoffice
  cp -rf packages/libreoffice tmp/
  cd tmp/libreoffice
  sed -i 's/TODAYPLACEHOLDER/'$TODAY'/g' description.xml
  zip -r ../../dicts/hunspel-is-$TODAY.oxt *
  cd ../../
  zip dicts/hunspel-is-$TODAY.oxt dicts/is.dic dicts/is.aff
  cd ..

elif [ "$1" != "" ]; then
  echo "Downloading files..."
  test -e ${TMP}/${1}wiktionary-latest-pages-articles.xml || wget --timestamping http://download.wikimedia.org/${1}wiktionary/latest/${1}wiktionary-latest-pages-articles.xml.bz2 -O - | bunzip2 > ${TMP}/${1}wiktionary-latest-pages-articles.xml
  test -e ${TMP}/${1}wiktionary-latest-pages-articles.xml.texts || grep -o "{{[^.]*|[^-.][^}]*" ${TMP}/iswiktionary-latest-pages-articles.xml | sort | uniq > ${TMP}/iswiktionary-latest-pages-articles.xml.texts
  echo "Extracting valid words from the wiktionary dump..."
  rm -f ${TMP}/wiktionary.extracted
  mkdir -p dicts
  cp langs/$1/common-aff dicts/$1.aff
  FLAG=`grep -o [[:space:]][[:digit:]]*[[:space:]]N[[:space:]] langs/$1/common-aff | gawk 'BEGIN {max = 0} {if($1>max) max=$1} END {print max}'`

  find langs/$1/* -type d | while read i
  do
    FLAG=`expr $FLAG + 1`
    RULE="`basename "$i"`"
    LINECOUNT="`grep -cve '^\s*$' "$i/aff"`"
    echo "   Extracting rule $RULE"

    echo "#$RULE" >> dicts/$1.aff
    echo "SFX $FLAG N $LINECOUNT" >> dicts/$1.aff
    cat "$i/aff" | sed "s/SFX X/SFX $FLAG/g" >> dicts/$1.aff

    if [ -e "$i/print-dic-entry" ]; then
        grep -o "^{{$RULE|[^}]\+" ${TMP}/${1}wiktionary-latest-pages-articles.xml.texts | grep -o "|.*" | "./$i/print-dic-entry" $FLAG >> ${TMP}/wiktionary.extracted
    else
        if [ -e "$i/format" ]; then
    	    REFORMATSTRING="`cat "$i/format"`"
        else
	    REFORMATSTRING="%s%s%s"
        fi
        grep -o "^{{$RULE|[^}]\+" ${TMP}/${1}wiktionary-latest-pages-articles.xml.texts | grep -o "|.*" | gawk -F "|" '{printf "'$REFORMATSTRING'\n", $1, $2, $3"/"'"$FLAG"'}' >> ${TMP}/wiktionary.extracted
    fi
  done
  cp ${TMP}/wiktionary.extracted ${TMP}/wiktionary.dic
  insertHead `wc -l < ${TMP}/wiktionary.dic` ${TMP}/wiktionary.dic
  cp dicts/$1.aff ${TMP}/wiktionary.aff

  echo "Finding extra words in the wordlist..."
  hunspell -i utf8 -l -d ${TMP}/wiktionary < langs/$1/wordlist > ${TMP}/wordlist.diff

  echo "Merging the wordlist and the wiktionary words..."
  LC_ALL=$1.UTF-8 sort ${TMP}/wiktionary.extracted ${TMP}/wordlist.diff > dicts/$1.dic
  insertHead `wc -l < dicts/$1.dic` dicts/$1.dic

  echo "Done building dictionary, see dicts/$1.dic and dicts/$1.aff."

else
  echo "Usage:"
  echo "        $0 is | packages is | test is | list | clean"
fi


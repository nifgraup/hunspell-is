#!/bin/bash

# Author: Björgvin Ragnarsson
# License: Public Domain

#todo:
#bæta bókstöfum við try? - nota nútímalegri texa en snerpu
#setja orðalistann inn í is.good bannorðalistann í is.bad ? ekki download-a orðalista.
#     Svo búa til "makedict.sh rebasegood" til að minnka orðalistann sem fylgir
#     hunspell-is eftir því sem wiktionary stækkar.
#gera jafn- að -is-forskeyti-, rímnaflæði er hvk
#profile automatic affix compression for speed, memory.
#add automatic affix compression (affixcompress, doubleaffixcompress, makealias)
#remove lower case word in dicts/*.dic when a capitalized word exists
#bæta við TMP breytu sem vísar á möppuna /tmp/ eða annað.
#wget -N does not work on cygwin - downloads every time.
#enforce & print dictionary license
#clean iswiktionary xml and wordlist.org
#make firefox/openoffice/chrome/opera dictionary packages
#is-extractwords.old tekur of mikið minni (140mb)
#Raða skilyrðum í is-extractwords.old í röð svo algengustu til að faila komi fyrst. (optimization)

TMP="tmp"
mkdir -p ${TMP}

insertHead() {
  printf '%s\n' H 1i "$1" . w | ed -s "$2"
}

if [ "$1" = "clean" ]; then
  rm -f wiktionary.dic wiktionary.aff wiktionary.extracted wordlist.diff wordlist.sorted
  rm -f ${TMP}/huntest.aff ${TMP}/huntest.dic
  rm -f dicts/*.dic dicts/*.aff
#  rm -f wordlist.orig ??wiktionary-latest-pages-articles.xml ??
  rmdir dicts

elif [ "$1" = "check" ]; then
  for i in $( echo "hunspell gawk bash ed sort bunzip2 iconv wget"); do
    if [ "`type $i | grep -o "not found"`" = "not found" ]; then
      echo "I require $i but it's not installed.  Aborting."
      exit 1
    fi
  done
  echo "All dependencies fullfilled."

elif [ "$1" = "list" ]; then
  basename langs/*.conf .conf

elif [ "$1" = "test" ]; then
  if [ "$2" = "" ]; then
    echo "Usage: $0 test is"
    exit 1
  fi
  echo "Testing known words..."
  for i in $( ls langs/$2/*.good); do
    TESTNAME="`basename $i .good`"
    cat langs/$2/common-aff langs/$2/$TESTNAME.aff > ${TMP}/huntest.aff
    cp langs/$2/$TESTNAME.dic ${TMP}/huntest.dic
    test -z "`hunspell -l -d ${TMP}/huntest < langs/$2/$TESTNAME.good`" || { echo "Good word test for $TESTNAME failed: `hunspell -l -d ${TMP}/huntest < langs/$2/$TESTNAME.good`"; exit 1; }
  done
  echo "All known words passed."
  echo "Testing bad words..."
  for i in $( ls langs/$2/*.bad); do
    TESTNAME="`basename $i .bad`"
    cat langs/$2/common-aff langs/$2/$TESTNAME.aff > ${TMP}/huntest.aff
    cp langs/$2/$TESTNAME.dic ${TMP}/huntest.dic
    test -z "`hunspell -G -d ${TMP}/huntest < langs/$2/$TESTNAME.bad`" || { echo "Bad word test for $TESTNAME failed: `hunspell -G -d ${TMP}/huntest < langs/$2/$TESTNAME.bad`"; exit 1; }
  done
  echo "Passed."

elif [ "$1" != "" ]; then
  echo "Downloading files..."
  test -e wordlist.orig || wget --timestamping http://elias.rhi.hi.is/pub/is/ordalisti -O wordlist.orig
  test -e ${1}wiktionary-latest-pages-articles.xml || wget --timestamping http://download.wikimedia.org/${1}wiktionary/latest/${1}wiktionary-latest-pages-articles.xml.bz2 -O - | bunzip2 > ${1}wiktionary-latest-pages-articles.xml
  echo "Extracting valid words from the wiktionary dump..."
  rm -f wiktionary.extracted
  cp langs/$1/common-aff wiktionary.aff
  FLAG=1
  for i in $( ls langs/$1/*.aff); do
    RULE="`basename $i .aff | sed 's/_/ /g'`"
    cat $i | sed "s/SFX X/SFX $FLAG/g" >> wiktionary.aff
    grep -o "^{{$RULE|[^}]*" ${1}wiktionary-latest-pages-articles.xml | grep -o "|.*" | tr -d "|" | gawk '{print $1"/"'"$FLAG"'}' >> wiktionary.extracted
    FLAG=`expr $FLAG + 1`
  done
  gawk '{print $1"/c"}' wiktionary.extracted > wiktionary.dic
  insertHead `wc -l < wiktionary.dic` wiktionary.dic
  echo "KEEPCASE c" >> wiktionary.aff

  echo "Finding extra words in the wordlist..."
  iconv -f iso8859-1 -t utf-8 wordlist.orig | sort | comm - langs/$1.banned -2 -3 > wordlist.sorted
  hunspell -i utf8 -l -d wiktionary < wordlist.sorted > wordlist.diff

  echo "Merging the wordlist and the wiktionary words..."
  mkdir -p dicts
  LC_ALL=$1.UTF-8 sort wiktionary.extracted wordlist.diff > dicts/$1.dic
  insertHead `wc -l < dicts/$1.dic` dicts/$1.dic
  cp langs/$1/common-aff dicts/$1.aff
  for i in $( ls langs/$1/*.aff); do
    cat $i >> dicts/$1.aff
  done

  echo "Done building dictionary, see dicts/$1.dic and dicts/$1.aff."

else
  echo "Usage:"
  echo "        $0 is | check | test is | list | clean"
fi


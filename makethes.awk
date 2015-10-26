#Todo:
#  Flokka eftir [1], [2] etc. (Viljum við gera það ef t.d. eru tvö [1] í sama *heiti eða bara á milli heita?)
#  Bæta við orðskýringum
#    ef þær eru fleiri en ein og eitt orð hver?
#    ef þær eru ekki nafnorð, þ.á.m. sérnöfn, karlmanns- og kvenmannsnöfn, (og fleiri en eitt)?
#  bæta við öðrum stafsetningum, "sjá einnig", (orðtök, "afleiddar merkingar" og orðsifjar).
#  Hvað með orð í fleiri en einum orðflokki, t.d. dýr?

BEGIN { print "UTF-8"; }
{
  if (match($0, /<title>.*<\/title>/)) {
    if (nMeanings > 0) {
      print word"|"nMeanings;
      print "|"lines;
    }
    nMeanings = 0;
    lines = "";
    word=substr($0, 12, length($0)-19);
    icelandic=0;
  } else if (match($0, /{{-..-}}/)) {
    if (match($0, /{{-is-}}/)) {
      icelandic=1;
    } else {
      icelandic=0;
    }
  }

  if (icelandic) {
    if (match($1, /{{-samheiti-}}/)) {
      explaination = "";
    } else if (match($1, /{{-andheiti-}}/)) {
      explaination = " (andheiti)";
    } else if (match($1, /{{-yfirheiti-}}/)) {
      explaination = " (yfirheiti)";
    } else if (match($1, /{{-undirheiti-}}/)) {
      explaination = " (undirheiti)";
    }

    if (RSTART) {
      getline;
      while (NF > 1) {
        thes = $0;
        # remove optinal listing at the beginning, eg. [1]:  todo: make use of this.
        sub(/:+(\[([[:alnum:]]|,|-)+\])? */, "", thes);

        # remove link template
        if (match(thes, /{{tengill\|/)) {
          sub(/{{tengill\|/, "", thes);
          sub(/\|/, " (", thes);
        }

        #remove [1] after word
        gsub(/ \[[0-9]\]/, "", thes);

        #remove links and brackets
        gsub(/\[(([[:alnum:]]| )*\|)?|\]/, "", thes);

        #remove html tags and text inside.
        gsub(/ *&lt;[[:alpha:]]+&gt;.*&lt;\/[[:alpha:]]+&gt;/, "", thes);

        #replace quotes, and curly brackets with parenthesis.
        while (match(thes, /[\047{}]/)) {
          sub(/[\047{]+/, "(", thes);
          sub(/[\047}]+/, ")", thes);
        }

        #remove colon
        gsub(/:\)/, ")", thes);
        sub(/[^:(]+: ?/, "", thes);

        #remove double parenthesis possibly added by previous replacement.
        gsub(/\(+/, "(", thes);
        gsub(/\)+/, ")", thes);

        #replace , with | unless the comma is inside parenthesis.
        while (match(thes, /[^,\(\)]*, /)) {
          if (substr(thes, RSTART-1, 1) == "(") {
            thes = substr(thes, 0, RSTART+RLENGTH-3) "𐌸" substr(thes, RSTART+RLENGTH);
          } else {
            thes = substr(thes, 0, RSTART+RLENGTH-3) explaination"|" substr(thes, RSTART+RLENGTH);
          }
        }
        gsub(/𐌸/, ", ", thes); # re-add commas inside parenthesis

        if(thes != "") {
          nMeanings++;
          if (lines == "") {
            lines=lines thes explaination;
          } else {
            lines=lines "\n|"thes explaination;
          }
        }
        getline;
      }
    }
  }
}

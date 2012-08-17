TH_GEN_IDX=/usr/share/mythes/th_gen_idx.pl

.PHONY: all clean test packages

all: packages

clean:
	rm -f dicts/is.aff dicts/is.dic dicts/th_is.dat dicts/th_is.idx dicts/is.oxt dicts/is.xpi
	rm -f wiktionary.dic wiktionary.aff wiktionary.extracted wordlist.diff
	rm -f huntest.aff huntest.dic
	#  rm -f ??wiktionary-latest-pages-articles.xml.bz2
	rm -f ??wiktionary-latest-pages-articles.xml ??wiktionary-latest-pages-articles.xml.texts
	rmdir --ignore-fail-on-non-empty dicts/

test:
	./makedict.sh test is

packages: dicts/is.oxt dicts/is.xpi

# LibreOffice extension
dicts/is.oxt: %.oxt: %.aff %.dic dicts/th_is.dat dicts/th_is.idx \
		packages/libreoffice/META-INF/manifest.xml \
		packages/libreoffice/description.xml \
		packages/libreoffice/dictionaries.xcu \
		packages/libreoffice/license.txt
	rm -rf $@ libreoffice-tmp
	cp -rf packages/libreoffice libreoffice-tmp
	cd libreoffice-tmp && sed -i 's/TODAYPLACEHOLDER/'`date +%Y.%m.%d`'/g' description.xml && zip -r ../$@ *
	zip $@ dicts/is.dic dicts/is.aff dicts/th_is.dat dicts/th_is.idx

# Mozilla extension
dicts/is.xpi: %.xpi: %.aff %.dic \
		packages/mozilla/install.js \
		packages/mozilla/install.rdf
	rm -rf $@ mozilla-tmp
	cp -rf packages/mozilla mozilla-tmp
	cd mozilla-tmp && sed -i 's/TODAYPLACEHOLDER/'`date +%Y.%m.%d`'/g' install.js && sed -i 's/TODAYPLACEHOLDER/'`date +%Y.%m.%d`'/g' install.rdf && mkdir dictionaries && cp ../dicts/is.dic ../dicts/is.aff dictionaries/ && zip -r ../$@ *

dicts/%.aff: makedict.sh %wiktionary-latest-pages-articles.xml.texts %wiktionary-latest-pages-articles.xml
	./$< is

dicts/%.dic: makedict.sh %wiktionary-latest-pages-articles.xml.texts %wiktionary-latest-pages-articles.xml
	./$< is

dicts/th_%.dat: makethes.awk %wiktionary-latest-pages-articles.xml
	echo "UTF-8" > $@
	LC_ALL=is_IS.utf8 gawk -F " " -f $< <iswiktionary-latest-pages-articles.xml >> $@

%.idx: %.dat
	LC_ALL=is_IS.utf8 ${TH_GEN_IDX} -o $@ < $<

iswiktionary-latest-pages-articles.xml.bz2:
	wget http://dumps.wikimedia.org/iswiktionary/latest/iswiktionary-latest-pages-articles.xml.bz2 -O iswiktionary-latest-pages-articles.xml.bz2

iswiktionary-latest-pages-articles.xml: iswiktionary-latest-pages-articles.xml.bz2
	bunzip2 -kf $<

iswiktionary-latest-pages-articles.xml.texts: iswiktionary-latest-pages-articles.xml
	tr -d "\r\n" < iswiktionary-latest-pages-articles.xml | grep -o "{{[^.|{}]*|[^-.}][^ }]*[}|][^}]*" | sed "s/mynd=.*//g" | sed "s/lo.nf.et.ó=.*//g" | sort | uniq > iswiktionary-latest-pages-articles.xml.texts


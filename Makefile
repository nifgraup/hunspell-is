all: packages

clean:
	rm -f dicts/is.aff dicts/is.dic dicts/th_is.dat dicts/th_is.idx dicts/is.oxt dicts/is.xpi
	rmdir --ignore-fail-on-non-empty dicts/

test:
	./makedict.sh test is

packages: dicts/is.oxt dicts/is.xpi

# LibreOffice extension
dicts/is.oxt: dicts/is.aff dicts/is.dic dicts/th_is.dat dicts/th_is.idx \
		packages/libreoffice/META-INF/manifest.xml \
		packages/libreoffice/description.xml \
		packages/libreoffice/dictionaries.xcu \
		packages/libreoffice/license.txt
	./makedict.sh packages is

# Mozilla extension
dicts/is.xpi: dicts/is.aff dicts/is.dic
		packages/mozilla/install.js \
		packages/mozilla/install.rdf \
	./makedict.sh packages is

dicts/is.aff: makedict.sh
	./makedict.sh is

dicts/is.dic: makedict.sh
	./makedict.sh is

dicts/th_is.dat: makethes.sh
	./makethes.sh

dicts/th_is.idx:
	LC_ALL=is_IS.utf8 /usr/share/mythes/th_gen_idx.pl -o dicts/th_is.idx < dicts/th_is.dat


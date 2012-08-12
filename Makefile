all: packages

clean:
	rm dicts/is.aff dicts/is.dic dicts/th_is.dat dicts/th_is.idx
	rmdir dicts

test:
	./makedict.sh test is

packages: dicts/is.aff dicts/is.dic dicts/th_is.dat dicts/th_is.idx
	./makedict.sh packages is

dicts/is.aff:
	./makedict.sh is

dicts/is.dic:
	./makedict.sh is

dicts/th_is.dat:
	./makethes.sh

dicts/th_is.idx:
	LC_ALL=is_IS.utf8 /usr/share/mythes/th_gen_idx.pl -o dicts/th_is.idx < dicts/th_is.dat


Ritvilluleit, málfræðigreining og samheitaorðabók
=================================================

Hunspell-is er hugbúnaður sem les inn gagnabanka [íslensku Wikiorðabókarinnar](http://is.wiktionary.org) og útbýr:

* orðabók fyrir villuleitarforritið [Hunspell](http://hunspell.sourceforge.net/) sem hægt er að nota m.a. með LibreOffice, Firefox, Thunderbird og Google Chrome. Hvert orð hefur skráðan orðflokk og beygingarlýsingu ef við á.
* samheitaorðabók fyrir LibreOffice.

Hunspell-is er samvinnuverkefni og samskipti fara fram á [póstlista](mailto:hunspell-is@googlegroups.com) ([sjá einnig á vefnum](https://groups.google.com/forum/#!forum/hunspell-is)).


Sækja orðabækur
---------------

Orðabækurnar fylgja með [LibreOffice](https://www.libreoffice.org/). Þær má einnig finna stakar í [kóðasafni LibreOffice](http://cgit.freedesktop.org/libreoffice/dictionaries/tree/is) eða í [pakkasafni Debian stýrikerfisins](https://packages.debian.org/sid/hunspell-is).


Málfræðigreining
----------------

Yfir 300 beygingarreglur nafnorða, sagnorða og lýsingarorða eru skráðar í [íslensku Wikiorðabókinni](http://is.wiktionary.org) og eru þær allar fluttar inn í hunspell-is ásamt þeim orðum sem nota reglurnar. Sem dæmi er hægt að greina orðið „á“ með skipuninni

    echo á | hunspell -m -d dicts/is

sem skilar

    á  st:á po:fs
    á  st:eiga po:so
    á  st:ær po:no is:2eó
    á  st:ær po:no is:3eó
    á  st:á po:no
    á  st:á po:no is:3eó
    á  st:á po:no is:2eó

og sjá að það tilheyrir þremur orðflokkum. Orðið er í þolfalli eða þágufalli þegar það þýðir kind en ef átt er við fljót koma þrjú eintöluföll til greina. Nefnimyndin (e. lemma) er einnig sýnd.


Forritið <code>chmorph</code> má nota til að umbreyta texta, t.d. setja sögn í þátíð:

    echo "Strákurinn kallar á mömmu sína." > setning.txt
    chmorph dicts/is.aff dicts/is.dic setning.txt "germynd-framsöguháttur-nútíð:hann" "germynd-framsöguháttur-þátíð:hann"

og útkoman verður

    Strákurinn kallaði á mömmu sína.

„Hvað ef ég finn villu?“
---------------------------

Ef orðið er rangt skráð í [íslensku Wikiorðabókinni](http://is.wiktionary.org) skal lagfæra orðið þar. Orð getur einnig verið rangt skráð í [orðalistanum](https://raw.githubusercontent.com/nifgraup/hunspell-is/master/langs/is/wordlist) sem notaður er til uppfyllingar. Ef svo er má [hafa samband](mailto:hunspell-is@googlegroups.com) og láta fjarlægja orðið.


Þróun
-----

Eftirfarandi skipanir sýna hvernig orðabækurnar eru útbúnar á Debian og Ubuntu stýrikerfum.

	# install dependencies
	sudo apt-get install bzip2 gawk bash ed coreutils make wget hunspell libmythes-dev git python3 python3-pip
	sudo locale-gen is_IS.UTF-8
	sudo LC_ALL=is_IS.utf8 pip3 install git+https://github.com/earwig/mwparserfromhell@87e0079512f3d85813541dc97a240713fc0b33c9
	
	# fetch hunspell-is
	git clone https://github.com/nifgraup/hunspell-is
	cd hunspell-is

	# generate the dictionary & thesaurus
	make
	
	# run correctness test on generated files
	make check

	# generate LibreOffice & Firefox extensions
	make packages


Notkunarleyfi
-------------
Orðabækurnar, líkt og íslenska Wikiorðabókin, eru gefnar út skv. [CC BY-SA 3.0 leyfinu](https://creativecommons.org/licenses/by-sa/3.0/deed.is). Hunspell-is hugbúnaðurinn er [gefinn í almenning](https://creativecommons.org/publicdomain/zero/1.0/deed.is). Orðabækurnar notast við orðalista til uppfyllingar sem var unninn af Orðabók Háskóla Íslands ásamt Reiknistofnun Háskóla Íslands á ofanverðum tíunda áratug síðustu aldar. Sá orðalisti var gefinn út í almenningseigu (e. public domain).

Hunspell-is - The Icelandic spelling dictionary project


Introduction
------------
This project aims to provide and maintain an Icelandic Hunspell spelling
dictionary. It's based on two sources: The wordlist was developed by Orðabók
Háskólans in cooperation with Reiknistofnun Háskóla Íslands in the early
nineties and was released into the public domain. The declension rules are
from the Icelandic Wiktionary Project, http://is.wiktionary.org. Hunspell-is
provides scripts to merge the sources. The wordlist will continue to be static
(maintainers are welcome to step forward) except for removal of non-word. All
new entries are added from Wiktionary.

Other languages can be added, see the langs/ folder.


Dependencies
------------

	bzip2                          http://www.bzip.org/
	GNU awk                        http://www.gnu.org/software/gawk/
	GNU Bash                       http://www.gnu.org/software/bash/
	GNU ed                         http://www.gnu.org/software/ed/
	GNU Core Utilities             http://www.gnu.org/software/coreutils/
	GNU Wget                       http://www.gnu.org/software/wget/
	Hunspell                       http://hunspell.sf.net/
	iconv


Usage Instructions
------------------

	makedict.sh list			# lists supported languages
	makedict.sh LANGUAGE			# generates a dictionary for LANGUAGE, e.g. is
	makedict.sh packages LANGUAGE	# Creates spell checking extensions for applications
	makedict.sh test LANGUAGE		# Runs test cases for wiktionary extraction rules
	makedict.sh clean			# remove temporary files


Download Packages
-----------------
This is a list of projects using hunspell-is

	Openoffice.org		http://extensions.services.openoffice.org/project/dict-is
	LibreOffice		http://extensions.libreoffice.org/extension-center/hunspell-is-the-icelandic-spelling-dictionary-project


Project maintainer
------------------
Björgvin Ragnarsson


Content contributors
--------------------
	Contributors to the Icelandic Wiktionary,
	Orðabók Háskóla Íslands,
	Reiknistofnun Háskóla Íslands.


Contact
-------
https://groups.google.com/group/hunspell-is


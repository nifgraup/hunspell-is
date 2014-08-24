#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Author: Björgvin Ragnarsson
# License: CC0 1.0
#
# TODO:
# * ifeq og switch, etc. |frumstig.et.ef.kk.sterk={{#switch: {{{2|}}} | ss={{{1}}}a{{{2}}} | #default={{{1}}}a{{{2}}}s }}

import mwparserfromhell
import re
from xml.etree import cElementTree as ET
import xml.etree
import sys
import os

if not len(sys.argv) == 4:
  print("Usage:")
  print("  " + sys.argv[0] + " wiki-dump.xml out.dic out.aff")
  exit(1)

templatesInPages = []
print("parsing xml")
tree = ET.ElementTree(file=sys.argv[1])
root = tree.getroot()
for elem in root.iter():
  if elem.tag == "{http://www.mediawiki.org/xml/export-0.9/}text":
    wikicode = mwparserfromhell.parse(elem.text)
    templatesInPages.append(wikicode.filter_templates(recursive=False))
print("done parsing xml, found", len(templatesInPages), "pages")

#TODO: split up to optimize
tagset = [
# Nouns
"1eó", "1eá", "1fó", "1fá", "2eó", "2eá", "2fó", "2fá", "3eó", "3eá", "3fó", "3fá", "4eó", "4eá", "4fó", "4fá",
# Fallbeyging mannsnafn
"1", "2", "3", "4",
# Verbs
"germynd:nafnháttur", "germynd-framsöguháttur-nútíð:ég", "germynd-framsöguháttur-nútíð:þú", "germynd-framsöguháttur-nútíð:hann", "germynd-framsöguháttur-nútíð:við", "germynd-framsöguháttur-nútíð:þið", "germynd-framsöguháttur-nútíð:þeir", "germynd-viðtengingarháttur-nútíð:ég", "germynd-viðtengingarháttur-nútíð:þú", "germynd-viðtengingarháttur-nútíð:hann", "germynd-viðtengingarháttur-nútíð:við", "germynd-viðtengingarháttur-nútíð:þið", "germynd-viðtengingarháttur-nútíð:þeir", "germynd-framsöguháttur-þátíð:ég", "germynd-framsöguháttur-þátíð:þú", "germynd-framsöguháttur-þátíð:hann", "germynd-framsöguháttur-þátíð:við", "germynd-framsöguháttur-þátíð:þið", "germynd-framsöguháttur-þátíð:þeir", "germynd-viðtengingarháttur-þátíð:ég", "germynd-viðtengingarháttur-þátíð:þú", "germynd-viðtengingarháttur-þátíð:hann", "germynd-viðtengingarháttur-þátíð:við", "germynd-viðtengingarháttur-þátíð:þið", "germynd-viðtengingarháttur-þátíð:þeir", "miðmynd:nafnháttur", "miðmynd-framsöguháttur-nútíð:ég", "miðmynd-framsöguháttur-nútíð:þú", "miðmynd-framsöguháttur-nútíð:hann", "miðmynd-framsöguháttur-nútíð:við", "miðmynd-framsöguháttur-nútíð:þið", "miðmynd-framsöguháttur-nútíð:þeir", "miðmynd-viðtengingarháttur-nútíð:ég", "miðmynd-viðtengingarháttur-nútíð:þú", "miðmynd-viðtengingarháttur-nútíð:hann", "miðmynd-viðtengingarháttur-nútíð:við", "miðmynd-viðtengingarháttur-nútíð:þið", "miðmynd-viðtengingarháttur-nútíð:þeir", "miðmynd-framsöguháttur-þátíð:ég", "miðmynd-framsöguháttur-þátíð:þú", "miðmynd-framsöguháttur-þátíð:hann", "miðmynd-framsöguháttur-þátíð:við", "miðmynd-framsöguháttur-þátíð:þið", "miðmynd-framsöguháttur-þátíð:þeir", "miðmynd-viðtengingarháttur-þátíð:ég", "miðmynd-viðtengingarháttur-þátíð:þú", "miðmynd-viðtengingarháttur-þátíð:hann", "miðmynd-viðtengingarháttur-þátíð:við", "miðmynd-viðtengingarháttur-þátíð:þið", "miðmynd-viðtengingarháttur-þátíð:þeir", "boðháttur:stýfður", "boðháttur:germynd:eintala", "boðháttur:germynd:fleirtala", "boðháttur:miðmynd:eintala", "boðháttur:miðmynd:fleirtala","lýsingarháttur nútíðar", "sagnbót:germynd", "sagnbót:miðmynd", "lýsingarháttur.et.nf.kk.sterk", "lýsingarháttur.et.nf.kv.sterk", "lýsingarháttur.et.nf.hk.sterk", "lýsingarháttur.ft.nf.kk.sterk", "lýsingarháttur.ft.nf.kv.sterk", "lýsingarháttur.ft.nf.hk.sterk", "lýsingarháttur.et.þf.kk.sterk", "lýsingarháttur.et.þf.kv.sterk", "lýsingarháttur.et.þf.hk.sterk", "lýsingarháttur.ft.þf.kk.sterk", "lýsingarháttur.ft.þf.kv.sterk", "lýsingarháttur.ft.þf.hk.sterk", "lýsingarháttur.et.þgf.kk.sterk", "lýsingarháttur.et.þgf.kv.sterk", "lýsingarháttur.et.þgf.hk.sterk", "lýsingarháttur.ft.þgf.kk.sterk", "lýsingarháttur.ft.þgf.kv.sterk", "lýsingarháttur.ft.þgf.hk.sterk", "lýsingarháttur.et.ef.kk.sterk", "lýsingarháttur.et.ef.kv.sterk", "lýsingarháttur.et.ef.hk.sterk", "lýsingarháttur.ft.ef.kk.sterk", "lýsingarháttur.ft.ef.kv.sterk", "lýsingarháttur.ft.ef.hk.sterk", "lýsingarháttur.et.nf.kk.veik", "lýsingarháttur.et.nf.kv.veik", "lýsingarháttur.et.nf.hk.veik", "lýsingarháttur.ft.nf.kk.veik", "lýsingarháttur.ft.nf.kv.veik", "lýsingarháttur.ft.nf.hk.veik", "lýsingarháttur.et.þf.kk.veik", "lýsingarháttur.et.þf.kv.veik", "lýsingarháttur.et.þf.hk.veik", "lýsingarháttur.ft.þf.kk.veik", "lýsingarháttur.ft.þf.kv.veik", "lýsingarháttur.ft.þf.hk.veik", "lýsingarháttur.et.þgf.kk.veik", "lýsingarháttur.et.þgf.kv.veik", "lýsingarháttur.et.þgf.hk.veik", "lýsingarháttur.ft.þgf.kk.veik", "lýsingarháttur.ft.þgf.kv.veik", "lýsingarháttur.ft.þgf.hk.veik", "lýsingarháttur.et.ef.kk.veik", "lýsingarháttur.et.ef.kv.veik", "lýsingarháttur.et.ef.hk.veik", "lýsingarháttur.ft.ef.kk.veik", "lýsingarháttur.ft.ef.kv.veik", "lýsingarháttur.ft.ef.hk.veik",
# Adjectives
"frumstig.et.nf.kk.sterk", "frumstig.et.nf.kv.sterk", "frumstig.et.nf.hk.sterk", "frumstig.ft.nf.kk.sterk", "frumstig.ft.nf.kv.sterk", "frumstig.ft.nf.hk.sterk", "frumstig.et.þf.kk.sterk", "frumstig.et.þf.kv.sterk", "frumstig.et.þf.hk.sterk", "frumstig.ft.þf.kk.sterk", "frumstig.ft.þf.kv.sterk", "frumstig.ft.þf.hk.sterk", "frumstig.et.þgf.kk.sterk", "frumstig.et.þgf.kv.sterk", "frumstig.et.þgf.hk.sterk", "frumstig.ft.þgf.kk.sterk", "frumstig.ft.þgf.kv.sterk", "frumstig.ft.þgf.hk.sterk", "frumstig.et.ef.kk.sterk", "frumstig.et.ef.kv.sterk", "frumstig.et.ef.hk.sterk", "frumstig.ft.ef.kk.sterk", "frumstig.ft.ef.kv.sterk", "frumstig.ft.ef.hk.sterk", "frumstig.et.nf.kk.veik", "frumstig.et.nf.kv.veik", "frumstig.et.nf.hk.veik", "frumstig.ft.nf.kk.veik", "frumstig.ft.nf.kv.veik", "frumstig.ft.nf.hk.veik", "frumstig.et.þf.kk.veik", "frumstig.et.þf.kv.veik", "frumstig.et.þf.hk.veik", "frumstig.ft.þf.kk.veik", "frumstig.ft.þf.kv.veik", "frumstig.ft.þf.hk.veik", "frumstig.et.þgf.kk.veik", "frumstig.et.þgf.kv.veik", "frumstig.et.þgf.hk.veik", "frumstig.ft.þgf.kk.veik", "frumstig.ft.þgf.kv.veik", "frumstig.ft.þgf.hk.veik", "frumstig.et.ef.kk.veik", "frumstig.et.ef.kv.veik", "frumstig.et.ef.hk.veik", "frumstig.ft.ef.kk.veik", "frumstig.ft.ef.kv.veik", "frumstig.ft.ef.hk.veik", "miðstig.et.nf.kk", "miðstig.et.nf.kv", "miðstig.et.nf.hk", "miðstig.ft.nf.kk", "miðstig.ft.nf.kv", "miðstig.ft.nf.hk", "miðstig.et.þf.kk", "miðstig.et.þf.kv", "miðstig.et.þf.hk", "miðstig.ft.þf.kk", "miðstig.ft.þf.kv", "miðstig.ft.þf.hk", "miðstig.et.þgf.kk", "miðstig.et.þgf.kv", "miðstig.et.þgf.hk", "miðstig.ft.þgf.kk", "miðstig.ft.þgf.kv", "miðstig.ft.þgf.hk", "miðstig.et.ef.kk", "miðstig.et.ef.kv", "miðstig.et.ef.hk", "miðstig.ft.ef.kk", "miðstig.ft.ef.kv", "miðstig.ft.ef.hk", "efsta stig.et.nf.kk.sterk", "efsta stig.et.nf.kv.sterk", "efsta stig.et.nf.hk.sterk", "efsta stig.ft.nf.kk.sterk", "efsta stig.ft.nf.kv.sterk", "efsta stig.ft.nf.hk.sterk", "efsta stig.et.þf.kk.sterk", "efsta stig.et.þf.kv.sterk", "efsta stig.et.þf.hk.sterk", "efsta stig.ft.þf.kk.sterk", "efsta stig.ft.þf.kv.sterk", "efsta stig.ft.þf.hk.sterk", "efsta stig.et.þgf.kk.sterk", "efsta stig.et.þgf.kv.sterk", "efsta stig.et.þgf.hk.sterk", "efsta stig.ft.þgf.kk.sterk", "efsta stig.ft.þgf.kv.sterk", "efsta stig.ft.þgf.hk.sterk", "efsta stig.et.ef.kk.sterk", "efsta stig.et.ef.kv.sterk", "efsta stig.et.ef.hk.sterk", "efsta stig.ft.ef.kk.sterk", "efsta stig.ft.ef.kv.sterk", "efsta stig.ft.ef.hk.sterk", "efsta stig.et.nf.kk.veik", "efsta stig.et.nf.kv.veik", "efsta stig.et.nf.hk.veik", "efsta stig.ft.nf.kk.veik", "efsta stig.ft.nf.kv.veik", "efsta stig.ft.nf.hk.veik", "efsta stig.et.þf.kk.veik", "efsta stig.et.þf.kv.veik", "efsta stig.et.þf.hk.veik", "efsta stig.ft.þf.kk.veik", "efsta stig.ft.þf.kv.veik", "efsta stig.ft.þf.hk.veik", "efsta stig.et.þgf.kk.veik", "efsta stig.et.þgf.kv.veik", "efsta stig.et.þgf.hk.veik", "efsta stig.ft.þgf.kk.veik", "efsta stig.ft.þgf.kv.veik", "efsta stig.ft.þgf.hk.veik", "efsta stig.et.ef.kk.veik", "efsta stig.et.ef.kv.veik", "efsta stig.et.ef.hk.veik", "efsta stig.ft.ef.kk.veik", "efsta stig.ft.ef.kv.veik", "efsta stig.ft.ef.hk.veik"]


# contains everything
rules = {}

# First round:
print("Collecting all rules.")
for templates in templatesInPages:
  for template in [t for t in templates if t.name in ["Fallbeyging", "Fallbeyging mannsnafn", "Sagnbeyging 2", "lýsingarorðsbeyging"]]:
    ruleValues = {}
    ruleValues["SFX"] = {}
    ruleValues["OTHER_FORMAT_STRINGS"] = {}

    for p in template.params:
      tag = re.sub(r'^[\s](<!--.*-->)?\n?', '', str(p.name)) # remove <!-- --> comments and newlines from beginning
      if not tag in tagset:
        continue
      displayed = re.sub(r'(<!--.*-->)?\n?', '', str(p.value)) # for comments in "Sagnbeyging 2"
      displayed = displayed.replace("{{{-| }}}", " ") # problems in 3eó, 4eó in Fallbeyging kvk vb örnefni
      for sword in displayed.split(" "):
        if re.search("\{\{\{[0-9]\}\}\}", sword):
          if (not sword.count("{") == sword.count("}")) or "#switch" in sword or "#default" in sword or "#ifeq" in sword or "=" in sword:
            print("Can not parse template for inflection " + tag + " of rule " + template.get("önnur orð").value.strip() + ". Skipping.")
            continue
          tword = re.sub(r"[\[\]/|]", "", sword)
          formatstr = tword.replace("{{{", "{").replace("}}}", "}")
          if not ("LEMMA_FORMAT_STRING" in ruleValues):
            ruleValues["LEMMA_FORMAT_STRING"] = formatstr # "1eó", "1", "germynd:nafnháttur" or "frumstig.et.nf.kk.sterk"
          else:
            if tag not in ruleValues["OTHER_FORMAT_STRINGS"]:
              ruleValues["OTHER_FORMAT_STRINGS"][tag] = [] # support many for rules such as Fallbeyging kvk vb 01 og 01a
            ruleValues["OTHER_FORMAT_STRINGS"][tag].append(formatstr)
            # Fill in the next round.
            ruleValues["SFX"][tag] = []

    if "LEMMA_FORMAT_STRING" in ruleValues:
      rulename = template.get("önnur orð").value.strip()
      rules[rulename] = ruleValues
ruleskeys = sorted(rules.keys())

# Second round:
print("Printing .dic entries. Getting possible suffixes for rules.")
dicfile = open(sys.argv[2], 'w')
for templates in templatesInPages:
  for t in [t for t in templates if str(t.name) in ruleskeys and not t.params[0].startswith("-") and not " " in t.params[0]]:#-gengill, -leysi, -nætti, San Marínó
    ruleValues = rules[str(t.name)]

    unnamedParams = []
    namedParams = {}
    for p in t.params:
      if "=" in p:
        d = p.split("=")
        namedParams[d[0]] = d[1]
      else:
        unnamedParams.append(p)
    lemma = ruleValues["LEMMA_FORMAT_STRING"].format("", *unnamedParams, **namedParams)
    if t.name.startswith("Fallbeyging"):
      po = "no"
    elif t.name.startswith("Lýsingarorðsbeyging"):
      po = "lo"
    elif t.name.startswith("Sagnbeyging"):
      po = "so"
    else:
      print(t.name)
      assert(False) # unknown part of speech category
    dicfile.write(lemma + "/" + str(ruleskeys.index(t.name)+1) + " po:"+po + "\n")
    for tag in [t for t in ruleValues["SFX"] if t in tagset]:
      for formatstr in ruleValues["OTHER_FORMAT_STRINGS"][tag]:
        inflection = formatstr.format("", *unnamedParams, **namedParams)
        common = os.path.commonprefix([lemma, inflection])
        added = inflection[len(common):]
        removed = lemma[len(common):]
        if removed == lemma:
          assert(added == inflection)
          # hunspell does not allow removal of the entire world, sidestep by adding inflection to .dic file
          dicfile.write(inflection + " st:" + lemma + " po:"+po + " is:"+tag + "\n")
        else:
          for sfx in ruleValues["SFX"][tag]:
            #only add to rule if not there yet
            if sfx["removed"] == removed and sfx["added"] == added:
              sfx["matchingWords"].append(lemma)
              break
          else:
            ruleValues["SFX"][tag].append({"removed": removed, "added": added, "matchingWords": [lemma]})

dicfile.close()
print("done")

# Third Round:
print("Finding constraints on SFX entries in the .aff file")
def commonSuffix(list) : return os.path.commonprefix([l[::-1] for l in list])[::-1]

# Post: conditional contains suffixes of all words in matchingWords
#       without any of them being suffixes of conflictingWords as well.
def addConditions(conditional, matchingWords, conflictingWords):
  common = commonSuffix(matchingWords)
  if common == "" or any([c[-len(common):] == common for c in conflictingWords]):
    bucket = {}
    for word in matchingWords:
      suff = word[-(len(common)+1):]
      if suff not in bucket:
        bucket[suff] = []
      bucket[suff].append(word)
    for suff in sorted(bucket.keys()):
      addConditions(conditional, bucket[suff], conflictingWords)
  else:
    while len(common) > 1 and not any([c[-len(common)+1:] == common[1:] for c in conflictingWords]):
      common = common[1:] # shorten as long as it doesn't conflict
    conditional.append(common)

for rule in ruleskeys:
    # find if suffixes conflict with "sibling" suffixes.
    for tag in [t for t in rules[rule]["SFX"] if t in tagset]:
      for sfx in rules[rule]["SFX"][tag]:
        wordsMatchingOtherSuffixes = []
        for othersfx in [a for a in rules[rule]["SFX"][tag] if (not a == sfx)]:
          wordsMatchingOtherSuffixes += othersfx["matchingWords"]
        conflictingWords = [w for w in wordsMatchingOtherSuffixes if w not in sfx["matchingWords"] and (sfx["removed"] == "" or w[-len(sfx["removed"]):] == sfx["removed"])]
        if len(conflictingWords) > 0:
          if not "conditional" in sfx:
            sfx["conditional"] = []
          addConditions(sfx["conditional"], sfx["matchingWords"], conflictingWords)

# Fourth "round":
print("Printing .aff file.")
afffile = open(sys.argv[3], 'w')
count = 1
for rule in ruleskeys:
  afffile.write("# " + rule + "\n")
  total = 0
  for tag in rules[rule]["SFX"]:
    for sfx in rules[rule]["SFX"][tag]:
      if "conditional" in sfx:
        total+=len(sfx["conditional"])
      else:
        total += 1
        sfx["conditional"] = ["."]
  if total:
    afffile.write("SFX " + str(count) + " N " + str(total) + "\n")
    for tag in [t for t in tagset if t in rules[rule]["SFX"]]:
      for sfx in rules[rule]["SFX"][tag]:
        if sfx["removed"] == "":
          sfx["removed"] = "0"
        if sfx["added"] == "":
          sfx["added"] = "0"
        for cond in sfx["conditional"]:
          afffile.write("SFX " + str(count) + " " + sfx["removed"] + " " + sfx["added"] + " " + cond + " is:"+tag + "\n")
  afffile.write("\n")
  count += 1
afffile.close()
print("all done")

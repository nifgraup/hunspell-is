#!/usr/bin/env python3
# Assumption: tabular is only used as a separator for morphological fields
import sys, re

inbasename = sys.argv[1]
outbasename = sys.argv[2]

aliasmap = []

indic = open(inbasename+".dic", "r").read().splitlines()
inaff = open(inbasename+".aff", "r").read().splitlines()
found = False
count = 0
for l in inaff + indic:
  if l[0:3] == "SFX" or l[0:3] == "PFX":
    found = True
  cols = re.split("\t", l)
  if len(cols) == 2 and cols[1] not in aliasmap:
    aliasmap.append(cols[1])
  if not found:
    count += 1

outdic = open(outbasename+".dic", "w")
for l in indic:
  col = re.split("\t", l)
  if len(col) == 2:
    outdic.write(col[0] + "\t" + str(aliasmap.index(col[1])+1) + "\n")
  else:
    outdic.write(l + "\n")

while count > 0 and inaff[count-1][0] == "#":
  count = count - 1

outaff = open(outbasename+".aff", "w")
outaff.write("\n".join(inaff[0:count]) + "\n")
outaff.write("AM " + str(len(aliasmap)) + "\n")
for a in aliasmap:
  outaff.write("AM " + a + "\n")
for l in inaff[count:]:
  col = re.split("\t", l)
  if len(col) == 2:
    outaff.write(col[0] + "\t" + str(aliasmap.index(col[1])+1) + "\n")
  else:
    outaff.write(l + "\n")

#!/usr/bin/python3

import sys

terms = {}

sys.stdout.write(sys.stdin.readline())

for line in sys.stdin:
	terms[line] = line
	splitted = line.split('|')
	for i in range(0, int(splitted[1])):
		l = sys.stdin.readline()
		terms[line] += l

for k in sorted(terms.keys()):
	sys.stdout.write(terms[k])


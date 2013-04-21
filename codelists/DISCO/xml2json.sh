#!/bin/bash

# Usage:
#   ./xml2json.sh {path to DISCO XML file} {path to xml2json.py executable}
#
# Steps:
#   xmllint (http://xmlsoft.org/xmllint.html) for removing whitespace
#   xml2json (https://github.com/hay/xml2json) for converting XML to JSON
#   jq (http://stedolan.github.io/jq/) for pretty-printing JSON
#   Output result to standard output

cat $1 \
  | xmllint --noblanks - \
  > DISCO.noblanks.xml

python $2 -t xml2json DISCO.noblanks.xml \
  | jq .

rm DISCO.noblanks.xml

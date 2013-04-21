#!/bin/bash

# Usage:
#  ./cleanup.sh {path to DISCO XML file}
#
# Steps:
#   Unescape ampersands in entity references, repair misencoded entity references for "ů"
#   xmllint (http://xmlsoft.org/xmllint.html) for cleaning up XML
#   Output result to standard output

cat $1 \
  | sed "s/amp;#/#/g" \
  | sed "s/#x016F;/#x16f;/g" \
  | sed "s/#x016F /#x16f;/g" \
  | xmllint --noent --dropdtd --encode UTF-8 --format -

#!/bin/bash

# Usage:
#  ./xml2rdf.sh {DISCO XML dump}

saxon -xsl:DISCO2RDF.xsl -s:$1 -o:DISCO.rdf
rapper -i rdfxml -o turtle DISCO.rdf > DISCO.ttl
rm DISCO.rdf

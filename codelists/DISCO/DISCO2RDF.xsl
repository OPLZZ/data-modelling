<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    version="2.0">
    
    <!-- TODO:
        Clear terms with DOUBLE in labels:
            DOUBLE TERM 1: prefLabel used twice for different concepts
            DOUBLE TERM 2: prefLabel used twice for different concepts
            DOUBLE PHRASE 2: prefLabel used twice for different concepts
            DOUBLE AS PREF TERM: used both as prefLabel and altLabel
            DOUBLE SYNONYM: used twice as altLabel for different concepts
            DOUBLE AS SYNONYM 2: used twice as prefLabel for the same concept
    -->
    
    <xsl:param name="namespace">http://data.damepraci.cz/resource/</xsl:param>
    <xsl:param name="synonymsCSfile">synonyms.xml</xsl:param>
    
    <xsl:variable name="scheme" select="concat($namespace, 'concept-scheme/', 'DISCO')"/>
    <xsl:variable name="termScheme" select="concat($scheme, '/terms')"/>
    <xsl:variable name="phraseScheme" select="concat($scheme, '/phrases')"/>
    <xsl:variable name="conceptNs" select="concat($namespace, 'DISCO/', 'concept/')"/>
    <xsl:variable name="synonymsCS" select="document($synonymsCSfile)"/>
    <xsl:variable name="metadataNamespace" select="concat($namespace, 'dataset/DISCO')"/>
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="THESAURUS">
        <rdf:RDF>
            <skos:ConceptScheme rdf:about="{$termScheme}">
                <dcterms:title xml:lang="en">DISCO 2: European Dictionary of Skills and Competences, Terms</dcterms:title>
            </skos:ConceptScheme>
            <skos:ConceptScheme rdf:about="{$phraseScheme}">
                <dcterms:title xml:lang="en">DISCO 2: European Dictionary of Skills and Competences, Phrases</dcterms:title>
            </skos:ConceptScheme>
            <xsl:apply-templates select="$synonymsCS/THESAURUS/CONCEPT[DESCRIPTOR]">
                <xsl:with-param name="defaultLang">cs</xsl:with-param>
            </xsl:apply-templates>
            <xsl:apply-templates select="CONCEPT[DESCRIPTOR]">
                <xsl:with-param name="defaultLang">en</xsl:with-param>
            </xsl:apply-templates>
        </rdf:RDF>
        <xsl:call-template name="generateMetadata"/>
    </xsl:template>
    
    <xsl:template match="CONCEPT[DESCRIPTOR]">
        <xsl:param name="defaultLang"/>
        <skos:Concept rdf:about="{concat($conceptNs, TNR)}">
            <xsl:variable name="scheme">
                <xsl:call-template name="getScheme">
                    <xsl:with-param name="label" select="DESCRIPTOR"/>
                </xsl:call-template>    
            </xsl:variable>
            <skos:inScheme rdf:resource="{$scheme}"/>
            <xsl:if test="not(BT)">
                <skos:topConceptOf rdf:resource="{$scheme}"/>
            </xsl:if>
            <xsl:apply-templates>
                <xsl:with-param name="defaultLang" select="$defaultLang"/>
            </xsl:apply-templates>
        </skos:Concept>
    </xsl:template>
    
    <xsl:template match="BT">
        <skos:broader>
            <xsl:call-template name="getLink">
                <xsl:with-param name="label" select="current()"/>
            </xsl:call-template>
        </skos:broader>    
    </xsl:template>
    
    <xsl:template match="CS">
        <skos:prefLabel xml:lang="cs">
            <xsl:call-template name="normalize">
                <xsl:with-param name="text" select="text()"/>
            </xsl:call-template>
        </skos:prefLabel>    
    </xsl:template>
    
    <xsl:template match="DESCRIPTOR">
        <xsl:param name="defaultLang"/>
        <skos:prefLabel xml:lang="{$defaultLang}">
            <xsl:call-template name="normalize">
                <xsl:with-param name="text" select="text()"/>
            </xsl:call-template>
        </skos:prefLabel>    
    </xsl:template>
    
    <xsl:template match="NT">
        <skos:narrower>
            <xsl:call-template name="getLink">
                <xsl:with-param name="label" select="current()"/>
            </xsl:call-template>
        </skos:narrower>    
    </xsl:template>
    
    <xsl:template match="RT">
        <skos:related>
            <xsl:call-template name="getLink">
                <xsl:with-param name="label" select="current()"/>
            </xsl:call-template>
        </skos:related>    
    </xsl:template>
    
    <xsl:template match="SN">
        <skos:scopeNote xml:lang="en"><xsl:apply-templates/></skos:scopeNote>    
    </xsl:template>
    
    <xsl:template match="SPNCS">
        <skos:definition xml:lang="cs"><xsl:apply-templates/></skos:definition>    
    </xsl:template>
    
    <xsl:template match="SPNEN">
        <skos:definition xml:lang="en"><xsl:apply-templates/></skos:definition>    
    </xsl:template>
    
    <xsl:template match="T2P">
        <skos:related>
            <xsl:call-template name="getLink">
                <xsl:with-param name="label" select="current()"/>
            </xsl:call-template> 
        </skos:related>    
    </xsl:template>
    
    <xsl:template match="TNR">
        <skos:notation><xsl:apply-templates/></skos:notation>
    </xsl:template>
    
    <xsl:template match="UF">
        <xsl:param name="defaultLang"/>
        <skos:altLabel xml:lang="{$defaultLang}">
            <xsl:call-template name="normalize">
                <xsl:with-param name="text" select="text()"/>
            </xsl:call-template>
        </skos:altLabel>    
    </xsl:template>
    
    <!-- Processing templates -->
    
    <xsl:template name="normalize">
        <xsl:param name="text"/>
        <xsl:variable name="normalized" select="normalize-space(replace(replace(replace($text, '^_+',''), '^PHRASES\s+', ''), '\s\(DOUBLE.*', ''))"/>
        <xsl:choose>
            <xsl:when test="$normalized"><xsl:value-of select="$normalized"/></xsl:when>
            <xsl:otherwise>Phrases</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="getScheme">
        <xsl:param name="label"/>
        <xsl:choose>
            <xsl:when test="starts-with($label, '__')">
                <xsl:value-of select="$phraseScheme"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$termScheme"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="getLink">
        <xsl:param name="label"/>
        <xsl:attribute namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#" name="resource">
            <xsl:value-of select="concat($conceptNs, /THESAURUS/CONCEPT[DESCRIPTOR = $label]/TNR)"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Metadata -->
    
    <xsl:template name="generateMetadata">
        <xsl:result-document href="metadata.xml">
            <rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:void="http://rdfs.org/ns/void#">
                <void:Dataset rdf:about="{$metadataNamespace}">
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#Entity"/>
                    <dcterms:source rdf:resource="http://disco-tools.eu/disco2_portal/"/>
                    <dcterms:title xml:lang="en">DISCO 2: European Dictionary of Skills and Competences</dcterms:title>
                    <dcterms:description xml:lang="en">DISCO 2: European Dictionary of Skills and Competences converted to RDF</dcterms:description>
                    <dcterms:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                        <xsl:value-of select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                    </dcterms:modified>
                    <dcterms:publisher rdf:resource="http://damepraci.cz"/>
                    <dcterms:license rdf:resource="http://opendatacommons.org/licenses/by/"/>
                    <void:rootResource rdf:resource="{$termScheme}"/>
                    <void:rootResource rdf:resource="{$phraseScheme}"/>
                    <void:exampleResource rdf:resource="{concat($conceptNs, '1037869')}"/>
                </void:Dataset>
            </rdf:RDF>
        </xsl:result-document>    
    </xsl:template>
    
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../xslmod/ci-schematron-functions.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <RESULT>
      <xsl:apply-templates select="doc('test-specification.xml')/*/ci:categories/ci:category"/>
    </RESULT>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:category">
    <xsl:message>{@id}</xsl:message>
    
    
    
    <CATEGORY id="{@id}" xxx="{../ancestor::ci:category/@mandatory-property-idrefs}">
      <xsl:value-of select="local:identifiers-used-more-than-once((
        ancestor-or-self::ci:category/@mandatory-property-idrefs, ancestor-or-self::ci:category/@optional-property-idrefs))"/>
    </CATEGORY>
    <xsl:apply-templates select="ci:categories/ci:category"></xsl:apply-templates>

  </xsl:template>


</xsl:stylesheet>

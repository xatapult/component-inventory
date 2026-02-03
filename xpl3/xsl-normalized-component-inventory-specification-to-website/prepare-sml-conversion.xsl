<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ds2_tbz_yhc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all"
  expand-text="true" xmlns="https://eriksiegel.nl/ns/component-inventory">
  <!-- ================================================================== -->
  <!-- 
       Prepares the SML conversion. 
       Takes all media SML document references, turns them into html references and adds a 
       <CONVERTSML href-source="..."' href-target="..." element to trigger the conversion.
       This element is removed after processing later on in the pipeline.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>
  
  <!-- ======================================================================= -->
  
  <xsl:param name="href-build-location" as="xs:string" required="true"/>
  
  <!-- ======================================================================= -->

  <xsl:template match="ci:media/ci:sml">

    <!-- Turn this into an html document. Add a _no-copy attribute to prevent copying this non-existing media document. -->
    <xsl:variable name="href-sml-source" as="xs:string" select="xs:string(@href)"/>
    <xsl:variable name="filename-html-source" as="xs:string" select="xtlc:href-name-noext($href-sml-source) || '.html'"/>
    <xsl:variable name="href-html-source" as="xs:string" select="xtlc:href-concat((xtlc:href-path($href-sml-source), $filename-html-source))"/>
    <html _no-copy="true">
      <xsl:attribute name="href" select="$href-html-source"/>
      <xsl:sequence select="@* except @href"/>
    </html>
    
    <!-- Create the temporary element that triggers the SML conversion: -->
    <xsl:variable name="item-type-plural" as="xs:string" select="xs:string(local-name(../../..))"/>
    <xsl:variable name="item-id" as="xs:string" select="xs:string(../../@id)"/>
    <xsl:variable name="href-html-target" as="xs:string" select="xtlc:href-concat(($href-build-location, $item-type-plural, $item-id, $filename-html-source))"/>
    <CONVERTSML href-source="{$href-sml-source}" href-target="{$href-html-target}"/>
    
  </xsl:template>
  
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ds2_tbz_yhc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all"
  expand-text="true" xmlns="https://eriksiegel.nl/ns/component-inventory">
  <!-- ================================================================== -->
  <!-- 
       Prepares the resource directory copies by adding a target URI.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>
  
  <!-- ======================================================================= -->
  
  <xsl:param name="href-build-location" as="xs:string" required="true"/>
  
  <!-- ======================================================================= -->

  <xsl:template match="ci:media/ci:resource-directory">

    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*"/>
      
      <xsl:variable name="href-resource-directory-source" as="xs:string" select="xs:string(@href)"/>
      <xsl:variable name="resource-directory-name" as="xs:string" select="xtlc:href-name-noext($href-resource-directory-source)"/>
      <xsl:variable name="item-type-plural" as="xs:string" select="xs:string(local-name(../../..))"/>
      <xsl:variable name="item-id" as="xs:string" select="xs:string(../../@id)"/>
      <xsl:variable name="href-resource-directory-target" as="xs:string" select="xtlc:href-concat(($href-build-location, $item-type-plural, $item-id, $resource-directory-name))"/>
      <xsl:attribute name="_href-target" select="$href-resource-directory-target"/>
      
      <xsl:apply-templates/>
    </xsl:copy>
    
  </xsl:template>
  
</xsl:stylesheet>

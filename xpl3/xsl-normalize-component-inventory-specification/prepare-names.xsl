<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.uym_lty_whc"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns="https://eriksiegel.nl/ns/component-inventory"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Makes all URIs (in href attributes) absolute according to the appropriate rules.
       For media: also adds a default usage type if nothing was specified.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/ci-normalization.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="(ci:property | ci:category | ci:price-range | ci:package | ci:location)[exists(@id)]">
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="normalize-space(@name) eq ''">
        <xsl:attribute name="name" select="$id"/>
      </xsl:if>
      <xsl:if test="normalize-space(@summary) eq ''">
        <xsl:attribute name="summary" select="ci:default-summary(.)"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>

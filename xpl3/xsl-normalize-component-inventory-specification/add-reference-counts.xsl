<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.hmp_vtr_whc"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:ci="https://eriksiegel.nl/ns/component-inventory"
  xmlns="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Adds reference counts to all items (categories, packages, etc.). Also adds a warning if one of these is unreferenced.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/ci-common.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="components" as="element(ci:component)*" select="/*/ci:components/ci:component"/>

  <!-- ======================================================================= -->

  <xsl:template match="ci:properties/ci:property">
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:call-template name="handle-reference-count">
      <xsl:with-param name="reference-count" select="count($components[exists(ci:property-values/ci:property-value[@property-idref eq $id])])"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="ci:categories/ci:category">
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:call-template name="handle-reference-count">
      <xsl:with-param name="reference-count" select="count($components[$id = xtlc:str2seq(@category-idrefs)])"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="ci:price-ranges/ci:price-range">
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:call-template name="handle-reference-count">
      <xsl:with-param name="reference-count" select="count($components[@price-range-idref eq $id])"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="ci:packages/ci:package">
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:call-template name="handle-reference-count">
      <xsl:with-param name="reference-count" select="count($components[@package-idref eq $id])"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  <xsl:template match="ci:locations/ci:location">
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:call-template name="handle-reference-count">
      <xsl:with-param name="reference-count" select="count($components[@location-idref eq $id])"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- ======================================================================= -->

  <xsl:template name="handle-reference-count">
    <xsl:param name="elm" as="element()" required="false" select="."/>
    <xsl:param name="id" as="xs:string" required="false" select="xs:string($elm/@id)"/>
    <xsl:param name="reference-count" as="xs:integer" required="true"/>

    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="reference-count" select="$reference-count"/>
      <xsl:apply-templates/>
      <xsl:if test="$reference-count le 0">
        <warning>{xtlc:capitalize(local-name($elm))} "{$id}" not referenced</warning>
      </xsl:if>
    </xsl:copy>

  </xsl:template>



</xsl:stylesheet>

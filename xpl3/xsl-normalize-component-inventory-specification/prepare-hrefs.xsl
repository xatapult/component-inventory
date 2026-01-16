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

  <xsl:template match="/ci:component-inventory-specification">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()">
        <xsl:with-param name="href-base-directory" as="xs:string" select="xtlc:href-path(@xml:base)" tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:packages | ci:components | ci:media">
    <!-- These elements have an @href-default-base-directory. -->
    <xsl:param name="href-base-directory" as="xs:string" required="true" tunnel="true"/>

    <xsl:copy>
      <xsl:apply-templates select="@* except @href-default-base-directory"/>
      <xsl:variable name="href-default-base-directory" as="xs:string"
        select="xtlc:href-concat(($href-base-directory, @href-default-base-directory)) => xtlc:href-canonical()"/>
      <xsl:attribute name="href-default-base-directory" select="$href-default-base-directory"/>
      <xsl:apply-templates>
        <xsl:with-param name="href-base-directory" as="xs:string" select="$href-default-base-directory" tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="(ci:media/ci:* | ci:components/ci:directory)[exists(@href)]">
    <!-- These elements have an @href. -->
    <xsl:param name="href-base-directory" as="xs:string" required="true" tunnel="true"/>

    <xsl:copy>
      <xsl:apply-templates select="@* except @href"/>
      <xsl:variable name="href" as="xs:string" select="xtlc:href-concat(($href-base-directory, @href)) => xtlc:href-canonical()"/>
      <xsl:attribute name="href" select="$href"/>

      <!-- For media, also add the usage type if not specified: -->
      <xsl:if test="exists(../self::ci:media)">
        <xsl:if test="normalize-space(@usage) eq ''">
          <xsl:attribute name="usage" select="ci:defaul-media-usage-type(local-name(.))"/>
        </xsl:if>
      </xsl:if>

      <!-- There are currently no children, but just to be sure: -->
      <xsl:apply-templates/>

    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

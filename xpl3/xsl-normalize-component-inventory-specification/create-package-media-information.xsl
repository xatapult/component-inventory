<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.hmp_vtr_whc"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:sml="http://www.eriksiegel.nl/ns/sml"
  xmlns="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Creates the package media information, based on the contents of the package media directory.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/ci-normalization.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="href-package-base-directory" as="xs:string" select="xs:string(/*/ci:packages/@href-default-base-directory)"/>
  <xsl:variable name="package-media-filenames" as="xs:string*" select="/*/ci:packages/c:directory/c:file/@name/string()"/>

  <!-- ======================================================================= -->

  <xsl:template match="ci:packages/c:directory">
    <!-- We don't need this any longer. -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:packages/ci:package[empty(ci:media)]">
    <!-- Try to add media information to a package that has no explicit media information already. -->

    <xsl:variable name="package-id" as="xs:string" select="xs:string(@id)"/>

    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>

      <xsl:variable name="applicable-media-filenames" as="xs:string*" select="$package-media-filenames[xtlc:href-name-noext(.) eq $package-id]"/>
      <xsl:if test="exists($applicable-media-filenames)">
        <media _generated="true" href-default-base-directory="{$href-package-base-directory}">
          <xsl:for-each select="$applicable-media-filenames">
            <xsl:call-template name="ci:handle-media-file">
              <xsl:with-param name="href-directory" select="$href-package-base-directory"/>
              <xsl:with-param name="filename" select="."/>
            </xsl:call-template>
          </xsl:for-each>
        </media>
      </xsl:if>

    </xsl:copy>

  </xsl:template>

</xsl:stylesheet>

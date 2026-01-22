<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rhy_3nr_whc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Module with common declarations for the component-inventory.
  -->
  <!-- ================================================================== -->

  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- VARIOUS: -->

  <xsl:variable name="ci:category-separator" as="xs:string" select="'.'">
    <!-- The character to use if we concatenate categories and sub-categories. -->
  </xsl:variable>

  <xsl:variable name="ci:default-component-description-document-regexp" as="xs:string" select="'^component-.+\.xml$'"/>

  <xsl:variable name="ci:special-value-unknown" as="xs:string" select="'#unknown'"/>
  <xsl:variable name="ci:special-value-many" as="xs:string" select="'#many'"/>
  <xsl:variable name="ci:special-value-many-limit" as="xs:integer" select="25"/>

  <!-- ======================================================================= -->
  <!-- MEDIA RELATED: -->

  <!-- The following media-types *must* be the same as the names of the possible child elements of <media>! -->
  <xsl:variable name="ci:media-type-image" as="xs:string" select="'image'"/>
  <xsl:variable name="ci:media-type-pdf" as="xs:string" select="'pdf'"/>
  <xsl:variable name="ci:media-type-text" as="xs:string" select="'text'"/>
  <xsl:variable name="ci:media-type-markdown" as="xs:string" select="'markdown'"/>
  <xsl:variable name="ci:media-type-sml" as="xs:string" select="'sml'"/>
  <xsl:variable name="ci:media-type-html" as="xs:string" select="'html'"/>

  <!-- The following media-usage-types must be the same as defined in the schema for the any-media-element/@usage attribute! -->
  <xsl:variable name="ci:media-usage-type-overview" as="xs:string" select="'overview'"/>
  <xsl:variable name="ci:media-usage-type-connections-overview" as="xs:string" select="'connections-overview'"/>
  <xsl:variable name="ci:media-usage-type-usage-example" as="xs:string" select="'usage-example'"/>
  <xsl:variable name="ci:media-usage-type-instruction" as="xs:string" select="'instruction'"/>
  <xsl:variable name="ci:media-usage-type-datasheet" as="xs:string" select="'datasheet'"/>
  
  <!-- ======================================================================= -->
  
</xsl:stylesheet>

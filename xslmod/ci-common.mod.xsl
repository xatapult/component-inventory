<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rhy_3nr_whc"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all"
  expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Module with common declarations and functionality for the component inventory.
  -->
  <!-- ================================================================== -->

  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- VARIOUS: -->

  <xsl:variable name="ci:category-separator" as="xs:string" select="'.'"/>

  <xsl:variable name="ci:default-component-description-document-regexp" as="xs:string" select="'^component-.+\.xml$'"/>

  <xsl:variable name="ci:special-value-unknown" as="xs:string" select="'#unknown'"/>

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
  <xsl:variable name="ci:media-usage-type-instructions" as="xs:string" select="'instructions'"/>
  <xsl:variable name="ci:media-usage-type-datasheet" as="xs:string" select="'datasheet'"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="ci:defaul-media-usage-type" as="xs:string">
    <!-- Determines the default usage type for a specific type of media. -->
    <xsl:param name="media-type" as="xs:string">
      <!-- One of the $ci:media-type-* constants defined above. -->
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$media-type eq $ci:media-type-image">
        <xsl:sequence select="$ci:media-usage-type-overview"/>
      </xsl:when>
      <xsl:when test="$media-type eq $ci:media-type-pdf">
        <xsl:sequence select="$ci:media-usage-type-datasheet"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$ci:media-usage-type-instructions"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ======================================================================= -->

  <xsl:function name="ci:default-summary" as="xs:string">
    <!-- Computes the default summary string for an element (for instance for a category or package). -->
    <xsl:param name="elm" as="element()"/>

    <xsl:sequence select="ci:default-summary($elm, ())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="ci:default-summary" as="xs:string">
    <!-- Computes the default summary string for an element (for instance for a category or package). -->
    <xsl:param name="elm" as="element()"/>
    <xsl:param name="default-id" as="xs:string?"/>

    <xsl:sequence select="string-join((xtlc:capitalize(local-name($elm)), xs:string(($elm/@name, $elm/@id, $default-id)[1])), ' ')"/>
  </xsl:function>

</xsl:stylesheet>

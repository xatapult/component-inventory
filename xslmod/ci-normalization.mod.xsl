<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rhy_3nr_whc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Module with common declarations and functionality for the normalization
       of a component-inventory specification.
  -->
  <!-- ================================================================== -->

  <xsl:include href="ci-common.mod.xsl"/>
  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ======================================================================= -->

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

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="ci:handle-media-file" xmlns="https://eriksiegel.nl/ns/component-inventory">
    <!-- Creates a media child element with the right type/element-name for the  given file. -->
    <xsl:param name="href-directory" as="xs:string" required="true"/>
    <xsl:param name="filename" as="xs:string" required="true"/>

    <!-- Determine the most likely media type. The type will be used as the element name! -->
    <xsl:variable name="extension" as="xs:string" select="xtlc:href-ext($filename) => lower-case()"/>
    <xsl:variable name="media-type" as="xs:string*">
      <xsl:choose>
        <xsl:when test="$extension = ('jpg', 'jpeg', 'png', 'svg')">
          <xsl:sequence select="$ci:media-type-image"/>
        </xsl:when>
        <xsl:when test="$extension = ('pdf')">
          <xsl:sequence select="$ci:media-type-pdf"/>
        </xsl:when>
        <xsl:when test="$extension = ('txt', 'text')">
          <xsl:sequence select="$ci:media-type-text"/>
        </xsl:when>
        <xsl:when test="$extension = ('md')">
          <xsl:sequence select="$ci:media-type-markdown"/>
        </xsl:when>
        <xsl:when test="$extension = ('xml')">
          <!-- For an XML file we have to find out if it has recognizable contents: -->
          <xsl:variable name="href-media-document" as="xs:string" select="xtlc:href-concat(($href-directory, $filename))"/>
          <xsl:try>
            <xsl:variable name="root-element" as="element()" select="doc($href-media-document)/*"/>
            <xsl:choose>
              <xsl:when test="exists($root-element/self::sml:sml)">
                <xsl:sequence select="$ci:media-type-sml"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- We cannot handle this XML document: -->
                <xsl:sequence select="()"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:catch>
              <!-- Some error, probably not well-formed. -->
              <xsl:sequence select="()"/>
            </xsl:catch>
          </xsl:try>
        </xsl:when>
        <xsl:when test="$extension = ('htm', 'html')">
          <xsl:sequence select="$ci:media-type-html"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="exists($media-type)">
        <xsl:element name="{$media-type}">
          <xsl:attribute name="href" select="xtlc:href-concat(($href-directory, $filename))"/>
          <xsl:attribute name="usage" select="ci:defaul-media-usage-type($media-type)"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <warning>Could not determine media-type for file "{$filename}"</warning>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>

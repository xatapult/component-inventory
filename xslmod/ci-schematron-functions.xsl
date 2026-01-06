<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all">
  <!-- ================================================================== -->
  <!--	
       Helper functions for the Schematron rules (therefore using XSLT v2).
	-->
  <!-- ================================================================== -->

  <xsl:function name="local:in-price-range" as="xs:boolean">
    <xsl:param name="price" as="xs:decimal"/>
    <xsl:param name="price-range" as="element(ci:price-range)"/>

    <xsl:sequence select="($price ge xs:decimal($price-range/@min-inclusive)) and ($price le xs:decimal($price-range/@max-inclusive))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:price-ranges-overlap" as="xs:boolean">
    <xsl:param name="price-range-1" as="element(ci:price-range)"/>
    <xsl:param name="price-range-2" as="element(ci:price-range)"/>

    <xsl:variable name="min-inclusive-1" as="xs:decimal" select="xs:decimal($price-range-1/@min-inclusive)"/>
    <xsl:variable name="max-inclusive-1" as="xs:decimal" select="xs:decimal($price-range-1/@max-inclusive)"/>
    <xsl:variable name="min-inclusive-2" as="xs:decimal" select="xs:decimal($price-range-2/@min-inclusive)"/>
    <xsl:variable name="max-inclusive-2" as="xs:decimal" select="xs:decimal($price-range-2/@max-inclusive)"/>

    <xsl:choose>
      <xsl:when test="$max-inclusive-2 lt $min-inclusive-1">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="$min-inclusive-2 gt $max-inclusive-1">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="true()"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:identifiers-used-more-than-once" as="xs:string*">
    <xsl:param name="identifier-strings" as="xs:string*"/>

    <xsl:variable name="identifier-sequence" as="xs:string*" select="for $is in $identifier-strings return (tokenize($is, '\s+')[.])"/>
    <xsl:variable name="identifiers-used-more-than-once" as="xs:string*">
      <xsl:for-each select="$identifier-sequence">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="count($identifier-sequence[. eq $id]) gt 1">
          <xsl:sequence select="$id"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="distinct-values($identifiers-used-more-than-once)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:identifiers-not-present" as="xs:string*">
    <xsl:param name="identifier-strings" as="xs:string*"/>
    <xsl:param name="identifiers-defined" as="xs:string*"/>

    <xsl:variable name="identifier-sequence" as="xs:string*" select="for $is in $identifier-strings return (tokenize($is, '\s+')[.])"/>
    <xsl:variable name="identifiers-not-present" as="xs:string*">
      <xsl:for-each select="$identifier-sequence">
        <xsl:variable name="id" as="xs:string" select="."/>
        <xsl:if test="not($id = $identifiers-defined)">
          <xsl:sequence select="$id"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="distinct-values($identifiers-not-present)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:quoted-string-list" as="xs:string?">
    <xsl:param name="strings" as="xs:string*"/>

    <xsl:if test="exists($strings)">
      <xsl:sequence select="'&quot;' || string-join($strings, '&quot;, &quot;') || '&quot;'"/>
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>

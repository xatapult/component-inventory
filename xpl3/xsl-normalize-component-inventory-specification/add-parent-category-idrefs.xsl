<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.hmp_vtr_whc"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:sml="http://www.eriksiegel.nl/ns/sml"
  xmlns="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Checks whether the @categories-idrefs attribute of a component contains a
       composed reference. If so, it check whether the parent categories of this composed reference exist
       and adds these also.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/ci-common.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="categories" as="element(ci:category)*" select="/ci:component-inventory-specification/ci:categories/ci:category"/>

  <!-- ======================================================================= -->

  <xsl:template match="ci:component/@category-idrefs">
    
    <xsl:variable name="new-category-idrefs" as="xs:string*">
      <xsl:for-each select="xtlc:str2seq(xs:string(.))">
        <xsl:variable name="idref" as="xs:string" select="."/>
        <xsl:sequence select="$idref"/>
        <xsl:choose>
          <xsl:when test="$idref eq $ci:special-value-unknown">
            <!-- Unknown, just copy only. -->
          </xsl:when>
          <xsl:when test="not(contains($idref, $ci:category-separator))">
            <!-- Not composed, just copy only. -->
          </xsl:when>
          <xsl:otherwise> 
            <!-- Composed, check whether all parent categories exist. If so, add them: -->
            <xsl:variable name="idref-parts" as="xs:string+" select="tokenize($idref, xtlc:str2regexp($ci:category-separator))"/>
            <xsl:for-each select="1 to (count($idref-parts) - 1)">
              <xsl:variable name="parent-level" as="xs:integer" select="."/>
              <xsl:variable name="parent-idref" as="xs:string" select="string-join(subsequence($idref-parts, 1, $parent-level), $ci:category-separator)"/>
              <xsl:if test="exists($categories[xs:string(@id) eq $parent-idref])">
                <xsl:sequence select="$parent-idref"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    
    <!-- Done, re-add the possibly changed attribute: -->
    <xsl:attribute name="{node-name(.)}" select="distinct-values($new-category-idrefs)"/>

  </xsl:template>

</xsl:stylesheet>

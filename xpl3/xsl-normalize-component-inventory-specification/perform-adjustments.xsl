<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.j2z_scq_c3c"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Performs the ad-hoc adjustments (used parts)
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:include href="../../xslmod/ci-common.mod.xsl"/>

  <!-- ================================================================== -->
  
  <xsl:param name="href-adjustments" as="xs:string" required="true"/>
  
  <xsl:variable name="adjustments-document" as="document-node()" select="doc($href-adjustments)"/>
  <xsl:variable name="ids-to-adjust" as="xs:string*" select="distinct-values($adjustments-document/*/ci:adjustment/@component-idref/string())"/>
  
  <!-- ======================================================================= -->
  
  <xsl:template match="/*/ci:components/ci:component[string(@id) = $ids-to-adjust]">
    
    <xsl:variable name="component-id" as="xs:string" select="string(@id)"/>
    <xsl:variable name="adjustments" as="element(ci:adjustment)+" select="$adjustments-document/*/ci:adjustment[string(@component-idref) eq $component-id]"/>
    <xsl:variable name="original-count" as="xs:string" select="string(@count)"/>      
    
    <xsl:copy>
      <xsl:copy-of select="@* except @count"/>
      
      <!-- Find out the new count: -->
      <xsl:choose>
        
        <xsl:when test="$original-count eq $ci:special-value-unknown">
          <!-- Original count is unknown, nothing we can do... -->
          <xsl:copy-of select="@count"/>
          <warning>Adjustment of {$ci:special-value-unknown} count</warning>
        </xsl:when>
        
        <xsl:when test="$original-count eq $ci:special-value-many">
          <!-- Original count is many. That's difficult to adjust... -->
          <xsl:copy-of select="@count"/>
          <warning>Adjustment of {$ci:special-value-many} count. Are there still more than approximately {$ci:special-value-many-limit}?</warning>
        </xsl:when>
        
        <xsl:otherwise>
          <!-- There was a "real" count. Adjust it: -->
          <xsl:variable name="original-count-nr" as="xs:integer" select="xs:integer($original-count)"/>
          <xsl:variable name="total-adjustments" as="xs:integer" select="sum(for $a in $adjustments return xs:integer($a/@used))"/>
          <xsl:choose>
            <xsl:when test="$total-adjustments gt $original-count-nr">
              <xsl:attribute name="count" select="0"/>
              <warning>Adjustments count ({$total-adjustments}) bigger than the original count ({$original-count-nr}). Count set to 0.</warning>
            </xsl:when>
            <xsl:when test="$total-adjustments eq $original-count-nr">
              <xsl:attribute name="count" select="0"/>
              <warning>Adjustments count ({$total-adjustments}) equal to original count. Out of stock?</warning>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="count" select="$original-count-nr - $total-adjustments"/>
            </xsl:otherwise>  
          </xsl:choose>
        </xsl:otherwise>  
        
      </xsl:choose>
      
      <!-- Create an overview of the adjustments: -->
      <adjustments original-count="{$original-count}">
        <xsl:copy-of select="$adjustments"/>
      </adjustments>
      
      <!-- And don't forget the rest: -->
      <xsl:apply-templates/>
      
    </xsl:copy>
    
  </xsl:template>

</xsl:stylesheet>

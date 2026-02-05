<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.kbv_slr_whc"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns="https://eriksiegel.nl/ns/component-inventory"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Flattens the category list.
       Sub-categories are appended to their parent category using a dot (.) as separator. 
       Whether a parent category exists on its own depends on whether its sub-categories 
       are mandatory.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-process-categories" on-no-match="fail"/>

  <xsl:include href="../../xslmod/ci-common.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="/ci:component-inventory-specification/ci:categories">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="ci:category" mode="mode-process-categories">
        <xsl:with-param name="parent-category-ids" as="xs:string*" select="()" tunnel="true"/>
        <xsl:with-param name="parent-mandatory-property-idrefs" as="xs:string*" select="()" tunnel="true"/>
        <xsl:with-param name="parent-optional-property-idrefs" as="xs:string*" select="()" tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:category" mode="mode-process-categories">
    <xsl:param name="parent-category-ids" as="xs:string*" required="true" tunnel="true"/>
    <xsl:param name="parent-mandatory-property-idrefs" as="xs:string*" required="true" tunnel="true"/>
    <xsl:param name="parent-optional-property-idrefs" as="xs:string*" required="true" tunnel="true"/>

    <xsl:variable name="base-id" as="xs:string" select="xs:string(@id)"/>
    <xsl:variable name="id" as="xs:string" select="string-join(($parent-category-ids, $base-id), $ci:category-separator)"/>
    <xsl:variable name="mandatory-property-idrefs" as="xs:string*"
      select="distinct-values(($parent-mandatory-property-idrefs, xtlc:str2seq(@mandatory-property-idrefs)))"/>
    <xsl:variable name="optional-property-idrefs" as="xs:string*"
      select="distinct-values(($parent-optional-property-idrefs, xtlc:str2seq(@optional-property-idrefs)))"/>

    <xsl:choose>
      <xsl:when test="exists(ci:categories) and xtlc:str2bln(ci:categories/@sub-category-mandatory, false())">
        <!-- This category has mandatory sub-categories. This means the current category does not exist on its own, 
          only together with its sub-categories. Therefore, we just have to descend... -->
      </xsl:when>
      <xsl:otherwise>
        <!-- This category exists on its own (but might still have sub-categories, so we still have to descend): -->
        <category>
          <xsl:attribute name="id" select="$id"/>
          <xsl:attribute name="mandatory-property-idrefs" select="$mandatory-property-idrefs"/>
          <xsl:attribute name="optional-property-idrefs" select="$optional-property-idrefs"/>
          <!-- We do nothing with the other attributes of the parent categories, only keep these for the current one: -->
          <xsl:copy-of select="@* except (@id, @mandatory-property-idrefs, @optional-property-idrefs)"/>
          <xsl:copy-of select="ci:description"/>
        </category>
      </xsl:otherwise>
    </xsl:choose>

    <!-- Now descend into the optional sub-categories: -->
    <xsl:apply-templates select="ci:categories/ci:category" mode="#current">
      <xsl:with-param name="parent-category-ids" as="xs:string*" select="($parent-category-ids, $base-id)" tunnel="true"/>
      <xsl:with-param name="parent-mandatory-property-idrefs" as="xs:string*" select="$mandatory-property-idrefs" tunnel="true"/>
      <xsl:with-param name="parent-optional-property-idrefs" as="xs:string*" select="$optional-property-idrefs" tunnel="true"/>
    </xsl:apply-templates>

  </xsl:template>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.hmp_vtr_whc"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:ci="https://eriksiegel.nl/ns/component-inventory"
  xmlns="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Checks all the component descriptions (identifiers, references, etc.).
       Adds warnings and/or errors to the document.
       
       Remark: We could have skipped the generated properties (have an _generated="true" attribute) under the assumption
       these are valid always. I still check these, to check the generation code.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/ci-common.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:variable name="doc" as="document-node()" select="/"/>

  <xsl:variable name="component-ids" as="xs:string*" select="/*/ci:components/ci:component/@id/string()"/>

  <!-- ======================================================================= -->

  <xsl:template match="ci:component">

    <xsl:variable name="component-id" as="xs:string" select="xs:string(@id)"/>

    <xsl:copy>

      <!-- Find out which properties are mandatory/optional, so we can pass this down: -->
      <xsl:variable name="category-idrefs" as="xs:string*" select="xtlc:str2seq(@category-idrefs)[. ne $ci:special-value-unknown]"/>
      <xsl:variable name="mandatory-property-idrefs" as="xs:string*"
        select="distinct-values(for $c in $category-idrefs return xtlc:str2seq(/*/ci:categories/ci:category[@id eq $c]/@mandatory-property-idrefs))"/>
      <xsl:variable name="optional-property-idrefs" as="xs:string*"
        select="distinct-values(for $c in $category-idrefs return xtlc:str2seq(/*/ci:categories/ci:category[@id eq $c]/@optional-property-idrefs))"/>

      <!-- Check the contents of the component: -->
      <xsl:apply-templates select="@* | node()">
        <xsl:with-param name="mandatory-property-idrefs" as="xs:string*" select="$mandatory-property-idrefs" tunnel="true"/>
        <xsl:with-param name="optional-property-idrefs" as="xs:string*" select="$optional-property-idrefs" tunnel="true"/>
      </xsl:apply-templates>

      <!-- Check ID uniqueness -->
      <xsl:variable name="component-id-count" as="xs:integer" select="count($component-ids[. eq $component-id])"/>
      <xsl:if test="$component-id-count gt 1">
        <error>Component id "{$component-id}" not unique (occurs {$component-id-count} times)</error>
      </xsl:if>

      <!-- Check the categories: -->
      <xsl:for-each select="$category-idrefs">
        <xsl:variable name="category-idref" as="xs:string" select="xs:string(.)"/>
        <xsl:if test="empty($doc/*/ci:categories/ci:category[@id eq $category-idref])">
          <error>Component id "{$component-id}" refers to non-existing category "{$category-idref}"</error>
        </xsl:if>
      </xsl:for-each>

      <!-- Price range: -->
      <xsl:variable name="idref" as="xs:string" select="xs:string((@price-range-idref, $ci:special-value-unknown)[1])"/>
      <xsl:if test="($idref ne $ci:special-value-unknown) and empty($doc/*/ci:price-ranges/ci:price-range[@id eq $idref])">
        <error>Component id "{$component-id}" refers to non-existing price-range "{$idref}"</error>
      </xsl:if>

      <!-- Location: -->
      <xsl:variable name="idref" as="xs:string" select="xs:string((@location-idref, $ci:special-value-unknown)[1])"/>
      <xsl:if test="($idref ne $ci:special-value-unknown) and empty($doc/*/ci:locations/ci:location[@id eq $idref])">
        <error>Component id "{$component-id}" refers to non-existing location "{$idref}"</error>
      </xsl:if>

      <!-- Package: -->
      <xsl:variable name="idref" as="xs:string" select="xs:string((@package-idref, $ci:special-value-unknown)[1])"/>
      <xsl:if test="($idref ne $ci:special-value-unknown) and empty($doc/*/ci:packages/ci:package[@id eq $idref])">
        <error>Component id "{$component-id}" refers to non-existing package "{$idref}"</error>
      </xsl:if>

    </xsl:copy>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:property-values">
    <xsl:param name="mandatory-property-idrefs" as="xs:string*" required="true" tunnel="true"/>

    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@* | node()"/>

      <!-- Check whether all mandatory properties are present: -->
      <xsl:variable name="mandatory-property-ids-not-found" as="xs:string*"
        select="for $p in $mandatory-property-idrefs return (if (exists(ci:property-value[xs:string(@property-idref) eq $p])) then () else $p)"/>

      <xsl:if test="exists($mandatory-property-ids-not-found)">
        <error>Undefined mandatory properties {local:quoted-string-list($mandatory-property-ids-not-found)}</error>
      </xsl:if>

    </xsl:copy>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:property-value">
    <xsl:param name="mandatory-property-idrefs" as="xs:string*" required="true" tunnel="true"/>
    <xsl:param name="optional-property-idrefs" as="xs:string*" required="true" tunnel="true"/>

    <xsl:variable name="property-idref" as="xs:string" select="xs:string(@property-idref)"/>
    <xsl:variable name="property-elm" as="element(ci:property)?"
      select="/ci:component-inventory-specification/ci:properties/ci:property[xs:string(@id) eq $property-idref]"/>

    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@* | node()"/>

      <xsl:choose>

        <xsl:when test="exists($property-elm)">

          <!-- Check whether this property is allowed at all: -->
          <xsl:if test="not(($property-idref = $mandatory-property-idrefs) or ($property-idref = $optional-property-idrefs))">
            <error>Property id "{$property-idref}" not allowed (given the component categories)</error>
          </xsl:if>

          <!-- Check whether this property is unique: -->
          <xsl:variable name="property-count" as="xs:integer" select="count(../ci:property-value[xs:string(@property-idref) eq $property-idref])"/>
          <xsl:if test="$property-count gt 1">
            <error>Property id "{$property-idref}" not unique (occurs {$property-count} times)</error>
          </xsl:if>

          <!-- Check whether the value of this property is ok: -->
          <xsl:variable name="property-value" as="xs:string" select="xs:string(@value)"/>
          <xsl:if test="$property-value ne $ci:special-value-unknown">
            <xsl:variable name="property-elm" as="element(ci:property)"
              select="/ci:component-inventory-specification/ci:properties/ci:property[xs:string(@id) eq $property-idref]"/>
            <xsl:variable name="property-value-pattern" as="xs:string?" select="xs:string($property-elm/@value-pattern)"/>
            <xsl:if test="exists($property-value-pattern)">
              <xsl:if test="not(matches($property-value, $property-value-pattern))">
                <error>Property id "{$property-idref}" value "{$property-value}" is invalid (against property value pattern
                  "{$property-value-pattern}")</error>
              </xsl:if>
            </xsl:if>
          </xsl:if>
        </xsl:when>

        <xsl:otherwise>
          <error>Property id "{$property-idref}" does not exist</error>
        </xsl:otherwise>

      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:function name="local:quoted-string-list" as="xs:string?">
    <xsl:param name="strings" as="xs:string*"/>

    <xsl:if test="exists($strings)">
      <xsl:sequence select="'&quot;' || string-join($strings, '&quot;, &quot;') || '&quot;'"/>
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>

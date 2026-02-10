<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.sf4_rs2_g3c"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       As a first step in create-component-overview-report, this stylesheet processes 
       the directory overview into an overview of all the components, 
       with just the information we need.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../xslmod/ci-common.mod.xsl"/>
  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="schema-location-reference" as="xs:string"
    select="'https://eriksiegel.nl/ns/component-inventory file:/xatapult/component-inventory/grammar/ci-component.xsd'"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <create-component-overview-report timestamp="{current-dateTime()}">
      <xsl:sequence select="/*/@*"/>
      <xsl:apply-templates select="/ci:components/ci:directory"/>
    </create-component-overview-report>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:directory">
    <xsl:variable name="href-dir-base" as="xs:string" select="xs:string(@href) => xtlc:href-canonical() => xtlc:href-path()"/>
    <xsl:apply-templates select="c:directory">
      <xsl:with-param name="href-dir-start" as="xs:string" select="$href-dir-base || '/'" tunnel="true"/>
      <xsl:with-param name="href-dir-base" as="xs:string" select="$href-dir-base" tunnel="true"/>
      <xsl:with-param name="component-description-document-regexp" as="xs:string"
        select="xs:string((@component-description-document-regexp, $ci:default-component-description-document-regexp)[1])" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="c:directory">
    <xsl:param name="href-dir-start" as="xs:string" required="true" tunnel="true"/>
    <xsl:param name="href-dir-base" as="xs:string" required="true" tunnel="true"/>
    <xsl:param name="component-description-document-regexp" as="xs:string" required="true" tunnel="true"/>

    <xsl:variable name="component-description-file-elm" as="element(c:file)?"
      select="c:file[matches(xs:string(@name), $ci:default-component-description-document-regexp)][1]"/>
    <xsl:choose>

      <xsl:when test="exists($component-description-file-elm)">
        <xsl:variable name="default-component-id" as="xs:string" select="xs:string(@name)"/>
        <xsl:variable name="href-dir" as="xs:string" select="xtlc:href-concat(($href-dir-base, $default-component-id))"/>
        <xsl:variable name="href-dir-rel" as="xs:string" select="substring-after($href-dir, $href-dir-start)"/>
        <xsl:variable name="href-component-description" as="xs:string"
          select="xtlc:href-concat(($href-dir, xs:string($component-description-file-elm/@name)))"/>

        <component href-dir="{$href-dir}" href-dir-rel="{$href-dir-rel}" href-group-dir-rel="{xtlc:href-path($href-dir-rel)}"
          href-component-description="{$href-component-description}">

          <!-- Get the component description document: -->
          <xsl:variable name="component-description-document" as="document-node()?">
            <xsl:try>
              <xsl:sequence select="doc($href-component-description)"/>
              <xsl:catch>
                <xsl:sequence select="()"/>
              </xsl:catch>
            </xsl:try>
          </xsl:variable>
          <xsl:attribute name="well-formed" select="exists($component-description-document)"/>

          <!-- Process the component description: -->
          <xsl:for-each select="$component-description-document/*">
            <xsl:variable name="id" as="xs:string" select="xs:string((@id, $default-component-id)[1])"/>
            <xsl:attribute name="id" select="$id"/>
            <xsl:attribute name="name" select="xs:string((@name, $id)[1])"/>

            <!-- The following things we're going to check on: -->
            <xsl:variable name="summary" as="xs:string" select="normalize-space(@summary)"/>
            <xsl:attribute name="summary" select="$summary"/>
            <xsl:variable name="category-idrefs" as="xs:string"
              select="string-join(distinct-values(xtlc:str2seq(string(@category-idrefs))[. ne $ci:special-value-unknown]), ' ')"/>
            <xsl:attribute name="category-idrefs" select="$category-idrefs"/>
            <xsl:variable name="has-schema-ref" as="xs:boolean" select="normalize-space(@xsi:schemaLocation) eq $schema-location-reference"/>
            <xsl:attribute name="has-schema-ref" select="$has-schema-ref"/>
            
            <!-- Is this component ok? -->
            <xsl:variable name="error-messages" as="xs:string*">
              <xsl:if test="$summary eq ''">
                <xsl:sequence select="'No summary'"/>
              </xsl:if>
              <xsl:if test="$category-idrefs eq ''">
                <xsl:sequence select="'No categories'"/>
              </xsl:if>
              <xsl:if test="not($has-schema-ref)">
                <xsl:sequence select="'Schema reference error'"/>
              </xsl:if>
            </xsl:variable>
            <xsl:attribute name="ok" select="empty($error-messages)"/>
            <xsl:if test="exists($error-messages)">
              <xsl:attribute name="errors" select="string-join($error-messages, '; ')"/>
            </xsl:if>
          </xsl:for-each>

        </component>

      </xsl:when>

      <xsl:otherwise>
        <!-- No component file here, descent further: -->
        <xsl:apply-templates select="c:directory">
          <xsl:with-param name="href-dir-base" as="xs:string" select="xtlc:href-concat(($href-dir-base, xs:string(@name)))" tunnel="true"/>
        </xsl:apply-templates>
      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>


</xsl:stylesheet>

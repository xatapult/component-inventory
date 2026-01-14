<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.fw2_kmq_yhc"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:sml="http://www.eriksiegel.nl/ns/sml"
  exclude-result-prefixes="#all" expand-text="true" xmlns="http://www.eriksiegel.nl/ns/sml">
  <!-- ================================================================== -->
  <!-- 
       Creates an SML report based on the normalized version of a component 
       inventory specification.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS: -->

  <xsl:param name="report-type" as="xs:string" required="true"/>
  <xsl:param name="add-toc" as="xs:boolean" required="true"/>

  <!-- ======================================================================= -->
  <!-- GLOBAL DECLARATIONS: -->

  <!-- Report types. -->
  <!-- WARNING: these must be the same as defined in the create-normalized-component-inventory-specification-report.xpl pipeline! -->
  <xsl:variable name="report-type-errors" as="xs:string" select="'errors'"/>
  <xsl:variable name="report-type-warnings-and-errors" as="xs:string" select="'warnings-and-errors'"/>
  <xsl:variable name="report-type-full" as="xs:string" select="'full'"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


  <xsl:template match="/*">
    <sml toc="{$add-toc}">
      <title>Component inventory specification report</title>

      <para>Source: <code>{xtlc:href-protocol-remove(@xml:base)}</code></para>
      <para>Timestamp: {format-dateTime(xs:dateTime(@timestamp-normalization), $xtlc:default-dt-format)}</para>
      <xsl:call-template name="add-counts"/>

      <xsl:for-each select="ci:*">
        <xsl:call-template name="handle-items"/>
      </xsl:for-each>

    </sml>
  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:template name="handle-items">
    <xsl:param name="items-root" as="element()" required="false" select="."/>

    <xsl:variable name="error-count" as="xs:integer" select="count($items-root//ci:error)"/>
    <xsl:variable name="has-errors" as="xs:boolean" select="$error-count gt 0"/>
    <xsl:variable name="warning-count" as="xs:integer" select="count($items-root//ci:warning)"/>
    <xsl:variable name="has-warnings" as="xs:boolean" select="$warning-count gt 0"/>

    <xsl:if test="local:include-in-report($warning-count, $error-count)">
      <section>
        <title>{xtlc:capitalize(local-name($items-root))}</title>
        <xsl:call-template name="add-counts">
          <xsl:with-param name="elm" select="$items-root"/>
          <xsl:with-param name="warning-count" select="$warning-count"/>
          <xsl:with-param name="error-count" select="$error-count"/>
        </xsl:call-template>

        <xsl:for-each select="ci:*">
          <xsl:call-template name="handle-item"/>
        </xsl:for-each>

      </section>

    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="handle-item">
    <xsl:param name="item-root" as="element()" required="false" select="."/>

    <xsl:variable name="error-count" as="xs:integer" select="count($item-root//ci:error)"/>
    <xsl:variable name="has-errors" as="xs:boolean" select="$error-count gt 0"/>
    <xsl:variable name="warning-count" as="xs:integer" select="count($item-root//ci:warning)"/>
    <xsl:variable name="has-warnings" as="xs:boolean" select="$warning-count gt 0"/>

    <xsl:if test="local:include-in-report($warning-count, $error-count)">
      <section>
        <title>{xtlc:capitalize(local-name($item-root))} {$item-root/@name}</title>
        <xsl:call-template name="add-counts">
          <xsl:with-param name="elm" select="$item-root"/>
          <xsl:with-param name="warning-count" select="$warning-count"/>
          <xsl:with-param name="error-count" select="$error-count"/>
        </xsl:call-template>

        <xsl:for-each select="$item-root">
          <xsl:call-template name="output-attribute">
            <xsl:with-param name="attr" select="@id"/>
            <xsl:with-param name="is-code" select="true()"/>
          </xsl:call-template>
          <xsl:call-template name="output-attribute">
            <xsl:with-param name="attr" select="@summary"/>
          </xsl:call-template>
          <xsl:call-template name="output-attribute">
            <xsl:with-param name="attr" select="@reference-count"/>
          </xsl:call-template>
          <xsl:for-each select="@* except(@name, @id, @summary, @reference-count)">
            <xsl:sort select="local-name(.)"/>
            <xsl:call-template name="output-attribute">
              <xsl:with-param name="is-code" select="local-name(.) = ('default', 'value-pattern')"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>


      </section>

    </xsl:if>

  </xsl:template>


  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-counts">
    <xsl:param name="elm" as="element()" required="false" select="."/>
    <xsl:param name="warning-count" as="xs:integer" required="false" select="count($elm//ci:warning)"/>
    <xsl:param name="error-count" as="xs:integer" required="false" select="count($elm//ci:error)"/>

    <xsl:if test="$warning-count gt 0">
      <para>Warnings: {$warning-count}</para>
    </xsl:if>
    <xsl:if test="$error-count gt 0">
      <para>Errors: {$error-count}</para>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-attribute">
    <xsl:param name="attr" as="attribute()?" required="false" select="."/>
    <xsl:param name="prompt" as="xs:string" required="false" select="local-name($attr) => translate('-', ' ') => xtlc:capitalize()"/>
    <xsl:param name="is-code" as="xs:boolean" required="false" select="false()"/>

    <xsl:variable name="value-raw" as="xs:string" select="xs:string(@attr)"/>
    <xsl:variable name="value" as="xs:string" select="if (starts-with($value-raw, 'file:/')) then xtlc:href-protocol-remove($value-raw) else $value-raw"/>
    
    <!-- TBD references! -->

    <xsl:choose>
      <xsl:when test="empty($attr)">
        <!-- Do nothing -->
      </xsl:when>
      <xsl:when test="$is-code">
        <para>{$prompt}: <code>{$value}</code></para>
      </xsl:when>
      <xsl:otherwise>
        <para>{$prompt}: {$value}</para>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:include-in-report" as="xs:boolean">
    <xsl:param name="warning-count" as="xs:integer"/>
    <xsl:param name="error-count" as="xs:integer"/>

    <xsl:variable name="has-errors" as="xs:boolean" select="$error-count gt 0"/>
    <xsl:variable name="has-warnings" as="xs:boolean" select="$warning-count gt 0"/>
    <xsl:sequence select="
      ($report-type eq $report-type-full) or 
      (($report-type eq $report-type-warnings-and-errors) and ($has-errors or $has-warnings)) or 
      (($report-type eq $report-type-errors) and $has-errors)
    "/>
  </xsl:function>

</xsl:stylesheet>

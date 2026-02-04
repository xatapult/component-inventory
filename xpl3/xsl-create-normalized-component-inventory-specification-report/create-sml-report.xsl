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

  <xsl:variable name="doc" as="document-node()" select="/"/>

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

      <para>Type: <code>{$report-type}</code></para>
      <para>Source: <code>{@xml:base}</code></para>
      <para>Timestamp: <code>{format-dateTime(xs:dateTime(@timestamp-normalization), $xtlc:default-dt-format)}</code></para>
      <xsl:call-template name="add-warning-error-counts"/>

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

        <xsl:call-template name="add-warning-error-counts">
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
      <section id="{local:item-link-id($item-root)}">
        <title>{xtlc:capitalize(local-name($item-root))} {$item-root/@name}</title>

        <xsl:variable name="attributes-upfront" as="attribute()+" select="(@id, @summary, @reference-count)"/>
        <xsl:for-each select="$item-root">
          <xsl:for-each select="$attributes-upfront">
            <xsl:call-template name="output-attribute"/>
          </xsl:for-each>
          <xsl:for-each select="@* except(@name, $attributes-upfront)">
            <xsl:sort select="local-name(.)"/>
            <xsl:call-template name="output-attribute"/>
          </xsl:for-each>
        </xsl:for-each>

        <!-- Output any media: -->
        <xsl:variable name="media" as="element()*" select="$item-root/ci:media/ci:*[not(self::ci:warning) and not(self::ci:error)]"/>
        <xsl:if test="exists($media)">
          <para>Media: <code>{count($media)}</code></para>
          <itemizedlist>
            <xsl:for-each select="$media">
              <listitem>
                <para>{xtlc:capitalize(local-name(.))} ({@usage}): <link href="{@href}">{@href}</link></para>
              </listitem>
            </xsl:for-each>
          </itemizedlist>
        </xsl:if>

        <!-- Property values: -->
        <xsl:variable name="property-values" as="element(ci:property-value)*" select="$item-root/ci:property-values/ci:property-value"/>
        <xsl:if test="exists($property-values)">
          <para>Property values: <code>{count($property-values)}</code></para>
          <itemizedlist>
            <xsl:for-each select="$property-values">
              <xsl:variable name="idref" as="xs:string" select="xs:string(@property-idref)"/>
              <listitem>
                <xsl:variable name="property-item-link-id" as="xs:string?" select="local:item-link-id-by-id('property', $idref)"/>
                <para>
                  <xsl:choose>
                    <xsl:when test="exists($property-item-link-id)">
                      <link href="#{$property-item-link-id}">{$idref}</link>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$idref"/>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>: </xsl:text>
                  <code>
                    <xsl:value-of select="@value"/>
                  </code>
                </para>
              </listitem>
            </xsl:for-each>
          </itemizedlist>
        </xsl:if>

        <!-- Add warnings and errors (if any): -->
        <xsl:if test="$warning-count gt 0">
          <para>Warnings: <code>{$warning-count}</code></para>
          <itemizedlist>
            <xsl:for-each select="$item-root//ci:warning">
              <listitem>
                <para>{.}</para>
              </listitem>
            </xsl:for-each>
          </itemizedlist>
        </xsl:if>
        <xsl:if test="$error-count gt 0">
          <para>Errors: <code>{$error-count}</code></para>
          <itemizedlist>
            <xsl:for-each select="$item-root//ci:error">
              <listitem>
                <para>{.}</para>
              </listitem>
            </xsl:for-each>
          </itemizedlist>
        </xsl:if>

        <!-- The optional description: -->
        <xsl:copy-of select="$item-root/ci:description/sml:*"/>

      </section>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-warning-error-counts">
    <xsl:param name="elm" as="element()" required="false" select="."/>
    <xsl:param name="warning-count" as="xs:integer" required="false" select="count($elm//ci:warning)"/>
    <xsl:param name="error-count" as="xs:integer" required="false" select="count($elm//ci:error)"/>

    <xsl:if test="$warning-count gt 0">
      <para>Warnings: <code>{$warning-count}</code></para>
    </xsl:if>
    <xsl:if test="$error-count gt 0">
      <para>Errors: <code>{$error-count}</code></para>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="output-attribute">
    <xsl:param name="attr" as="attribute()?" required="false" select="."/>
    <xsl:param name="prompt" as="xs:string" required="false" select="local-name($attr) => translate('-', ' ') => xtlc:capitalize()"/>

    <xsl:variable name="attr-name" as="xs:string" select="local-name($attr)"/>
    <xsl:variable name="value" as="xs:string" select="string($attr)"/>

    <xsl:choose>

      <xsl:when test="empty($attr)">
        <!-- Do nothing -->
      </xsl:when>

      <xsl:when test="ends-with($attr-name, '-idref') or ends-with($attr-name, '-idrefs')">
        <!-- A single or multiple references. Try to create links: -->

        <!-- Find out the type of the item we're referring to here: -->
        <xsl:variable name="attr-name-parts" as="xs:string+" select="tokenize($attr-name, '-')[.]"/>

        <xsl:variable name="referred-item-type" as="xs:string?" select="$attr-name-parts[count($attr-name-parts) - 1]"/>
        <para>
          <xsl:value-of select="$prompt"/>
          <xsl:text>: </xsl:text>
          <xsl:for-each select="xtlc:str2seq($value)">
            <xsl:variable name="idref" as="xs:string" select="."/>
            <xsl:variable name="item-link-id" as="xs:string?" select="local:item-link-id-by-id($referred-item-type, $idref)"/>
            <xsl:choose>
              <xsl:when test="empty($referred-item-type) or empty($item-link-id)">
                <xsl:value-of select="$idref"/>
              </xsl:when>
              <xsl:otherwise>
                <link href="#{$item-link-id}">{$idref}</link>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() ne last()">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </para>

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

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:item-link-id" as="xs:string">
    <xsl:param name="item-elm" as="element()"/>
    <xsl:sequence select="local-name($item-elm) || '-' || generate-id($item-elm)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:item-link-id-by-id" as="xs:string?">
    <!-- Finds the id of a referenced item. Only when the report type is full! -->
    <xsl:param name="item-name" as="xs:string"/>
    <xsl:param name="id" as="xs:string"/>

    <xsl:if test="$report-type eq $report-type-full">
      <xsl:variable name="item-elm" as="element()?" select="$doc/ci:*/ci:*/ci:*[local-name(.) eq $item-name][xs:string(@id) eq $id]"/>
      <xsl:if test="exists($item-elm)">
        <xsl:sequence select="local:item-link-id($item-elm)"/>
      </xsl:if>
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>

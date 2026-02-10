<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.fw2_kmq_yhc"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:sml="http://www.eriksiegel.nl/ns/sml"
  exclude-result-prefixes="#all" expand-text="true" xmlns="http://www.eriksiegel.nl/ns/sml">
  <!-- ================================================================== -->
  <!-- 
       Creates an SML report based on the prepared component overview 
       (by process-directory-overview.xsl)
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/general.mod.xsl"/>
  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


  <xsl:template match="/*">
    <sml toc="true">
      <title>Component overview report</title>

      <para>Source: <code>{@xml:base => xtlc:href-canonical()}</code></para>
      <para>Timestamp: <code>{format-dateTime(xs:dateTime(current-dateTime()), $xtlc:default-dt-format)}</code></para>
      <xsl:call-template name="add-totals">
        <xsl:with-param name="elms" select="component"/>
      </xsl:call-template>

      <xsl:for-each-group select="component" group-by="xs:string(@href-group-dir-rel)">
        <xsl:sort select="current-grouping-key()"/>

        <section>
          <title>Group directory: <code>{current-grouping-key()}</code></title>
          <xsl:call-template name="add-totals">
            <xsl:with-param name="elms" select="current-group()"/>
          </xsl:call-template>

          <table>
            <header>
              <entry>
                <para>Status</para>
              </entry>
              <entry>
                <para>Name</para>
              </entry>
              <entry>
                <para>Id</para>
              </entry>
              <entry>
                <para>Summary</para>
              </entry>
              <entry>
                <para>Category idrefs</para>
              </entry>
              <entry>
                <para>Schema ref</para>
              </entry>
              <entry>
                <para>Error(s)</para>
              </entry>

            </header>
            <xsl:for-each select="current-group()">
              <xsl:sort select="xs:string(@name)"/>
              <row>
                <entry>
                  <para>{if (xs:boolean(@ok)) then 'Ok' else 'Error'}</para>
                </entry>
                <entry>
                  <para>{@name}</para>
                </entry>
                <entry>
                  <para>
                    <code>{@id}</code>
                  </para>
                </entry>
                <entry>
                  <para>{@summary}</para>
                </entry>
                <entry>
                  <para>{@category-idrefs}</para>
                </entry>
                <entry>
                  <para>{if (xs:boolean(@has-schema-ref)) then 'Ok' else 'Error'}</para>
                </entry>
                <entry>
                  <para>{@errors}</para>
                </entry>
              </row>

            </xsl:for-each>
          </table>

        </section>

      </xsl:for-each-group>

    </sml>
  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:template name="add-totals">
    <xsl:param name="elms" as="element(component)+" required="true"/>

    <xsl:variable name="total" as="xs:integer" select="count($elms)"/>
    <xsl:variable name="errors" as="xs:integer" select="count($elms[not(xs:boolean(@ok))])"/>

    <para>
      <xsl:text>Total: </xsl:text>
      <xsl:sequence select="$total"/>
      <xsl:if test="$errors ne 0">
        <xsl:text> - </xsl:text>
        <emphasis bold="true" italic="false">
          <xsl:text>Errors: </xsl:text>
          <xsl:sequence select="$errors"/>
          <xsl:text> (</xsl:text>
          <xsl:sequence select="($errors * 100) idiv $total"/>
          <xsl:text>%)</xsl:text>
          
        </emphasis>
      </xsl:if>
    </para>

  </xsl:template>



</xsl:stylesheet>

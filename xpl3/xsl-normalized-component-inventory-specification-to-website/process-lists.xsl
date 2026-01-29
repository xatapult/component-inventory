<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ds2_tbz_yhc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all"
  expand-text="true" xmlns="http://www.w3.org/1999/xhtml">
  <!-- ================================================================== -->
  <!-- 
       Takes an ciLIST element and turns this into the appropriate page contents.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/general.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="limit-to-simple-list-item-count" as="xs:integer" select="10">
    <!-- If the number of items in the list is le this, it becomes a simple list. Otherwise it becomes 
      a list with an index banner for the first characters. -->
  </xsl:variable>

  <xsl:variable name="items-id-prefix" as="xs:string" select="'items-'"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/ci:LIST">

    <xsl:variable name="listitems" as="element(ci:LISTITEM)*" select="ci:LISTITEM"/>
    <div class="item-list">
      <xsl:choose>

        <xsl:when test="count ($listitems) gt $limit-to-simple-list-item-count">
          <!-- Create the bar with start characters: -->
          <xsl:variable name="item-type-name" as="xs:string" select="xs:string(@type)"/>
          <p class="para item-start-character-list">
            <xsl:for-each-group select="$listitems" group-by="local:group-char(.)">
              <xsl:sort select="current-grouping-key()"/>
              <a href="#{$items-id-prefix || current-grouping-key()}"
                title="{xtlc:capitalize($item-type-name)} starting with {current-grouping-key()}">{current-grouping-key()}</a>
              <xsl:if test="position() ne last()">
                <xsl:text>&#160; </xsl:text>
              </xsl:if>
            </xsl:for-each-group>
          </p>
          <!-- Now create the links to the items: -->
          <xsl:for-each-group select="$listitems" group-by="local:group-char(.)">
            <xsl:sort select="current-grouping-key()"/>
            <a name="{$items-id-prefix || current-grouping-key()}"><!----></a>
            <h2>{current-grouping-key()}</h2>
            <ul>
              <xsl:for-each select="current-group()">
                <xsl:sort select="@name"/>
                <li>
                  <a href="{@href}">{@name}</a>
                  <xsl:text> - </xsl:text>
                  <xsl:value-of select="@description"/>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:for-each-group>
        </xsl:when>

        <xsl:otherwise>
          <xsl:where-populated>
            <ul>
              <xsl:for-each select="$listitems">
                <xsl:sort select="@name"/>
                <li>
                  <a href="{@href}">{@name}</a>
                  <xsl:text> - </xsl:text>
                  <xsl:value-of select="@description"/>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:where-populated>
        </xsl:otherwise>
        
      </xsl:choose>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:group-char" as="xs:string">
    <xsl:param name="listitem" as="element(ci:LISTITEM)"/>

    <xsl:sequence select="normalize-space($listitem/@name) => substring(1, 1) => upper-case()"/>
  </xsl:function>


</xsl:stylesheet>

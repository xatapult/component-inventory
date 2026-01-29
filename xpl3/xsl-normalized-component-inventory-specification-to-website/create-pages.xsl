<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ds2_tbz_yhc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all"
  expand-text="true" xmlns="http://www.w3.org/1999/xhtml">
  <!-- ================================================================== -->
  <!-- 
       Takes a container with documents containing the body HTML. 
       Turns this into real pages, including a menu, etc.
       
       There will still be some sections that are filled in later, like the menu, SML parts 
       and some others.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-create-page" on-no-match="shallow-copy"/>
  <xsl:mode name="mode-create-menu" on-no-match="fail"/>

  <xsl:include href="../../xslmod/ci-website-building.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:param name="href-web-template" as="xs:string" required="true"/>

  <!-- ================================================================== -->

  <xsl:variable name="homedir-string" as="xs:string" select="'$HOMEDIR$'"/>
  <xsl:variable name="homedir-string-regexp" as="xs:string" select="xtlc:str2regexp($homedir-string, false())"/>

  <!-- Pre-load the web template: -->
  <xsl:variable name="web-template" as="document-node()" select="doc($href-web-template)"/>
  
  <!-- Discard whitespace in HTML production. Set to true for production: -->
  <xsl:variable name="discard-html-whitespace" as="xs:boolean" select="false()"/>

  <!-- ======================================================================= -->
  <!-- We are going to prepare menus for pages a number of levels deep up-front, in a map.
    The key is the page level, the content is the menu html.
  -->

  <xsl:variable name="max-page-level" as="xs:integer" select="2"/>
  <xsl:variable name="menu-map" as="map(xs:integer, element(html:div))">
    <xsl:map>
      <xsl:for-each select="(0 to $max-page-level)">
        <xsl:variable name="page-level" as="xs:integer" select="."/>
        <xsl:map-entry key="$page-level">
          <xsl:call-template name="create-menu">
            <xsl:with-param name="base-menu" select="$ci:additional-data-document/*/ci:menu"/>
            <xsl:with-param name="page-level" select="$page-level"/>
          </xsl:call-template>
        </xsl:map-entry>
      </xsl:for-each>
    </xsl:map>
  </xsl:variable>

  <!-- ======================================================================= -->

  <xsl:template match="xtlcon:document">

    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*"/>

      <!-- Find out how deep this page is in the directory structure and create an appropriate homedir string: -->
      <xsl:variable name="page-level" as="xs:integer" select="xs:integer((@page-level, 0)[1])"/>

      <!-- Create the page based on the web template: -->
      <xsl:apply-templates select="$web-template/*" mode="mode-create-page">
        <xsl:with-param name="title" as="xs:string" select="xs:string(@title)" tunnel="true"/>
        <xsl:with-param name="homedir" as="xs:string" select="local:homedir-prefix($page-level)" tunnel="true"/>
        <xsl:with-param name="page-contents" as="element()*" select="*" tunnel="true"/>
        <xsl:with-param name="keywords" as="xs:string?" select="xs:string(@keywords)" tunnel="true"/>
        <xsl:with-param name="page-level" as="xs:integer" select="$page-level" tunnel="true"/>
      </xsl:apply-templates>

    </xsl:copy>

  </xsl:template>

  <!-- ======================================================================= -->
  <!-- TEMPLATE PROCESSING: -->

  <xsl:template match="ci:TITLE" mode="mode-create-page">
    <xsl:param name="title" as="xs:string" required="true" tunnel="true"/>

    <xsl:value-of select="$title"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:PAGE-CONTENTS" mode="mode-create-page">
    <xsl:param name="page-contents" as="element()*" required="true" tunnel="true"/>

    <xsl:call-template name="ci:elements-to-html-namespace">
      <xsl:with-param name="elements" select="$page-contents"/>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:MENU" mode="mode-create-page">
    <xsl:param name="page-level" as="xs:integer" required="true" tunnel="true"/>

    <xsl:sequence select="$menu-map($page-level)"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="@*[contains(., $homedir-string)]" mode="mode-create-page">
    <xsl:param name="homedir" as="xs:string" required="true" tunnel="true"/>

    <xsl:attribute name="{node-name(.)}" select="replace(xs:string(.), $homedir-string-regexp, $homedir)"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="html:meta[@name eq 'keywords']/@content" mode="mode-create-page">
    <xsl:param name="keywords" as="xs:string?" required="true" tunnel="true"/>

    <xsl:attribute name="{node-name(.)}" select="$keywords"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="text()[$discard-html-whitespace][normalize-space(.) eq '']" mode="mode-create-page">
    <!-- Discard -->
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="comment() | processing-instruction()" mode="mode-create-page">
    <!-- Discard. -->
  </xsl:template>
 
  <!-- ======================================================================= -->
  <!-- CREATE MENU: -->

  <xsl:template name="create-menu" as="element(html:div)">
    <!-- This creates the menu HTML structure, suitable for use on a page on a certain level. -->
    <xsl:param name="base-menu" as="element(ci:menu)" required="true"/>
    <xsl:param name="page-level" as="xs:integer" required="true"/>

    <div class="container-fluid">
      <ul class="nav justify-content-end nav-pills text-light">
        <xsl:apply-templates select="$base-menu/ci:menu-entry" mode="mode-create-menu">
          <xsl:with-param name="homedir" as="xs:string" select="local:homedir-prefix($page-level)" tunnel="true"/>
        </xsl:apply-templates>
      </ul>
    </div>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:menu-entry" mode="mode-create-menu">
    <xsl:param name="homedir" as="xs:string" required="true" tunnel="true"/>

    <xsl:choose>
      <xsl:when test="exists(ci:sub-menu-entry)">
        <li class="nav-item dropdown lead">
          <a class="nav-link dropdown-toggle text-light" data-bs-toggle="dropdown" href="#">{@caption}</a>
          <ul class="dropdown-menu">
            <xsl:apply-templates select="ci:sub-menu-entry" mode="mode-create-menu"/>
          </ul>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <li class="nav-item lead">
          <a class="nav-link text-light" href="{$homedir}{@href}">{@caption}</a>
        </li>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:sub-menu-entry" mode="mode-create-menu">
    <xsl:param name="homedir" as="xs:string" required="true" tunnel="true"/>

    <li class="lead">
      <a class="dropdown-item" href="{$homedir}{@href}">{@caption}</a>
    </li>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- OTHERS: -->

  <xsl:function name="local:homedir-prefix" as="xs:string">
    <xsl:param name="page-level" as="xs:integer"/>

    <xsl:sequence select="string-join(for $d in (1 to $page-level) return '..', '/') || (if ($page-level gt 0) then '/' else ())"/>
  </xsl:function>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ds2_tbz_yhc"
  xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all" expand-text="true">
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
  <xsl:mode name="mode-copy-contents" on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/ci-website-building.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:param name="href-web-template" as="xs:string" required="true"/>

  <!-- ================================================================== -->

  <xsl:variable name="homedir-string" as="xs:string" select="'$HOMEDIR$'"/>
  <xsl:variable name="homedir-string-regexp" as="xs:string" select="xtlc:str2regexp($homedir-string, false())"/>

  <!-- Pre-load the web template: -->
  <xsl:variable name="web-template" as="document-node()" select="doc($href-web-template)"/>

  <!-- ======================================================================= -->

  <xsl:template match="xtlcon:document">

    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*"/>

      <!-- Find out how deep this page is in the directory structure and create an appropriate homedir string: -->
      <xsl:variable name="level" as="xs:integer" select="count(tokenize(@href-target, '/')[.]) - 1"/>
      <xsl:variable name="homedir" as="xs:string"
        select="string-join(for $d in (1 to $level) return '..', '/') || (if ($level gt 0) then '/' else ())"/>

      <!-- TBD SOMETHING WITH KEYWORDS (STANDARD + SPECIAL ON DOCUMENT ATTRIBUTE?) -->

      <!-- Create the page based on the web template: -->
      <xsl:apply-templates select="$web-template/*" mode="mode-create-page">
        <xsl:with-param name="title" as="xs:string" select="xs:string(@title)" tunnel="true"/>
        <xsl:with-param name="homedir" as="xs:string" select="$homedir" tunnel="true"/>
        <xsl:with-param name="page-contents" as="element()*" select="*" tunnel="true"/>
        <xsl:with-param name="keywords" as="xs:string?" select="xs:string(@keywords)" tunnel="true"/>
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

    <xsl:apply-templates mode="mode-copy-contents" select="$page-contents"/>
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
  
  <!-- TBD TURN BACK ON FOR PRODUCTION -->
  <!--<xsl:template match="text()[normalize-space(.) eq '']" mode="mode-create-page">
    <!-\- Discard -\->
  </xsl:template>-->
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="comment() | processing-instruction()" mode="mode-create-page">
    <!-- Discard. -->
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- COPY CONTENTS INTO THE HTML NAMESPACE: -->

  <xsl:template match="*" mode="mode-copy-contents">

    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>

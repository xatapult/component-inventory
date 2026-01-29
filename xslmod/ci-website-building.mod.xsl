<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rhy_3nr_whc"
  xmlns:html="http://www.w3.org/1999/xhtml" xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:ci="https://eriksiegel.nl/ns/component-inventory"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Module with common declarations and functionality for building the website
       for component-inventory.
  -->
  <!-- ================================================================== -->

  <xsl:include href="ci-common.mod.xsl"/>
  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

  <xsl:mode name="local:mode-copy-contents" on-no-match="shallow-copy"/>

  <!-- ======================================================================= -->

  <xsl:variable name="namespace-html" as="xs:string" select="namespace-uri-for-prefix('html', doc('')/*)"/>

  <!-- ======================================================================= -->
  <!-- ACCES TO THE ADDITIONAL DATA: -->

  <xsl:variable name="ci:href-additional-data-document" as="xs:string"
    select="resolve-uri('../data/component-inventory-additional-data.xml', static-base-uri())"/>
  <xsl:variable name="ci:additional-data-document" as="document-node()" select="doc($ci:href-additional-data-document)"/>

  <!-- ======================================================================= -->
  <!-- COPY CONTENTS INTO THE HTML NAMESPACE: -->

  <xsl:template name="ci:elements-to-html-namespace">
    <xsl:param name="elements" as="element()*" required="true"/>
    <xsl:apply-templates select="$elements" mode="local:mode-copy-contents"/>
  </xsl:template>


  <xsl:template match="*" mode="local:mode-copy-contents">
    <xsl:element name="{local-name(.)}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="sml:*" mode="local:mode-copy-contents">
    <!-- SML elements will get translated into HTML later on... -->
    <xsl:sequence select="."/>
  </xsl:template>

</xsl:stylesheet>

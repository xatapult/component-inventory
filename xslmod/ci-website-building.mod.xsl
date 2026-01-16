<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rhy_3nr_whc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Module with common declarations and functionality for building the website
       for component-inventory.
  -->
  <!-- ================================================================== -->

  <xsl:include href="ci-common.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:variable name="ci:document-type-index" as="xs:string" select="'index'"/>
  <xsl:variable name="ci:document-type-component" as="xs:string" select="'component'"/>
 
</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.rhy_3nr_whc"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Module with common declarations and functionality for the component inventory.
  -->
  <!-- ================================================================== -->
  
  <xsl:include href="file:/xatapult/xtpxlib-common/xslmod/general.mod.xsl"/>
  
  <!-- ======================================================================= -->
  
  
  <xsl:variable name="ci:category-separator" as="xs:string" select="'.'"/>
  
  <xsl:variable name="ci:default-component-description-document-regexp" as="xs:string" select="'^component-.+\.xml$'"/>
  
  <xsl:variable name="ci:special-value-unknown" as="xs:string" select="'#unknown'"/>
  
</xsl:stylesheet>

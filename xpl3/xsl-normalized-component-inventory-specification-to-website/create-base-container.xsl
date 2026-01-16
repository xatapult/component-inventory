<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ds2_tbz_yhc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Creates a container with stubs for all the pages we have to fill in,
       based on a (clean and normalized) component-inventory specification.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>
  
  <xsl:include href="../../xslmod/ci-website-building.mod.xsl"/>
  
  <!-- ======================================================================= -->
  
  <xsl:param name="href-build-location" as="xs:string" required="true"/>
  
  <!-- ================================================================== -->

  <xsl:template match="/"> 
    <xtlcon:document-container timestamp="{current-dateTime()}" href-target-path="{$href-build-location}">
      
      <!-- Home/index page: -->
      <xtlcon:document href-target="index.html" type="{$ci:document-type-index}" title="Component-inventory home" >
        <!-- Filled in later -->
        <p>HOME PAGE COMPONENT-INVENTORY</p>
      </xtlcon:document>
      
    </xtlcon:document-container>
  
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->



</xsl:stylesheet>

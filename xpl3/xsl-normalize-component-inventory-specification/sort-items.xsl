<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.j2z_scq_c3c"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Sorts a component-specification
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="no" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <!-- ================================================================== -->

  <xsl:template match="/ci:*/ci:*">
    <!-- Item level -->
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="ci:*">
        <xsl:sort select="upper-case(@name)"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

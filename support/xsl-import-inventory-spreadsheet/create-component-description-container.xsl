<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.xxv_1fx_c3c"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlxo="http://www.xtpxlib.nl/ns/xoffice" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Creates a container with CI component description documents.
       
       Input is the combined spreadsheet contents and subdirectory list, as created by
       the encompassing pipeline.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../xslmod/ci-common.mod.xsl"/>
  <xsl:include href="file:/xatapult/xtpxlib-xoffice/xslmod/excel-conversions.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:param name="href-target-dir" as="xs:string" required="true"/>

  <!-- ======================================================================= -->

  <xsl:variable name="worksheet-name" as="xs:string" select="'Components'"/>
  <xsl:variable name="content-rows" as="element(xtlxo:row)*"
    select="/*/xtlxo:workbook/xtlxo:worksheet[@name eq $worksheet-name]/xtlxo:row[position() gt 1]"/>

  <xsl:variable name="subdir-component-ids" as="xs:string*" select="/*/subdir-list/subdir/@name/string()"/>

  <xsl:variable name="filename-prefix" as="xs:string" select="'component-'"/>

  <xsl:variable name="col-id" as="xs:integer" select="1"/>
  <xsl:variable name="col-date" as="xs:integer" select="2"/>
  <xsl:variable name="col-name" as="xs:integer" select="3"/>
  <xsl:variable name="col-description" as="xs:integer" select="4"/>
  <xsl:variable name="col-package" as="xs:integer" select="5"/>
  <xsl:variable name="col-category" as="xs:integer" select="6"/>
  <xsl:variable name="col-amount" as="xs:integer" select="7"/>
  <xsl:variable name="col-price" as="xs:integer" select="8"/>
  <xsl:variable name="col-discontinued" as="xs:integer" select="9"/>
  <xsl:variable name="col-information-available" as="xs:integer" select="10"/>
  <xsl:variable name="col-overflow" as="xs:integer" select="11"/>
  <xsl:variable name="col-location" as="xs:integer" select="12"/>
  <xsl:variable name="col-label" as="xs:integer" select="13"/>
  <xsl:variable name="col-remarks" as="xs:integer" select="14"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xtlcon:document-container xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" timestamp="{current-dateTime()}"
      href-target-path="{$href-target-dir}">
      <xsl:apply-templates select="$content-rows">
        <xsl:sort select="local:get-value(., $col-id)"/>
      </xsl:apply-templates>
    </xtlcon:document-container>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="xtlxo:row">

    <xsl:variable name="row" as="element(xtlxo:row)" select="."/>
    <xsl:variable name="id" as="xs:string" select="local:get-value($row, $col-id)"/>
    <xsl:variable name="information-available" as="xs:boolean" select="local:get-value-boolean($row, $col-information-available, true())"/>

    <!-- If there is information, we should have a corresponding directory: -->
    <xsl:if test="$information-available and not($id = $subdir-component-ids)">
      <xsl:call-template name="xtlc:raise-error">
        <xsl:with-param name="msg-parts" select="'Component ' || $id || ' has no corresponding subdirectory in ' || $href-target-dir"/>
      </xsl:call-template>
    </xsl:if>

    <!-- Create the component document: -->
    <xtlcon:document href-target="{$id}/{$filename-prefix}{$id}.xml" serialization="{{'indent': 'true'}}">
      <component xmlns="https://eriksiegel.nl/ns/component-inventory" id="{$id}">

        <xsl:attribute name="name" select="local:get-value($row, $col-name, $id)"/>

        <xsl:sequence select="local:attribute-if-value($row, $col-description, 'summary')"/>

        <xsl:variable name="count-string" as="xs:string" select="local:get-value($row, $col-amount, '?')"/>
        <xsl:choose>
          <xsl:when test="$count-string castable as xs:integer">
            <xsl:variable name="count" as="xs:integer" select="xs:integer($count-string)"/>
            <xsl:attribute name="count" select="if ($count gt $ci:special-value-many-limit) then $ci:special-value-many else string($count)"/>
          </xsl:when>
          <xsl:when test="$count-string eq '+'">
            <xsl:attribute name="count" select="$ci:special-value-many"/>
          </xsl:when>
        </xsl:choose>

        <xsl:sequence select="local:attribute-if-value($row, $col-category, 'category-idrefs')"/>

        <xsl:variable name="price-string" as="xs:string" select="local:get-value($row, $col-price, '?')"/>
        <xsl:if test="$price-string castable as xs:double">
          <xsl:variable name="price" as="xs:double" select="xs:double($price-string)"/>
          <xsl:variable name="price-range-idref" as="xs:string">
            <xsl:choose>
              <xsl:when test="$price le 0.5">
                <xsl:sequence select="'VERY-CHEAP'"/>
              </xsl:when>
              <xsl:when test="$price gt 0.5 and $price le 2.0">
                <xsl:sequence select="'CHEAP'"/>
              </xsl:when>
              <xsl:when test="$price gt 2.0 and $price le 10.0">
                <xsl:sequence select="'EXPENSIVE'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="'VERY-EXPENSIVE'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="price-range-idref" select="$price-range-idref"/>
        </xsl:if>

        <xsl:sequence select="local:attribute-if-value($row, $col-package, 'package-idref')"/>

        <xsl:sequence select="local:attribute-if-value($row, $col-location, 'location-idref', 'CBSB')"/>

        <xsl:sequence select="local:attribute-if-value($row, $col-label, 'location-box-label')"/>

        <xsl:if test="local:get-value-boolean($row, $col-overflow, false())">
          <xsl:attribute name="partly-in-reserve-stock" select="string(true())"/>
        </xsl:if>

        <xsl:variable name="since-string" as="xs:string" select="local:get-value($row, $col-date, '?')"/>
        <xsl:if test="$since-string castable as xs:integer">
          <xsl:attribute name="since" select="xtlxo:excel-date-to-xs-date(xs:integer($since-string)) => string()"/>
        </xsl:if>

        <xsl:variable name="discontinued" as="xs:boolean" select="local:get-value-boolean($row, $col-discontinued, false())"/>
        <xsl:if test="$discontinued">
          <xsl:attribute name="discontinued" select="string(true())"/>
        </xsl:if>

        <xsl:if test="local:has-value($row, $col-remarks)">
          <description>
            <p>
              <xsl:text>Remark: </xsl:text>
              <xsl:value-of select="local:get-value($row, $col-remarks)"/>
            </p>
          </description>
        </xsl:if>

      </component>

    </xtlcon:document>

  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:function name="local:value-elm" as="element(xtlxo:value)?">
    <xsl:param name="row" as="element(xtlxo:row)"/>
    <xsl:param name="col" as="xs:integer"/>

    <xsl:sequence select="$row/xtlxo:cell[xs:integer(@index) eq $col]/xtlxo:value[normalize-space(.) ne '']"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:has-value" as="xs:boolean">
    <xsl:param name="row" as="element(xtlxo:row)"/>
    <xsl:param name="col" as="xs:integer"/>

    <xsl:sequence select="exists(local:value-elm($row, $col))"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:attribute-if-value" as="attribute()?">
    <xsl:param name="row" as="element(xtlxo:row)"/>
    <xsl:param name="col" as="xs:integer"/>
    <xsl:param name="attribute-name" as="xs:string"/>
    <xsl:param name="default" as="xs:string?"/>

    <xsl:choose>
      <xsl:when test="local:has-value($row, $col)">
        <xsl:attribute name="{$attribute-name}" select="local:get-value($row, $col)"/>
      </xsl:when>
      <xsl:when test="exists($default)">
        <xsl:attribute name="{$attribute-name}" select="$default"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:attribute-if-value" as="attribute()?">
    <xsl:param name="row" as="element(xtlxo:row)"/>
    <xsl:param name="col" as="xs:integer"/>
    <xsl:param name="attribute-name" as="xs:string"/>

    <xsl:sequence select="local:attribute-if-value($row, $col, $attribute-name, ())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-value" as="xs:string">
    <xsl:param name="row" as="element(xtlxo:row)"/>
    <xsl:param name="col" as="xs:integer"/>
    <xsl:param name="default" as="xs:string?">
      <!-- If this is (), a value is mandatory. -->
    </xsl:param>

    <xsl:variable name="value-elm" as="element(xtlxo:value)?" select="local:value-elm($row, $col)"/>
    <xsl:choose>
      <xsl:when test="exists($value-elm)">
        <xsl:sequence select="normalize-space($value-elm)"/>
      </xsl:when>
      <xsl:when test="exists($default)">
        <xsl:sequence select="$default"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="xtlc:raise-error">
          <xsl:with-param name="msg-parts" select="'Missing value for row ' || $row/@index || ' column ' || $col"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-value" as="xs:string">
    <xsl:param name="row" as="element(xtlxo:row)"/>
    <xsl:param name="col" as="xs:integer"/>

    <xsl:sequence select="local:get-value($row, $col, ())"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:get-value-boolean" as="xs:boolean">
    <xsl:param name="row" as="element(xtlxo:row)"/>
    <xsl:param name="col" as="xs:integer"/>
    <xsl:param name="default" as="xs:boolean"/>

    <xsl:variable name="value" as="xs:string" select="local:get-value($row, $col, string($default))"/>
    <xsl:choose>
      <xsl:when test="$value castable as xs:boolean">
        <xsl:sequence select="xs:boolean($value)"/>
      </xsl:when>
      <xsl:when test="$value castable as xs:integer">
        <xsl:sequence select="xs:integer($value) ne 0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$default"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.flf_2tl_whc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" version="3.0">

  <!-- ======================================================================= -->

  <p:import href="../xpl3mod/component-inventory.mod.xpl"/>

  <!-- ======================================================================= -->

  <p:option static="true" name="ci:report-type-errors" as="xs:string" select="'errors'"/>
  <p:option static="true" name="ci:report-type-warnings-and-errors" as="xs:string" select="'warnings-and-errors'"/>
  <p:option static="true" name="ci:report-type-full" as="xs:string" select="'full'"/>

  <!-- ======================================================================= -->

  <p:declare-step exclude-inline-prefixes="#all" name="create-normalized-component-inventory-specification-report"
    type="ci:create-normalized-component-inventory-specification-report">

    <p:documentation>
      Creates a report based on the normalized version of a component inventory specification.
      The step itself acts almost as an identity step: it just adds an @duration-report attribute.
    </p:documentation>

    <!-- ======================================================================= -->
    <!-- IMPORTS: -->

    <p:import-functions href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

    <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/message/message.xpl"/>
   
    <!-- ======================================================================= -->
    <!-- PORTS: -->

    <p:input port="source" primary="true" sequence="false" content-types="xml" href="../test/test-specification.xml">
      <p:documentation>The normalized component inventory specification (output of normalize-component-inventory-specification.xpl).</p:documentation>
    </p:input>

    <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
      <p:documentation>The source with a duration attribute added.</p:documentation>
    </p:output>

    <!-- ======================================================================= -->
    <!-- OPTIONS -->

    <p:option name="href-dir-result" as="xs:string" required="true">
      <p:documentation>The directory where to write the result.</p:documentation>
    </p:option>

    <p:option name="filename" as="xs:string" required="true">
      <p:documentation>The filename of the result (the extension is determined by the report type</p:documentation>
    </p:option>

    <p:option name="report-type" as="xs:string" required="false" select="$ci:report-type-full">
      <p:documentation>The report type (see the static options $report-type-*).</p:documentation>
    </p:option>

    <p:option name="add-toc" as="xs:boolean" required="false" select="true()">
      <p:documentation>Whether or not to add a TOC to the report.</p:documentation>
    </p:option>

    <p:option name="report-output-types" as="xs:string+" required="false" select="$ci:report-output-type-html">
      <p:documentation>One or more report output type names (see the static options $report-type-*).</p:documentation>
    </p:option>

    <p:option name="message-indent-level" as="xs:integer" required="false" select="0">
      <p:documentation>The (starting) indent level for any console messages.</p:documentation>
    </p:option>

    <p:option name="messages-enabled" as="xs:boolean" required="false" select="true()">
      <p:documentation>Whether or not console messages are enabled.</p:documentation>
    </p:option>

    <!-- ================================================================== -->
    <!-- MAIN: -->

    <p:variable name="timestamp-start" as="xs:dateTime" select="current-dateTime()"/>

    <!-- Create and output the report: -->
    <p:group name="create-report">

      <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level}">
        <p:with-option name="text" select="'Creating component-inventory ' || $report-type || ' report'"/>
      </xtlc:message>

      <!-- Create the report: -->
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-create-normalized-component-inventory-specification-report/create-sml-report.xsl"/>
        <p:with-option name="parameters" select="map{
          'report-type': $report-type,
          'add-toc': $add-toc
        }"/>
      </p:xslt>

      <ci:write-sml-report>
        <p:with-option name="href-dir-result" select="$href-dir-result"/>
        <p:with-option name="filename" select="$filename"/>
        <p:with-option name="add-toc" select="$add-toc"/>
        <p:with-option name="report-output-types" select="$report-output-types"/>
        <p:with-option name="message-indent-level" select="$message-indent-level"/>
        <p:with-option name="messages-enabled" select="$messages-enabled"/>
      </ci:write-sml-report>

    </p:group>

    <!-- Create the output (= source + duration attribute): -->
    <p:add-attribute depends="create-report" attribute-name="duration-reporting">
      <p:with-input pipe="source@create-normalized-component-inventory-specification-report"/>
      <p:with-option name="attribute-value" select="string(current-dateTime() - $timestamp-start)"/>
    </p:add-attribute>

  </p:declare-step>

</p:library>

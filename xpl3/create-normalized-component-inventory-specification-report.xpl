<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.flf_2tl_whc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" version="3.0">

  <!-- ======================================================================= -->

  <p:option static="true" name="ci:report-type-errors" as="xs:string" select="'errors'"/>
  <p:option static="true" name="ci:report-type-warnings-and-errors" as="xs:string" select="'warnings-and-errors'"/>
  <p:option static="true" name="ci:report-type-full" as="xs:string" select="'full'"/>

  <!-- Report output types: -->
  <p:option static="true" name="ci:report-output-type-html" as="xs:string" select="'html'"/>
  <p:option static="true" name="ci:report-output-type-md" as="xs:string" select="'md'"/>

  <!-- Others: -->
  <p:option static="true" name="local:empty-map" as="map(*)" select="map{}" visibility="private"/>

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

    <p:import href="file:/xatapult/xtpxlib-sml/xpl3/sml-prepare.xpl"/>
    <p:import href="file:/xatapult/xtpxlib-sml/xpl3/prepared-sml-to-html.xpl"/>
    <p:import href="file:/xatapult/xtpxlib-sml/xpl3/prepared-sml-to-markdown.xpl"/>

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

      <!-- Prepare the SML: -->
      <sml:sml-prepare>
        <p:with-option name="href-dir-result" select="$href-dir-result"/>
      </sml:sml-prepare>
      <p:set-properties>
        <p:with-option name="properties" select="map{'serialization': $local:empty-map}"/>
      </p:set-properties>
      <p:identity name="prepared-sml"/>

      <!-- Output it: -->
      <p:if test="$ci:report-output-type-html = $report-output-types">
        <p:variable name="href-output" as="xs:string" select="xtlc:href-concat(($href-dir-result, $filename || '.html'))"/>
        <sml:prepared-sml-to-html>
          <p:with-input pipe="@prepared-sml"/>
        </sml:prepared-sml-to-html>
        <p:store serialization="map{'method': 'html'}">
          <p:with-option name="href" select="$href-output"/>
        </p:store>
        <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
          <p:with-option name="text" select="'HTML report written to &quot;' || $href-output || '&quot;'"/>
        </xtlc:message>
      </p:if>

      <p:if test="$ci:report-output-type-md = $report-output-types">
        <p:variable name="href-output" as="xs:string" select="xtlc:href-concat(($href-dir-result, $filename || '.md'))"/>
        <sml:prepared-sml-to-markdown>
          <p:with-input pipe="@prepared-sml"/>
        </sml:prepared-sml-to-markdown>
        <p:store serialization="map{'method': 'text'}">
          <p:with-option name="href" select="$href-output"/>
        </p:store>
        <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
          <p:with-option name="text" select="'Markdown report written to &quot;' || $href-output || '&quot;'"/>
        </xtlc:message>
      </p:if>

    </p:group>

    <p:add-attribute depends="create-report" attribute-name="duration-reporting">
      <p:with-input pipe="source@create-normalized-component-inventory-specification-report"/>
      <p:with-option name="attribute-value" select="string(current-dateTime() - $timestamp-start)"/>
    </p:add-attribute>

  </p:declare-step>

</p:library>

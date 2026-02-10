<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.eb3_dn2_g3c"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="3.0" exclude-inline-prefixes="#all" name="create-component-overview-report">

  <p:documentation>
    Creates a report to get an overview of all the components. Both a Markdown and HTML report are produced.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../xpl3mod/component-inventory.mod.xpl"/>

  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/message/message.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/recursive-directory-list/recursive-directory-list.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/expand-macro-definitions/expand-macro-definitions.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="../src/ci-specification.xml">
    <p:documentation>The component inventory specification document to process.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small report XML</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-dir-result" as="xs:string" required="false" select="resolve-uri('../build/', static-base-uri())">
    <p:documentation>The directory where to write the result.</p:documentation>
  </p:option>

  <p:option name="filename" as="xs:string" required="false" select="'component-overview-report'">
    <p:documentation>The filename of the result (the extension is added by the pipeline).</p:documentation>
  </p:option>

  <p:option name="report-output-types" as="xs:string+" required="false" select="($ci:report-output-type-html, $ci:report-output-type-md)">
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

  <!-- Setup: -->
  <p:variable name="timestamp-start" as="xs:dateTime" select="current-dateTime()"/>
  <xtlc:message enabled="{$messages-enabled}" level="0">
    <p:with-option name="text" select="'Generating component overview report'"/>
  </xtlc:message>

  <!-- Only keep the components part and do some preparations: -->
  <p:variable name="base-uri" as="xs:string" select="base-uri(/)"/>
  <p:identity>
    <p:with-input select="/ci:*/ci:components"/>
  </p:identity>
  <p:add-xml-base/>
  <xtlc:expand-macro-definitions/>
  <p:make-absolute-uris match="@href" base-uri="{$base-uri}"/>

  <!-- Get the directory info in: -->
  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
    <p:with-option name="text" select="'Generating component information'"/>
  </xtlc:message>
  <p:viewport match="ci:components/ci:directory" name="get-component-directory-information">
    <xtlc:recursive-directory-list name="component-directory-information">
      <p:with-option name="path" select="xs:string(/*/@href)"/>
    </xtlc:recursive-directory-list>
    <p:insert position="first-child">
      <p:with-input pipe="current@get-component-directory-information"/>
      <p:with-input port="insertion" pipe="@component-directory-information"/>
    </p:insert>
  </p:viewport>

  <!-- Create the report (in SML): -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-create-component-overview-report/process-directory-overview.xsl"/>
  </p:xslt>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-create-component-overview-report/create-sml-report.xsl"/>
  </p:xslt>

  <!-- Write it: -->
  <ci:write-sml-report name="write-sml-report">
    <p:with-option name="href-dir-result" select="$href-dir-result"/>
    <p:with-option name="filename" select="$filename"/>
    <p:with-option name="report-output-types" select="$report-output-types"/>
    <p:with-option name="message-indent-level" select="$message-indent-level"/>
    <p:with-option name="messages-enabled" select="$messages-enabled"/>
  </ci:write-sml-report>

  <!-- Final XML report thingie: -->
  <p:identity depends="write-sml-report">
    <p:with-input>
      <create-component-overview-report/>
    </p:with-input>
  </p:identity>
  <p:set-attributes match="/*">
    <p:with-option name="attributes" select="map{
      'timestamp': $timestamp-start,
      'href-component-specification': $base-uri,
      'duration': string(current-dateTime() - $timestamp-start),
      'href-dir': $href-dir-result,
      'filename': $filename,
      'report-output-types': string-join($report-output-types, ' ')
    }"/>
  </p:set-attributes>

</p:declare-step>

<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.flf_2tl_whc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:sml="http://www.eriksiegel.nl/ns/sml"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" version="3.0" exclude-inline-prefixes="#all" name="create-website" type="ci:create-website">

  <p:documentation>
    This pipeline creates the main component-inventory website.
  </p:documentation>

  <!-- ======================================================================= -->

  <p:import href="normalize-component-inventory-specification.xpl"/>
  <p:import href="create-normalized-component-inventory-specification-report.xpl"/>
  <p:import href="normalized-component-inventory-specification-to-website.xpl"/>

  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/message/message.xpl"/>

  <!-- ======================================================================= -->

  <p:option static="true" name="debug-output" as="xs:boolean" select="false()"/>

  <!-- ======================================================================= -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="../src/ci-specification.xml">
    <p:documentation>The main component-inventory specification document to process.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small report document.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->

  <p:option name="href-build-location" as="xs:string" required="false" select="resolve-uri('../docs', static-base-uri())">
    <p:documentation>The location where the website is built.</p:documentation>
  </p:option>

  <p:option name="href-report-location" as="xs:string" required="false" select="resolve-uri('../build', static-base-uri())">
    <p:documentation>The location where the report is written. The normalized version  of the specification is written there also.</p:documentation>
  </p:option>

  <p:option name="report-name" as="xs:string" required="false" select="'component-inventory-report'">
    <p:documentation>The filename (no extension) for the report.</p:documentation>
  </p:option>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Setup: -->
  <p:variable name="timestamp-start" as="xs:dateTime" select="current-dateTime()"/>
  <xtlc:message>
    <p:with-option name="text" select="'Creating component-inventory website in &quot;' || $href-build-location || '&quot;'"/>
  </xtlc:message>

  <!-- Normalize the definitions: -->
  <ci:normalize-component-inventory-specification message-indent-level="1" name="normalized-specification"/>
  <p:store href="{$href-report-location}/component-inventory-specification-normalized.xml"/>

  <!-- Create a report: -->
  <ci:create-normalized-component-inventory-specification-report message-indent-level="1">
    <p:with-option name="filename" select="$report-name"/>
    <p:with-option name="href-dir-result" select="$href-report-location"/>
    <p:with-option name="report-type" select="$ci:report-type-full"/>
    <p:with-option name="report-output-types" select="($ci:report-output-type-html, $ci:report-output-type-md)"/>
  </ci:create-normalized-component-inventory-specification-report>

  <!-- If there are no errors, create the website: -->
  <p:variable name="error-count" as="xs:integer" select="xs:integer(/*/@error-count)"/>
  <p:choose>
    <p:when test="$error-count eq 0">
      <ci:normalized-component-inventory-specification-to-website message-indent-level="1">
        <p:with-option name="href-build-location" select="$href-build-location"/>
      </ci:normalized-component-inventory-specification-to-website>
    </p:when>
    <p:otherwise>
      <xtlc:message>
        <p:with-option name="text" select="$error-count || ' errors found, website creation aborted'"/>
      </xtlc:message>
    </p:otherwise>
  </p:choose>

  <!-- Finalize the report: -->
  <p:delete match="/*/node()"/>
  <p:namespace-delete prefixes="sml"/>
  <p:delete match="/*/@xml:base"/>
  <p:rename match="/*" new-name="create-website-result"/>
  <p:variable name="duration" as="xs:dayTimeDuration" select="current-dateTime() - $timestamp-start"/>
  <p:set-attributes>
    <p:with-option name="attributes" select="map{
      'timestamp': xs:string($timestamp-start),
      'duration': xs:string($duration)
    }"/>
  </p:set-attributes>

  <p:variable name="duration-prittyfied" as="xs:string" select="string($duration) => translate('TP', '  ') => lower-case() => normalize-space()"/>
  <xtlc:message>
    <p:with-option name="text" select="'Component-inventory website built in ' || $duration-prittyfied"/>
  </xtlc:message>
</p:declare-step>

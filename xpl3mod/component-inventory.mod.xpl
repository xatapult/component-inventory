<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.dz4_c42_g3c"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  version="3.0" exclude-inline-prefixes="#all">

  <p:documentation>
    Library with several constants (static options) and pipelines for 
    general use within component-inventory.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- GENERAL IMPORTS: -->

  <p:import-functions href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl" />
  
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/message/message.xpl"/>

  <!-- ================================================================== -->
  <!-- GENERAL CONSTANTS (STATIC OPTIONS): -->

  <!-- Report output types: -->
  <p:option static="true" name="ci:report-output-type-html" as="xs:string" select="'html'" visibility="public"/>
  <p:option static="true" name="ci:report-output-type-md" as="xs:string" select="'md'" visibility="public"/>

  <!-- Others: -->
  <p:option static="true" name="ci:empty-map" as="map(*)" select="map{}" visibility="public"/>

  <!-- ======================================================================= -->

  <p:declare-step type="ci:write-sml-report" name="write-sml-report" visibility="public">
    
    <p:documentation>Takes an SML report as input and converts it to Markdown and/or HTML.</p:documentation>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <p:import href="file:/xatapult/xtpxlib-sml/xpl3/sml-prepare.xpl"/>
    <p:import href="file:/xatapult/xtpxlib-sml/xpl3/prepared-sml-to-html.xpl"/>
    <p:import href="file:/xatapult/xtpxlib-sml/xpl3/prepared-sml-to-markdown.xpl"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <p:input port="source" primary="true" sequence="false" content-types="xml" >
      <p:documentation>The SML report.</p:documentation>
    </p:input>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <p:option name="href-dir-result" as="xs:string" required="true">
      <p:documentation>The directory where to write the result.</p:documentation>
    </p:option>
    
    <p:option name="filename" as="xs:string" required="true">
      <p:documentation>The filename of the result (the extension is determined by the report type).</p:documentation>
    </p:option>
   
    <p:option name="add-toc" as="xs:boolean" required="false" select="true()">
      <p:documentation>Whether or not to add a TOC to the report.</p:documentation>
    </p:option>
    
    <p:option name="report-output-types" as="xs:string+" required="false" select="($ci:report-output-type-html, $ci:report-output-type-md)">
      <p:documentation>One or more report output type names (see the static options $report-type-*).</p:documentation>
    </p:option>
    
    <p:option name="message-indent-level" as="xs:integer" required="false" select="1">
      <p:documentation>The (starting) indent level for any console messages.</p:documentation>
    </p:option>
    
    <p:option name="messages-enabled" as="xs:boolean" required="false" select="true()">
      <p:documentation>Whether or not console messages are enabled.</p:documentation>
    </p:option>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <!-- Prepare the SML: -->
    <sml:sml-prepare>
      <p:with-option name="href-dir-result" select="$href-dir-result"/>
    </sml:sml-prepare>
    <p:set-properties>
      <p:with-option name="properties" select="map{'serialization': $ci:empty-map}"/>
    </p:set-properties>
    <p:identity name="prepared-sml"/>
    
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
    
  </p:declare-step>

</p:library>

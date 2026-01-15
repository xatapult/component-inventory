<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.flf_2tl_whc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" version="3.0" exclude-inline-prefixes="#all"
  name="normalized-component-inventory-specification-to-website" type="ci:normalized-component-inventory-specification-to-website">

  <p:documentation>
    Takes a normalized component-inventory specification and turns this into
    the website.
  </p:documentation>

  <!-- ======================================================================= -->

  <p:import-functions href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>
  
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/message/message.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/create-clear-directory/create-clear-directory.xpl"/>

  <!-- ======================================================================= -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="../test/test-specification.xml">
    <p:documentation>The normalized component-inventory specification document to process.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>A small report XML.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  
  <p:option name="href-build-location" as="xs:string" required="false" select="resolve-uri('../build/website', static-base-uri())">
    <p:documentation>The location where the website is built.</p:documentation>
  </p:option>
  
  <p:option name="href-web-resources" as="xs:string" required="false" select="resolve-uri('../resources/web', static-base-uri())">
    <p:documentation>Directory with web-resources (like CSS, JavaScript, etc.). All sub-directories underneath this directory are 
      copied verbatim to the build location.</p:documentation>
  </p:option>
  
  <p:option name="href-web-template" as="xs:string" required="false" select="resolve-uri('../templates/web/default-template.html', static-base-uri())">
    <p:documentation>URI of the web template used to build the pages.</p:documentation>
  </p:option>
  
  <p:option name="process-with-warnings" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether to process this specification if it contains any warnings.</p:documentation>
  </p:option>
  
  <p:option name="message-indent-level" as="xs:integer" required="false" select="0">
    <p:documentation>The (starting) indent level for any console messages.</p:documentation>
  </p:option>

  <p:option name="messages-enabled" as="xs:boolean" required="false" select="true()">
    <p:documentation>Whether or not console messages are enabled.</p:documentation>
  </p:option>
  
  <!-- ======================================================================= -->
  
  <p:declare-step type="local:copy-web-resources" name="copy-web-resources">
    <!-- Copies the web resources to the appropriate location on the website. Acts as an identity step. -->
    
    <p:import href="../../xtpxlib-common/xpl3mod/subdir-list/subdir-list.xpl"/>
    <p:import href="../../xtpxlib-common/xpl3mod/copy-dir/copy-dir.xpl"/>
    
    <p:input port="source" primary="true" sequence="true" content-types="any"/>
    <p:output port="result" primary="true" sequence="true" content-types="any" pipe="source@copy-web-resources"/>
    
    <p:option name="href-web-resources" as="xs:string" required="true"/>
    <p:option name="href-build-location" as="xs:string" required="true"/>
    
    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    
    <xtlc:subdir-list path="{$href-web-resources}"/>
    <p:for-each>
      <p:with-input select="/*/subdir"/>
      <p:variable name="source-dir" as="xs:string" select="/*/@href"/>
      <p:variable name="target-dir" as="xs:string" select="string-join(($href-build-location, /*/@name), '/')"/>
      <xtlc:copy-dir href-source="{$source-dir}" href-target="{$target-dir}"/>
    </p:for-each>
    
  </p:declare-step>
  
  
  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Setup: -->
  <p:variable name="timestamp-start" as="xs:dateTime" select="current-dateTime()"/>

  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level}">
    <p:with-option name="text" select="'Creating component-inventory website'"/>
  </xtlc:message>
  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
    <p:with-option name="text" select="'Location: &quot;' || $href-build-location || '&quot;'"/>
  </xtlc:message>
  
  <!-- Pre-flight checks: -->
  <p:if test="empty(/*/self::ci:component-inventory-specification) or empty(/*/@duration-normalization)">
    <p:error code="ci:error">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">Source is not a normalized component-inventory specification</p:inline>
      </p:with-input>
    </p:error>
  </p:if>
  
  <p:variable name="error-count" as="xs:integer" select="xs:integer(/*/@error-count)"/>
  <p:if test="$error-count gt 0">
    <p:error code="ci:error">
      <p:with-input>
        <p:inline content-type="text/plain" xml:space="preserve">Specification contains {$error-count} error(s)</p:inline>
      </p:with-input>
    </p:error>
  </p:if>
  
  <p:variable name="warning-count" as="xs:integer" select="xs:integer(/*/@warning-count)"/>
  <p:if test="$warning-count gt 0">
    <p:choose>
      <p:when test="$process-with-warnings">
        <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
          <p:with-option name="text" select="'Warning: specification contains ' || $warning-count || ' warning(s)'"/>
        </xtlc:message>
      </p:when>
      <p:otherwise>
        <p:error code="ci:error">
          <p:with-input>
            <p:inline content-type="text/plain" xml:space="preserve">Specification contains {$warning-count} warnings</p:inline>
          </p:with-input>
        </p:error>
      </p:otherwise>
    </p:choose>
  </p:if>
  
  <!-- Clean the result directory and copy the web resources to it: -->
  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
    <p:with-option name="text" select="'Clearing result directory and copying web resources'"/>
  </xtlc:message>
  <xtlc:create-clear-directory clear="true">
    <p:with-option name="href-dir" select="$href-build-location"/>
  </xtlc:create-clear-directory>
  <local:copy-web-resources >
    <p:with-option name="href-web-resources" select="$href-web-resources"/>
    <p:with-option name="href-build-location" select="$href-build-location"/>
  </local:copy-web-resources>
  
</p:declare-step>

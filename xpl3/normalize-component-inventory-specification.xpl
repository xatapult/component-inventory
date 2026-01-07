<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.flf_2tl_whc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" version="3.0" exclude-inline-prefixes="#all"
  name="normalize-component-inventory-specification">

  <p:documentation>
    This pipeline normalizes a component inventory specification. That means:
    * Validates any input documents
    * Makes all URIs absolute using appropriate default locations.
    * Inserts and finalizes all the component information.
    * Checks the result for problems (double identifiers, invalid references, etc.) 
    
    The result is one big document with all information included.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import-functions href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/validate/validate.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/recursive-directory-list/recursive-directory-list.xpl"/>

  <!-- ======================================================================= -->
  <!-- STATIC OPTIONS: -->

  <p:option static="true" name="href-schema-specification" as="xs:string"
    select="resolve-uri('../grammar/ci-specification.xsd', static-base-uri()) => xtlc:href-canonical()"/>
  <p:option static="true" name="href-schematron-specification" as="xs:string"
    select="resolve-uri('../grammar/ci-specification.sch', static-base-uri()) => xtlc:href-canonical()"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="../test/test-specification.xml">
    <p:documentation>The component inventory specification document to process.</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting normalized components definition document.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->



  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Setup: -->
  <p:variable name="base-uri" as="xs:string" select="base-uri(/) => xtlc:href-canonical()"/>

  <!-- First check whether our input is ok: -->
  <xtlc:validate simplify-error-messages="false">
    <p:with-option name="href-schema" select="$href-schema-specification"/>
    <p:with-option name="href-schematron" select="$href-schematron-specification"/>
  </xtlc:validate>

  <!-- Remove all Schema references (these are only in the way later): -->
  <p:delete match="@xsi:*"/>
  <p:namespace-delete prefixes="xsi"/>
  <p:delete match="processing-instruction(xml-model)"/>

  <!-- Flatten the category list: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-normalize-component-inventory-specification/flatten-categories.xsl"/>
  </p:xslt>
  
  <!-- Get the directory information on-board for the components: -->
  <p:viewport match="ci:components/ci:directory" name="get-directory-information">
    <p:variable name="href-directory" as="xs:string" select="resolve-uri(/*/@href, $base-uri)"/>
    <xtlc:recursive-directory-list name="directory-information">
      <p:with-option name="path" select="$href-directory"/>
    </xtlc:recursive-directory-list>
    <p:insert position="first-child">
      <p:with-input pipe="current@get-directory-information"/>
      <p:with-input port="insertion" pipe="@directory-information"/>
    </p:insert>
  </p:viewport>
  
  <!-- Process this information into full component specifications: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-normalize-component-inventory-specification/create-component-descriptions.xsl"/>
  </p:xslt>
  
  <!-- And now check all the component specifications: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-normalize-component-inventory-specification/check-component-descriptions.xsl"/>
  </p:xslt>
  
  

</p:declare-step>

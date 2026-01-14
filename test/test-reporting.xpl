<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.i44_cpq_yhc"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" version="3.0" exclude-inline-prefixes="#all" name="test-reporting">

  <!-- ======================================================================= -->

  <p:import href="../xpl3/normalize-component-inventory-specification.xpl"/>
  <p:import href="../xpl3/create-normalized-component-inventory-specification-report.xpl"/>

  <!-- ======================================================================= -->

  <p:input port="source" primary="true" sequence="false" content-types="xml" href="test-specification.xml"/>
  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:inline>
      <report/>
    </p:inline>
  </p:output>

  <!-- ======================================================================= -->

  <ci:normalize-component-inventory-specification/>
  
  <ci:create-normalized-component-inventory-specification-report>
    <p:with-option name="href-dir-result" select="resolve-uri('tmp', static-base-uri())"/>
    <p:with-option name="filename" select="'test-specification-report'"/>
    <p:with-option name="report-type" select="'full'"/>
    <p:with-option name="report-output-types" select="('html', 'md')"/>
  </ci:create-normalized-component-inventory-specification-report>

</p:declare-step>

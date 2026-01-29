<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.kbv_cdx_c3c" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:xtlxo="http://www.xtpxlib.nl/ns/xoffice" version="3.0" exclude-inline-prefixes="#all"
  name="import-inventory-spreadsheet">
  <!-- ======================================================================= -->
  <!--
    Support pipeline to do a (one-time) import of the original spreadsheet with component information    
  -->
  <!-- ======================================================================= -->

  <p:import href="file:/xatapult/xtpxlib-xoffice/xpl3/xlsx-to-xml.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/subdir-list/subdir-list.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-container/xpl3mod/container-to-disk/container-to-disk.xpl"></p:import>

  <!-- ======================================================================= -->

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}"/>

  <!-- ======================================================================= -->

  <p:option name="href-spreadsheet" as="xs:string" required="false" select="resolve-uri('inventory.xlsx', static-base-uri())"/>

  <p:option name="href-target-dir" as="xs:string" required="false" select="resolve-uri('../src/components', static-base-uri())"/>

  <!-- ======================================================================= -->

  <!-- Get the contents of the spreadsheet: -->
  <xtlxo:xlsx-to-xml name="spreadsheet-contents">
    <p:with-option name="xlsx-href" select="$href-spreadsheet"/>
  </xtlxo:xlsx-to-xml>

  <!-- Get a list with sub-directories of the target (those should be the ids in the spreadsheet...) -->
  <xtlc:subdir-list name="component-subdirs">
    <p:with-option name="path" select="$href-target-dir"/>
  </xtlc:subdir-list>

  <!-- Combine these two: -->
  <p:insert position="first-child" match="/*">
    <p:with-input>
      <import-inventory-spreadsheet/>
    </p:with-input>
    <p:with-input port="insertion" pipe="@spreadsheet-contents @component-subdirs"/>
  </p:insert>
  
  <!-- Turn everything in an output container: -->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-import-inventory-spreadsheet/create-component-description-container.xsl"/>
    <p:with-option name="parameters" select="map{'href-target-dir': $href-target-dir }"/>
  </p:xslt>
  
  <!-- And write it to disk: -->
  <xtlcon:container-to-disk remove-target="false"/>

</p:declare-step>

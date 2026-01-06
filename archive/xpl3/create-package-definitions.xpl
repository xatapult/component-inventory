<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.bnq_zfc_rdc"
  xmlns:xtlc="http://www.xtpxlib.nl/ns/common" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" version="3.0" exclude-inline-prefixes="#all"
  name="create-package-definitions">

  <p:documentation>
    Takes a directory with package images and creates the appropriate package-definition entries for the document-inventory.
    Meant to be fired by a ci:generate element.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The ci:generate element that fired this pipeline.</p:documentation>
    <p:inline>
      <ci:generate href-pipeline="{static-base-uri()}" href-dir-package-images="{resolve-uri('../resources/packaging/', static-base-uri())}"
        extensions="jpg svg png"/>
    </p:inline>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>The resulting package definitions, wrapped in a ci:group element.</p:documentation>
  </p:output>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <!-- Get all the files: -->
  <p:variable name="extensions-raw" as="xs:string?" select="normalize-space(/*/@extensions)"/>
  <p:variable name="extensions" as="xs:string+" select="if ($extensions-raw eq '') then 'jpg' else (tokenize($extensions-raw, '\s+')[.])"/>
  <p:variable name="extension-regexps" as="xs:string+" select="for $e in $extensions return ('\.' || $e || '$')"/>
  <p:directory-list max-depth="unbounded">
    <p:with-option name="path" select="string(/*/@href-dir-package-images)"/>
    <p:with-option name="include-filter" select="$extension-regexps"/>
  </p:directory-list>
  <p:make-absolute-uris match="c:file/@name"/>

  <p:for-each>
    <p:with-input select="//c:file"/>

    <p:variable name="href-resource" as="xs:string" select="string(/*/@name)"/>
    <p:variable name="name-resource" as="xs:string" select="replace($href-resource, '.*[/\\]([^/\\]+)$', '$1')"/>
    <p:variable name="name-resource-noext" as="xs:string" select="replace($name-resource, '\.[^\.]+$', '')"/>

    <p:identity>
      <p:with-input>
        <ci:package-definition id="{$name-resource-noext}">
          <ci:resource href="{$href-resource}" type="image"/>
        </ci:package-definition>
      </p:with-input>
    </p:identity>

  </p:for-each>
  <p:wrap-sequence wrapper="ci:group"/>

</p:declare-step>

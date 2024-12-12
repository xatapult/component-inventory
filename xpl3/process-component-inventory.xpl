<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.y4s_1jd_5bc"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xpref="http://www.xtpxlib.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:db="http://docbook.org/ns/docbook" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xdoc="http://www.xtpxlib.nl/ns/xdoc" version="3.0"
  exclude-inline-prefixes="#all" name="process-component-inventory" type="xpref:process-component-inventory">

  <p:documentation>
    TBD 
    Processes an component-inventory specification into a website.
  </p:documentation>

  <!-- ======================================================================= -->
  <!-- IMPORTS: -->

  <p:import href="../../xtpxlib-common/xpl3mod/validate/validate.xpl"/>
  <p:import href="../../xtpxlib-common/xpl3mod/expand-macro-definitions/expand-macro-definitions.xpl"/>
  <p:import href="../../xtpxlib-common/xpl3mod/create-clear-directory/create-clear-directory.xpl"/>

  <p:import href="../../xtpxlib-xdoc/xpl3/xdoc-to-xhtml.xpl"/>
  <p:import href="../../xtpxlib-xdoc/xpl3/docbook-to-xhtml.xpl"/>

  <p:import href="../../xtpxlib-container/xpl3mod/container-to-disk/container-to-disk.xpl"/>

  <p:import href="../../xtpxlib-xdoc/xpl3mod/xtpxlib-xdoc.mod/xtpxlib-xdoc.mod.xpl"/>

  <!-- ======================================================================= -->
  <!-- PORTS: -->

  <p:input port="source" primary="true" sequence="false" content-types="xml">
    <p:documentation>The main component-inventory specification to process</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="false" content-types="xml" serialization="map{'method': 'xml', 'indent': true()}">
    <p:documentation>Some report thingie.</p:documentation>
  </p:output>

  <!-- ======================================================================= -->
  <!-- DEBUG SETTINGS -->

  <p:option static="true" name="write-intermediate-results" as="xs:boolean" required="false" select="true()"/>
  <p:option static="true" name="href-intermediate-results" as="xs:string" required="false" select="resolve-uri('../tmp', static-base-uri())"/>

  <!-- ======================================================================= -->
  <!-- OPTIONS: -->

  <p:option name="href-build-location" as="xs:string" required="false" select="resolve-uri('../build', static-base-uri())">
    <p:documentation>The location where the website is built.</p:documentation>
  </p:option>

  <p:option name="href-web-resources" as="xs:string" required="false" select="resolve-uri('../web-resources', static-base-uri())">
    <p:documentation>Directory with web-resources (like CSS, JavaScript, etc.). All sub-directories underneath this directory are 
      copied verbatim to the build location.</p:documentation>
  </p:option>

  <p:option name="href-web-template" as="xs:string" required="false" select="resolve-uri('../web-templates/default-template.html', static-base-uri())">
    <p:documentation>URI of the web template used to build the pages.</p:documentation>
  </p:option>

  <p:option name="cname" as="xs:string?" required="false" select="'component-inventory.org'">
    <p:documentation>The URI under which the pages are published (for GitHub pages). If empty no CNAME entry is created.</p:documentation>
  </p:option>

  <!-- ======================================================================= -->
  <!-- SUBSTEPS: -->

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

  <!-- ======================================================================= -->
  <!-- GLOBAL SETTINGS: -->

  <p:variable name="component-inventory-base-uri" as="xs:string" select="base-uri(/)"/>

  <p:variable name="href-component-inventory-schema" as="xs:string" select="resolve-uri('../xsd/component-inventory.xsd', static-base-uri())"/>
  <p:variable name="href-component-inventory-schematron" as="xs:string" select="resolve-uri('../sch/component-inventory.sch', static-base-uri())"/>

  <!-- ================================================================== -->
  <!-- MAIN: -->

  <p:variable name="start-timestamp" as="xs:dateTime" select="current-dateTime()"/>

  <p:identity message="* component-inventory processing ({$type-string})"/>
  <p:identity message="  * Source document: {$component-inventory-base-uri}"/>
  <p:identity message="  * Build location: {$href-build-location}"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Preparations: -->

  <!-- Process any XIncludes and record the original base URIs: -->
  <p:xinclude/>
  <p:add-xml-base relative="false"/>

  <!-- Delete schema references (annoying, since they are no longer valid): -->
  <p:delete match="@xsi:*"/>
  <p:namespace-delete prefixes="xsi"/>
  <p:delete match="processing-instruction(xml-model)"/>

  <!-- Validate: -->
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/10-component-inventory-after-xinclude.xml"/>
  <xtlc:validate simplify-error-messages="true" p:message="  * Validating primary source">
    <p:with-option name="href-schema" select="$href-component-inventory-schema"/>
    <p:with-option name="href-schematron" select="$href-component-inventory-schematron"/>
  </xtlc:validate>

  <!-- Expand any macros: -->
  <xtlc:expand-macro-definitions/>
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/30-component-inventory-after-expand-macro-definitions.xml"/>

  <!-- Just to be sure, re-validate -->
  <xtlc:validate simplify-error-messages="true">
    <p:with-option name="href-schema" select="$href-component-inventory-schema"/>
    <p:with-option name="href-schematron" select="$href-component-inventory-schematron"/>
  </xtlc:validate>

  <!-- Prepare some attributes and unwrap the step-groups: -->
  <!--<p:unwrap match="xpref:step-group"/>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-component-inventory/prepare-component-inventory-specification.xsl"/>
  </p:xslt>

  <!-\- Remove the unpublished steps when creating a production version: -\->
  <p:variable name="step-count-1" as="xs:integer" select="count(/*/xpref:steps/xpref:step)"/>
  <p:if test="exists($limit-to-steps)">
    <p:delete match="xpref:steps/xpref:step[not(xs:string(@name) = {$limit-to-steps-sequence})]"
      message="  * WARNING: Limiting to steps: {$limit-to-steps-sequence}"/>
  </p:if>
  <p:if test="$production-version">
    <p:delete match="xpref:steps/xpref:step[not(xs:boolean((@publish, false())[1]))]"/>
  </p:if>
  <p:variable name="step-count-2" as="xs:integer" select="count(/*/xpref:steps/xpref:step)"/>
  <p:if test="$step-count-2 lt 1">
    <p:error code="xpref:error">
      <p:with-input>
        <p:inline content-type="text/plain">No steps to publish (production-version={$production-version};
          limit-to-steps=({string-join($limit-to-steps, ', ')}))</p:inline>
      </p:with-input>
    </p:error>
  </p:if>
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/40-component-inventory-prepared.xml"/>
  <p:identity name="prepared-component-inventory-specification" message="  * Step count: {$step-count-2}/{$step-count-1}"/>-->

  <!-- Clean the result directory: -->
  <xtlc:create-clear-directory clear="true">
    <p:with-option name="href-dir" select="$href-build-location"/>
  </xtlc:create-clear-directory>

  <!-- Copy the web resources: -->
  <local:copy-web-resources p:message="  * Copying web resources">
    <p:with-option name="href-web-resources" select="$href-web-resources"/>
    <p:with-option name="href-build-location" select="$href-build-location"/>
  </local:copy-web-resources>

  <!-- Create a CNAME document (for the GitHub pages): -->
  <p:if test="$production-version and exists($cname)">
    <p:store href="{$href-build-location}/CNAME" serialization="map{'method': 'text'}" message="  * Creating CNAME ({$cname})">
      <p:with-input>
        <p:inline xml:space="preserve" content-type="text/plain">{$cname}</p:inline>
      </p:with-input>
    </p:store>
  </p:if>

  <!-- Create an index document: -->
  <!--<p:xslt>
    <p:with-input pipe="@prepared-component-inventory-specification"/>
    <p:with-input port="stylesheet" href="xsl-process-component-inventory/create-component-inventory-index.xsl"/>
  </p:xslt>
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/50-component-inventory-index.xml"/>
  <p:variable name="component-inventory-index" as="document-node()" select="."/>
-->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Create container: -->

 <!-- <!-\- Create a container (all text still in DocBook/Markdown): -\->
  <p:xslt message="  * Creating pages">
    <p:with-input pipe="@prepared-component-inventory-specification"/>
    <p:with-input port="stylesheet" href="xsl-process-component-inventory/create-component-inventory-container.xsl"/>
    <p:with-option name="parameters" select="map{'component-inventory-index': $component-inventory-index, 'production-version': $production-version, 'wip': $wip}"/>
  </p:xslt>

  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-component-inventory/fixup-texts.xsl"/>
  </p:xslt>

  <!-\- Process any Markdown (into DocBook): -\->
  <xdoc:markdown-to-docbook p:message="  * Finalizing pages"/>

  <!-\- Add a ToC to the steps: -\->
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-component-inventory/add-toc-to-steps.xsl"/>
  </p:xslt>

  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/60-component-inventory-raw-container-docbook.xml"/>

  <!-\- Process the resulting DocBook/xdoc into XHTML: -\->
  <p:variable name="html-page-count" as="xs:integer" select="count(/*/xtlcon:document[exists(db:article)])"/>
  <p:viewport match="xtlcon:document[exists(db:article)]" message="  * Converting {$html-page-count} pages to HTML">
    <p:if test="(p:iteration-position() mod 10) eq 0">
      <p:identity message="    * Page {p:iteration-position()}/{$html-page-count}"/>
    </p:if>
    <p:variable name="href-target" as="xs:string" select="xs:string(/*/@href-target)"/>
    <p:viewport match="db:article[1]">
      <xdoc:xdoc-to-xhtml add-numbering="false" add-identifiers="false" create-header="false"/>
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-process-component-inventory/xhtml-to-page.xsl"/>
        <p:with-option name="parameters"
          select="map{'href-template': $href-web-template, 'href-target': $href-target, 'component-inventory-index': $component-inventory-index}"/>
      </p:xslt>
      <p:xslt>
        <p:with-input port="stylesheet" href="xsl-process-component-inventory/convert-menu.xsl"/>
      </p:xslt>
    </p:viewport>
  </p:viewport>
  <p:store use-when="$write-intermediate-results" href="{$href-intermediate-results}/70-component-inventory-final-container-html.xml"/>-->

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Finishing: -->

  <!-- Check for any markup errors and report these: -->
 <!-- <p:xslt>
    <p:with-input port="stylesheet" href="xsl-process-component-inventory/check-for-markup-errors.xsl"/>
  </p:xslt>

  <!-\- Write the container to disk: -\->
  <xtlcon:container-to-disk remove-target="false" p:message="  * Writing to target">
    <p:with-option name="href-target-path" select="$href-build-location"/>
  </xtlcon:container-to-disk>

  <p:variable name="duration" as="xs:string"
    select="string(current-dateTime() - $start-timestamp) => replace('P', '') => replace('T', ' ') => normalize-space() => lower-case()"/>
  <p:identity message="* component-inventory processing done ({$type-string}; {$step-count-2}/{$step-count-1}) ({$duration})"/>-->

</p:declare-step>

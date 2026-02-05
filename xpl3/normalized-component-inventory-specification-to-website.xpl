<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.flf_2tl_whc"
  xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" version="3.0" exclude-inline-prefixes="#all" xmlns:sml="http://www.eriksiegel.nl/ns/sml"
  name="normalized-component-inventory-specification-to-website" type="ci:normalized-component-inventory-specification-to-website">

  <p:documentation>
    Takes a normalized component-inventory specification and turns this into
    the website.
  </p:documentation>

  <!-- ======================================================================= -->

  <p:import-functions href="file:/xatapult/xtpxlib-common/xslmod/href.mod.xsl"/>

  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/message/message.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/create-clear-directory/create-clear-directory.xpl"/>
  <p:import href="file:/xatapult/xtpxlib-common/xpl3mod/copy-dir/copy-dir.xpl"/>

  <p:import href="file:/xatapult/xtpxlib-container/xpl3mod/container-to-disk/container-to-disk.xpl"/>

  <p:import href="file:/xatapult/xtpxlib-sml/xpl3/sml-to-html.xpl"/>

  <!-- ======================================================================= -->

  <p:option static="true" name="debug-output" as="xs:boolean" select="false()"/>

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

  <p:option name="cname" as="xs:string?" required="false" select="'TBD'">
    <p:documentation>The CNAME as used for the GitHub pages.</p:documentation>
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

  <!-- Setup: -->
  <p:variable name="timestamp-start" as="xs:dateTime" select="current-dateTime()"/>

  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level}">
    <p:with-option name="text" select="'Creating component-inventory website'"/>
  </xtlc:message>
  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
    <p:with-option name="text" select="'Location: &quot;' || $href-build-location || '&quot;'"/>
  </xtlc:message>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
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
    <!-- Remove generated warnings, they might get in the way... -->
    <p:delete match="ci:warning"/>
  </p:if>

  <p:identity name="clean-specification"/>
  <p:store href="tmp/w-10-clean-specification.xml" use-when="$debug-output"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Preparations: -->

  <!-- Clean the result directory and copy the web resources to it: -->
  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
    <p:with-option name="text" select="'Clearing result directory and copying web resources'"/>
  </xtlc:message>
  <xtlc:create-clear-directory clear="true">
    <p:with-option name="href-dir" select="$href-build-location"/>
  </xtlc:create-clear-directory>
  <local:copy-web-resources>
    <p:with-option name="href-web-resources" select="$href-web-resources"/>
    <p:with-option name="href-build-location" select="$href-build-location"/>
  </local:copy-web-resources>

  <!-- Create a CNAME document (for the GitHub pages): -->
  <p:if test="exists($cname)">
    <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
      <p:with-option name="text" select="'CNAME: ' || $cname"/>
    </xtlc:message>
    <p:store serialization="map{'method': 'text'}">
      <p:with-input>
        <p:inline xml:space="preserve" content-type="text/plain">{$cname}</p:inline>
      </p:with-input>
      <p:with-option name="href" select="xtlc:href-concat(($href-build-location, 'CNAME'))"/>
    </p:store>
  </p:if>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Handle the SML documents: -->
  <!-- An SML document must be converted into HTML. The media element also needs to change (to <html>). -->

  <p:identity>
    <p:with-input pipe="@clean-specification"/>
  </p:identity>
  <p:variable name="sml-media-count" as="xs:integer" select="count(/*/*/*/ci:media/ci:sml)"/>
  <p:if test="$sml-media-count gt 0">
    <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
      <p:with-option name="text" select="'Converting ' || $sml-media-count || ' SML document(s) to HTML'"/>
    </xtlc:message>
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-normalized-component-inventory-specification-to-website/prepare-sml-conversion.xsl"/>
      <p:with-option name="parameters" select="map{'href-build-location': $href-build-location }"/>
    </p:xslt>
    <p:viewport match="ci:CONVERTSML">
      <p:variable name="href-source" as="xs:string" select="xs:string(/*/@href-source)"/>
      <p:variable name="href-target" as="xs:string" select="xs:string(/*/@href-target)"/>
      <sml:sml-to-html>
        <p:with-input port="source" href="{$href-source}"/>
      </sml:sml-to-html>
      <p:store href="{$href-target}"/>
      <p:identity>
        <p:with-input>
          <p:empty/>
        </p:with-input>
      </p:identity>
    </p:viewport>
  </p:if>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Handle the copying of any resource directories: -->

  <p:variable name="resource-directory-count" as="xs:integer" select="count(/*/*/*/ci:media/ci:resource-directory)"/>
  <p:if test="$resource-directory-count gt 0">
    <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
      <p:with-option name="text" select="'Copying ' || $resource-directory-count || ' resource directories'"/>
    </xtlc:message>
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-normalized-component-inventory-specification-to-website/prepare-resource-directory-copies.xsl"/>
      <p:with-option name="parameters" select="map{'href-build-location': $href-build-location }"/>
    </p:xslt>
    <p:viewport match="ci:resource-directory">
      <p:variable name="href-source" as="xs:string" select="xs:string(/*/@href)"/>
      <p:variable name="href-target" as="xs:string" select="xs:string(/*/@_href-target)"/>
      <xtlc:copy-dir>
        <p:with-option name="href-source" select="$href-source"/>
        <p:with-option name="href-target" select="$href-target"/>
      </xtlc:copy-dir>
    </p:viewport>
  </p:if>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- Create the website container: -->

  <!-- First make a container with documents for all pages. Fill in what we can. -->
  <p:variable name="item-type-count" as="xs:integer" select="count(/*/*)"/>
  <p:variable name="item-count" as="xs:integer" select="count(/*/*/*)"/>
  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
    <p:with-option name="text" select="'Creating base container for ' || $item-type-count || ' item-types containing ' || $item-count || ' items'"/>
  </xtlc:message>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-normalized-component-inventory-specification-to-website/create-base-container.xsl"/>
    <p:with-option name="parameters" select="map{'href-build-location': $href-build-location }"/>
  </p:xslt>
  <!-- Turn the SML that's still inside into HTML: -->
  <p:viewport match="sml:sml">
    <sml:sml-to-html do-validation="false">
      <p:with-option name="href-template" select="()"/>
      <p:with-option name="href-dir-result" select="xs:string(/*/@_href-dir-result)"/>
    </sml:sml-to-html>
  </p:viewport>
  <p:store href="tmp/w-20-base-container.xml" use-when="$debug-output"/>
  <!-- Turn the lists into HTML: -->
  <p:viewport match="ci:LIST">
    <p:xslt>
      <p:with-input port="stylesheet" href="xsl-normalized-component-inventory-specification-to-website/process-lists.xsl"/>
    </p:xslt>
  </p:viewport>
  <p:store href="tmp/w-25-base-container-lists-processed.xml" use-when="$debug-output"/>

  <!-- The container documents now contain complete body HTML. Turn this into pages: -->
  <p:variable name="page-count" as="xs:integer" select="count(/*/xtlcon:document)"/>
  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
    <p:with-option name="text" select="'Creating ' || $page-count || ' HTML pages'"/>
  </xtlc:message>
  <p:xslt>
    <p:with-input port="stylesheet" href="xsl-normalized-component-inventory-specification-to-website/create-pages.xsl"/>
    <p:with-option name="parameters" select="map{'href-web-template': $href-web-template}"/>
  </p:xslt>
  <p:store href="tmp/w-30-page-container.xml" use-when="$debug-output"/>

  <!-- Write it away! -->
  <xtlc:message enabled="{$messages-enabled}" level="{$message-indent-level + 1}">
    <p:with-option name="text" select="'Writing container to &quot;' || /*/@href-target-path || '&quot;'"/>
  </xtlc:message>
  <xtlcon:container-to-disk remove-target="false" name="write-container"/>

  <!-- Create a report: -->
  <p:group depends="write-container">
    <!-- We take the root element of the original input (with all its attributes) and add some of our own: -->
    <p:delete match="/*/node()">
      <p:with-input pipe="source@normalized-component-inventory-specification-to-website"/>
    </p:delete>
    <p:namespace-delete prefixes="sml"/>
    <p:set-attributes match="/*">
      <p:with-option name="attributes" select="map{
        'href-source': xs:string(/*/@xml:base) => xtlc:href-canonical(),
        'item-type-count': $item-type-count,
        'item-count': $item-count,
        'page-count': xs:string($page-count),
        'href-website-build': $href-build-location => xtlc:href-canonical(),
        'timestamp-website-build': xs:string($timestamp-start),
        'duration-website-build': xs:string(current-dateTime() - $timestamp-start)
      }"/>
    </p:set-attributes>
    <p:delete match="/*/@xml:base"/>
    <p:rename match="/*" new-name="component-inventory-website-build-result"/>
  </p:group>


</p:declare-step>

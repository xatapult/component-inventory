<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.hmp_vtr_whc"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:ci="https://eriksiegel.nl/ns/component-inventory" xmlns:sml="http://www.eriksiegel.nl/ns/sml"
  xmlns="https://eriksiegel.nl/ns/component-inventory" xmlns:xtlc="http://www.xtpxlib.nl/ns/common" exclude-result-prefixes="#all" expand-text="true">
  <!-- ================================================================== -->
  <!-- 
       Takes the directory information for the components and turns this into 
       component descriptions.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode name="mode-process-component-description" on-no-match="shallow-copy"/>

  <xsl:include href="../../xslmod/ci-normalization.mod.xsl"/>

  <!-- ================================================================== -->
  <!-- GLOBAL DECLARATIONS: -->

  <xsl:variable name="flattened-categories-element" as="element(ci:categories)?" select="/ci:component-inventory-specification/ci:categories">
    <!-- The (flattened!) categories root. -->
  </xsl:variable>

  <!-- ======================================================================= -->

  <xsl:template match="/ci:component-inventory-specification/ci:components/ci:directory">

    <xsl:variable name="component-description-document-regexp" as="xs:string"
      select="xs:string((@component-description-document-regexp, $ci:default-component-description-document-regexp)[1])"/>

    <!-- We have to do something with all directories that have a (possible) component description document: -->
    <xsl:apply-templates select=".//c:directory[exists(c:file[matches(@name, $component-description-document-regexp)])]">
      <xsl:with-param name="component-description-document-regexp" as="xs:string" select="$component-description-document-regexp" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:components/ci:directory//c:directory">
    <!-- This is a match on a directory containing a component description file. -->
    <xsl:param name="component-description-document-regexp" as="xs:string" required="true" tunnel="true"/>

    <xsl:variable name="default-id" as="xs:string" select="xs:string(@name)">
      <!-- The default identifier for a component is its directory name. -->
    </xsl:variable>
    <xsl:variable name="href-directory" as="xs:string" select="xtlc:href-concat(ancestor-or-self::c:directory/@xml:base) => xtlc:href-canonical()"/>
    <xsl:variable name="filename-component-document" as="xs:string"
      select="xs:string((c:file[matches(@name, $component-description-document-regexp)][1])/@name)"/>
    <xsl:variable name="href-component-document" as="xs:string" select="xtlc:href-concat(($href-directory, $filename-component-document))"/>

    <!-- Get the component description document in. This might be not well-formed or not a component description at all… -->
    <xsl:variable name="component-document" as="document-node()">
      <xsl:try>
        <xsl:variable name="component-document-raw" as="document-node()" select="doc($href-component-document)"/>
        <xsl:choose>
          <xsl:when test="exists($component-document-raw/ci:component)">
            <!-- Component description document well-formed and starts with the right root element. Assume it is ok, for now. -->
            <xsl:sequence select="$component-document-raw"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Something is wrong with the root element. Fix this and leave a warning. -->
            <xsl:document>
              <component id="{$default-id}">
                <xsl:attribute name="xml:base" select="$href-component-document"/>
                <error>Component description document "{$filename-component-document}" has an invalid root element</error>
              </component>
            </xsl:document>
          </xsl:otherwise>
        </xsl:choose>

        <!-- Catch any not well-formed document: -->
        <xsl:catch>
          <xsl:document>
            <component id="{$default-id}">
              <xsl:attribute name="xml:base" select="$href-component-document"/>
              <error>Component description document "{$filename-component-document}" not well-formed</error>
            </component>
          </xsl:document>
        </xsl:catch>

      </xsl:try>
    </xsl:variable>

    <!-- Now process the retrieved component description document (if there are no errors): -->
    <xsl:choose>
      <xsl:when test="exists($component-document//ci:error)">
        <!-- Errors, go no further: -->
        <xsl:copy-of select="$component-document" copy-namespaces="false"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$component-document" mode="mode-process-component-description">
          <xsl:with-param name="default-id" as="xs:string" select="$default-id" tunnel="true"/>
          <xsl:with-param name="href-component-document" as="xs:string" select="$href-component-document" tunnel="true"/>
          <xsl:with-param name="possible-media-files" as="element(c:file)*" select="c:file[xs:string(@name) ne $filename-component-document]"
            tunnel="true"/>
        </xsl:apply-templates>
      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>

  <!-- ======================================================================= -->

  <xsl:template match="/ci:component" mode="mode-process-component-description">
    <xsl:param name="default-id" as="xs:string" required="true" tunnel="true"/>
    <xsl:param name="href-component-document" as="xs:string" required="true" tunnel="true"/>
    <xsl:param name="possible-media-files" as="element(c:file)*" required="true" tunnel="true"/>

    <xsl:variable name="component-element" as="element(ci:component)" select="."/>
    <xsl:variable name="href-directory" as="xs:string" select="xtlc:href-path($href-component-document)"/>

    <!-- Copy the element and complete it: -->
    <xsl:copy copy-namespaces="false">
      <xsl:attribute name="xml:base" select="$href-component-document"/>

      <!-- Make sure all attributes for a component description are there, event when they're unknown: -->
      <xsl:call-template name="process-attribute">
        <xsl:with-param name="attribute-name" select="'id'"/>
        <xsl:with-param name="default" select="$default-id"/>
      </xsl:call-template>
      <xsl:call-template name="process-attribute">
        <xsl:with-param name="attribute-name" select="'name'"/>
        <xsl:with-param name="default" select="$default-id"/>
      </xsl:call-template>
      <xsl:call-template name="process-attribute">
        <xsl:with-param name="attribute-name" select="'summary'"/>
        <xsl:with-param name="default" select="ci:default-summary($component-element, $default-id)"/>
      </xsl:call-template>
      <xsl:call-template name="process-attribute">
        <xsl:with-param name="attribute-name" select="'partly-in-reserve-stock'"/>
        <xsl:with-param name="default" select="'false'"/>
      </xsl:call-template>
      <xsl:call-template name="process-attribute">
        <xsl:with-param name="attribute-name" select="'discontinued'"/>
        <xsl:with-param name="default" select="'false'"/>
      </xsl:call-template>
      
      <!-- Some attributes don't need any further processing: -->
      <xsl:sequence select="@keywords"/>

      <xsl:variable name="attributes-defaulting-to-unknown" as="xs:string+"
        select="('count', 'category-idrefs', 'price-range-idref', 'package-idref', 'location-idref', 'since')"/>
      <xsl:for-each select="$attributes-defaulting-to-unknown">
        <xsl:call-template name="process-attribute">
          <xsl:with-param name="elm" select="$component-element"/>
          <xsl:with-param name="attribute-name" select="."/>
        </xsl:call-template>
      </xsl:for-each>
      
      <!-- Handle the description (just copy...) -->
      <xsl:sequence select="ci:description"/>

      <!-- Handle the property values: -->
      <xsl:choose>
        <xsl:when test="exists($component-element/ci:property-values)">
          <!-- There is an existing property values element. Just copy it. Checking will be done later on in the processing pipeline: -->
          <xsl:apply-templates select="$component-element/ci:property-values" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- There are no existing property values. Create it for the mandatory properties, value unknown. -->
          <xsl:variable name="component-categories" as="xs:string*" select="xtlc:str2seq($component-element/@category-idrefs)"/>
          <xsl:variable name="mandatory-properties" as="xs:string*"
            select="distinct-values(for $c in $component-categories return xtlc:str2seq($flattened-categories-element/ci:category[xs:string(@id) eq $c]/@mandatory-property-idrefs))"/>
          <property-values _generated="true">
            <xsl:for-each select="$mandatory-properties">
              <property-value property-idref="{.}" value="{$ci:special-value-unknown}"/>
            </xsl:for-each>
          </property-values>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Now check the media: -->
      <xsl:choose>
        <xsl:when test="exists($component-element/ci:media)">
          <!-- There is an existing media element. Just copy it. Checking will be done later on in the processing pipeline: -->
          <xsl:apply-templates select="$component-element/ci:media" mode="#current">
            <xsl:with-param name="href-directory" select="$href-directory" tunnel="true"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <!-- No existing media information. Generate something from all the files in the directory: -->
          <xsl:where-populated>
            <media _generated="true" href-default-base-directory="{$href-directory}">
              <xsl:for-each select="$possible-media-files">
                <xsl:sort select="xs:string(@name)"/>
                <xsl:call-template name="ci:handle-media-file">
                  <xsl:with-param name="href-directory" select="$href-directory"/>
                  <xsl:with-param name="filename" select="xs:string(@name)"/>
                </xsl:call-template>
              </xsl:for-each>
            </media>
          </xsl:where-populated>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Don't forget any already generated warnings and errors: -->
      <xsl:apply-templates select="ci:warning | ci:error"/>

    </xsl:copy>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="ci:media" mode="mode-process-component-description">
    <!-- We're copying an existing media element. Check whether all files in the directory 
      are mentioned. If not, issue warnings.-->
    <xsl:param name="href-directory" as="xs:string" required="true" tunnel="true"/>
    <xsl:param name="possible-media-files" as="element(c:file)*" required="true" tunnel="true"/>

    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@* except @href-default-base-directory"/>

      <!-- Get the right base directory: -->
      <xsl:variable name="href-default-base-directory" as="xs:string">
        <xsl:choose>
          <xsl:when test="normalize-space(@href-default-base-directory) eq ''">
            <!-- No default base directory present, use the directory of the component: -->
            <xsl:sequence select="$href-directory"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Make sure the default base directory present is absolute: -->
            <xsl:sequence select="xtlc:href-concat(($href-directory, @href-default-base-directory)) => xtlc:href-canonical()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="href-default-base-directory" select="$href-default-base-directory"/>

      <!-- First copy all the children, making the hrefs absolute: -->
      <!-- Remark: We would also like to check here whether these files actually exist, but we can't do this in XSLT. 
        So we'll leave that for something outside this stylesheet. -->
      <xsl:for-each select="ci:*[exists(@href)]">
        <xsl:copy copy-namespaces="false">
          <xsl:apply-templates select="@* except @href"/>
          <xsl:attribute name="href" select="xtlc:href-concat(($href-default-base-directory, @href)) => xtlc:href-canonical()"/>
          <xsl:if test="empty(@usage)">
            <xsl:attribute name="usage" select="ci:defaul-media-usage-type(local-name(.))"/>
          </xsl:if>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:for-each>

      <!-- Now check whether all files in the base directory are mentioned: -->
      <xsl:variable name="hrefs-referenced-media" as="xs:string*"
        select="for $m in ci:* return (xtlc:href-concat(($href-default-base-directory, $m/@href)) => xtlc:href-canonical())"/>
      <xsl:for-each select="$possible-media-files">
        <xsl:variable name="media-filename" as="xs:string" select="xs:string(@name)"/>
        <xsl:variable name="href-media" as="xs:string" select="xtlc:href-concat(($href-directory, $media-filename))"/>
        <xsl:if test="not($href-media = $hrefs-referenced-media)">
          <warning>Possible media file "{$media-filename}" not referenced</warning>
        </xsl:if>
      </xsl:for-each>

    </xsl:copy>

  </xsl:template>


  <!-- ======================================================================= -->

  <xsl:template name="process-attribute">
    <!-- Check whether this attribute is present and filled. if not, create one with a default value. -->
    <xsl:param name="attribute-name" as="xs:string" required="true"/>
    <xsl:param name="elm" as="element()" required="false" select="."/>
    <xsl:param name="default" as="xs:string" required="false" select="$ci:special-value-unknown"/>

    <xsl:variable name="attr" as="attribute()?" select="$elm/@*[local-name() eq $attribute-name]"/>
    <xsl:choose>
      <xsl:when test="normalize-space($attr) eq ''">
        <xsl:attribute name="{$attribute-name}" select="$default"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$attr"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>

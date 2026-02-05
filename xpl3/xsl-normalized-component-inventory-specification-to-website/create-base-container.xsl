<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="#local.ds2_tbz_yhc"
  xmlns:sml="http://www.eriksiegel.nl/ns/sml" xmlns:xtlcon="http://www.xtpxlib.nl/ns/container" xmlns:xtlc="http://www.xtpxlib.nl/ns/common"
  xmlns:ci="https://eriksiegel.nl/ns/component-inventory" exclude-result-prefixes="#all" expand-text="true" xmlns="http://www.w3.org/1999/xhtml">
  <!-- ================================================================== -->
  <!-- 
       Creates a container with stubs for all the pages we have to fill in,
       based on a (clean and normalized) component-inventory specification.
  -->
  <!-- ================================================================== -->
  <!-- SETUP: -->

  <xsl:output method="xml" indent="true" encoding="UTF-8"/>

  <xsl:mode on-no-match="fail"/>

  <xsl:include href="../../xslmod/ci-website-building.mod.xsl"/>

  <!-- ======================================================================= -->

  <xsl:param name="href-build-location" as="xs:string" required="true"/>

  <!-- ======================================================================= -->
  <!-- INDEXS: -->
  <!-- Important: the name of the index *must* be the item type name followed by $suffix-index! -->

  <xsl:variable name="suffix-index" as="xs:string" select="'-index'"/>

  <xsl:key name="property-index" match="/*/ci:properties/ci:property" use="@id"/>
  <xsl:key name="category-index" match="/*/ci:categories/ci:category" use="@id"/>
  <xsl:key name="price-range-index" match="/*/ci:price-ranges/ci:price-range" use="@id"/>
  <xsl:key name="package-index" match="/*/ci:packages/ci:package" use="@id"/>
  <xsl:key name="location-index" match="/*/ci:locations/ci:location" use="@id"/>

  <!-- ======================================================================= -->

  <!-- Various: -->
  <xsl:variable name="doc" as="document-node()" select="/"/>
  <xsl:variable name="components" as="element(ci:component)*" select="/*/ci:components/ci:component"/>
  <xsl:variable name="categories" as="element(ci:category)*" select="/*/ci:categories/ci:category"/>

  <xsl:variable name="extension-html" as="xs:string" select="'.html'"/>
  <xsl:variable name="namespace-sml" as="xs:string" select="namespace-uri-for-prefix('sml', doc('')/*)"/>

  <!-- Page levels: -->
  <xsl:variable name="page-level-main" as="xs:integer" select="0"/>
  <xsl:variable name="page-level-item-overview" as="xs:integer" select="1"/>
  <xsl:variable name="page-level-item" as="xs:integer" select="2"/>

  <!-- CSS classes used in creating the pages: -->
  <xsl:variable name="class-info-table" as="xs:string" select="'info'"/>
  <xsl:variable name="class-info-table-prompt-column" as="xs:string" select="'prompt'"/>
  <xsl:variable name="class-info-table-value-column" as="xs:string" select="'value'"/>
  <xsl:variable name="class-link-nomark" as="xs:string" select="'nomark'"/>
  <xsl:variable name="class-citooltip" as="xs:string" select="'citooltip'"/>
  <xsl:variable name="class-citooltiptext" as="xs:string" select="'citooltiptext'"/>
  <xsl:variable name="class-grey" as="xs:string" select="'grey'"/>

  <!-- Some constants necessary for creating the content about attribute names and values: -->
  <xsl:variable name="attr-suffix-idref" as="xs:string" select="'-idref'"/>
  <xsl:variable name="attr-suffix-idrefs" as="xs:string" select="'-idrefs'"/>
  <xsl:variable name="attr-prefix-mandatory" as="xs:string" select="'mandatory-'"/>
  <xsl:variable name="attr-prefix-optional" as="xs:string" select="'optional-'"/>
  <xsl:variable name="attr-name-count" as="xs:string" select="'count'"/>

  <!-- Some special characters used: -->
  <xsl:variable name="char-encircled-d" as="xs:string" select="'&#x24D3;'"/>
  <xsl:variable name="char-encircled-i" as="xs:string" select="'&#x24D8;'"/>
  <xsl:variable name="char-thinspace" as="xs:string" select="'&#x200A;'"/>

  <!-- The order in which the various media usage and types are presented: -->
  <xsl:variable name="media-usage-types-ordered" as="xs:string+" select="($ci:media-usage-type-overview, $ci:media-usage-type-datasheet, 
    $ci:media-usage-type-connections-overview, $ci:media-usage-type-instruction, $ci:media-usage-type-usage-example)"/>
  <xsl:variable name="media-types-ordered" as="xs:string+" select="($ci:media-type-image, $ci:media-type-pdf, $ci:media-type-html, 
    $ci:media-type-markdown, $ci:media-type-text, $ci:media-type-sml)"/>

  <!-- Flags for additional contents: -->
  <xsl:variable name="add-page-creation-timestamp" as="xs:boolean" select="true()"/>

  <!-- Currency prefix: -->
  <xsl:variable name="currency-prefix" as="xs:string" select="'€'"/>

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xtlcon:document-container timestamp="{current-dateTime()}" href-target-path="{$href-build-location}">

      <!-- Home/index page: -->
      <xsl:call-template name="create-container-document">
        <xsl:with-param name="base-elm" select="()"/>
        <xsl:with-param name="href-target" select="'index.html'"/>
        <xsl:with-param name="title" select="'Component-inventory home'"/>
        <xsl:with-param name="content" as="node()*">
          <xsl:call-template name="handle-text-block-contents">
            <xsl:with-param name="text-block-parent-elm" select="$ci:additional-data-document/*/ci:home-page"/>
            <xsl:with-param name="href-dir-target" select="$href-build-location"/>
          </xsl:call-template>
          <xsl:call-template name="add-favorites-section"/>
        </xsl:with-param>
      </xsl:call-template>

      <!-- About page: -->
      <xsl:call-template name="create-container-document">
        <xsl:with-param name="base-elm" select="()"/>
        <xsl:with-param name="href-target" select="'about.html'"/>
        <xsl:with-param name="title" select="'About component-inventory'"/>
        <xsl:with-param name="content" as="node()*">
          <xsl:call-template name="handle-text-block-contents">
            <xsl:with-param name="text-block-parent-elm" select="$ci:additional-data-document/*/ci:about-page"/>
            <xsl:with-param name="href-dir-target" select="$href-build-location"/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="force-creation-timestamp-footer" select="true()"/>
      </xsl:call-template>

      <!-- Create pages for all the items: -->
      <xsl:apply-templates select="/ci:component-inventory-specification/ci:*"/>

    </xtlcon:document-container>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- OVERVIEW PAGES FOR THE ITEM TYPES: -->

  <xsl:template match="/ci:component-inventory-specification/ci:*">
    <!-- Create an item type overview page with a list of all items: -->

    <xsl:variable name="is-categories" as="xs:boolean" select="exists(self::ci:categories)"/>
    <xsl:variable name="item-type-plural" as="xs:string" select="local-name(.)"/>
    <xsl:variable name="item-type-plural-no-hyphens" as="xs:string" select="translate($item-type-plural, '-', ' ')"/>
    <xsl:call-template name="create-container-document">
      <xsl:with-param name="href-target" select="xtlc:href-concat(($item-type-plural, $item-type-plural || $extension-html))"/>
      <xsl:with-param name="title" select="xtlc:capitalize($item-type-plural-no-hyphens)"/>
      <xsl:with-param name="title-full" select="'All ' || $item-type-plural-no-hyphens"/>
      <xsl:with-param name="content" as="item()*">
        <xsl:call-template name="handle-text-block-contents">
          <xsl:with-param name="text-block-parent-elm" select="$ci:additional-data-document/*/ci:overview-page[@item-type eq $item-type-plural]"/>
          <xsl:with-param name="href-dir-target" select="xtlc:href-concat(($href-build-location, $item-type-plural))"/>
        </xsl:call-template>
        <ci:LIST type="{$item-type-plural}">
          <xsl:for-each select="ci:*">
            <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
            <!-- For categories, add a count: -->
            <ci:LISTITEM href="{xtlc:href-concat(($id, $id || $extension-html))}" name="{@name}" description="{@summary}">
              <xsl:if test="$is-categories">
                <xsl:attribute name="count" select="count($components[$id = xtlc:str2seq(@category-idrefs)])"/>
              </xsl:if>
            </ci:LISTITEM>
          </xsl:for-each>
        </ci:LIST>
      </xsl:with-param>
    </xsl:call-template>

    <!-- Now process the items for this item type: -->
    <xsl:apply-templates select="ci:*"/>

  </xsl:template>

  <!-- ======================================================================= -->
  <!-- ITEM: COMPONENT: -->

  <xsl:template match="/ci:component-inventory-specification/ci:components/ci:component">

    <xsl:variable name="component-elm" as="element(ci:component)" select="."/>
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:variable name="item-type-plural" as="xs:string" select="local-name(..)"/>
    <xsl:variable name="item-type" as="xs:string" select="local-name(.)"/>
    <xsl:variable name="item-name" as="xs:string" select="xs:string(@name)"/>
    <xsl:variable name="href-directory" as="xs:string" select="xtlc:href-concat(($item-type-plural, $id))"/>

    <xsl:variable name="name" as="xs:string" select="xs:string($component-elm/@name)"/>
    <xsl:call-template name="create-container-document">
      <xsl:with-param name="base-elm" select="$component-elm"/>
      <xsl:with-param name="item-previous" select="(preceding-sibling::ci:component)[last()]"/>
      <xsl:with-param name="item-next" select="(following-sibling::ci:component)[1]"/>
      <xsl:with-param name="href-target" select="local:href-to-item($component-elm)"/>
      <xsl:with-param name="title" select="$name"/>
      <xsl:with-param name="title-full" select="string-join(($name, xs:string($component-elm/@summary)[.]), ' - ')"/>
      <xsl:with-param name="content" as="element()*">

        <!-- Create a media section: -->
        <xsl:variable name="package-idref" as="xs:string?" select="xs:string(@package-idref)[. ne $ci:special-value-unknown]"/>
        <xsl:variable name="package" as="element(ci:package)?"
          select="if (exists($package-idref)) then key('package' || $suffix-index, $package-idref) else ()"/>
        <xsl:call-template name="create-media-section">
          <xsl:with-param name="media" select="ci:media"/>
          <xsl:with-param name="package-media" select="$package/ci:media"/>
        </xsl:call-template>

        <!-- Info table: -->
        <p>{$char-thinspace}</p>
        <table class="{$class-info-table}">

          <!-- Properties: -->
          <xsl:for-each select="ci:property-values/ci:property-value">
            <xsl:variable name="property-elm" as="element(ci:property)" select="key('property' || $suffix-index, xs:string(@property-idref))"/>
            <xsl:call-template name="create-info-table-row">
              <xsl:with-param name="label" select="xs:string($property-elm/@name)"/>
              <xsl:with-param name="content" as="item()*">
                <xsl:value-of select="string-join((@value, $property-elm/@suffix), $char-thinspace)"/>
                <xsl:call-template name="create-popup">
                  <xsl:with-param name="popups" select="xs:string($property-elm/@summary)"/>
                </xsl:call-template>
                <xsl:call-template name="create-detail-link">
                  <xsl:with-param name="item-from-elm" select="$component-elm"/>
                  <xsl:with-param name="detail-link-item-elm" select="$property-elm"/>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>

          <!-- Attributes: -->
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@package-idref"/>
          </xsl:call-template>

          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@count"/>
            <xsl:with-param name="label" select="'In stock'"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@location-idref"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@location-box-label"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@partly-in-reserve-stock"/>
            <xsl:with-param name="is-boolean" select="true()"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@price-range-idref"/>
            <xsl:with-param name="popups" select="'The price range is an estimate, based on commercial pricing on the date the part was added.'"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@discontinued"/>
            <xsl:with-param name="is-boolean" select="true()"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="label" select="'In categories'"/>
            <xsl:with-param name="attr" select="@category-idrefs"/>
            <xsl:with-param name="make-detail-link" select="false()"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="label" select="'Registered since'"/>
            <xsl:with-param name="attr" select="@since"/>
          </xsl:call-template>
        </table>

      </xsl:with-param>
    </xsl:call-template>

    <!-- Make sure the media for this item (if any) are included and copied: -->
    <xsl:call-template name="copy-media">
      <xsl:with-param name="href-directory" select="$href-directory"/>
    </xsl:call-template>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-info-table-row-for-attribute">
    <xsl:param name="item-from-elm" as="element()" required="false" select="."/>
    <xsl:param name="attr" as="attribute()?" required="false" select="."/>
    <xsl:param name="label" as="xs:string" required="false" select="local:attr-label($attr)"/>
    <xsl:param name="popups" as="xs:string*" required="false" select="()"/>
    <xsl:param name="is-boolean" as="xs:boolean" required="false" select="false()"/>
    <xsl:param name="discard-boolean-false" as="xs:boolean" required="false" select="true()">
      <!-- If it's a boolean *and* its value is false, don't show this row -->
    </xsl:param>
    <xsl:param name="make-detail-link" as="xs:boolean" required="false" select="true()"/>
    <xsl:param name="is-code" as="xs:boolean" required="false" select="false()"/>
    <xsl:param name="prefix" as="xs:string?" required="false" select="()"/>

    <xsl:variable name="value" as="xs:string?" select="normalize-space($attr)[. ne $ci:special-value-unknown]"/>
    <xsl:variable name="value-seq" as="xs:string*" select="xtlc:str2seq($value)[. ne $ci:special-value-unknown]"/>
    <xsl:variable name="show-row" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="empty($value-seq)">
          <xsl:sequence select="false()"/>
        </xsl:when>
        <xsl:when test="$is-boolean and $discard-boolean-false">
          <xsl:sequence select="xs:boolean($value)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="true()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$show-row">
      <xsl:variable name="attr-name" as="xs:string" select="local-name($attr)"/>

      <xsl:call-template name="create-info-table-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content" as="item()*">

          <xsl:choose>

            <xsl:when test="ends-with($attr-name, $attr-suffix-idref)">
              <xsl:call-template name="create-item-reference">
                <xsl:with-param name="item-from-elm" select="$item-from-elm"/>
                <xsl:with-param name="item-to-type" select="local:reference-attribute-item-type($attr)"/>
                <xsl:with-param name="item-to-id" select="$value"/>
                <xsl:with-param name="popups" select="$popups"/>
                <xsl:with-param name="make-detail-link" select="$make-detail-link"/>
              </xsl:call-template>
            </xsl:when>

            <xsl:when test="ends-with($attr-name, $attr-suffix-idrefs)">
              <xsl:variable name="item-type" as="xs:string" select="local:reference-attribute-item-type($attr)"/>
              <xsl:for-each select="$value-seq">
                <xsl:call-template name="create-item-reference">
                  <xsl:with-param name="item-from-elm" select="$item-from-elm"/>
                  <xsl:with-param name="item-to-type" select="$item-type"/>
                  <xsl:with-param name="item-to-id" select="."/>
                  <xsl:with-param name="popups" select="$popups"/>
                  <xsl:with-param name="make-detail-link" select="$make-detail-link"/>
                </xsl:call-template>
                <xsl:if test="position() ne last()">
                  <br/>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>

            <xsl:when test="$is-boolean">
              <xsl:value-of select="if (xs:boolean($value)) then 'Yes' else 'No'"/>
              <xsl:call-template name="create-popup">
                <xsl:with-param name="popups" as="xs:string*" select="$popups"/>
              </xsl:call-template>
            </xsl:when>

            <xsl:when test="$attr-name eq $attr-name-count">
              <xsl:variable name="is-many" as="xs:boolean" select="$value eq $ci:special-value-many"/>
              <xsl:value-of select="if ($is-many) then 'Many' else $value"/>
              <xsl:call-template name="create-popup">
                <xsl:with-param name="popups" as="xs:string*">
                  <xsl:sequence select="'Approximately, not all usage is accurately recorded.'"/>
                  <xsl:choose>
                    <xsl:when test="$is-many">
                      <xsl:sequence select="'Too many to count comfortably (usually &gt; ' || $ci:special-value-many-limit || ').'"/>
                    </xsl:when>
                    <xsl:when test="xs:integer($value) le 0">
                      <xsl:sequence select="'Out of stock, but kept for reference purposes.'"/>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:sequence select="$popups"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>

            <xsl:when test="$is-code">
              <code>{xs:string($attr)}</code>
              <xsl:call-template name="create-popup">
                <xsl:with-param name="popups" as="xs:string*" select="$popups"/>
              </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
              <xsl:value-of select="$prefix"/>
              <xsl:value-of select="xs:string($attr) => xtlc:capitalize()"/>
              <xsl:call-template name="create-popup">
                <xsl:with-param name="popups" as="xs:string*" select="$popups"/>
              </xsl:call-template>
            </xsl:otherwise>

          </xsl:choose>
        </xsl:with-param>

      </xsl:call-template>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-item-reference">
    <xsl:param name="item-from-elm" as="element()" required="false" select="."/>
    <xsl:param name="item-to-type" as="xs:string" required="true"/>
    <xsl:param name="item-to-id" as="xs:string" required="true"/>
    <xsl:param name="popups" as="xs:string*" required="false" select="()"/>
    <xsl:param name="make-detail-link" as="xs:boolean" required="false" select="true()"/>

    <xsl:variable name="item-to-elm" as="element()" select="key($item-to-type || $suffix-index, $item-to-id, $doc)"/>
    <xsl:choose>
      <xsl:when test="$make-detail-link">
        <xsl:value-of select="xs:string($item-to-elm/@name)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="create-item-link">
          <xsl:with-param name="item-from-elm" select="$item-from-elm"/>
          <xsl:with-param name="item-to-type" select="$item-to-type"/>
          <xsl:with-param name="item-to-id" select="$item-to-id"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:call-template name="create-popup">
      <xsl:with-param name="popups" as="xs:string*">
        <xsl:sequence select="$item-to-elm/@summary"/>
        <xsl:sequence select="$popups"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$make-detail-link">
      <xsl:call-template name="create-detail-link">
        <xsl:with-param name="item-from-elm" select="$item-from-elm"/>
        <xsl:with-param name="detail-link-item-elm" select="$item-to-elm"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:attr-label" as="xs:string?">
    <xsl:param name="attr" as="attribute()?"/>

    <xsl:if test="exists($attr)">
      <xsl:variable name="attr-name" as="xs:string" select="local-name($attr)"/>
      <xsl:variable name="attr-label-raw" as="xs:string">
        <xsl:choose>
          <xsl:when test="ends-with($attr-name, $attr-suffix-idref) or ends-with($attr-name, $attr-suffix-idrefs)">
            <xsl:sequence select="local:reference-attribute-item-type($attr)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$attr-name"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:sequence select="$attr-label-raw => translate('-', ' ') => xtlc:capitalize()"/>
    </xsl:if>
  </xsl:function>

  <!-- ======================================================================= -->
  <!-- PAGES FOR OTHER ITEM TYPES... -->

  <xsl:template match="/ci:component-inventory-specification/ci:properties/ci:property">
    <xsl:call-template name="create-page-for-non-component-item">
      <xsl:with-param name="additional-content" as="item()*">
        <p>{$char-thinspace}</p>
        <table class="{$class-info-table}">
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@value-pattern"/>
            <xsl:with-param name="is-code" select="true()"/>
            <xsl:with-param name="popups" select="'Regular expression for the value to match'"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@default"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@suffix"/>
            <xsl:with-param name="label" select="'Value suffix'"/>
          </xsl:call-template>
        </table>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/ci:component-inventory-specification/ci:categories/ci:category">
    <xsl:call-template name="create-page-for-non-component-item">
      <xsl:with-param name="additional-content" as="item()*">
        <p>{$char-thinspace}</p>
        <table class="{$class-info-table}">
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@mandatory-property-idrefs"/>
            <xsl:with-param name="label" select="'Mandatory properties'"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@optional-property-idrefs"/>
            <xsl:with-param name="label" select="'Optional properties'"/>
          </xsl:call-template>
        </table>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/ci:component-inventory-specification/ci:price-ranges/ci:price-range">
    <xsl:call-template name="create-page-for-non-component-item">
      <xsl:with-param name="additional-content" as="item()*">
        <p>{$char-thinspace}</p>
        <table class="{$class-info-table}">
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@min-inclusive"/>
            <xsl:with-param name="label" select="'Minimum price (inclusive)'"/>
            <xsl:with-param name="prefix" select="$currency-prefix"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@max-inclusive"/>
            <xsl:with-param name="label" select="'Maximum price (inclusive)'"/>
            <xsl:with-param name="prefix" select="$currency-prefix"/>
          </xsl:call-template>
        </table>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template match="/ci:component-inventory-specification/ci:*/ci:*" priority="-1000">
    <xsl:call-template name="create-page-for-non-component-item"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-page-for-non-component-item">
    <xsl:param name="item-elm" as="element()" required="false" select="."/>
    <xsl:param name="additional-content" as="item()*" required="false" select="()"/>

    <xsl:for-each select="$item-elm">
      <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
      <xsl:variable name="name" as="xs:string" select="local-name(.)"/>
      <xsl:variable name="item-type-plural" as="xs:string" select="local-name(..)"/>
      <xsl:variable name="href-directory" as="xs:string" select="xtlc:href-concat(($item-type-plural, $id))"/>
      <xsl:variable name="href-target" as="xs:string" select="xtlc:href-concat(($href-directory, $id || $extension-html))"/>
      <xsl:variable name="title" as="xs:string" select="xtlc:capitalize($name) || ': ' || @name"/>

      <xsl:call-template name="create-container-document">
        <xsl:with-param name="item-previous" select="(preceding-sibling::ci:*[local-name(.) eq $name])[last()]"/>
        <xsl:with-param name="item-next" select="(following-sibling::ci:*[local-name(.) eq $name])[1]"/>
        <xsl:with-param name="title" select="$title"/>
        <xsl:with-param name="title-full" select="string-join(($title, xs:string(@summary)[.]), ' - ')"/>
        <xsl:with-param name="href-target" select="$href-target"/>
        <xsl:with-param name="content" as="item()*">
          <xsl:call-template name="create-media-section">
            <xsl:with-param name="media" select="ci:media"/>
          </xsl:call-template>

          <xsl:sequence select="$additional-content"/>

          <xsl:variable name="idref-attribute-names" as="xs:string+" select="($name || $attr-suffix-idref, $name || $attr-suffix-idrefs)"/>
          <xsl:variable name="referenced-components" as="element(ci:component)*"
            select="/ci:component-inventory-specification/ci:components/ci:component[local:component-references-item(., $id, $idref-attribute-names)]"/>
          <xsl:if test="exists($referenced-components)">
            <h3>Components referencing this {$name}:</h3>
            <ci:LIST type="components">
              <xsl:for-each select="$referenced-components">
                <xsl:variable name="component-id" as="xs:string" select="xs:string(@id)"/>
                <ci:LISTITEM href="{xtlc:href-concat(('..', '..', 'components', $component-id, $component-id || $extension-html))}" name="{@name}"
                  description="{@summary}"/>
              </xsl:for-each>
            </ci:LIST>
          </xsl:if>

        </xsl:with-param>
      </xsl:call-template>

      <!-- Make sure the media for this item (if any) are included and copied: -->
      <xsl:call-template name="copy-media">
        <xsl:with-param name="href-directory" select="$href-directory"/>
      </xsl:call-template>

    </xsl:for-each>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:component-references-item" as="xs:boolean">
    <xsl:param name="component-elm" as="element(ci:component)"/>
    <xsl:param name="item-id" as="xs:string"/>
    <xsl:param name="idref-attribute-names" as="xs:string+"/>

    <xsl:variable name="idref-attribute" as="attribute()?" select="$component-elm/@*[local-name(.) = $idref-attribute-names]"/>
    <xsl:choose>
      <xsl:when test="exists($idref-attribute)">
        <xsl:sequence select="$item-id = xtlc:str2seq($idref-attribute)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ======================================================================= -->
  <!-- GENERAL SUPPORT: -->

  <xsl:template name="create-container-document">
    <!-- Creates the base container document for a page.  -->
    <xsl:param name="base-elm" as="element()?" required="false" select="."/>
    <xsl:param name="content" as="element()*" required="true"/>
    <xsl:param name="href-target" as="xs:string" required="true"/>
    <xsl:param name="title" as="xs:string" required="true"/>
    <xsl:param name="title-full" as="xs:string" required="false" select="$title"/>
    <xsl:param name="item-previous" as="element()?" required="false" select="()"/>
    <xsl:param name="item-next" as="element()?" required="false" select="()"/>
    <xsl:param name="force-creation-timestamp-footer" as="xs:boolean" required="false" select="false()"/>

    <xsl:variable name="id" as="xs:string?" select="xs:string($base-elm/@id)"/>
    <xtlcon:document href-target="{$href-target}" type="{if (empty($base-elm)) then xtlc:href-name-noext($href-target) else local-name($base-elm)}"
      title="{$title}" page-level="{if (empty($base-elm)) then 0 else count($base-elm/ancestor::ci:*)}"
      serialization="{{'method': 'html', 'indent': 'false'}}">
      <xsl:if test="exists($id)">
        <xsl:attribute name="id" select="$id"/>
      </xsl:if>
      <xsl:if test="exists($base-elm/@keywords)">
        <xsl:attribute name="keywords" select="distinct-values(($id, xtlc:str2seq($base-elm/@keywords))) => string-join(' ')"/>
      </xsl:if>

      <!-- Page title (with optional previous/next links): -->
      <h1>
        <xsl:if test="exists($item-previous)">
          <a href="{local:href-to-item($base-elm, $item-previous)}" title="Previous {local-name($item-previous)}">
            <img src="../../images/previous.png" width="1.5%"/>
          </a>
          <xsl:text>&#160;</xsl:text>
        </xsl:if>
        <xsl:value-of select="$title-full"/>
        <xsl:if test="exists($item-next)">
          <xsl:text>&#160;</xsl:text>
          <a href="{local:href-to-item($base-elm, $item-next)}" title="Next {local-name($item-next)}">
            <img src="../../images/next.png" width="1.5%"/>
          </a>
        </xsl:if>
      </h1>

      <!-- Description (if any): -->
      <xsl:call-template name="handle-text-block-contents">
        <xsl:with-param name="text-block-parent-elm" select="$base-elm/ci:description"/>
        <xsl:with-param name="href-dir-target" select="xtlc:href-path($href-target)"/>
      </xsl:call-template>

      <!-- Contents: -->
      <xsl:sequence select="$content"/>

      <!-- Footer with internal id and optional timestamp: -->
      <p>&#160;</p>
      <p class="site-remark">
        <xsl:if test="exists($id)">
          <xsl:text>Internal identifier: </xsl:text>
          <xsl:value-of select="$id"/>
          <xsl:if test="$add-page-creation-timestamp or $force-creation-timestamp-footer">
            <xsl:text> - </xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:if test="$add-page-creation-timestamp or $force-creation-timestamp-footer">
          <xsl:text>Created: </xsl:text>
          <xsl:value-of select="format-dateTime(current-dateTime(), $xtlc:default-dt-format)"/>
        </xsl:if>
      </p>

    </xtlcon:document>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-info-table-row">
    <!-- Creates a row for an information table. -->
    <xsl:param name="label" as="xs:string" required="true"/>
    <xsl:param name="content" as="item()*" required="true"/>

    <tr class="{$class-info-table}">
      <td class="{$class-info-table} {$class-info-table-prompt-column}">
        <xsl:value-of select="$label"/>
        <xsl:text>:&#160;</xsl:text>
      </td>
      <td class="{$class-info-table} {$class-info-table-value-column}">
        <xsl:sequence select="$content"/>
      </td>
    </tr>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-popup">
    <!-- Creates a popup (an encircled i that shows popup info when hovered over). -->
    <xsl:param name="popups" as="xs:string*" required="true"/>

    <xsl:variable name="popups-normalized" as="xs:string*" select="for $p in $popups return normalize-space($p)[.]"/>
    <xsl:if test="exists($popups-normalized)">
      <xsl:text> </xsl:text>
      <span class="citooltip {$class-grey}">
        <!-- Encircled i: -->
        <xsl:text>&#x24D8;</xsl:text>
        <span class="citooltiptext">
          <xsl:for-each select="$popups-normalized">
            <xsl:value-of select="."/>
            <xsl:if test="position() ne last()">
              <br/>
            </xsl:if>
          </xsl:for-each>
        </span>
      </span>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-detail-link">
    <!-- Creates a detail link (an encircled d that links to the page about an item) -->
    <xsl:param name="item-from-elm" as="element()" required="false" select="."/>
    <xsl:param name="detail-link-item-elm" as="element()" required="true"/>

    <xsl:if test="exists($detail-link-item-elm)">
      <xsl:variable name="item-detail-type" as="xs:string" select="local-name($detail-link-item-elm)"/>
      <xsl:text> </xsl:text>
      <span>
        <xsl:call-template name="create-item-link">
          <xsl:with-param name="item-from-elm" select="$item-from-elm"/>
          <xsl:with-param name="item-to-type" select="$item-detail-type"/>
          <xsl:with-param name="item-to-id" select="xs:string($detail-link-item-elm/@id)"/>
          <xsl:with-param name="popup" select="'Details for ' || $item-detail-type || ' ' || $detail-link-item-elm/@name"/>
          <xsl:with-param name="prompt" select="'&#x24D3;'">
            <!-- Encircled d -->
          </xsl:with-param>
          <xsl:with-param name="class" select="string-join(($class-link-nomark, $class-grey), ' ')"/>
        </xsl:call-template>
      </span>
    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-item-link">
    <!-- Creates a link element(<a>) to an item of a certain type/id. -->
    <xsl:param name="item-from-elm" as="element()" required="false" select="."/>
    <xsl:param name="item-to-type" as="xs:string" required="true"/>
    <xsl:param name="item-to-id" as="xs:string" required="true"/>
    <xsl:param name="popup" as="xs:string?" required="false" select="()"/>
    <xsl:param name="prompt" as="xs:string?" required="false" select="()"/>
    <xsl:param name="class" as="xs:string?" required="false" select="()"/>

    <xsl:variable name="item-to-elm" as="element()" select="key($item-to-type || $suffix-index, $item-to-id, $doc)"/>
    <a href="{local:href-to-item($item-from-elm, $item-to-elm)}" title="{($popup, $item-to-elm/@summary)[1]}">
      <xsl:if test="normalize-space($class) ne ''">
        <xsl:attribute name="class" select="$class"/>
      </xsl:if>
      <xsl:value-of select="($prompt, $item-to-elm/@name)[1]"/>
    </a>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:reference-attribute-item-type" as="xs:string">
    <!-- Returns the item type a reference attribute is referring to. For instance: 
         * package-idref => package
         * optional-property-idrefs => property
    -->
    <xsl:param name="attr" as="attribute()"/>

    <xsl:variable name="attr-name" as="xs:string" select="local-name($attr)"/>
    <xsl:variable name="item-type-raw" as="xs:string">
      <xsl:choose>
        <xsl:when test="ends-with($attr-name, $attr-suffix-idref)">
          <xsl:sequence select="substring-before($attr-name, $attr-suffix-idref)"/>
        </xsl:when>
        <xsl:when test="ends-with($attr-name, $attr-suffix-idrefs)">
          <xsl:sequence select="substring-before($attr-name, $attr-suffix-idrefs)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="xtlc:raise-error">
            <xsl:with-param name="msg-parts" select="('Not a reference attribute: ', $attr)"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($item-type-raw, $attr-prefix-mandatory)">
        <xsl:sequence select="substring-after($item-type-raw, $attr-prefix-mandatory)"/>
      </xsl:when>
      <xsl:when test="starts-with($item-type-raw, $attr-prefix-optional)">
        <xsl:sequence select="substring-after($item-type-raw, $attr-prefix-optional)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$item-type-raw"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <!-- ======================================================================= -->
  <!-- MEDIA SUPPORT: -->

  <xsl:template name="copy-media">
    <xsl:param name="item-from-elm" as="element()" required="false" select="."/>
    <xsl:param name="href-directory" as="xs:string" required="true"/>
    <!-- Remark: The SML conversion process converts SML documents into HTML and directly copies these to the 
      right location. It adds a _no-copy="true" attribute. Therefore we skip media with such an attribute. -->
    <xsl:for-each select="$item-from-elm/ci:media/ci:*[not(xtlc:str2bln(@_no-copy, false()))][not(exists(self::ci:resource-directory))]">
      <xsl:variable name="href" as="xs:string" select="xs:string(@href)"/>
      <xtlcon:external-document href-source="{$href => xtlc:href-add-encoding()}"
        href-target="{xtlc:href-concat(($href-directory, xtlc:href-name($href))) => xtlc:href-add-encoding()}"/>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-media-section">
    <xsl:param name="item-from-elm" as="element()" required="false" select="."/>
    <xsl:param name="media" as="element(ci:media)?" required="true"/>
    <xsl:param name="package-media" as="element(ci:media)?" required="false" select="()"/>

    <xsl:variable name="overview-media-image-lms" as="element()*"
      select="($media/ci:image, $package-media/ci:image)[@usage eq $ci:media-usage-type-overview]"/>
    <xsl:variable name="other-media-elms" as="element()*"
      select="$media/ci:*[not(exists(self::ci:image) and (@usage eq $ci:media-usage-type-overview))]"/>
    <xsl:if test="exists($overview-media-image-lms) or exists($other-media-elms)">
      <div class="container">

        <xsl:choose>

          <xsl:when test="exists($overview-media-image-lms)">
            <!-- There are overview images. Create a carousel and the (optional) other media side by side: -->
            <div class="row pt-5">
              <div class="col-sm-6">
                <xsl:call-template name="create-overview-images-carousel">
                  <xsl:with-param name="item-from-elm" select="$item-from-elm"/>
                  <xsl:with-param name="image-elms" select="$overview-media-image-lms"/>
                </xsl:call-template>
              </div>
              <div class="col-sm-6">
                <xsl:call-template name="create-media-list-section">
                  <xsl:with-param name="media-elms" select="$other-media-elms"/>
                </xsl:call-template>
              </div>
            </div>
          </xsl:when>

          <xsl:otherwise>
            <!-- No overview images. Just create something for the other media: -->
            <xsl:call-template name="create-media-list-section">
              <xsl:with-param name="media-elms" select="$other-media-elms"/>
            </xsl:call-template>
          </xsl:otherwise>

        </xsl:choose>

      </div>
    </xsl:if>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-overview-images-carousel">
    <!-- Creates a carousel with the overview images. You can only have one of these on a page! -->
    <xsl:param name="item-from-elm" as="element()" required="false" select="."/>
    <xsl:param name="image-elms" as="element(ci:image)*" required="true"/>

    <xsl:if test="exists($image-elms)">
      <xsl:variable name="carousel-id" as="xs:string" select="'carouselOverviewImages'"/>

      <div id="{$carousel-id}" class="carousel slide" data-bs-ride="false">

        <!-- Indicators: -->
        <xsl:if test="count($image-elms) gt 1">
          <div class="carousel-indicators">
            <xsl:for-each select="$image-elms">
              <button type="button" data-bs-target="#carouselOverviewImages" data-bs-slide-to="{position() - 1}"
                aria-label="{if (exists(@description)) then xs:string(@description) else ('Overview image ' || position())}">
                <xsl:if test="position() eq 1">
                  <xsl:attribute name="class" select="'active'"/>
                  <xsl:attribute name="aria-current" select="'true'"/>
                </xsl:if>
              </button>
            </xsl:for-each>
          </div>
        </xsl:if>

        <!-- The images: -->
        <div class="carousel-inner">
          <xsl:for-each select="$image-elms">
            <xsl:variable name="description" as="xs:string?" select="xs:string(@description)"/>
            <div class="carousel-item{if (position() eq 1) then ' active' else ()}">
              <img class="d-block w-100" src="{local:link-to-media($item-from-elm, .)}">
                <xsl:if test="exists($description)">
                  <xsl:attribute name="alt" select="$description"/>
                </xsl:if>
              </img>
              <xsl:if test="exists($description)">
                <div class="carousel-caption d-none d-md-block">
                  <p>{$description}</p>
                </div>
              </xsl:if>
            </div>
          </xsl:for-each>
        </div>

        <!-- Next/prev buttons: -->
        <xsl:if test="count($image-elms) gt 1">
          <button class="carousel-control-prev" type="button" data-bs-target="#carouselOverviewImages" data-bs-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"/>
            <span class="visually-hidden">Previous</span>
          </button>
          <button class="carousel-control-next" type="button" data-bs-target="#carouselOverviewImages" data-bs-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"/>
            <span class="visually-hidden">Next</span>
          </button>
        </xsl:if>

      </div>

    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-media-list-section">
    <xsl:param name="media-elms" as="element()*" required="true"/>

    <xsl:for-each-group select="$media-elms" group-by="xs:string(@usage)">
      <xsl:sort select="local:sort-order-key($media-usage-types-ordered, current-grouping-key())"/>
      <xsl:variable name="label" as="xs:string"
        select="(xtlc:capitalize(current-grouping-key()) => translate('-', ' ')) || (if (count(current-group()) gt 1) then 's' else ()) "/>
      <p>
        <b>{$label}</b>
        <xsl:if test="current-grouping-key() eq $ci:media-usage-type-datasheet">
          <xsl:text> </xsl:text>
          <xsl:call-template name="create-popup">
            <xsl:with-param name="popups"
              select="'Multiple datasheets are usually available for a component. The listed datasheets may not be the exact ones, but should be sufficient for normal use.'"
            />
          </xsl:call-template>
        </xsl:if>
        <xsl:text>:</xsl:text>
      </p>
      <ul>
        <xsl:for-each select="current-group()">
          <xsl:sort select="local:sort-order-key($media-types-ordered, local-name(.))"/>
          <li>
            <xsl:variable name="name" as="xs:string" select="xtlc:href-name(@href)"/>
            <a href="{$name}" target="_blank">
              <xsl:value-of select="xtlc:href-decode-uri($name)"/>
            </a>
            <xsl:if test="normalize-space(@description) ne ''">
              <xsl:text> (</xsl:text>
              <xsl:value-of select="@description"/>
              <xsl:text>)</xsl:text>
            </xsl:if>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:for-each-group>

  </xsl:template>

  <!-- ======================================================================= -->
  <!-- FILENAME AND URI SUPPORT: -->

  <xsl:function name="local:item-filename" as="xs:string">
    <!-- Computes the filename for the HTML page of an item. -->
    <xsl:param name="item-elm" as="element()"/>

    <xsl:sequence select="xtlc:str2filename-safe($item-elm/@id) || $extension-html"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:href-to-item" as="xs:string">
    <!-- Computes the URI to an item's page (including its filename). -->
    <xsl:param name="item-elm-from" as="element()?">
      <!-- The item this link originates from. () means originating from the root
        of the website. -->
    </xsl:param>
    <xsl:param name="item-elm-to" as="element()"/>

    <xsl:variable name="id" as="xs:string" select="xs:string($item-elm-to/@id)"/>
    <xsl:variable name="href-base" as="xs:string" select="xtlc:href-concat(($id, local:item-filename($item-elm-to)))"/>
    <xsl:variable name="href-full" as="xs:string" select="xtlc:href-concat((local-name($item-elm-to/..), $href-base))"/>
    <xsl:choose>
      <xsl:when test="empty($item-elm-from)">
        <!-- From the root of the website: -->
        <xsl:sequence select="$href-full"/>
      </xsl:when>
      <xsl:when test="local-name($item-elm-to) eq local-name($item-elm-from)">
        <!-- Link to something of the same item type: -->
        <xsl:sequence select="xtlc:href-concat(('..', $href-base))"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Link to something of a different item type: -->
        <xsl:sequence select="xtlc:href-concat(('..', '..', $href-full))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:href-to-item" as="xs:string">
    <!-- Computes the URI to an item's page from the root of the website. -->
    <xsl:param name="item-elm-to" as="element()"/>

    <xsl:sequence select="local:href-to-item((), $item-elm-to)"/>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:function name="local:link-to-media" as="xs:string">
    <xsl:param name="item-elm-from" as="element()"/>
    <xsl:param name="media-elm" as="element()">
      <!-- A media element (for instance ci:image) -->
    </xsl:param>

    <xsl:variable name="item-of-media-elm" as="element()" select="$media-elm/../.."/>
    <xsl:choose>
      <xsl:when test="$item-of-media-elm is $item-elm-from">
        <xsl:sequence select="xtlc:href-name($media-elm/@href)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="xtlc:href-concat(('..', '..', local-name($item-of-media-elm/..), $item-of-media-elm/@id, xtlc:href-name($media-elm/@href)))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ======================================================================= -->
  <!-- TEXT BLOCK CONTENTS HANDLING: -->

  <xsl:template name="handle-text-block-contents">
    <!-- Handles text block contents. 
      Adjacent SML elements are put into an <sml:sml> container and turned into HTML later in the pipeline. 
      Anything else is turned into the HTML namespace.
    -->
    <xsl:param name="text-block-parent-elm" as="element()?" required="false" select="."/>
    <xsl:param name="href-dir-target" as="xs:string" required="true">
      <!-- The URI of the target directory where the result will be written. -->
    </xsl:param>

    <xsl:for-each-group select="$text-block-parent-elm/*" group-adjacent="namespace-uri(.) eq $namespace-sml">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <!-- Some elements in the SML namespace: -->
          <sml:sml toc="false" _href-dir-result="{$href-dir-target}">
            <xsl:sequence select="current-group()"/>
          </sml:sml>
        </xsl:when>
        <xsl:otherwise>
          <!-- Anything else, turn into HTML: -->
          <xsl:call-template name="ci:elements-to-html-namespace">
            <xsl:with-param name="elements" select="current-group()"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>

  </xsl:template>


  <!-- ======================================================================= -->
  <!-- OTHERS: -->

  <xsl:function name="local:sort-order-key" as="xs:integer">
    <!-- Returns a number used for sorting vales. $value-list-ordered is an ordered list of strings. 
      The function checks whether $value is in this. If so, it returns its position in this list. 
      If not, it returns the size of the list + 1. 
    -->
    <xsl:param name="value-list-ordered" as="xs:string*"/>
    <xsl:param name="value" as="xs:string?"/>

    <xsl:variable name="default" as="xs:integer" select="count($value-list-ordered) + 1"/>
    <xsl:choose>
      <xsl:when test="empty($value) or empty($value-list-ordered)">
        <xsl:sequence select="$default"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="index" as="xs:integer?" select="index-of($value-list-ordered, $value)[1]"/>
        <xsl:sequence select="($index, $default)[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-favorites-section">
    <!-- Creates some HTML structure to show the favorites: -->

    <xsl:variable name="favorite-component-elements" as="element(ci:component)*"
      select="$ci:additional-data-document/*/ci:favorite-components/ci:component"/>
    <xsl:variable name="favorite-component-idrefs-raw" as="xs:string*">
      <xsl:for-each select="$favorite-component-elements">
        <xsl:variable name="idref" as="xs:string" select="xs:string(@idref)"/>
        <xsl:variable name="component-elm" as="element(ci:component)?" select="$components[@id eq $idref]"/>
        <xsl:if test="exists($component-elm)">
          <xsl:sequence select="$idref"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="favorite-component-idrefs" as="xs:string*" select="distinct-values($favorite-component-idrefs-raw)"/>

    <xsl:variable name="favorite-category-elements" as="element(ci:category)*"
      select="$ci:additional-data-document/*/ci:favorite-categories/ci:category"/>
    <xsl:variable name="favorite-category-idrefs-raw" as="xs:string*">
      <xsl:for-each select="$favorite-category-elements">
        <xsl:variable name="idref" as="xs:string" select="xs:string(@idref)"/>
        <xsl:variable name="category-elm" as="element(ci:category)?" select="$categories[@id eq $idref]"/>
        <xsl:if test="exists($category-elm)">
          <xsl:sequence select="$idref"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="favorite-category-idrefs" as="xs:string*" select="distinct-values($favorite-category-idrefs-raw)"/>

    <div class="container">

      <xsl:choose>
        <xsl:when test="exists($favorite-category-idrefs) and exists($favorite-component-idrefs)">
          <div class="row pt-5">
            <div class="col-sm-6">
              <xsl:call-template name="add-favorites-subsection">
                <xsl:with-param name="favorite-idrefs" select="$favorite-category-idrefs"/>
                <xsl:with-param name="favorite-reference-elms" select="$favorite-category-elements"/>
                <xsl:with-param name="item-elms" select="$categories"/>
              </xsl:call-template>
            </div>
            <div class="col-sm-6">
              <xsl:call-template name="add-favorites-subsection">
                <xsl:with-param name="favorite-idrefs" select="$favorite-component-idrefs"/>
                <xsl:with-param name="favorite-reference-elms" select="$favorite-component-elements"/>
                <xsl:with-param name="item-elms" select="$components"/>
              </xsl:call-template>
            </div>
          </div>
        </xsl:when>
        <xsl:when test="exists($favorite-category-idrefs)">
          <p>&#160;</p>
          <xsl:call-template name="add-favorites-subsection">
            <xsl:with-param name="favorite-idrefs" select="$favorite-category-idrefs"/>
            <xsl:with-param name="favorite-reference-elms" select="$favorite-category-elements"/>
            <xsl:with-param name="item-elms" select="$categories"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="exists($favorite-component-idrefs)">
          <p>&#160;</p>
          <xsl:call-template name="add-favorites-subsection">
            <xsl:with-param name="favorite-idrefs" select="$favorite-component-idrefs"/>
            <xsl:with-param name="favorite-reference-elms" select="$favorite-component-elements"/>
            <xsl:with-param name="item-elms" select="$components"/>
          </xsl:call-template>
        </xsl:when>

      </xsl:choose>

    </div>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="add-favorites-subsection">
    <xsl:param name="favorite-idrefs" as="xs:string*" required="true"/>
    <xsl:param name="favorite-reference-elms" as="element()*" required="true">
      <!-- We need this to get the additional remarks that are sometimes there. -->
    </xsl:param>
    <xsl:param name="item-elms" as="element()*" required="true"/>

    <xsl:if test="exists($favorite-idrefs)">
      <xsl:variable name="item-type-plural" as="xs:string" select="local-name($item-elms[1]/..)"/>
      <p>
        <b>Favorite {$item-type-plural}</b>
        <xsl:call-template name="create-popup">
          <xsl:with-param name="popups" select="'Favorite ' || $item-type-plural || ' are based on my personal preferences and usage'"/>
        </xsl:call-template>
        <xsl:text>:</xsl:text>
      </p>
      <ul>
        <xsl:for-each select="$favorite-idrefs">
          <xsl:variable name="idref" as="xs:string" select="."/>
          <xsl:variable name="item-elm" as="element()" select="$item-elms[@id eq $idref]"/>
          <xsl:variable name="reference-elm" as="element()" select="$favorite-reference-elms[@idref eq $idref][1]"/>
          <li>
            <a href="{$item-type-plural}/{$idref}/{$idref}{$extension-html}">
              <xsl:value-of select="$item-elm/@name"/>
            </a>
            <xsl:text> - </xsl:text>
            <xsl:value-of select="$item-elm/@summary"/>
            <xsl:if test="normalize-space($reference-elm/@remark) ne ''">
              <xsl:text> (</xsl:text>
              <xsl:value-of select="$reference-elm/@remark"/>
              <xsl:text>)</xsl:text>
            </xsl:if>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>

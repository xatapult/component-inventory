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

  <xsl:variable name="doc" as="document-node()" select="/"/>

  <xsl:variable name="extension-html" as="xs:string" select="'.html'"/>

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

  <!-- ================================================================== -->

  <xsl:template match="/">
    <xtlcon:document-container timestamp="{current-dateTime()}" href-target-path="{$href-build-location}">

      <!-- Home/index page: -->
      <xtlcon:document href-target="index.html" type="{$ci:document-type-index}" title="Component-inventory home">
        <!-- TBD -->
        <h1>HOME PAGE COMPONENT-INVENTORY TBD</h1>
      </xtlcon:document>

      <!-- Create pages for all the items: -->
      <xsl:apply-templates select="/ci:component-inventory-specification/ci:*/ci:*"/>

    </xtlcon:document-container>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- ITEM: COMPONENT: -->

  <xsl:template match="ci:components/ci:component">

    <xsl:variable name="component-elm" as="element(ci:component)" select="."/>
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:variable name="item-type-plural" as="xs:string" select="local-name(..)"/>
    <xsl:variable name="item-type" as="xs:string" select="local-name(.)"/>
    <xsl:variable name="item-name" as="xs:string" select="xs:string(@name)"/>
    <xsl:variable name="href-directory" as="xs:string" select="xtlc:href-concat(($item-type-plural, $id))"/>

    <xsl:call-template name="create-item-page-container-document">
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
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="attr" select="@discontinued"/>
            <xsl:with-param name="is-boolean" select="true()"/>
          </xsl:call-template>
          <xsl:call-template name="create-info-table-row-for-attribute">
            <xsl:with-param name="label" select="'In categories'"/>
            <xsl:with-param name="attr" select="@category-idrefs"/>
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

            <xsl:otherwise>
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

    <xsl:for-each select="$doc">
      <xsl:variable name="item-to-elm" as="element()" select="key($item-to-type || $suffix-index, $item-to-id)"/>
      <xsl:value-of select="xs:string($item-to-elm/@name)"/>
      <xsl:call-template name="create-popup">
        <xsl:with-param name="popups" as="xs:string*">
          <xsl:sequence select="$item-to-elm/@summary"/>
          <xsl:sequence select="$popups"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="create-detail-link">
        <xsl:with-param name="item-from-elm" select="$item-from-elm"/>
        <xsl:with-param name="detail-link-item-elm" select="$item-to-elm"/>
      </xsl:call-template>
    </xsl:for-each>
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
  <!-- TBD PAGES FOR OTHER ITEM TYPES... -->
  
  <xsl:template match="ci:packages/ci:package">
    
    <xsl:variable name="id" as="xs:string" select="xs:string(@id)"/>
    <xsl:variable name="item-type-plural" as="xs:string" select="local-name(..)"/>
    <xsl:variable name="href-directory" as="xs:string" select="xtlc:href-concat(($item-type-plural, $id))"/>
    
    <xsl:comment> == ITEM NOT YET HANDLED: {local-name(.)} - {@id} == </xsl:comment>
    
    <!-- Make sure the media for this item (if any) are included and copied: -->
    <xsl:call-template name="copy-media">
      <xsl:with-param name="href-directory" select="$href-directory"/>
    </xsl:call-template>
    
  </xsl:template>
  
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  
  
  <xsl:template match="/*/ci:*/ci:*" priority="-1000">
    <xsl:comment> == ITEM NOT YET HANDLED: {local-name(.)} - {@id} == </xsl:comment>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- GENERAL SUPPORT: -->

  <xsl:template name="create-item-page-container-document">
    <!-- Creates the container document for the page for an item, filling in all the common stuff.  -->
    <xsl:param name="item-elm" as="element()" required="false" select="."/>
    <xsl:param name="content" as="element()*" required="true"/>

    <xsl:variable name="id" as="xs:string" select="xs:string($item-elm/@id)"/>

    <xtlcon:document href-target="{local:href-to-item($item-elm)}" type="{local-name($item-elm)}" id="{$id}" title="{$item-elm/@name}"
      keywords="{distinct-values(($id, xtlc:str2seq($item-elm/@keywords))) => string-join(' ')}"
      serialization="{{'method': 'html', 'indent': 'false'}}">
      <h1>{$item-elm/@name} - {$item-elm/@summary}</h1>
      <xsl:where-populated>
        <sml:sml>
          <xsl:sequence select="ci:description/sml:*"/>
        </sml:sml>
      </xsl:where-populated>

      <xsl:sequence select="$content"/>

      <!-- FOR NOW ADD DATE/TIME: -->
      <p>&#160;</p>
      <p>Created: {format-dateTime(current-dateTime(), $xtlc:default-dt-format)}</p>
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
    <xsl:if test="exists($popups)">
      <xsl:text> </xsl:text>
      <span class="citooltip {$class-grey}">
        <!-- Encircled i: -->
        <xsl:text>&#x24D8;</xsl:text>
        <span class="citooltiptext">
          <xsl:for-each select="$popups">
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

    <xsl:for-each select="$doc">
      <xsl:variable name="item-to-elm" as="element()" select="key($item-to-type || $suffix-index, $item-to-id)"/>
      <a href="{local:href-to-item($item-from-elm, $item-to-elm)}" title="{($popup, $item-to-elm/@summary)[1]}">
        <xsl:if test="normalize-space($class) ne ''">
          <xsl:attribute name="class" select="$class"/>
        </xsl:if>
        <xsl:value-of select="($prompt, $item-to-elm/@name)[1]"/>
      </a>
    </xsl:for-each>
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

    <xsl:for-each select="$item-from-elm/ci:media/ci:*">
      <xsl:variable name="href" as="xs:string" select="xs:string(@href)"/>
      <xtlcon:external-document href-source="{$href}" href-target="{xtlc:href-concat(($href-directory, xtlc:href-name($href)))}"/>
    </xsl:for-each>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template name="create-media-section">
    <xsl:param name="item-from-elm" as="element()" required="false" select="."/>
    <xsl:param name="media" as="element(ci:media)?" required="true"/>
    <xsl:param name="package-media" as="element(ci:media)?" required="false" select="()"/>

    <xsl:variable name="overview-media-elms" as="element()*"
      select="($media/ci:image, $package-media/ci:image)[@usage eq $ci:media-usage-type-overview]"/>
    <xsl:variable name="other-media-elms" as="element()*"
      select="$media/ci:*[not(exists(self::ci:image) and (@usage eq $ci:media-usage-type-overview))]"/>
    <xsl:if test="exists($overview-media-elms) or exists($other-media-elms)">
      <div class="container">

        <xsl:choose>

          <xsl:when test="exists($overview-media-elms)">
            <!-- There are overview images. Create a carousel and the (optional) other media side by side: -->
            <div class="row pt-5">
              <div class="col-sm-6">
                <xsl:call-template name="create-overview-images-carousel">
                  <xsl:with-param name="item-from-elm" select="$item-from-elm"/>
                  <xsl:with-param name="image-elms" select="$overview-media-elms"/>
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

    <p>Other media... {count($media-elms)}</p>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- FILENAME AND URI SUPPORT: -->

  <xsl:function name="local:item-filename" as="xs:string">
    <!-- COmputes the filename for the HTML page of an item. -->
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

</xsl:stylesheet>

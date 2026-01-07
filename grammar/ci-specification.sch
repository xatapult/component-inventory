<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local" queryBinding="xslt2">
  <!-- ================================================================== -->
  <!--	
       Definitions of rules for the Component Inventory specification document.
       
       See ci-specification.xsd.
	-->
  <!-- ================================================================== -->

  <ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
  <ns uri="https://eriksiegel.nl/ns/component-inventory" prefix="ci"/>
  <ns uri="#local" prefix="local"/>

  <!-- ======================================================================= -->

  <xsl:include href="../xslmod/ci-schematron-functions.xsl"/>

  <!-- ======================================================================= -->
  <!-- Property related: -->

  <let name="property-identifiers" value="/ci:component-inventory-specification/ci:properties/ci:property/@id/string()"/>

  <pattern>
    <rule context="/ci:component-inventory-specification/ci:properties/ci:property">
      <let name="id" value="string(@id)"/>
      <assert test="count($property-identifiers[. eq $id]) eq 1">Multiple definitions of property "<value-of select="$id"/>"</assert>
      <assert test="(normalize-space(@default) eq '') or (normalize-space(@value-pattern) eq '') or matches(@default, @value-pattern)">Default value
          "<value-of select="@default"/>" does not match value-pattern "<value-of select="@value-pattern"/>" for property "<value-of select="$id"
        />"</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Category related: -->

  <pattern>
    <rule context="/ci:component-inventory-specification//ci:categories/ci:category">
      <let name="category-identifiers" value="../ci:category/@id/string()"/>
      <let name="id" value="string(@id)"/>
      <let name="property-identifiers-used-more-than-once"
        value="local:identifiers-used-more-than-once((ancestor-or-self::ci:category/@mandatory-property-idrefs, ancestor-or-self::ci:category/@optional-property-idrefs))"/>
      <let name="property-identifiers-not-present"
        value="local:identifiers-not-present((@mandatory-property-idrefs, @optional-property-idrefs), $property-identifiers)"/>

      <assert test="count($category-identifiers[. eq $id]) eq 1">Multiple definitions of category "<value-of select="$id"/>"</assert>
      <assert test="empty($property-identifiers-used-more-than-once)">Property identifier(s) used more than once on category "<value-of select="$id"
        />": <value-of select="local:quoted-string-list($property-identifiers-used-more-than-once)"/> (on this or parent category)</assert>
      <assert test="empty($property-identifiers-not-present)">Property identifier(s) not found on category "<value-of select="$id"/>": <value-of
          select="local:quoted-string-list($property-identifiers-not-present)"/></assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Price-range related: -->

  <let name="price-range-identifiers" value="/ci:component-inventory-specification/ci:price-ranges/ci:price-range/@id/string()"/>

  <pattern>
    <rule context="/ci:component-inventory-specification/ci:price-ranges/ci:price-range">
      <let name="current-price-range" value="."/>
      <let name="id" value="string($current-price-range/@id)"/>
      <let name="min-inclusive" value="xs:decimal($current-price-range/@min-inclusive)"/>
      <let name="max-inclusive" value="xs:decimal($current-price-range/@max-inclusive)"/>
      <let name="overlapping-price-range-ids" value="../ci:price-range[@id ne $id][local:price-ranges-overlap(., $current-price-range)]/@id/string()"/>

      <assert test="count($price-range-identifiers[. eq $id]) eq 1">Multiple definitions of price-range "<value-of select="$id"/>"</assert>
      <assert test="$min-inclusive le $max-inclusive">Minimum price greater than maximum price</assert>
      <assert test="empty($overlapping-price-range-ids)">Price range overlaps with <value-of
          select="local:quoted-string-list($overlapping-price-range-ids)"/></assert>

    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Packages related: -->

  <let name="package-identifiers" value="/ci:component-inventory-specification/ci:packages/ci:package/@id/string()"/>

  <pattern>
    <rule context="/ci:component-inventory-specification/ci:packages/ci:package">
      <let name="id" value="string(@id)"/>
      <assert test="count($package-identifiers[. eq $id]) eq 1">Multiple definitions of package "<value-of select="$id"/>"</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Packages related: -->

  <let name="location-identifiers" value="/ci:component-inventory-specification/ci:locations/ci:location/@id/string()"/>

  <pattern>
    <rule context="/ci:component-inventory-specification/ci:locations/ci:location">
      <let name="id" value="string(@id)"/>
      <assert test="count($location-identifiers[. eq $id]) eq 1">Multiple definitions of location "<value-of select="$id"/>"</assert>
    </rule>
  </pattern>

</schema>

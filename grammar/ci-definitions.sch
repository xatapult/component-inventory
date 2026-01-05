<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="#local" queryBinding="xslt2">
  <!-- ================================================================== -->
  <!--	
       Definitions of rules for the Component Inventory definitions document.
       
       See ci-definitions.xsd.
	-->
  <!-- ================================================================== -->

  <ns uri="https://eriksiegel.nl/ns/component-inventory" prefix="ci"/>
  <ns uri="#local" prefix="local"/>

  <!-- ======================================================================= -->

  <xsl:include href="../xslmod/ci-schematron-functions.xsl"/>

  <!-- ======================================================================= -->
  <!-- Property related: -->

  <let name="property-identifiers" value="/ci:definitions/ci:properties/ci:property/@id/string()"/>

  <pattern>
    <rule context="/ci:definitions/ci:properties/ci:property">
      <let name="id" value="string(@id)"/>
      <assert test="count($property-identifiers[. eq $id]) eq 1">Multiple definitions of property "<value-of select="$id"/>"</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Category related: -->

  <pattern>
    <rule context="ci:categories/ci:category">
      <let name="category-identifiers" value="../ci:category/@id/string()"/>
      <let name="id" value="string(@id)"/>
      <assert test="count($category-identifiers[. eq $id]) eq 1">Multiple definitions of category "<value-of select="$id"/>"</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Price-range related: -->

  <let name="price-range-identifiers" value="/ci:definitions/ci:price-ranges/ci:price-range/@id/string()"/>

  <pattern>
    <rule context="/ci:definitions/ci:price-ranges/ci:price-range">
      <let name="current-price-range" value="."/>
      <let name="id" value="string($current-price-range/@id)"/>
      <let name="min-inclusive" value="xs:decimal($current-price-range/@min-inclusive)"/>
      <let name="max-inclusive" value="xs:decimal($current-price-range/@max-inclusive)"/>
      <let name="overlapping-price-range-ids" value="../ci:price-range[@id ne $id][local:price-ranges-overlap(., $current-price-range)]/@id/string()"/>

      <assert test="count($price-range-identifiers[. eq $id]) eq 1">Multiple definitions of price-range "<value-of select="$id"/>"</assert>
      <assert test="$min-inclusive le $max-inclusive">Minimum price greater than maximum price</assert>
      <assert test="empty($overlapping-price-range-ids)">Price range overlaps with "<value-of select="string-join($overlapping-price-range-ids, '&quot;, &quot;')"/>"</assert>
    </rule>
  </pattern>
  
  <!-- ======================================================================= -->
  <!-- Packages related: -->
  
  <let name="package-identifiers" value="/ci:definitions/ci:packages/ci:package/@id/string()"/>
  
  <pattern>
    <rule context="/ci:definitions/ci:packages/ci:package">
      <let name="id" value="string(@id)"/>
      <assert test="count($package-identifiers[. eq $id]) eq 1">Multiple definitions of package "<value-of select="$id"/>"</assert>
    </rule>
  </pattern>
  
  <!-- ======================================================================= -->
  <!-- Packages related: -->
  
  <let name="location-identifiers" value="/ci:definitions/ci:locations/ci:location/@id/string()"/>
  
  <pattern>
    <rule context="/ci:definitions/ci:locations/ci:location">
      <let name="id" value="string(@id)"/>
      <assert test="count($location-identifiers[. eq $id]) eq 1">Multiple definitions of location "<value-of select="$id"/>"</assert>
    </rule>
  </pattern>
  
</schema>

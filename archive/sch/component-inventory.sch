<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <!-- ================================================================== -->
  <!--
        Schematron schema for component-inventory documents    
  -->
  <!-- ================================================================== -->
  <!-- Global settings: -->

  <ns uri="https://eriksiegel.nl/ns/component-inventory" prefix="ci"/>

  <let name="category-ids" value="/*/ci:category-definitions//ci:category-definition/@id/string()"/>
  <let name="location-ids" value="/*/ci:location-definitions//ci:location-definition/@id/string()"/>
  <let name="price-range-ids" value="/*/ci:price-range-definitions//ci:price-range-definition/@id/string()"/>
  <let name="package-ids" value="/*/ci:package-definitions//ci:package-definition/@id/string()"/>

  <!-- ======================================================================= -->
  <!-- Property checks: -->

  <pattern>
    <!-- All property references must exist and the values must be according to the value-pattern: -->
    <rule context="ci:property">
      <let name="property-idref" value="string(@idref)"/>
      <let name="property-definition" value="/*/ci:property-definitions/ci:property-definition[@id eq $property-idref]"/>

      <!-- All references must exist: -->
      <assert test="exists($property-definition)">Property with id "<value-of select="$property-idref"/>" not defined.</assert>

      <!-- The value must match the value-pattern: -->
      <let name="property-value" value="string(@value)"/>
      <let name="property-regexp" value="/*/ci:property-definitions/ci:property-definition[@id eq $property-idref]/@value-pattern"/>
      <assert test="empty($property-regexp) or matches($property-value, ($property-regexp, '.*')[1])">Property value "<value-of
          select="$property-value"/>" does not match the property definition value-pattern "<value-of select="$property-regexp"/>".</assert>

      <!-- There must be no double definitions: -->
      <assert test="count(../ci:property[@idref eq $property-idref]) eq 1">Property "<value-of select="$property-idref"/>" is double defined.</assert>

    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Category checks -->

  <pattern>
    <!-- A reference to a category must exist: -->
    <rule context="@category-idrefs">
      <let name="category-idrefs" value="tokenize(string(.), '\s+')[.]"/>
      <let name="undefined-category-idrefs" value="$category-idrefs[not(. = $category-ids)]"/>
      <assert test="empty($undefined-category-idrefs)">Categories with ids "<value-of select="string-join($undefined-category-idrefs, ' ')"/>" not
        defined.</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Location checks: -->

  <pattern>
    <!-- A reference to a location must exist: -->
    <rule context="@location-idref">
      <let name="location-idref" value="string(.)"/>
      <let name="undefined-location-idrefs" value="$location-idref[not(. = $location-ids)]"/>
      <assert test="$location-idref = $location-ids">Location with id "<value-of select="$location-idref"/>" not defined.</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Price-range checks: -->

  <pattern>
    <!-- A reference to a price-range must exist: -->
    <rule context="@price-range-idref">
      <let name="price-range-idref" value="string(.)"/>
      <let name="undefined-price-range-idrefs" value="$price-range-idref[not(. = $price-range-ids)]"/>
      <assert test="$price-range-idref = $price-range-ids">Price-range with id "<value-of select="$price-range-idref"/>" not defined.</assert>
    </rule>
  </pattern>

  <!-- ======================================================================= -->
  <!-- Package checks: -->

  <pattern>
    <!-- A reference to a package must exist: -->
    <rule context="@package-idref">
      <let name="package-idref" value="string(.)"/>
      <let name="undefined-package-idrefs" value="$package-idref[not(. = $package-ids)]"/>
      <assert test="$package-idref = $package-ids">Package with id "<value-of select="$package-idref"/>" not defined.</assert>
    </rule>
  </pattern>

</schema>

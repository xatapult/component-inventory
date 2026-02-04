# Component-inventory


* [Introduction](#section-d16e8)
* [Base concepts](#section-d16e27)

  * [Base terminology](#section-d16e34)
  * [Item-types](#sect-item-types)

    * [General properties of all items](#section-d16e366)


* [Component-inventory processing](#section-d16e583)

  * [Automatic creation of media elements](#sect-auto-media)

* [Component-inventory XML documents](#ci-documents)

  * [Namespace usage](#sect-namespace-usage)
  * [The component-inventory specification document](#sect-ci-specification-document)

    * [Defining property items: ci:properties](#sect-xml-properties)
    * [Defining category items: ci:categories](#sect-xml-categories)
    * [Defining price-range items: ci:price-ranges](#sect-xml-price-ranges)
    * [Defining package items: ci:packages](#sect-xml-packages)
    * [Defining location items: ci:locations](#sect-xml-locations)
    * [Defining component items: ci:components](#sect-xml-components)

  * [Component specification documents](#sect-ci-component-specification)

    * [Defining property values](#sect-xml-property-values)

  * [The additional data document](#sect-ci-additional-data)
  * [Shared definitions](#section-d16e2534)

    * [Media](#sect-xml-media)
    * [Text/SML](#sect-text-sml)
    * [The macro mechanism](#macro-mechanism)

      * [Standard macros](#section-d16e3285)





 

-----

## Introduction<a name="section-d16e8"/>

Component-inventory is a Xatapult component that generates a website with information about my electronic components (ICs, transistors,
      etc.). 

GitHub: [https://github.com/xatapult/component-inventory](https://github.com/xatapult/component-inventory) (`git@github.com:xatapult/component-inventory.git`)

-----

## Base concepts<a name="section-d16e27"/>

### Base terminology<a name="section-d16e34"/>


| Term | Description | 
| ----- | ----- | 
| Identifier | A string to identify something with. An identifier in component-inventory consists of letters, numbers, hyphens (`-`) and underscores (`_`). It must start with a letter of number. | 
| Combined-identifier | For categories, identifiers are combined (because categories can have sub-categories, see [Defining category items: ci:categories](#sect-xml-categories)). Combining identifiers is done using the dot (`.`) as separator, for instance `ICS.LOGIC.74HC`. | 
| Item-type | The component-inventory system works with items (see below) of a certain item-type, for instance `property`, `category`, `component`, etc. See [Item-types](#sect-item-types). | 
| Item | An item is the basic building block component-inventory works with. An item is always of a certain item-type (see above).<br/>The most common item is the `component`. | 

### Item-types<a name="sect-item-types"/>


| Item-type | Description | 
| ----- | ----- | 
|  `property`  | A `property item` describes some property of a component. For instance its supply voltage, number of connections, etc.<br/>You must define which properties are mandatory/optional for components in a certain category. <br/>Items of this item-type are defined in the [component-inventory specification document](#sect-ci-specification-document). | 
|  `category`  | A `category item` describes a category to divide the components into. For instance `ICS`, or `RELAYS`.<br/>Categories can have sub-categories.<br/>Items of this item-type are defined in the [component-inventory specification document](#sect-ci-specification-document). | 
|  `price-range`  | A `price-range item` describes a price-range to attach to a component. For instance `CHEAP` (between €0.01 and €0.50), `EXPENSIVE` (over €10.00), etc.<br/>Price-ranges were chosen over exact pricing because commercial prices differ and it is not always clear what a component exactly costs.<br/>Items of this item-type are defined in the [component-inventory specification document](#sect-ci-specification-document). | 
|  `package`  | A `package item` describes the packaging of a component. For instance `DIP16`.<br/>Items of this item-type are defined in the [component-inventory specification document](#sect-ci-specification-document). | 
|  `location`  | A `location item` describes where the component can (usually) be found in my shed.<br/>Items of this item-type are defined in the [component-inventory specification document](#sect-ci-specification-document). | 
|  `component`  | A `component item` describes what this system is all about: an electronic component.<br/>Items of this item-type are defined in their own [component specification document](#sect-ci-component-specification). The central [component-inventory specification document](#sect-ci-specification-document) defines where on disk to search for component information. | 

#### General properties of all items<a name="section-d16e366"/>

All items of all item-types share the following common properties:


| Property | Where | Description | Example | 
| ----- | ----- | ----- | ----- | 
| Identifier |  `@id`  | The (mandatory) identifier for this item. This must be unique for all items of this item-type. |  `id="74HC123B"`  | 
| Name |  `@name`  | The (optional) name of this item, as used to display/identify it in the generated website.<br/>If not specified, it is the same as the identifier of the item. |  `name="74HC123"`  | 
| Summary |  `@summary`  | A short summary of this component (optional). |  `summary="Quad 4-input NAND gate"`  | 
| keywords |  `@keywords`  | An (optional) whitespace-separated list of keywords for the HTML page about this item (the name of the item automatically becomes a keyword and does not need to be specified again). |  `keywords="logic-circuit flipflop"`  | 
| Description |  `ci:description`  | An (optional) description for this item, see [Text/SML](#sect-text-sml). |  `<ci:description><para xmlns="http://www.eriksiegel.nl/ns/sml">This is a descriptive paragraph…</para></ci:description>`  | 

-----

## Component-inventory processing<a name="section-d16e583"/>

TBD

### Automatic creation of `<media>` elements<a name="sect-auto-media"/>

If an item that can have a `<media>` element has none, an attempt is being made to create one.


* For packages, files in the designated directory with same name as the package identifier are considered.
* For components, all files in the directory where the [component specification document](#sect-ci-component-specification) is stored are considered. Any sub-directories are considered to be additional resource directories.

The usage type (the contents of `@usage`) is determined as follows:


* Any image is considered usage type `overview`.
* A PDF is considered usage type `datasheet`.
* Anything else is considered usage type `instruction`.

-----

## Component-inventory XML documents<a name="ci-documents"/>

### Namespace usage<a name="sect-namespace-usage"/>

All XML for the component-inventory uses the `https://eriksiegel.nl/ns/component-inventory` namespace.

This document uses the recommended namespace prefix `ci` for this.

### The component-inventory specification document<a name="sect-ci-specification-document"/>

The component-inventory specification document is the starting point for generating the website. It contains the definitions of most items
        and points to where the information about component items can be found.


```
<component-inventory-specification>
  <macrodefs>?
  <properties>
  <categories>
  <proces-ranges>
  <packages>
  <locations>
  <components>
</component-inventory-specification>
```


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `properties` | 1 | Property item definitions. See [Defining property items: ci:properties](#sect-xml-properties). | 
| `categories` | 1 | Category item definitions. See [Defining category items: ci:categories](#sect-xml-categories). | 
| `proces-ranges` | 1 | Price-range item definitions. See [Defining price-range items: ci:price-ranges](#sect-xml-price-ranges). | 
| `packages` | 1 | Package item definitions. See [Defining package items: ci:packages](#sect-xml-packages). | 
| `locations` | 1 | Location item definitions. See [sml/sect-xml-locations](sml/sect-xml-locations). | 
| `components` | 1 | The locations where component item information can be found. See [sml/sect-xml-components](sml/sect-xml-components). | 

#### Defining `property` items: `<ci:properties>`<a name="sect-xml-properties"/>


```
<properties>
  <macrodefs>?
  <property>*
</properties>
```


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `property` | * | A single item definition. | 


```
<property id = identifier
          name? = xs:string
          summary? = xs:string
          keywords? = list of xs:string
          value-pattern? = xs:string
          default? = xs:string
          suffix? = xs:string >
  <macrodefs>?
  <description>?
</property>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `id` | 1 | `identifier` | The identifier of this item. | 
| `name` | ? | `xs:string` | Default: `@id`<br/>The visible name of this item. | 
| `summary` | ? | `xs:string` | A short summary of this item. If not present, something will be made up using `@name`. | 
| `keywords` | ? | `list of xs:string` | A whitespace-separated list of keywords for the HTML page for this item. | 
| `value-pattern` | ? | `xs:string` | A regular expression for the value to match. If absent or empty, anything goes.<br/>If you want this pattern to match the whole value, take care to anchor it using `^` and `$`. | 
| `default` | ? | `xs:string` | The default value for this property. | 
| `suffix` | ? | `xs:string` | An optional suffix appended to the value when displaying this property. For instance `suffix="V DC"`. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `description` | ? | A longer description of this item. See [sml/sect-text-sml](sml/sect-text-sml). | 

#### Defining `category` items: `<ci:categories>`<a name="sect-xml-categories"/>

Categories can have sub-categories. The identifier of a category+sub-category is made by concatenating their identifiers, with a dot
            (`.`) in between, to a combined-identifier.


```
<categories sub-category-mandatory? = xs:boolean >
  <macrodefs>?
  <category>*
</categories>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `sub-category-mandatory` | ? | `xs:boolean` | Default: `false`<br/>*Only for nested categories.* Whether using these sub-categories is mandatory. If `true` it means that the parent category cannot exist on its own. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `category` | * | A single item definition. | 


```
<category id = identifier
          name? = xs:string
          summary? = xs:string
          keywords? = list of xs:string
          mandatory-property-idrefs? = list of identifier
          optional-property-idrefs? = list of identifier >
  <macrodefs>?
  <description>?
  <categories>?
</category>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `id` | 1 | `identifier` | The identifier of this item. | 
| `name` | ? | `xs:string` | Default: `@id`<br/>The visible name of this item. | 
| `summary` | ? | `xs:string` | A short summary of this item. If not present, something will be made up using `@name`. | 
| `keywords` | ? | `list of xs:string` | A whitespace-separated list of keywords for the HTML page for this item. | 
| `mandatory-property-idrefs` | ? | `list of identifier` | A whitespace-separated list of property identifiers. These identifiers are mandatory for components in this category and must have a value. | 
| `optional-property-idrefs` | ? | `list of identifier` | A whitespace-separated list of property identifiers. These identifiers are optional for components in this category. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `description` | ? | A longer description of this item. See [sml/sect-text-sml](sml/sect-text-sml). | 
| `categories` | ? | Definition of sub-categories for this category. The definition of this element is the same as that of the `<categories>` element described above. | 

#### Defining `price-range` items: `<ci:price-ranges>`<a name="sect-xml-price-ranges"/>


```
<price-ranges>
  <macrodefs>?
  <price-range>*
</price-ranges>
```


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `price-range` | * | A single item definition. | 


```
<price-range id = identifier
             name? = xs:string
             summary? = xs:string
             keywords? = list of xs:string
             min-inclusive = xs:double
             max-inclusive = xs:double >
  <macrodefs>?
  <description>?
</price-range>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `id` | 1 | `identifier` | The identifier of this item. | 
| `name` | ? | `xs:string` | Default: `@id`<br/>The visible name of this item. | 
| `summary` | ? | `xs:string` | A short summary of this item. If not present, something will be made up using `@name`. | 
| `keywords` | ? | `list of xs:string` | A whitespace-separated list of keywords for the HTML page for this item. | 
| `min-inclusive` | 1 | `xs:double` | Minimum inclusive price for this price-range. | 
| `max-inclusive` | 1 | `xs:double` | Maximum inclusive price for this price-range. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `description` | ? | A longer description of this item. See [sml/sect-text-sml](sml/sect-text-sml). | 

#### Defining `package` items: `<ci:packages>`<a name="sect-xml-packages"/>


```
<packages href-default-base-directory? = xs:anyURI >
  <macrodefs>?
  <package>*
</packages>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `href-default-base-directory` | ? | `xs:anyURI` | The default directory for resolving all URIs in further child elements. If not specified the base URI of the document will be used. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `package` | * | A single item definition. | 


```
<package id = identifier
         name? = xs:string
         summary? = xs:string
         keywords? = list of xs:string >
  <macrodefs>?
  <description>?
  <media>?
</package>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `id` | 1 | `identifier` | The identifier of this item. | 
| `name` | ? | `xs:string` | Default: `@id`<br/>The visible name of this item. | 
| `summary` | ? | `xs:string` | A short summary of this item. If not present, something will be made up using `@name`. | 
| `keywords` | ? | `list of xs:string` | A whitespace-separated list of keywords for the HTML page for this item. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `description` | ? | A longer description of this item. See [sml/sect-text-sml](sml/sect-text-sml). | 
| `media` | ? | Any media for this package. See [Media](#sect-xml-media).<br/>If not present an attempt will be made to create one. The directory located by `packages/@href-default-base-directory` is searched for media files with the same filename as the package identifier. See [Automatic creation of media elements](#sect-auto-media). | 

#### Defining `location` items: `<ci:locations>`<a name="sect-xml-locations"/>


```
<locations>
  <macrodefs>?
  <location>*
</locations>
```


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `location` | * | A single item definition. | 


```
<location id = identifier
          name? = xs:string
          summary? = xs:string
          keywords? = list of xs:string >
  <macrodefs>?
  <description>?
</location>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `id` | 1 | `identifier` | The identifier of this item. | 
| `name` | ? | `xs:string` | Default: `@id`<br/>The visible name of this item. | 
| `summary` | ? | `xs:string` | A short summary of this item. If not present, something will be made up using `@name`. | 
| `keywords` | ? | `list of xs:string` | A whitespace-separated list of keywords for the HTML page for this item. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `description` | ? | A longer description of this item. See [sml/sect-text-sml](sml/sect-text-sml). | 

#### Defining `component` items: `<ci:components>`<a name="sect-xml-components"/>

Components are not defined directly in the main specification document. Instead, this document contains a list of directories to search
          for component definitions.


```
<components href-default-base-directory? = xs:anyURI >
  <macrodefs>?
  <directory>*
</components>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `href-default-base-directory` | ? | `xs:anyURI` | The default directory for resolving all URIs in further child elements. If not specified the base URI of the document will be used. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `directory` | * | A directory to search for component definitions. Sub-directories are also searched, recursively. | 


```
<directory href = xs:anyURI
           component-description-document-regexp? = xs:string />
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `href` | 1 | `xs:anyURI` | The URI of the directory. | 
| `component-description-document-regexp` | ? | `xs:string` | Default: `^component(-.+)?\.xml$`<br/>The regular expression for the filename of a component description file. If such a file is found, it is assumed to be a component description. See [Component specification documents](#sect-ci-component-specification).<br/>The directory it is in is used for automatically finding its media. See [Automatic creation of media elements](#sect-auto-media). | 

### Component specification documents<a name="sect-ci-component-specification"/>

A component specification document contains the description of a component item. It can be very minimal. Missing information will be
        filled in as best as possible (often using the special value `#unknown`).


```
<component id? = identifier
           name? = xs:string
           summary? = xs:string
           count? = xs:integer \| #many \| #unknown
           category-idrefs? = list of (combined-identifier \| #unknown)
           price-range-idref? = identifier \| #unknown
           package-idref? = identifier \| #unknown
           location-idref? = identifier \| #unknown
           location-box-label? = xs:string
           partly-in-reserve-stock? = xs:boolean
           since? = xs:date \| #unknown
           discontinued? = xs:boolean
           keywords? = list of xs:string >
  <macrodefs>?
  <description>?
  <property-values>?
  <media>?
</component>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `id` | ? | `identifier` | The identifier for this component. If absent, the name of the encompassing directory is used. | 
| `name` | ? | `xs:string` | Default: `@id`<br/>The visible name of this component. | 
| `summary` | ? | `xs:string` | A short summary of this component. If not present, something will be made up using `@name`. | 
| `count` | ? | `xs:integer \| #many \| #unknown` | Default: `#unknown`<br/>The number in stock.<br/>Use the special value `#many` for large numbers (large remains undefined but usually means something like > 25).<br/>Use the special value `#unknown` if unknown. | 
| `category-idrefs` | ? | `list of (combined-identifier \| #unknown)` | Default: `#unknown`<br/>A whitespace-separated list of combined-identifiers of the categories this component is in.<br/>Use the special value `#unknown` if unknown. | 
| `price-range-idref` | ? | `identifier \| #unknown` | Default: `#unknwon`<br/>The identifier of the price-range this component is in.<br/>Use the special value `#unknown` if unknown. | 
| `package-idref` | ? | `identifier \| #unknown` | Default: `#unknown`<br/>The identifier of the package for this component.<br/>Use the special value `#unknown` if unknown. | 
| `location-idref` | ? | `identifier \| #unknown` | Default: `#unknown`<br/>The identifier of the location for this component.<br/>Use the special value `#unknown` if unknown. | 
| `location-box-label` | ? | `xs:string` | Optional label on the box (or bag) where this component is stored in. | 
| `partly-in-reserve-stock` | ? | `xs:boolean` | Default: `false`<br/>Sometimes there are so many components, they do not fit in their main box (or bag). | 
| `since` | ? | `xs:date \| #unknown` | Default: `#unknown`<br/>The date when this component was registered. | 
| `discontinued` | ? | `xs:boolean` | Default: `false`<br/>Set to `true` for a discontinued component (a component that is no longer produced). | 
| `keywords` | ? | `list of xs:string` | A whitespace-separated list of keywords for the HTML page for this component. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `description` | ? | A longer description of this component. See [sml/sect-text-sml](sml/sect-text-sml). | 
| `property-values` | ? | Definition of the property item values for this component. See [Defining property values](#sect-xml-property-values). | 
| `media` | ? | Any media for this component. See [Media](#sect-xml-media).<br/>If not present an attempt will be made to create one. The directory this component description document is in is searched for media files. See [Automatic creation of media elements](#sect-auto-media). | 

#### Defining property values<a name="sect-xml-property-values"/>


```
<property-values>
  <property-value>*
</property-values>
```


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `property-value` | * | A property value. | 


```
<property-value property-idref = identifier
                value? = xs:string \| #unknown />
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `property-idref` | 1 | `identifier` | The identifier of the property. | 
| `value` | ? | `xs:string \| #unknown` | The value for this property.<br/>Use the special value `#unknown` if unknown. | 

### The additional data document<a name="sect-ci-additional-data"/>

The additional data document contains information used to build the final website. It contains:


* Favorite categories and components.
* The menu (the same for every page).
* Contents of the home and about page.
* Some information to put at the top of the item-type overview pages.

It is fairly simple, using [Text/SML](#sect-text-sml) to define contents. 

### Shared definitions<a name="section-d16e2534"/>

#### Media<a name="sect-xml-media"/>

A `<media>` element defines media for some of the items.

If it is not present for an item it is defined on, an attempt will be made to automatically create it, using the available media files.
          See [Automatic creation of media elements](#sect-auto-media).


```
<media href-default-base-directory? = xs:anyURI >
  <macrodefs>?
  ( <image> |
    <pdf> |
    <text> |
    <markdown> |
    <sml> |
    <html> |
    <resource-directory href="…"> )*
</media>
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `href-default-base-directory` | ? | `xs:anyURI` | The default directory for resolving all URIs in further child elements. If not specified the base URI of the document will be used. | 


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodefs` | ? | Optional macro definitions. See [The macro mechanism](#macro-mechanism). | 
| `image` |   | Some image. Supported are `jpg`, `png`, and `svg`. | 
| `pdf` |   | A PDF document. | 
| `text` |   | A text document. | 
| `markdown` |   | A markdown document. | 
| `sml` |   | An SML document. | 
| `html` |   | A HTML document. | 
| `resource-directory` |   | A directory with further resources for the media (for instance images on a HTML page). This directory will be copied to the website build location, on the location of the page for the item its is defined on, under the same name. | 

The `<image>`, `<pdf>`, `<text>`, `<markdown>`, `<sml>`, and `<html>` elements all have the
          same definition as the `<image>` element described here:


```
<image href = xs:anyURI
       usage? = xs:string
       description? = xs:string />
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `href` | 1 | `xs:anyURI` | The URI of the media file. | 
| `usage` | ? | `xs:string` | Default: `overview`<br/>Defines how this media document must be used/presented. See the table below. | 
| `description` | ? | `xs:string` | An optional short description for the media file. | 

The `usage` attribute can have the following values. This will be used to group them on the website page for the item.


| Value | Description | 
| ----- | ----- | 
|  `overview`  | Anything that provides an overview of the item. For instance a straight image. | 
|  `connections-overview`  | A media file that provides an overview of the connections of the item (pinning). | 
|  `datasheet`  | A datasheet for the item. | 
|  `usage-example`  | Some example of how to use the item. | 
|  `instruction`  | Instructions on how to use the item. | 

#### Text/SML<a name="sect-text-sml"/>

Any descriptions and longer pieces of content can be stated in both HTML and SML. The rules are:


* The child elements of a content/description element that are in the SML namespace (`http://www.eriksiegel.nl/ns/sml`) are considered to be SML. This will be converted into HTML.<br/>For more information on SML see its component documentation.<br/>Tip: Use a `<fragment xmlns="http://www.eriksiegel.nl/ns/sml">` element to surround larger chunks of SML, so the namespace is defaulted.
* Child elements in any other namespace are considered to be HTML and will be put in the HTML namespace.

#### The macro mechanism<a name="macro-mechanism"/>


The macro mechanism allows using and defining string macros.

##### Using macros<a name="section-d16e2962"/>

A reference to a parameter can be done in two different ways:


* As `{$MACRO}`
* As `${MACRO}`

Both will result in the text of the macro. To stop macro expansion, double the first curly brace.

Referencing macros can be done in text nodes and attribute values. If the macro does not exist, an error will be raised.

*Watch out:* it is possible that the software that uses the macro mechanism limits where macros can be used!

##### Macro expansion flags<a name="section-d16e3004"/>

A macro reference can be followed by zero or more flags, separated by colons (`:`). Assume for instance that the macro called
        `REF` contains the value `alpha:beta`. Then referring to it as `${REF:uc}` results in `ALPHA:BETA`
      (everything upper-case). Referring to is as `${REF:uc:fns}` will result in `ALPHA_BETA` (everything upper-case,
      filename-safe).

The following flags are defined:


| Flag | Description | 
| ----- | ----- | 
|  `cap`  | Capitalize the macro value (first character upper-case, rest as-is). | 
|  `compact`  | Remove all whitespace. | 
|  `fns`  | Filename safe expansion: replace all forbidden characters in a filename with underscores (`_`). | 
|  `fnsx`  | Filename safe expansion extra: like the `fns` flag, additionally replace all whitespace characters with underscores. | 
|  `lc`  | All lower-case. | 
|  `normalize`  | Normalize the macro value (like the `normalize-space()` function). | 
|  `uc`  | All upper-case. | 

##### Defining macros<a name="section-d16e3195"/>

Macros can be defined using the `<macrodefs>` element. Where this element can appear depends on the application that uses the macro
      mechanism and must be defined in its schema. It is *always* the first child element of some other element (usually for
      something grouping/container like, for instance sections).


```
<macrodefs>
  <macrodef>*
</macrodefs>
```


| Child element | # | Description | 
| ----- | ----- | ----- | 
| `macrodef` | * |   | 


```
<macrodef name = xs:NCName
          value? = xs:string />
```


| Attribute | # | Type | Description | 
| ----- | ----- | ----- | ----- | 
| `name` | 1 | `xs:NCName` | The name of the macro. Convention is to use all upper-case. | 
| `value` | ? | `xs:string` | The value for the macro. Can contain nested references to other macros. | 

##### Standard macros<a name="section-d16e3285"/>

The following macros are always available:


| Macro name | Description | Example(s) | 
| ----- | ----- | ----- | 
|  `DATE`  | The current date (`YYYY-MM-DD`). |  `2025-05-20`  | 
|  `DATECOMPACT`  | The current date in more compact format (`YYYYMMDD`)  |  `20250520`  | 
|  `DATETIMEISO`  | The current date/time in ISO format (may include a timezone indicator). |  `2025-05-20T12:12:23`  | 
|  `TIME`  | The current time (`HH:MM:SS`). |  `12:12:23`  | 
|  `TIMECOMPACT`  | The current time in more compact format (`HHMMSS`) |  `121223`  | 
|  `TIMESHORT`  | The current time without seconds (`HH:MM`). |  `12:12`  | 
|  `TIMESHORTCOMPACT`  | The current time in more compact format (HHMM) |  `1212`  | 


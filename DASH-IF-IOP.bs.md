<style>
body{
    counter-reset: tables;
}
table {
  counter-increment: tables;
}
table caption::before {
  font-weight: bold;
  content: "Table " counter(tables) ": ";
}
</style>

# Document editing notes # {#introduction-editing}

Documentation: https://dashif.org/DocumentAuthoring/

Example document repository: https://dashif.org/DocumentAuthoring/

Live discussion in #document-authoring on Slack.

Scope
Disclaimer

# Introduction # {#chapter-introduction}
This document defines DASH-IF's InterOperability Points (IOPs). The document includes IOPs for only this version of the document. For earlier versions, please refer to version 1 [1] and version 2 [2] of this document. DASH-IF recommends to deprecate the IOPs in previous versions and deploy using one of the IOPs and extensions in this document.

As a historical note, the scope of the initial DASH-AVC/264 IOP, issued with version 1 of this document [1] was the basic support high-quality video distribution over the top. Both live and on-demand services are supported.

In the second version of this document [2], HD video (up to 1080p) extensions and several mul-tichannel audio extensions are defined.

In this third version of the DASH-IF IOP document, two new DASH-264/AVC IOPs are defined. Detailed refinements and improvements for DASH-IF live services and for ad insertion were added in these IOPs. One of these IOP is the superset of the simpler one. Additionally, two cor-responding IOPs are defined to also support HEVC [19]. In both cases, AVC and HEVC, the more advanced IOP adds additional requirements on the DASH client to support segment pars-ing to achieve enhancement of live services. This structuring separates the Media Profiles from DASH features.

In the fourth version, beyond minor improvements, corrections and alignment with MPEG-DASH third edition, the key additions are extensions for next generation audio and UHD/HDR video.

This document defines the IOPs in Table 1 and Extensions in Table 2. The Implementation Guideline’s version in which each IOP or Extension was added is also provided in the tables.

Note that all version 1 IOPs are also defined in version 2 and therefore referencing version [2] is sufficient.

<table class="def">
  <caption>DASH-IF Interoperability Points</caption>
	<tr><th>DASH-IF Interoperability Point<th>Identifier<th>Version<th>Reference
	<tr><td>DASH-AVC/264<td>http://dashif.org/guidelines/dash264<td>1.0<td>[2], 6.3
  <tr><td>DASH-AVC/264 SD<td>http://dashif.org/guidelines/dash264#sd<td>1.0<td>[2], 7.3
  <tr><td>DASH-AVC/264 HD<td>http://dashif.org/guidelines/dash264#hd<td>2.0<td>[2], 8.3
  <tr><td>DASH-AVC/264 main<td>http://dashif.org/guidelines/dash264main<td>3.0<td>8.2
  <tr><td>DASH-AVC/264 high<td>http://dashif.org/guidelines/dash264high<td>3.0<td>8.3
  <tr><td>DASH-IF IOP simple<td>http://dashif.org/guidelines/dash-if-simple<td>3.0<td>8.4
  <tr><td>DASH-IF IOP main<td>http://dashif.org/guidelines/dash-if-main<td>3.0<td>8.5
  <tr><td>DASH-IF IOP on-demand<td>http://dashif.org/guidelines/dash-if-ondemand<td>4.3<td>3.10.3
  <tr><td>DASH-IF IOP mixed on-demand<td>http://dashif.org/guidelines/dash-if-mixed<td>4.3<td>3.10.4
</table>

Note that all extensions defined in version 2 of this document are carried over into version 3 without any modifications. In order to maintain a single document, referencing in Table 2 is restricted to this document.

<table class="def">
    <caption>DASH-IF Interoperability Point Extensions</caption>
    <tr><th>Extension<th>Identifier<th>Version<th>Section
    <tr><td>DASH-IF multichannel audio extension with Enhanced AC-3<td>http://dashif.org/guidelines/dashif#ec-3<td>2.0<td>9.4.2.3
    <tr><td>DASH-IF multichannel extension with Dolby TrueHD<td>http://dashif.org/guidelines/dashif#mlpa<td>2.0<td>9.4.2.3
    <tr><td>DASH-IF multichannel extension with AC-4<td>http://dashif.org/guidelines/dashif#ac-4<td>3.1<td>9.4.2.3
    <tr><td>DASH-IF multichannel audio extension with DTS Digital Surround<td>http://dashif.org/guidelines/dashif#dtsc<td>2.0<td>9.4.3.3
    <tr><td>DASH-IF multichannel audio extension with DTS-HD High Resolu-tion and DTS-HD Mas-ter Audio<td>http://dashif.org/guidelines/dashif#dtsh<td>2.0<td>9.4.3.3
    <tr><td>DASH-IF multichannel audio extension with DTS Express<td>http://dashif.org/guidelines/dashif#dtse<td>2.0<td>9.4.3.3
    <tr><td>DASH-IF multichannel extension with DTS-HD Lossless (no core)<td>http://dashif.org/guidelines/dashif#dtsl<td>2.0<td>9.4.3.3
    <tr><td>DASH-IF multichannel audio extension with MPEG Surround<td>http://dashif.org/guidelines/dashif#mps<td>2.0<td>9.4.4.3
    <tr><td>DASH-IF multichannel audio extension with HE-AACv2 level 4<td>http://dashif.org/guidelines/dashif#heaac-mc51<td>2.0<td>9.4.5.3
    <tr><td>DASH-IF multichannel audio extension with HE-AACv2 level 6<td>http://dashif.org/guidelines/dashif#heaac-mc71<td>2.0<td>9.4.5.3
    <tr><td>DASH-IF multichannel audio extension with MPEG-H 3D Audio<td>http://dashif.org/guidelines/dashif#mpeg-h-3da<td>4.2<td>9.4.6.3
    <tr><td>DASH-IF audio exten-sion with USAC<td>http://dashif.org/guidelines/dashif#cxha<td>4.3<td>9.4.7.3
    <tr><td>DASH-IF UHD HEVC 4k<td>http://dashif.org/guidelines/dash-if-uhd#4k<td>4.0<td>10.2
    <tr><td>DASH-IF HEVC HDR PQ10<td>http://dashif.org/guidelines/dash-if-uhd#hdr-pq10<td>4.0<td>10.3
    <tr><td>DASH-IF UHD Dual-Stream (Dolby Vision)<td>http://dashif.org/guidelines/dash-if-uhd#hdr-pq10<td>4.1<td>10.4
    <tr><td>DASH-IF VP9 HD<td>http://dashif.org/guide-lines/dashif#vp9<td>4.1<td>11.3.1
    <tr><td>DASH-IF VP9 UHD<td>http://dashif.org/guidelines/dash-if-uhd#vp9<td>4.1<td>11.3.2
    <tr><td>DASH-IF VP9 HDR<td>http://dashif.org/guide-lines/dashif#vp9-hdr \n http://dashif.org/guidelines/dash-if-uhd#vp9-hdr<td>4.1<td>11.3.3
</table>

In addition to the Interoperability points in Table 1 and extensions in Table 2, this document also defines several other identifiers and other interoperability values for functional purposes as documented in Table 3.

<table class="def">
    <caption>Identifiers and other interoperability values defined in this Document</caption>
    <tr><th>Identifier<th>Semantics<th>Type<th>Section
    <tr><td>http://dashif.org/identifiers/vast30<td>Defines an event for signalling events of VAST3.0<td>Event<td>5.6
    <tr><td>http://dashif.org/guidelines/trickmode<td>Defines a trick mode Adaptation Set.<td>Functionality<td>3.2.9
    <tr><td>http://dashif.org/guidelines/clearKey<td>Defines name space for the Laurl element in W3C<td>Namespace<td>7.6.2.4
    <tr><td>e2719d58-a985-b3c9-781a-b030af78d30e<td>UUID for W3C Clear Key with DASH<td>Content Protection<td>7.6.2.4
    <tr><td>http://dashif.org/guidelines/last-segment-number<td>Signaling last segment number<td>Functionality<td>4.4.3.6
    <tr><td>http://dashif.org/guidelines/thumbnail_tile<td>Signalling the availability of the thumbnail tile adaptation set<td>Functionality<td>6.2.6
</table>

DASH-IF supports these guidelines with test and conformance tools:
* DASH-IF conformance software is available for use online at http://dashif.org/conformance.html [32]. The software is based on an open-source code. The frontend source code and documentation is available at: https://github.com/Dash-Industry-Forum/Conformance-Software. The backend source code is available at: https://github.com/Dash-Industry-Forum/Conformance-and-reference-source.
* DASH-IF test assets (features, test cases, test vectors) along with the documentation are available at http://testassets.dashif.org [31]. 
* DASH Identifiers for different categories can be found at http://dashif.org/identifiers/ [33]. DASH-IF supporters are encouraged that external identifiers are submitted for doc-umentation there as well. Note also that DASH-IF typically tries to avoid defining iden-tifiers. Identifiers in italics are subject to discussion with other organizations and may be deprecated in a later version. 

Technologies included in this document and for which no test and conformance material is provided, are only published as a candidate technology and may be removed if no test material is provided before releasing a new version of this guidelines document.


# References # {#chapter-references}

See v4.3 references

# Conventions, Context, Terms and Definitions # {#chapter-conventions-context-terms-defn}

## Relation to MPEG-DASH ## {#relation-to-MPEG-DASH}
## Conventions ## {#conventions}
* usage of keywords
* Formats

see v4.3 and bug filed by Sander

## Abbreviations ## {#abbreviations}
see v4.3

## Terms and Definitions ## {#terms-and-definitions}
see v4.3 (may be hotlinked in bikeshed, auto generated)

# General DASH Features # {#general-DASH-features}

## Architecture ## {#architecture}
* High-level end-to-end streaming architecture
* ABR Encoder
* Encryption
* File Format Architecture
* DASH Packager and MPD Generator
* Origin Server
* CDN
* DASH Client
    * DASH access client
        * Selection
        * Download
    * Media Pipeline

Reference other DASH activities (Ingest, CPIX, SAND, etc.)

(re-use low-latency architecture)

## Formats ## {#formats}
(new clause with some usage from clause 3.2.1)

### MPD ### {#mpd}
* General high-level requirements

### Segments ### {#segments}
* Segment Formats in DASH
* Requirements
* Connect to CMAF and cmf2

### Segment Addressing Schemes ### {#segment-addressing-schemes}
* SegmentTemplate
    *  $Number$ and $Time$
* Self-Initializing
    * Single Segment with Segment Index
* Explain why we use different addressing
* Follows clause 3.5 of https://dashif-documents.azurewebsites.net//DASH-IF-IOP/pull/210/DASH-IF-IOP.html#timing-addressing

## Protocol Considerations ## {#protocol-considerations}
See clause 3.4 in v4.3

## Location and Reference Resolution ## {#location-and-reference-resolution}
See clause 3.2.15 in v4.3

## Client-Server Synchronization ## {#client-server-synchronization}
See clause 3.5 and 4.7 in v4.3

https://dashif-documents.azurewebsites.net//DASH-IF-IOP/pull/210/DASH-IF-IOP.html#timing-sync

## Client Reference Model ## {#client-reference-model}
Refer to dash.js and MSE

(new clause) point to CTA WAVE Device Playback

## Media Presentation Data Model ## {#media-presentation-data-model}
### Timing Model ### {#timing-model}
* Features
* Content Offering Requirements and Recommendations
* Client Requirements and Recommendations

See 3.2.7 and document from Sander

https://dashif-documents.azurewebsites.net//DASH-IF-IOP/pull/210/DASH-IF-IOP.html#timing-period

https://dashif-documents.azurewebsites.net//DASH-IF-IOP/pull/210/DASH-IF-IOP.html#timing-representation

### Content Annotation and Selection  ### {#content-annotation-and-selection}
* Features
* Content Offering Requirements and Recommendations
* Client Requirements and Recommendations

See 3.9 and document from Sander

### Adaptive Switching ### {#adaptive-switching}
* Features
* Content Offering Requirements and Recommendations
* Client Requirements and Recommendations

(Adaptation Set, segment and subsegment alignment)

https://dashif-documents.azurewebsites.net//DASH-IF-IOP/pull/210/DASH-IF-IOP.html#timing-segmentalignment

### Segment Timing ### {#segment-timing}
See clause 4.3 as well as document from Sander 3.5-3.5.4

https://dashif-documents.azurewebsites.net//DASH-IF-IOP/pull/210/DASH-IF-IOP.html#timing-sampletimeline

* @duration
* Segment Timeline
* Segment Index

## Bandwidth Signaling ## {#bandwidth-signaling}
* Minbuffertime
* @bandwidth
* Segment Index

See clause 3.2.8

## Service Types ## {#service-types}
See clause 3.6

On-Demand Services
* On-Demand Services
    * MPD Signaling
    * Reference to clause X
* Live Services
    * Content availability, time shift window and presentation delay concepts (Sander’s 3.8-3.9.4)
    * MPD Signaling
    * MPD updates (Sanders 3.8.5)
    * Reference to clause X

## Media in DASH ## {#media-in-dash}
(new clause)

### Media in one Period ### {#media-in-one-period}
* Features
* Content Offering Requirements and Recommendations
* Client Requirements and Recommendations
* Text from Sander 3.6

### Media Across Periods ### {#media-across-periods}
* Features
* Content Offering Requirements and Recommendations
* Client Requirements and Recommendations
* Text from Sander 3.7

### Requirements and Recommendation for Media Codecs in DASH ### {#req-rec-media-codecs}
* General Statements on how to add
* Capabilities
* Requirements on what needs to be defined (CMAF relation)

## Events ## {#events}
(new clause)

## Remote Elements ## {#remote-elements}
(new clause)

Text from Sander 3.9

https://dashif-documents.azurewebsites.net//DASH-IF-IOP/pull/210/DASH-IF-IOP.html#timing-xlink

## Profiles and Interop ## {#profiles-and-interop}
Clause 2.4

## Examples ## {#examples}
Clause 2.4

# On-Demand Services # {#on-demand-services}
Clause 3.10

# Live Services # {#live-services}
Clause 4, but reduced as some issues are moved to general clause

https://dashif-documents.azurewebsites.net//DASH-IF-IOP/pull/210/DASH-IF-IOP.html#timing-dynamic

# Content Replacement and Ad Insertion # {#content-replacements-and-ad-insertion}
Newly developed in Ad Insertion TF
    - Content conditioning and splicing

# Content Protection and Security # {#content-protection-and-security}
Based on Clause

# Video in DASH # {#video-in-dash}
(new clause adding all codecs in IOP)

(focusses on very specific issues following the general requirements from clause 4)

## General ## {#general3}

### MPD and Adaptation Set Signaling ### {#mpd-and-adaptationSet-signaling}

### Segment Formats ### {#segment-formats}

## H.264/AVC ## {#H264-AVC}
(add a table with media profiles and reference CMAF)
(create a clause with specific issues)

## H.265/HEVC ## {#H265-HEVC}
(add a table with media profiles and reference CMAF)
(create a clause with specific issues)

## VP9 ## {#VP9}

# Audio in DASH # {#audio-in-DASH}
(new clause adding all codecs in IOP)
(focusses on very specific issues following the general requirements from clause 4)
test;

## General ## {#general1}

### MPD and Adaptation Set Signaling ### {#mpd-and-adaptation-set-signaling}

### Segment Formats ### {#segment-formats2}

## (Codec 1) ## {#codec-1}
(add a table with media profiles and reference CMAF)
(create a clause with specific issues)

## (Codec 2) ## {#codec-2}
(add a table with media profiles and reference CMAF)
(create a clause with specific issues)

# Subtitles in DASH # {#subtitles-in-DASH}
(new clause adding all codecs in IOP)
(focusses on very specific issues following the general requirements from clause 4)

## General ## {#genera2}

### MPD and Adaptation Set Signaling ### {#MPD-and-adaptation-set-signaling}

### Segment Formats ### {#segment-formats3}

## (Codec 1) ## {#codec-1x}

(add a table with media profiles and reference CMAF)
(create a clause with specific issues)

## (Codec 2) ## {#codec-2x}
(add a table with media profiles and reference CMAF)
(create a clause with specific issues)

# Other DASH Features # {#other-DASH-features}
## Seek Preview and Thumbnail Navigation ## {#seek-preview-and-thumbnail-navigation}

# Annex Exclusions from MPEG-DASH # {#annex-exclusions-from-MPEG-DASH}
This section list the exclusions and forbidden options of MPEG-DASH.
Sanders 3.10 Forbidden techniques goes here

<!-- Document metadata follows. The below sections are used by the document compiler and are not directly visible. -->

<pre class="metadata">
Revision: 5.0

Title: Guidelines for Implementation: DASH-IF Interoperability Points
Status: LD
Shortname: iop
URL: https://dashif.org/guidelines/
Issue Tracking: GitHub https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues
Repository: https://github.com/Dash-Industry-Forum/DASH-IF-IOP GitHub
Editor: DASH Industry Forum

Default Highlight: text
<!-- Enabling line numbers breaks code blocks in PDF! (2018-10-02) -->
Line Numbers: off
Markup Shorthands: markdown yes
Boilerplate: copyright off, abstract off
Abstract: None
</pre>

<!-- Example of custom bibliography entries. Prefer adding your document to SpecRef over maintaining a custom definition. -->
<pre class="biblio">
{
}
</pre>

<pre boilerplate="logo">
<a href="https://dashif.org/"><img src="Images/DASH-IF.png" /></a>
</pre>
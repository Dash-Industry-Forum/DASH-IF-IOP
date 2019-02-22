# Document editing notes # {#introduction-editing}

Documentation: https://dashif.org/DocumentAuthoring/

Example document repository: https://dashif.org/DocumentAuthoring/

Live discussion in #document-authoring on Slack.

Scope
Disclaimer

# Introduction # {#chapter-introduction}

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
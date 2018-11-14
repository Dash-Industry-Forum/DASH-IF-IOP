# Document editing notes # {#introduction-editing}

Documentation: https://dashif.org/DocumentAuthoring/

Example document repository: https://dashif.org/DocumentAuthoring/

Live discussion in #document-authoring on Slack.

# Chapter 1 # {#chapter1-the-real-intro}

Placeholder text. This document will eventually contain IOP v5.

# Addressing and timing # {#timing}

This chapter describes an interoperable view of DASH presentation timing and segment addressing. The presentation manifest or <dfn>MPD</dfn> defines the <dfn>MPD timeline</dfn> which serves as the baseline for all scheduling decisions made during DASH presentation playback.

The playback of a static MPD SHALL NOT depend on the mapping of the MPD timeline to real time. A client MAY play any part of the presentation at any time as long as the presentation exists.

The MPD timeline of a dynamic MPD SHALL have a fixed mapping to real time, with each point on the timeline corresponding to a point in real time. Clients MAY introduce an additional offset with respect to real time [[#timing-timeshift|to the extent allowed by the time shift signaling in the MPD]].

The zero point in the MPD timeline of a dynamic MPD SHALL be mapped to the point in real time indicated by `MPD@availabilityStartTime`. This value SHALL NOT change between MPD updates.

The ultimate purpose of the MPD is to enable the client to obtain media samples for playback. The following data structures are most relevant to locating and scheduling the samples:

1. The MPD consists of consecutive [=periods=] which map data onto the MPD timeline.
1. Each period contains of one or more [=representations=], each of which provides media samples inside a sequence of [=media segments=].
1. Representations within a period are grouped in adaptation sets, which associate related representations and decorate them with metadata.

<figure>
	<img src="Images/Timing/BasicMpdElements.png" />
	<figcaption>Illustration of the primary elements described by an MPD.</figcaption>
</figure>

The chapters below explore these relationships in detail.

## Periods ## {#timing-period}

An MPD SHALL define an ordered list of one or more <dfn id="period">periods</dfn>. A period is both a time span on the [=MPD timeline=] and a definition of the data to be presented during the period. Period timing is relative to the zero point of the [=MPD timeline=].

All periods SHALL be consecutive and non-overlapping.

<div class="example">
The below MPD example consists of two 20-second periods. The duration of the first period is calculated using the start point of the second period.

<xmp highlight="xml">
<MPD type="static" mediaPresentationDuration="PT40S">
	<Period>
		...
	</Period>
	<Period start="PT20S" duration="PT20S">
		...
	</Period>
</MPD>
</xmp>
</div>

In a static MPD, the first period SHALL start at the zero point of the [=MPD timeline=]. In a dynamic MPD, the first period SHALL start at or after the zero point of the [=MPD timeline=].

In a static MPD, the last period SHALL have a `Period@duration`. In a dynamic MPD, the last period MAY lack a `Period@duration`, in which case it SHALL be considered to have an unlimited duration.

In a static MPD, `MPD@mediaPresentationDuration` SHALL be present. In a dynamic MPD, `MPD@mediaPresentationDuration` MAY be present. When present, `MPD@mediaPresentationDuration` SHALL accurately indicate the duration between the zero point on the [=MPD timeline=] and the end of the last period.

## Representations ## {#timing-representation}

A <dfn>representation</dfn> is a sequence of references to [=media segments=] containing media samples. Each representation belongs to exactly one adaptation set and to exactly one [=period=], although [[#timing-continuity|a representation may be logically continuous with a representation in another period]].

In a static MPD, the representation SHALL reference media segments so that the [=MPD timeline=] is covered with segments at least from the beginning of the period to the end of the period.

<figure>
	<img src="Images/Timing/MandatorySegmentReferencesInDynamicMpd.png" />
	<figcaption>In a dynamic MPD, the time shift window determines the set of required [=media segment=] references. Segments filled with gray need not be referenced by representations due to falling outside the time shift window, despite falling within the bounds of a period.</figcaption>
</figure>

In a dynamic MPD, the representation SHALL reference [=media segments=] for the part of the [=period=] which falls within the time shift window and SHOULD NOT reference [=media segments=] that lie entirely outside the time shift window.

Note: In other words, outdated references should be cleaned up once they are entirely outside the time shift window and future [=media segments=] that are not yet in the time shift window need not be referenced.

There SHALL NOT be gaps or overlapping [=media segments=] in a representation.

A representation SHOULD NOT reference [=media segments=] that are entirely out of the bounds of the [=period=]. Clients SHALL NOT present any samples from [=media segments=] that are entirely outside the [=period=], even if such [=media segments=] are referenced.

Note: It may be impractical to exclude irrelevant [=media segments=] in some situations. For example, if you use `SegmentBase` addressing, there exists an index segment on disk that references all [=media segments=]. If a [=period=] is only intended to present a subset of these [=media segments=], it would be needlessly complicated to require a period-specific index segment to be generated.

<figure>
	<img src="Images/Timing/SamplesOnPeriodBoundary.png" />
	<figcaption>[=Media segments=] and samples need not align with [=period=] boundaries. Some samples may be entirely outside a [=period=] (marked gray) and some may overlap the [=period=] boundary (yellow).</figcaption>
</figure>

[=Media segment=] start/end points MAY be unaligned with [=period=] start/end points. If a [=media segment=] overlaps a [=period=] boundary, clients SHOULD NOT present the samples that lie outside the [=period=]. Whether samples that overlap a [=period=] boundary are to be considered inside or outside the [=period=] is implementation-defined.

Note: It may be impractical to present [=media segments=] only partially, depending on the capabilties of the client platform, the type of media samples involved and any dependencies between samples. It is up to the client to ensure that platform capabilities are not exceeded and to account for the time shift that it incurs due to over-/underplayback.

## Sample timeline ## {#timing-sampletimeline}

The samples within a [=representation=] exist on a <dfn>sample timeline</dfn> defined by the encoder that created the samples. One or more sample timelines are mapped onto the [=MPD timeline=] by metadata stored in or referenced by the [=MPD=].

The sample timeline SHALL be shared by all [=representations=] in the same adaptation set. [=Representations=] in different adaptation sets MAY use different sample timelines.

The sample timeline is measured in unnamed timescale units. The term timescale refers to the number of timescale units per second. This value may be present in the [=MPD=] as the `@timescale` attribute, [[#timing-addressingmodes|depending on the addressing mode used]].

<figure>
	<img src="Images/Timing/PresentationTimeOffset.png" />
	<figcaption>`@presentationTimeOffset` establishes the relationship between the [=MPD timeline=] and the sample timeline.</figcaption>
</figure>

The point on the sample timeline indicated by `@presentationTimeOffset` (in timescale units, default zero) SHALL be considered equivalent to the [=period=] start point on the [=MPD timeline=].

If a `SegmentTemplate` [[#timing-addressingmodes|addressing mode]] is used, `@presentationTimeOffset` SHALL be a point within or at the start of the first [=media segment=] that is currently or was previously referenced by the [=period=] (the first [=media segment=] might no longer be referenced by a dynamic [=MPD=] if it has fallen out of the time shift window).

If a `SegmentBase` [[#timing-addressingmodes|addressing mode]] is used, `@presentationTimeOffset` SHALL be a point within or at the start of any [=media segment=] referenced by the [=period=].

## Media segments ## {#timing-mediasegment}

A <dfn>media segment</dfn> is an HTTP-addressable data structure that contains one or more media samples.

Note: Parts of [[MPEGDASH]] use the term "subsegment" instead of "segment". The distinction is largely irrelevant in practice.

[=Media segments=] SHALL contain one or more consecutive media samples.

[=Media segments=] SHALL contain the media samples that exactly match the time span on the [=sample timeline=] that is mapped to the segment's associated time span on the [=MPD timeline=], except when the [[#timing-addressingmodes|addressing mode]] in use allows for inaccuracy in [=media segment=] contents.

### Inaccurate addressing ### {#timing-mediasegment-inaccuracy}

In addressing modes that allow for inaccuracy in [=media segment=] contents, a deviation of up to 50% of the nominal segment duration SHALL be acceptable, in either direction at either end or both ends, provided that this deviation does not violate any constraints defined by this document (e.g. the entire [=period=] must still be covered with a continuous sequence of non-overlapping media samples).

Note: Inaccurate addressing is intended to allow reasoning on the [=MPD timeline=] using average values for [=media segment=] timing. If the addressing data says that a [=media segment=] contains 4 seconds of data on average, a client can predict with reasonable accuracy which samples are found in which segments, while at the same time the packager is not required to emit per-segment timing data in the [=MPD=]. It is expected that the content is packaged with this contraint in mind (i.e. **every** segment cannot be inaccurate in the same direction - a shorter segment now implies a longer segment in the future to make up for it).

<div class="example">
Consider a [=media segment=] with a nominal start time of 10 seconds from period start and a nominal duration of 4 seconds, within a [=period=] of unlimited duration, using an addressing mode that allows for inaccuracy.

The following are all valid contents for such a media segment:

* samples from 10 to 14 seconds (perfect accuracy)
* samples from 8 to 16 seconds (maximally large segment allowed by drift tolerance, 50% increase from both ends)
* samples from 11.9 to 12 seconds (near-minimally small segment; while drift tolerance allows 50% decrease from both ends, resulting in zero duration, every segment must still contain at least one sample)
* samples from 8 to 12 seconds (maximal drift toward zero point at both ends)
* samples from 12 to 16 seconds (maximal drift away from zero point at both ends)

Near [=period=] boundaries, all the constraints of timing and addressing must still be respected. Consider a [=media segment=] with a nominal start time of 0 seconds from [=period=] start and a nominal duration of 4 seconds, using an addressing mode that allows for inaccuracy.

If such a [=media segment=] contained samples from 1 to 5 seconds (drift of 1 second away from zero point at both ends, which is within acceptable limits) it would be non-conforming because it would leave a gap of 1 second at the start of the [=period=] that is not covered by samples.
</div>

## Segment addressing modes ## {#timing-addressingmodes}

Issue: Determine appropriate content for this section.

## Segment alignment ## {#timing-segmentalignment}

Segments are said to be aligned if the start/end points of all [=media segments=] are equal in all [=representations=] that belong to the same adaptation set. This is expressed by the `AdaptationSet@segmentAlignment` or `AdaptationSet@subsegmentAlignment` attributes in the [=MPD=] (depending on profile).

Segments SHALL be aligned.

## Period continuity ## {#timing-continuity}

As a [=period=] may start and/or end in the middle of a segment, the same segment may exist in two period-continuous [=representations=], with one part of it being ideally presented during the first [=period=] and the other part of it during the second [=period=].

Clients SHALL deduplicate [=media segments=] that overlap the bounds of period-continuous representations in order to enable seamless playback of period-continuous [=representations=].

Note: The exact behavior depends greatly on the client implementation details. It may be that a client will simply shift such a partial segment in its entirety to either the first or the second [=period=] in the interest of implementation simplicity.

An [=MPD=] MAY contain unrelated [=periods=] between [=periods=] that contain period-continuous representations.

Issue: This section obviously needs more text, just constraining it to current proposal scope here.

## Time shift window ## {#timing-timeshift}

Issue: Determine appropriate content for this section.

## XLink ## {#timing-xlink}

Issue: Determine appropriate content for this section.

## Leap seconds ## {#timing-leapseconds}

This section is intentionally left blank to indicate that the leap seconds topic is out of scope of this proposal.

## Forbidden techniques ## {#timing-nonos}

Some aspects of [[!MPEGDASH]] are not compatible with the interoperable timing model defined in this document. In the interest of clarity, they are explicitly listed here:

* The `@presentationDuration` attribute SHALL NOT be used.

## Dynamic MPD updates ## {#timing-mpdupdates}

Issue: Determine appropriate content for this section.

## Bringing nonconforming content into conformance ## {#timing-make-conformant}

Some existing content that does not conform to IOP addressing and timing requirements can be easily made conforming via manifest manipulation. This section describes some common issues and their solutions.

<table class="def">
	<tr>
		<th>Nonconforming aspect</th>
		<th>Solution</th>
	</tr>
	<tr>
		<td>One or more representations are "short" - there are no addressable segments for them for some time span before the end of the period.</td>
		<td>[[#timing-examples-splitperiod|Split the period]] at the point where the last segment of a "short" representation ends and drop the representation from the next period.</td>
	</tr>
</table>

## Examples ## {#timing-examples}

This section is informative.

### Split a period ### {#timing-examples-splitperiod}

There exist scenarios where you would wish to split a period in two. Common reasons would be:

* to insert an ad [=period=] in the middle of an existing [=period=].
* parameters of one adaptation set change (e.g. KID or display aspect ratio), requiring a new [=period=] to update signaling.
* some adaptation sets become available or unavailable (e.g. different languages).

This example shows how an existing [=period=] can be split in a way that clients capable of [[#timing-continuity|period-continuous playback]] do not experience interruptions in playback among representations that are present both before and after the split.

Our starting point is a presentation with a single period that contains an audio [=representation=] with short samples and a video [=representation=] with slightly longer samples, so that [=media segment=] start points do not always overlap.

<figure>
	<img src="Images/Timing/SplitInTwoPeriods - Before.png" />
	<figcaption>Presentation with one period, before splitting. Blue is a segment, yellow is a sample. Duration in arbitrary units is listed on samples. Segment durations are taken to be the sum of sample durations. `presentationTimeOffset` may have any value - it is listed because will be referenced later.</figcaption>
</figure>

Note: [=Periods=] may be split at any point in time as long as both sides of the split remain in conformance to this document (e.g. each contains at least 1 [=media segment=]). Furthermore, period splitting does not require manipulation of the segments themselves, only manipulation of the MPD.

Let's split this period at position 220. This split occurs during segment 3 for both [=representations=] and during sample 8 and sample 5 of the audio and video [=representation=], respectively.

The mechanism that enables [=period=] splitting in the middle of a segment is the following:

* a segment that overlaps a period boundary exists in both periods.
* representations that are split are signaled in the MPD as period continuous.
* a representation that is period-continuous with a representation in a previous period is marked with the period continuity descriptor.
* clients are expected to deduplicate boundary-overlapping segments for representations on which period continuity is signaled.
* clients are expected to present only the samples that are within the bounds of the current period (may be limited by client platform capabilities).

After splitting the example presentation, we arrive at the following structure.

<figure>
	<img src="Images/Timing/SplitInTwoPeriods - After.png" />
	<figcaption>Presentation with two periods, after splitting. Audio segment 3 and video segment 3 are shared by both periods, with the continuity signaling indicating that continuous playback with de-duplicating behavior is expected from clients.</figcaption>
</figure>

Depending on the segment addressing mode used, the two resulting periods may reference more segments than necessary. For example, if `SegmentBase` addressing is used, both periods will reference all segments as both periods will use the same unmodified index segment. Clients are expected to ignore [=media segments=] that fall outside the [=period=] bounds.

Other [=periods=] (e.g. ads) may be inserted between the two [=periods=] resulting from the split. This does not affect the addressing and timing of the two [=periods=].



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
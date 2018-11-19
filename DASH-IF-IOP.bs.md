# Document editing notes # {#introduction-editing}

Documentation: https://dashif.org/DocumentAuthoring/

Example document repository: https://dashif.org/DocumentAuthoring/

Live discussion in #document-authoring on Slack.

# Chapter 1 # {#chapter1-the-real-intro}

Placeholder text. This document will eventually contain IOP v5.

# Timing and addressing # {#timing}

This chapter describes an interoperable view of DASH presentation timing and segment addressing. This interpretation is considerably narrower than afforded by [[MPEGDASH]], constraining services to a specific set of reasonably flexible behaviors that are highly interoperable with modern client platforms. Services conforming to this document SHALL use this timing model.

The presentation manifest or <dfn>MPD</dfn> defines the <dfn>MPD timeline</dfn> which serves as the baseline for all scheduling decisions made during DASH presentation playback.

The playback of a static MPD SHALL NOT depend on the mapping of the MPD timeline to real time. A client MAY play any part of the presentation at any time.

The MPD timeline of a dynamic MPD SHALL have a fixed mapping to real time, with each point on the timeline corresponding to a point in real time. Clients MAY introduce an additional offset with respect to real time [[#timing-timeshift|to the extent allowed by the time shift signaling in the MPD]].

Note: In addition to mapping the content to real time, [[#timing-mpd-updates|a dynamic MPD can be updated during the presentation]]. Updates may add new periods and remove or modify existing ones.

The zero point in the MPD timeline of a dynamic MPD SHALL be mapped to the point in real time indicated by `MPD@availabilityStartTime`. This value SHALL NOT change between MPD updates.

The ultimate purpose of the MPD is to enable the client to obtain media samples for playback. The following data structures are most relevant to locating and scheduling the samples:

1. The MPD consists of consecutive [=periods=] which map data onto the MPD timeline.
1. Each period contains of one or more [=representations=], each of which provides media samples inside a sequence of [=media segments=].
1. Representations within a period are grouped in [=adaptation sets=], which associate related representations and decorate them with metadata.

<figure>
	<img src="Images/Timing/BasicMpdElements.png" />
	<figcaption>The primary elements described by an MPD.</figcaption>
</figure>

The chapters below explore these relationships in detail.

## Periods ## {#timing-period}

An MPD SHALL define an ordered list of one or more <dfn title="period">periods</dfn>. A period is both a time span on the [=MPD timeline=] and a definition of the data to be presented during the period. Period timing is relative to the zero point of the [=MPD timeline=].

<figure>
	<img src="Images/Timing/PeriodsMakeTheMpd.png" />
	<figcaption>An MPD is a collection of periods, starting from a zero point and with a total duration (which may be unlimited for live services).</figcaption>
</figure>

Common reasons for defining multiple periods are:

* Assembling a presentation from multiple self-contained pieces of content.
* Inserting ads in the middle of existing content and/or replacing spans of existing content with ads.
* Adding/removing certain representations as the nature of the content changes (e.g. a new title starts with a different set of offered languages).
* Updating period-scoped metadata (e.g. codec configuration or DRM signaling).

Perioods are self-contained - a service SHALL NOT require a client to know the contents of another period in order to correctly present a period. Knowledge of the contents of different periods MAY be used by a client to achieve seamless period transitions, especially when working with [[#timing-connectivity|period-connected representations]].

All periods SHALL be consecutive and non-overlapping. A period MAY have a duration of zero.

Note: A period with a duration of zero might, for example, be the result of ad-insertion logic deciding not to insert any ad.

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

In a static MPD, `MPD@mediaPresentationDuration` SHALL be present. In a dynamic MPD, `MPD@mediaPresentationDuration` SHALL be present if the content of the MPD will no longer be updated and SHALL NOT be present if the content of the MPD might be updated.

Note: Publishing a dynamic MPD that will not be updated enables a service to schedule the availability of content that has already been fully generated (e.g. a finished live event or a scheduled playback of existing content).

When present, `MPD@mediaPresentationDuration` SHALL accurately indicate the duration between the zero point on the [=MPD timeline=] and the end of the last [=period=].

## Representations ## {#timing-representation}

A <dfn>representation</dfn> is a sequence of references to [=media segments=] containing media samples. Each representation belongs to exactly one [=adaptation set=] and to exactly one [=period=], although [[#timing-connectivity|a representation may be connected with a representation in another period]].

A reference to a [=media segment=] determines which [=media segment=] corresponds to which time span on the [=MPD timeline=]. The exact mechanism used to define references depends on the [=addressing mode=] used by the representation. All representations in the same [=adaptation set=] SHALL use the same [=addressing mode=].

A representation SHALL reference a set of media segments that ensures the [=MPD timeline=] is covered with segments at least from the beginning of the period active range to the end of the period active range.

In a static MPD, the period active range SHALL be the entire time span of a [=period=].

<figure>
	<img src="Images/Timing/StaticMpdMustBeCovered.png" />
	<figcaption>In a static MPD, the entire period must be covered with [=media segments=].</figcaption>
</figure>

In a dynamic MPD, the period active range SHALL be the time span of the [=period=] constrained to the time shift window.

<figure>
	<img src="Images/Timing/MandatorySegmentReferencesInDynamicMpd.png" />
	<figcaption>In a dynamic MPD, the time shift window determines the set of required [=media segment=] references. [=Media segments=] filled with gray need not be referenced due to falling outside the time shift window, despite falling within the bounds of a [=period=].</figcaption>
</figure>

In a static MPD, a representation SHALL NOT reference [=media segments=] that are not necessary to cover the period active range with segments, except when using [=indexed addressing=] in which case such [=media segments=] MAY be referenced.

In a dynamic MPD, a representation SHOULD NOT reference [=media segments=] that are older than the period active range if using [=explicit addressing=]. Such [=media segments=] MAY be referenced if using other addressing modes.

Note: For scheduled playback of pre-generated content, it is needless complexity to require old [=media segment=] references to be removed. However, obsolete references should be removed in ongoing live presentations to keep the [=MPD=] small and efficient to process.

There SHALL NOT be gaps or overlapping [=media segments=] in a representation.

A representation SHALL NOT reference [=media segments=] that are entirely out of the bounds of the [=period=], except when using [=indexed addressing=] in which case such [=media segments=] MAY be referenced. Clients SHALL NOT present any samples from [=media segments=] that are entirely outside the [=period=], even if such [=media segments=] are referenced.

Note: If you use [=indexed addressing=], there exists an index segment on disk that references all [=media segments=]. If a [=period=] is only intended to present a subset of these [=media segments=], it would be needlessly complicated to require a period-specific index segment to be generated.

<figure>
	<img src="Images/Timing/SamplesOnPeriodBoundary.png" />
	<figcaption>[=Media segments=] and samples need not align with [=period=] boundaries. Some samples may be entirely outside a [=period=] (marked gray) and some may overlap the [=period=] boundary (yellow).</figcaption>
</figure>

[=Media segment=] start/end points MAY be unaligned with [=period=] start/end points. If a [=media segment=] overlaps a [=period=] boundary, clients SHOULD NOT present the samples that lie outside the [=period=]. Whether samples that overlap a [=period=] boundary are to be considered inside or outside the [=period=] is implementation-defined.

Issue: The boundary-overlapping sample treatment being vague like this feels wrong. Is there an interoperable interpretation that we can just state here? It feels a very low level detail, hard to estimate what is practical.

Note: It may be impractical to present [=media segments=] only partially, depending on the capabilties of the client platform, the type of media samples involved and any dependencies between samples. It is up to the client to ensure that platform capabilities are not exceeded and to account for the time shift that it incurs due to over-/underplayback.

## Sample timeline ## {#timing-sampletimeline}

<figure>
	<img src="Images/Timing/TimelineAlignment.png" />
	<figcaption>Sample timelines are mapped onto the [=MPD timeline=] based on parameters defined in the [=MPD=].</figcaption>
</figure>

The samples within a [=representation=] exist on a linear <dfn>sample timeline</dfn> defined by the encoder that created the samples. One or more sample timelines are mapped onto the [=MPD timeline=] by metadata stored in or referenced by the [=MPD=].

Note: The sample timeline is linear - encoders are expected to use an appropriate timescale and sufficiently large timestamp fields to avoid any wrap-around. If wrap-around does occur, a new [=period=] must be started in order to establish a new sample timeline.

The sample timeline SHALL be shared by all [=representations=] in the same [=adaptation set=]. [=Representations=] in different [=adaptation sets=] MAY use different sample timelines.

The sample timeline is measured in unnamed timescale units. The term timescale refers to the number of timescale units per second. This value SHALL be present in the [=MPD=] as `SegmentTemplate@timescale`.

<figure>
	<img src="Images/Timing/PresentationTimeOffset.png" />
	<figcaption>`SegmentTemplate@presentationTimeOffset` establishes the relationship between the [=MPD timeline=] and the sample timeline.</figcaption>
</figure>

The point on the sample timeline indicated by `SegmentTemplate@presentationTimeOffset` (in timescale units, default zero) SHALL be considered equivalent to the [=period=] start point on the [=MPD timeline=].

If [=simple addressing=] or [=explicit addressing=] is used, `SegmentTemplate@presentationTimeOffset` SHALL be a point within or at the start of the [=media segment=] that starts at or overlaps the [=period=] start point, even if this [=media segment=] is no longer referenced by the [=MPD=] (as may be the case with a dynamic MPD if the [=media segment=] has fallen out of the time shift window).

If [=indexed addressing=] is used, `SegmentTemplate@presentationTimeOffset` SHALL be a point within or at the start of any [=media segment=] referenced by the [=period=].

## Media segments ## {#timing-mediasegment}

A <dfn>media segment</dfn> is an HTTP-addressable data structure that contains one or more media samples.

Note: [[MPEGDASH]] makes a distinction between "segment" (HTTP-addressable entity) and "subsegment" (byte range of an HTTP-addressable entity). This document refers to both concepts as "segment".

Issue: Moving to CMAF terms might simplify the linguistic overhead caused by DASH terminology here. See https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/217

[=Media segments=] SHALL contain one or more consecutive media samples. Consecutive [=media segments=] in the same [=representation=] SHALL contain consecutive media samples.

[=Media segments=] SHALL contain the media samples that exactly match the time span on the [=sample timeline=] that is mapped to the segment's associated time span on the [=MPD timeline=], except when using [=simple addressing=] in which case a certain amount of inaccuracy MAY be present as defined in [[#timing-addressing-inaccuracy]].

The [=media segment=] that starts at or overlaps the [=period=] start point on the [=MPD timeline=] SHALL contain a media sample that starts at or overlaps the [=period=] start point.

The [=media segment=] that ends at or overlaps the [=period=] end point on the [=MPD timeline=] SHALL contain a media sample that ends at or overlaps the [=period=] end point.

Note: The requirements on providing samples for the [=period=] start/end point in the first/last [=media segment=] apply even when [[#timing-addressing-inaccuracy|inaccurate addressing]] is used.

## Segment addressing modes ## {#timing-addressing}

Issue: Need to go over segment-related terminology and ideally move to CMAF terms (https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/217). Right now this is a bit too "media segment" oriented.

This section defines the <dfn title="addressing mode">addressing modes</dfn> that can be used for referencing [=media segments=] in interopreable DASH presentations.

The choice of addressing mode depends on the implementation details of a particular content processing flow. Use whichever addressing mode is suitable for your needs when authoring content.

Addressing modes not listed in this chapter SHALL NOT be used.

All [=representations=] in the same [=adaptation set=] SHALL use the same addressing mode. [=Representations=] in different [=adaptation sets=] MAY use different addressing modes.

### Indexed addressing ### {#timing-addressing-indexed}

Placeholder chapter.

<dfn>indexed addressing</dfn> means `SegmentTemplate` with `@indexRange`.

### Explicit addressing ### {#timing-addressing-explicit}

Placeholder chapter.

<dfn>explicit addressing</dfn> means `SegmentTemplate` with `SegmentTimeline`.

### Simple addressing ### {#timing-addressing-simple}

Placeholder chapter.

<dfn>simple addressing</dfn> means `SegmentTemplate` without `SegmentTimeline`.

#### Inaccurate addressing #### {#timing-addressing-inaccuracy}

When using [=simple addressing=], the samples contained in a [=media segment=] MAY cover a different time span on the [=sample timeline=] than what is indicated in the [=MPD=], as long as no constraints defined in this document are violated by this deviation.

<figure>
	<img src="Images/Timing/InaccurateAddressing.png" />
	<figcaption>Inaccurate addressing relaxes the requirement on [=media segment=] contents matching the [=MPD timeline=] and the [=sample timeline=]. Red boxes indicate samples.</figcaption>
</figure>

The allowed deviation is defined as the maximum offset between the edges of the nominal time span (as defined by the segment reference in the [=MPD=]) and the edges of the true time span (as defined by the contents of the [=media segment=]). The deviation is evaluated separately for each edge.

The deviation SHALL be no more than 50% of the nominal segment duration and MAY be in either direction.

Note: This results in a maximum true duration of 200% (+50% outward extension on both edges) and a minimum segment duration of 1 sample (-50% inward from both edges would result in 0 but empty segments are not allowed).

This allowed deviation does not relax any requirements that do not explicitly define an exception. For example, [=periods=] must still be covered with samples for their entire duration, which constrains the flexibility allowed for the first and last [=media segment=].

Note: Inaccurate addressing is intended to allow reasoning on the [=MPD timeline=] using average values for [=media segment=] timing. If the addressing data says that a [=media segment=] contains 4 seconds of data on average, a client can predict with reasonable accuracy which samples are found in which segments, while at the same time the packager is not required to emit per-segment timing data in the [=MPD=]. It is expected that the content is packaged with this contraint in mind (i.e. **every** segment cannot be inaccurate in the same direction - a shorter segment now implies a longer segment in the future to make up for it).

<div class="example">
Consider a [=media segment=] with a nominal start time of 10 seconds from period start and a nominal duration of 4 seconds, within a [=period=] of unlimited duration.

The following are all valid contents for such a [=media segment=]:

* samples from 10 to 14 seconds (perfect accuracy)
* samples from 8 to 16 seconds (maximally large segment allowed by drift tolerance, 50% increase from both ends)
* samples from 11.9 to 12 seconds (near-minimally small segment; while drift tolerance allows 50% decrease from both ends, resulting in zero duration, every segment must still contain at least one sample)
* samples from 8 to 12 seconds (maximal drift toward zero point at both ends)
* samples from 12 to 16 seconds (maximal drift away from zero point at both ends)

Near [=period=] boundaries, all the constraints of timing and addressing must still be respected. Consider a [=media segment=] with a nominal start time of 0 seconds from [=period=] start and a nominal duration of 4 seconds.

If such a [=media segment=] contained samples from 1 to 5 seconds (drift of 1 second away from zero point at both ends, which is within acceptable limits) it would be non-conforming because of the requirement in [[#timing-mediasegment]] that the first [=media segment=] contain a media sample that starts at or overlaps the [=period=] start point.
</div>

## Segment alignment ## {#timing-segmentalignment}

[=Media segments=] are said to be aligned if the start/end points of all [=media segments=] on the [=MPD timeline=] are equal in all [=representations=] that belong to the same [=adaptation set=].

[=Media segments=] SHALL be aligned. When using [=simple addressing=] or [=explicit addressing=], this means `AdaptationSet@segmentAlignment=true` in the [=MPD=]. When using [=indexed addressing=], this means `AdaptationSet@subsegmentAlignment=true` in the [=MPD=].

Equivalent aligned [=media segments=] in different [=representations=] SHALL contain samples for the same time span on the [=sample timeline=], even if using [[#timing-addressing-inaccuracy|inaccurate addressing]].

## Period connectivity ## {#timing-connectivity}

In certain circumstances content may be offered such that a [=period=] contains a continuation of the content in a previous [=period=]. Such content SHOULD be signaled in the [=MPD=] as period-connected, to help clients ensure seamless playback across [=period=] transitions. Any subset of the [=representations=] in a [=period=] MAY be <dfn>period-connected</dfn> with their counterparts in a future or past [=period=]. Period connectivity MAY be chained across any number of [=periods=].

An [=MPD=] MAY contain unrelated [=periods=] between [=periods=] that contain period-connected [=representations=].

[=Initialization segments=] of period-connected [=representations=] SHALL be functionally equivalent (i.e. the [=initialization segment=] from any period-connected [=representation=] can be used to initialize playback of any period-connected [=representation=]).

The following signaling SHALL be used to identify period-connected [=representations=] across two [=periods=]:

* `Representation@id` is equal.
* `AdaptationSet@id` is equal.
* The [=adaptation set=] in the second [=period=] has a supplemental property with:
	* `@shemeIdUri` set to `urn:mpeg:dash:period-connectivity:2015`.
	* `@value` set to the `Period@id` of the first period.

Note: Not all [=representations=] in an [=adaptation set=] need to be period-connected. For example, if a new [=period=] is introduced to add a [=representation=] that contains a new video quality level, all other [=representations=] will likely be connected but not the one that was added.

The [=sample timelines=] of period-connected [=representations=] MAY be mutually discontinuous (e.g. due to skipping some content, encoder clock wrap-around or editorial decisions).

<figure>
	<img src="Images/Timing/SegmentOverlapOnPeriodConnectivity.png" />
	<figcaption>The same [=media segment=] will often exist in two periods at a period-connected transition. On the diagram, this is segment 4.</figcaption>
</figure>

As a [=period=] may start and/or end in the middle of a [=media segment=], the same [=media segment=] MAY simultaneously exist in two period-connected [=representations=], with one part of it scheduled for playback during the first [=period=] and the other part during the second [=period=]. This is likely to be the case when no [=sample timeline=] discontinuity is introduced by the transition.

Clients SHOULD NOT present a [=media segment=] twice when it occurs on both sides of a period transition in a period-connected [=representation=].

Clients SHOULD ensure seamless playback of period-connected [=representations=] in consecutive [=periods=].

Note: The exact mechanism that ensures seamless playback depends on client capabilities and will be implementation-specific. The shared [=media segment=] may need to be detected and deduplicated to avoid presenting it twice.

### Period continuity ### {#timing-connectivity-continuity}

In addition to [[#timing-connectivity|period connectivity]], [[!MPEGDASH]] defines period continuity, which is a special case of period connectivity where the two samples on the boundary between the connected [=representations=] are consecutive on the same [=sample timeline=].

Note: The above can only be true if the sample boundary exactly matches the period boundary.

Period continuity MAY be signaled in the [=MPD=] when the above condition is met, in which case period connectivity SHALL NOT be simultaneously signaled on the same [=representation=]. Continuity implies connectivity.

The signaling of period continuity is the same as for [[#timing-connectivity|period connectivity]], except that the value to use for `@schemeIdUri` is `urn:mpeg:dash:period-continuity:2015`.

Clients MAY take advantage of any platform-specific optimizations for seamless playback that knowledge of period continuity enables; otherwise, clients SHALL treat continuity the same as connectivity.

## Time shift window ## {#timing-timeshift}

Issue: Determine appropriate content for this section.

## Real time clock synchronization ## {#timing-sync}

Issue: Determine appropriate content for this section.

## XLink ## {#timing-xlink}

Issue: Determine appropriate content for this section.

## Leap seconds ## {#timing-leapseconds}

This section is intentionally left blank to indicate that the leap seconds topic is out of scope of this proposal.

## Forbidden techniques ## {#timing-nonos}

Some aspects of [[!MPEGDASH]] are not compatible with the interoperable timing model defined in this document. In the interest of clarity, they are explicitly listed here:

* The `@presentationDuration` attribute SHALL NOT be used.

## Dynamic MPD updates ## {#timing-mpd-updates}

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

### Offer content with imperfectly aligned tracks ### {#timing-examples-not-same-length}

It may be that for various content processing workflow reasons, some tracks have a different duration from others. For example, the audio track might start a fraction of a second before the video track and end some time before the video track ends.

<figure>
	<img src="Images/Timing/NonequalLengthTracks - Initial.png" />
	<figcaption>Content with different track lengths, before packaging as DASH.</figcaption>
</figure>

You now have some choices to make in how you package these tracks into a DASH presentation that conforms to this document. Specifically, there exists the requirement that every [=representation=] must cover the entire [=period=] with media samples.

<figure>
	<img src="Images/Timing/NonequalLengthTracks - CutEverything.png" />
	<figcaption>Content may be cut (indicated in black) to equalize track lengths.</figcaption>
</figure>

The simplest option is to define a single [=period=] that contains [=representations=] resulting from cutting the content to match the shortest common time span, thereby covering the entire [=period=] with samples. Depending on the nature of the data that is removed, this may or may not be acceptable.

<figure>
	<img src="Images/Timing/NonequalLengthTracks - PadEverything.png" />
	<figcaption>Content may be padded (indicated in green) to equalize track lengths.</figcaption>
</figure>

If you wish to preserve track contents in their entirety, the most interoperable option is to add padding samples (e.g. silence or black frames) to all tracks to ensure that all [=representations=] have enough data to cover the entire [=period=] with samples. This may require customization of the encoding process, as the padding must match the codec configuration of the real content and might be impractical to add after the real content has already been encoded.

<figure>
	<img src="Images/Timing/NonequalLengthTracks - MakePeriods.png" />
	<figcaption>New periods may be started at any change in the set of available tracks.</figcaption>
</figure>

Another option that preserves track contents is to [[#timing-examples-splitperiod|split the content]] into multiple [=periods=] that each contain a different set of [=representations=], starting a new [=period=] whenever a track starts or ends. This enables you to ensure every [=representations=] covers its [=period=] with samples. The upside of this approach is that it can be done easily, requiring only manipulation of the [=MPD=]. The downside is that some clients may be unable to seamlessly play across every [=period=] transition.

<figure>
	<img src="Images/Timing/NonequalLengthTracks - Mix.png" />
	<figcaption>You may combine the different approaches, cutting in some places (black), padding in others (green) and defining multiple [=periods=] as needed.</figcaption>
</figure>

You may wish to combine the different approaches, depending on the track, to achieve the optimal result.

Some clients are known to fail when transitioning from a period with audio and video to a period with only one of these components. You should avoid such transitions unless you have exact knowledge of the capabilities of your clients.

### Split a period ### {#timing-examples-splitperiod}

There exist scenarios where you would wish to split a [=period=] in two. Common reasons would be:

* to insert an ad [=period=] in the middle of an existing [=period=].
* parameters of one [=adaptation set=] change (e.g. KID or display aspect ratio), requiring a new [=period=] to update signaling.
* some [=adaptation sets=] become available or unavailable (e.g. different languages).

This example shows how an existing [=period=] can be split in a way that clients capable of [[#timing-connectivity|seamless period-connected playback]] do not experience interruptions in playback among [=representations=] that are present both before and after the split.

Our starting point is a presentation with a single period that contains an audio [=representation=] with short samples and a video [=representation=] with slightly longer samples, so that [=media segment=] start points do not always overlap.

<figure>
	<img src="Images/Timing/SplitInTwoPeriods - Before.png" />
	<figcaption>Presentation with one period, before splitting. Blue is a segment, yellow is a sample. Duration in arbitrary units is listed on samples. Segment durations are taken to be the sum of sample durations. `presentationTimeOffset` may have any value - it is listed because will be referenced later.</figcaption>
</figure>

Note: [=Periods=] may be split at any point in time as long as both sides of the split remain in conformance to this document (e.g. each contains at least 1 [=media segment=]). Furthermore, period splitting does not require manipulation of the segments themselves, only manipulation of the MPD.

Let's split this period at position 220. This split occurs during segment 3 for both [=representations=] and during sample 8 and sample 5 of the audio and video [=representation=], respectively.

The mechanism that enables [=period=] splitting in the middle of a segment is the following:

* a [=media segment=] that overlaps a [=period=] boundary exists in both [=periods=].
* [=representations=] that are split are signaled in the MPD as [=period-connected=].
* a representation that is [=period-connected=] with a representation in a previous period [[#timing-connectivity|is marked with the period connectivity descriptor]].
* clients are expected to deduplicate boundary-overlapping [=media segments=] for [=representations=] on which [[#timing-connectivity|period connectivity]] is signaled, if necessary for seamless playback (implementation-specific).
* clients are expected to present only the samples that are within the bounds of the current [=period=] (may be limited by client platform capabilities).

After splitting the example presentation, we arrive at the following structure.

<figure>
	<img src="Images/Timing/SplitInTwoPeriods - After.png" />
	<figcaption>Presentation with two periods, after splitting. Audio segment 3 and video segment 3 are shared by both periods, with the connectivity signaling indicating that seamless playback with de-duplicating behavior is expected from clients.</figcaption>
</figure>

If [=indexed addressing=] is used, both periods will reference all segments as both periods will use the same unmodified index segment. Clients are expected to ignore [=media segments=] that fall outside the [=period=] bounds.

Other [=periods=] (e.g. ads) may be inserted between the two [=periods=] resulting from the split. This does not affect the addressing and timing of the two [=periods=].

## Placeholder chapter ## {#placeholder-for-temporary-terms}

This chapter contains a set of terms that will exist in the IOP document but that do not exist in it yet. By defining these terms here, we enable references to be already inserted in existing text, simplifying the editing process.

* <dfn>adaptation set</dfn>
* <dfn>initialization segment</dfn>

## Editorial notes ## {#editorial-notes}

Notes on merging IOP v4.3 content into this chapter:

* 1 - not relevant
* 2 - not relevant
* 3.1 - not relevant
* 3.2.1 - potentially merged, needs a 2nd pass later to be sure
* 3.2.2 - not relevant (some overlap with relevant chapters, nothing unique)
* 3.2.3 - merged
* 3.2.4 - not relevant
* 3.2.5 - not relevant
* 3.2.6 - not relevant
* 3.2.7 - partially merged/superseded
	* This PR currently misses the "availability" aspect of timing, describing only the "when to play what" aspect.
* 3.2.7.2 - TODO ("availability" aspect)
* 3.2.7.3 - TODO ("availability" aspect)
* 3.2.7.4 - not relevant (?), make a 2nd pass later to verify where to put this - sounds like a "MPD format" thing rather than "timing" but maybe timing chapter is nearest fit
* 3.2.8 - not relevant
* 3.2.9 - not relevant
* 3.2.10 - not relevant
* 3.2.11 - not relevant
	* this seems more "file format" level text; while timing-related, it seems very specific to BMFF internals to have a place in the timing chapter (where the general situation seems already sufficiently well described); review this after we have restructured the rest of the document, see where the best home for this information (or whatever part of this information we keep) is
* 3.2.12 Content Offering With Periods - merged
	* There is some implied period-continuity logic. This is excessive combinatorics to expect the player to do. Just signal it on the service with the descriptor. Omitted.
	* AssetIdentifier has some implied connectivity logic that seems needless. Omitted. See https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/215
* 3.2.13 - not relevant
* 3.2.14 - not relevant
* 3.2.15 - TODO (addressing and base URLs)

Needs review:
* 4.8 Robust Operation - needs review

General comments:

* Chapter 3 in v4.3 is largely a random pile of constraints. Some that were timing-relevant are merged here. Others were not. Needs thorough review to ensure that nothing got unexpectedly missed or duplicated.
* Some terms "defined" in the timing chapter should probably be defined elsewhere once we have more content migrated.


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
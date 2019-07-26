## Segment addressing modes ## {#addressing}

This section defines the <dfn>addressing modes</dfn> that can be used for referencing [=media segments=], [=initialization segments=] and [=index segments=] in interopreable DASH presentations.

[=Addressing modes=] not defined in this chapter SHALL NOT be used by DASH services. Clients SHOULD support all [=addressing modes=] defined in this chapter.

All [=representations=] in the same [=adaptation set=] SHALL use the same [=addressing mode=]. [=Representations=] in different [=adaptation sets=] MAY use different [=addressing modes=]. [[#timing-connectivity|Period-connected representations]] SHALL use the same [=addressing mode=] in every [=period=].

You SHOULD choose the addressing mode based on the nature of the content:

<dl class="switch">

: Content generated on the fly
:: Use [=explicit addressing=].

: Content generated in advance of publishing
:: Use [=indexed addressing=] or [=explicit addressing=].

</dl>

A service MAY use [=simple addressing=] which enables the packager logic to be very simple. This simplicity comes at a cost of reduced applicability to multi-period scenarios and reduced client compatibility.

Note: Future updates to [[!MPEGDASH]] are expected to eliminate the critical limitations of [=simple addressing=], enabling a wider range of applicable use cases.

Issue: Update to match [[!MPEGDASH]] 4th edition.

[=Indexed addressing=] enables all data associated with a single [=representation=] to be stored in a single [=CMAF track file=] from which byte ranges are served to clients to supply [=media segments=], the [=initialization segment=] and the [=index segment=]. This gives it some unique advantages:

* A single large file is more efficient to transfer and cache than 100 000 or more small files, reducing computational and I/O overhead.
* CDNs are aware of the nature of byte-range requests and can preemptively read-ahead to fill the cache ahead of playback.

### Indexed addressing ### {#addressing-indexed}

A representation that uses <dfn>indexed addressing</dfn> consists of a [=CMAF track file=] containing an [=index segment=], an [=initialization segment=] and a sequence of [=media segments=].

Note: This addressing mode is sometimes called "SegmentBase" in other documents.

Clauses in section only apply to [=representations=] that use [=indexed addressing=].

Note: [[!MPEGDASH]] makes a distinction between "segment" (HTTP-addressable entity) and "subsegment" (byte range of an HTTP-addressable entity). This document does not make such a distinction and has no concept of subsegments. Usage of "segment" here matches the definition of CMAF segment [[!MPEGCMAF]].

<figure>
	<img src="Images/Timing/IndexedAddressing.png" />
	<figcaption>[=Indexed addressing=] is based on an [=index segment=] that references all [=media segments=].</figcaption>
</figure>

The [=MPD=] defines the byte range in the [=CMAF track file=] that contains the [=index segment=]. The [=index segment=] informs the client of all the [=media segments=] that exist, the time spans they cover on the [=sample timeline=] and their byte ranges.

Multiple [=representations=] SHALL NOT be stored in the same [=CMAF track file=] (i.e. no multiplexed [=representations=] are to be used).

At least one `Representation/BaseURL` element SHALL be present in the [=MPD=], containing a URL pointing to the [=CMAF track file=].

The `SegmentBase@indexRange` attribute SHALL be present in the [=MPD=]. The value of this attribute identifies the byte range of the [=index segment=] in the [=CMAF track file=]. The value is a `byte-range-spec` as defined in [[!RFC7233]], referencing a single range of bytes.

The `SegmentBase@timescale` attribute SHALL be present and its value SHALL match the value of the `timescale` field in the [=index segment=] (in the [[!ISOBMFF]] `sidx` box) and the value of the `timescale` field in the [=initialization segment=] (in the [[!ISOBMFF `tkhd` box)]]).

The `SegmentBase/Initialization@range` attribute SHALL identify the byte range of the initialization segment in the [=CMAF track file=]. The value is a `byte-range-spec` as defined in [[!RFC7233]], referencing a single range of bytes. The `Initialization@sourceURL` attribute SHALL NOT be used.

<div class="example">
Below is an example of common usage of [=indexed addressing=].

The example defines a [=timescale=] of 48000 units per second, with the [=period=] starting at position 8100 (or 0.16875 seconds) on the [=sample timeline=]. The client can use the [=index segment=] referenced by `indexRange` to determine where the [=media segment=] containing position 8100 (and all other [=media segments=]) can be found. The byte range of the [=initialization segment=] is also provided.

<xmp highlight="xml">
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011">
	<Period>
		<AdaptationSet>
			<Representation>
				<BaseURL>showreel_audio_dashinit.mp4</BaseURL>
				<SegmentBase timescale="48000" presentationTimeOffset="8100" indexRange="848-999">
					<Initialization range="0-847"/>
				</SegmentBase>
			</Representation>
		</AdaptationSet>
	</Period>
</MPD>
</xmp>

Parts of the [=MPD=] structure that are not relevant for this chapter have been omitted - this is not a fully functional [=MPD=] file.
</div>

### Structure of the index segment ### {#addressing-indexed-indexstructure}

The [=index segment=] SHALL consist of a single Segment Index Box (`sidx`) as defined by [[!ISOBMFF]]. The field layout is as follows:

<xmp>
aligned(8) class SegmentIndexBox extends FullBox('sidx', version, 0) {
	unsigned int(32) reference_ID;
	unsigned int(32) timescale;

	if (version==0) {
		unsigned int(32) earliest_presentation_time;
		unsigned int(32) first_offset;
	}
	else {
		unsigned int(64) earliest_presentation_time;
		unsigned int(64) first_offset;
	}

	unsigned int(16) reserved = 0;
	unsigned int(16) reference_count;

	for (i = 1; i <= reference_count; i++)
	{
		bit (1) reference_type;
		unsigned int(31) referenced_size;
		unsigned int(32) subsegment_duration;
		bit(1) starts_with_SAP;
		unsigned int(3) SAP_type;
		unsigned int(28) SAP_delta_time;
	}
}
</xmp>

The values of the fields are determined as follows:

: `reference_ID`
:: The `track_ID` of the [[!ISOBMFF]] track that contains the data of this [=representation=].

: `timescale`
:: Same as the `timescale` field of the Media Header Box and same as the `SegmentBase@timescale` attribute in the [=MPD=].

: `earliest_presentation_time`
:: The start timestamp of the first [=media segment=] on the [=sample timeline=], in [=timescale units=].

: `first_offset`
:: Distance from the end of the [=index segment=] to the first [=media segment=], in bytes. For example, 0 indicates that the first [=media segment=] immediately follows the [=index segment=].

: `reference_count`
:: Total number of [=media segments=] referenced by the [=index segment=].

: `reference_type`
:: `0`

: `referenced_size`
:: Size of the [=media segment=] in bytes. [=Media segments=] are assumed to be consecutive, so this is also the distance to the start of the next [=media segment=].

: `subsegment_duration`
:: Duration of the [=media segment=] in [=timescale units=].

: `starts_with_SAP`
:: `1`

: `SAP_type`
:: Either `1` or `2`, depending on the sample structure in the [=media segment=].

: `SAP_delta_time`
:: `0`

Issue: We need to clarify how to determine the right value for `SAP_type`. [#235](https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/235)

#### Moving the period start point (indexed addressing) #### {#addressing-indexed-startpoint}

When splitting [=periods=] in two or performing other types of editorial timing adjustments, a service might want to start a [=period=] at a point after the "natural" start point of the [=representations=] within.

For [=representations=] that use [=indexed addressing=], perform the following adjustments to set a new [=period=] start point:

1. Update `SegmentBase@presentationTimeOffset` to indicate the desired start point on the [=sample timeline=].
1. Update `Period@duration` to match the new duration.

### Explicit addressing ### {#addressing-explicit}

A representation that uses <dfn>explicit addressing</dfn> consists of a set of [=media segments=] accessed via URLs constructed using a template defined in the [=MPD=], with the exact time span covered by each [=media segment=] described in the [=MPD=].

Note: This addressing mode is sometimes called "SegmentTemplate with SegmentTimeline" in other documents.

Clauses in section only apply to [=representations=] that use [=explicit addressing=].

<figure>
	<img src="Images/Timing/ExplicitAddressing.png" />
	<figcaption>[=Explicit addressing=] uses a segment template that is combined with explicitly defined time spans for each [=media segment=] in order to reference [=media segments=], either by start time or by sequence number.</figcaption>
</figure>

The [=MPD=] SHALL contain a `SegmentTemplate/SegmentTimeline` element, containing a set of [=segment references=], which satisfies the requirements defined in this document. The [=segment references=] exist as a sequence of `S` elements, each of which references one or more [=media segments=] with start time `S@t` and duration `S@d` [=timescale units=] on the [=sample timeline=]. The `SegmentTemplate@duration` attribute SHALL NOT be present.

To enable concise [=segment reference=] definitions, an `S` element may represent a repeating [=segment reference=] that indicates a number of repeated consecutive [=media segments=] with the same duration. The value of `S@r` SHALL indicate the number of additional consecutive [=media segments=] that exist.

Note: Only additional [=segment references=] are counted, so `S@r=5` indicates a total of 6 consecutive [=media segments=] with the same duration.

The start time of a [=media segment=] is calculated from the start time and duration of the previous [=media segment=] if not specified by `S@t`. There SHALL NOT be any gaps or overlap between [=media segments=].

The value of `S@r` is nonnegative, except for the last `S` element which MAY have a negative value in `S@r`, indicating that the repeated [=segment references=] continue indefinitely up to a [=media segment=] that either ends at or overlaps the [=period=] end point.

[[#timing-mpd-updates|Updates to a dynamic MPD]] MAY add more `S` elements, remove expired `S` elements, increment `SegmentTemplate@startNumber`, add the `S@t` attribute to the first `S` element or increase the value of `S@r` on the last `S` element but SHALL NOT otherwise modify existing `S` elements.

The `SegmentTemplate@media` attribute SHALL contain the URL template for referencing [=media segments=], using either the `$Time$` or `$Number$` template variable to unique identify [=media segments=]. The `SegmentTemplate@initialization` attribute SHALL contain the URL template for referencing [=initialization segments=].

If using `$Number$` addressing, the number of the first segment reference is defined by `SegmentTemplate@startNumber` (default value 1). The `S@n` attribute SHALL NOT be used - segment numbers form a continuous sequence starting with `SegmentTemplate@startNumber`.

<div class="example">
Below is an example of common usage of [=explicit addressing=].

The example defines 225 [=media segments=] starting at position 900 on the [=sample timeline=] and lasting for a total of 900.225 seconds. The [=period=] ends at 900 seconds, so the last 0.225 seconds of content is clipped (out of bounds samples may also simply be omitted from the last [=media segment=]). The [=period=] starts at position 900 which matches the start position of the first [=media segment=] found at the relative URL `video/900.m4s`.

<xmp highlight="xml">
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011">
	<Period duration="PT900S">
		<AdaptationSet>
			<Representation>
				<SegmentTemplate timescale="1000" presentationTimeOffset="900"
						media="video/$Time$.m4s" initialization="video/init.mp4">
					<SegmentTimeline>
						<S t="900" d="4001" r="224" />
					</SegmentTimeline>
				</SegmentTemplate>
			</Representation>
		</AdaptationSet>
	</Period>
</MPD>
</xmp>

Parts of the [=MPD=] structure that are not relevant for this chapter have been omitted - this is not a fully functional [=MPD=] file.
</div>

<div class="example">
Below is an example of [=explicit addressing=] used in a scenario where different [=media segments=] have different durations (e.g. due to encoder limitations).

The example defines a sequence of 11 [=media segments=] starting at position 120 on the [=sample timeline=] and lasting for a total of 95520 units at a [=timescale=] of 1000 units per second (which results in 95.52 seconds of data). The [=period=] starts at position 810, which is within the first [=media segment=], found at the relative URL `video/120.m4s`. The fifth [=media segment=] repeats once, resulting in a sixth [=media segment=] with the same duration.

<xmp highlight="xml">
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011">
	<Period>
		<AdaptationSet>
			<Representation>
				<SegmentTemplate timescale="1000" presentationTimeOffset="810"
						media="video/$Time$.m4s" initialization="video/init.mp4">
					<SegmentTimeline>
						<S t="120" d="8520"/>
						<S d="8640"/>
						<S d="8600"/>
						<S d="8680"/>
						<S d="9360" r="1"/>
						<S d="8480"/>
						<S d="9080"/>
						<S d="6440"/>
						<S d="10000"/>
						<S d="8360"/>
					</SegmentTimeline>
				</SegmentTemplate>
			</Representation>
		</AdaptationSet>
	</Period>
</MPD>
</xmp>

Parts of the [=MPD=] structure that are not relevant for this chapter have been omitted - this is not a fully functional [=MPD=] file.
</div>

#### Moving the period start point (explicit addressing) #### {#addressing-explicit-startpoint}

When splitting [=periods=] in two or performing other types of editorial timing adjustments, a service might want to start a [=period=] at a point after the "natural" start point of the [=representations=] within.

For [=representations=] that use [=explicit addressing=], perform the following adjustments to set a new [=period=] start point:

<div class="algorithm">

1. Update `SegmentTemplate@presentationTimeOffset` to indicate the desired start point on the [=sample timeline=].
1. Update `Period@duration` to match the new duration.
1. Remove any [=unnecessary segment references=].
1. If using the `$Number$` template variable, increment `SegmentTemplate@startNumber` by the number of [=media segments=] removed from the beginning of the [=representation=].

</div>

Note: See [[#timing-representation]] and [[#timing-mpd-updates-remove-content]] to understand the constraints that apply to [=segment reference=] removal.

### Simple addressing ### {#addressing-simple}

Issue: Once we have a specific `@earliestPresentationTime` proposal submitted to MPEG we need to update this section to match. See [#245](https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/245). This is now done in [[!MPEGDASH]] 4th edition - need to synchronize this text.

A representation that uses <dfn>simple addressing</dfn> consists of a set of [=media segments=] accessed via URLs constructed using a template defined in the [=MPD=], with the nominal time span covered by each [=media segment=] described in the [=MPD=].

Advisement: [=Simple addressing=] defines the nominal time span of each [=media segment=] in the MPD. The true time span covered by samples within the [=media segment=] can be slightly different than the nominal time span. See [[#addressing-simple-inaccuracy]].

Note: This addressing mode is sometimes called "SegmentTemplate without SegmentTimeline" in other documents.

Clauses in section only apply to [=representations=] that use [=simple addressing=].

<figure>
	<img src="Images/Timing/SimpleAddressing.png" />
	<figcaption>[=Simple addressing=] uses a segment template that is combined with approximate first [=media segment=] timing information and an average [=media segment=] duration in order to reference [=media segments=], either by start time or by sequence number.</figcaption>
</figure>

The `SegmentTemplate@duration` attribute SHALL define the nominal duration of a [=media segment=] in [=timescale units=].

The set of [=segment references=] SHALL consist of the first [=media segment=] starting exactly at the [=period=] start point and all other [=media segments=] following in a consecutive series of equal time spans of `SegmentTemplate@duration` [=timescale units=], ending with a [=media segment=] that ends at or overlaps the [=period=] end time.

The `SegmentTemplate@media` attribute SHALL contain the URL template for referencing [=media segments=], using either the `$Time$` or `$Number$` template variable to uniquely identify [=media segments=]. The `SegmentTemplate@initialization` attribute SHALL contain the URL template for referencing initialization segments.

If using `$Number$` addressing, the number of the first segment reference is defined by `SegmentTemplate@startNumber` (default value 1).

<div class="example">
Below is an example of common usage of [=simple addressing=].

The example defines a [=sample timeline=] with a [=timescale=] of 1000 units per second, with the [=period=] starting at position 900. The average duration of a [=media segment=] is 4001. [=Media segment=] numbering starts at 800, so the first [=media segment=] is found at the relative URL `video/800.m4s`. The sequence of [=media segments=] continues to the end of the period, which is 900 seconds long, making for a total of 225 defined [=segment references=].

<xmp highlight="xml">
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011">
	<Period duration="PT900S">
		<AdaptationSet>
			<Representation>
				<SegmentTemplate timescale="1000" presentationTimeOffset="900"
						media="video/$Number$.m4s" initialization="video/init.mp4"
						duration="4001" startNumber="800" />
			</Representation>
		</AdaptationSet>
	</Period>
</MPD>
</xmp>

Parts of the [=MPD=] structure that are not relevant for this chapter have been omitted - this is not a fully functional [=MPD=] file.
</div>

#### Inaccuracy in media segment timing when using simple addressing #### {#addressing-simple-inaccuracy}

When using [=simple addressing=], the samples contained in a [=media segment=] MAY cover a different time span on the [=sample timeline=] than what is indicated by the nominal timing in the [=MPD=], as long as no constraints defined in this document are violated by this deviation.

<figure>
	<img src="Images/Timing/InaccurateAddressing.png" />
	<figcaption>[=Simple addressing=] relaxes the requirement on [=media segment=] contents matching the [=sample timeline=]. Red boxes indicate samples.</figcaption>
</figure>

The allowed deviation is defined as the maximum offset between the edges of the nominal time span (as defined by the [=MPD=]) and the edges of the true time span (as defined by the contents of the [=media segment=]). The deviation is evaluated separately for each edge.

Advisement: This allowed deviation does not relax any requirements that do not explicitly define an exception. For example, [=periods=] must still be covered with samples for their entire duration, which constrains the flexibility allowed for the first and last [=media segment=] in a [=period=].

The deviation SHALL be no more than 50% of the nominal [=media segment=] duration and MAY be in either direction.

Note: This results in a maximum true duration of 200% (+50% outward extension on both edges) and a minimum true duration of 1 sample (-50% inward from both edges would result in 0 duration but empty [=media segments=] are not allowed).

Allowing inaccurate timing is intended to enable reasoning on the [=sample timeline=] using average values for [=media segment=] timing. If the addressing data says that a [=media segment=] contains 4 seconds of data on average, a client can predict with reasonable accuracy which samples are found in which [=media segments=], while at the same time the service is not required to publish per-segment timing data in the MPD. It is expected that the content is packaged with this contraint in mind (i.e. **every** segment cannot be inaccurate in the same direction - a shorter segment now implies a longer segment in the future to make up for it).

<div class="example">
Consider a [=media segment=] with a nominal start time of 8 seconds from [=period=] start and a nominal duration of 4 seconds, within a [=period=] of unlimited duration.

The following are all valid contents for such a [=media segment=]:

* samples from 8 to 12 seconds (perfect accuracy)
* samples from 6 to 14 seconds (maximally large segment allowed, 50% increase from both ends)
* samples from 9.9 to 10 seconds (near-minimally small segment; while we allow a 50% decrease from both ends, potentially resulting in zero duration, every segment must still contain at least one sample)
* samples from 6 to 10 seconds (maximal offset toward zero point at both ends)
* samples from 10 to 14 seconds (maximal offset away from zero point at both ends)

Near [=period=] boundaries, all the constraints of timing and addressing must still be respected! Consider a [=media segment=] with a nominal start time of 0 seconds from [=period=] start and a nominal duration of 4 seconds. If such a [=media segment=] contained samples from 1 to 5 seconds (offset of 1 second away from zero point at both ends, which is within acceptable limits) it would be non-conforming because of the requirement in [[#timing-mediasegment]] that the first [=media segment=] contain a media sample that starts at or overlaps the [=period=] start point. This severely limits the usefulness of [=simple addressing=].
</div>

#### Moving the period start point (simple addressing) #### {#addressing-simple-startpoint}

When splitting [=periods=] in two or performing other types of editorial timing adjustments, a service might want to start a [=period=] at a point after the "natural" start point of the [=representations=] within.

[=Simple addressing=] is challenging to use in such scenarios. You SHOULD convert [=simple addressing=] [=representations=] to use [=explicit addressing=] before adjusting the [=period=] start point or splitting a [=period=]. See [[#addressing-simple-to-explicit]].

The rest of this chapter provides instructions for situations where you choose **not** to convert to [=explicit addressing=].

To move the [=period=] start point, for [=representations=] that use [=simple addressing=]:

* Every [=simple addressing=] [=representation=] in the [=period=] must contain a [=media segment=] that starts exactly at the new [=period=] start point.
* [=Media segments=] starting at the new [=period=] start point must contain a sample that starts at or overlaps the new [=period=] start point.

Note: If you are splitting a [=period=], also keep in mind [[#timing-mediasegment|the requirements on period end point sample alignment]] for the [=period=] that remains before the split point.

Finding a suitable new start point that conforms to the above requirements can be very difficult. If inaccurate timing is used, it may be altogether impossible. This is a limitation of [=simple addressing=].

Having ensured conformance to the above requirements for the new [=period=] start point, perform the following adjustments:

<div class="algorithm">

1. Update `SegmentTemplate@presentationTimeOffset` to indicate the desired start point on the [=sample timeline=].
1. If using the `$Number$` template variable, increment `SegmentTemplate@startNumber` by the number of [=media segments=] removed from the beginning of the [=representation=].
1. Update `Period@duration` to match the new duration.

</div>

#### Converting simple addressing to explicit addressing #### {#addressing-simple-to-explicit}

It may sometimes be desirable to convert a presentation from [=simple addressing=] to [=explicit addressing=]. This chapter provides an algorithm to do this.

Advisement: [=Simple addressing=] allows for inaccuracy in [=media segment=] timing. No inaccuracy is allowed by [=explicit addressing=]. The mechanism of conversion described here is only valid when there is no inaccuracy. If the nominal time spans in original the [=MPD=] differ from the true time spans of the [=media segments=], re-package the content from scratch using [=explicit addressing=] instead of converting.

To perform the conversion, execute the following steps:

<div class="algorithm">

1. Calculate the number of [=media segments=] in the [=representation=] as `SegmentCount = Ceil(AsSeconds(Period@duration) / ( SegmentTemplate@duration / SegmentTemplate@timescale))`.
1. Update the MPD.
	1. Add a single `SegmentTemplate/SegmentTimeline` element.
	1. Add a single `SegmentTimeline/S` element.
	1. Set `S@t` to equal `SegmentTemplate@presentationTimeOffset`.
	1. Set `S@d` to equal `SegmentTemplate@duration`.
	1. Remove `SegmentTemplate@duration`.
	1. Set `S@r` to `SegmentCount - 1`.

</div>

<div class="example">
Below is an example of a [=simple addressing=] [=representation=] before conversion.

<xmp highlight="xml">
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011">
	<Period duration="PT900S">
		<AdaptationSet>
			<Representation>
				<SegmentTemplate timescale="1000" presentationTimeOffset="900"
						media="video/$Number$.m4s" initialization="video/init.mp4"
						duration="4001" startNumber="800" />
			</Representation>
		</AdaptationSet>
	</Period>
</MPD>
</xmp>

As part of the conversion, we calculate `SegmentCount = Ceil(900 / (4001 / 1000)) = 225`.

After conversion, we arrive at the following result.

<xmp highlight="xml">
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011">
	<Period duration="PT900S">
		<AdaptationSet>
			<Representation>
				<SegmentTemplate timescale="1000" presentationTimeOffset="900"
						media="video/$Number$.m4s" initialization="video/init.mp4"
						startNumber="800">
					<SegmentTimeline>
						<S t="900" d="4001" r="224" />
					</SegmentTimeline>
				</SegmentTemplate>
			</Representation>
		</AdaptationSet>
	</Period>
</MPD>
</xmp>

Parts of the [=MPD=] structure that are not relevant for this chapter have been omitted - the above are not fully functional [=MPD=] files.
</div>
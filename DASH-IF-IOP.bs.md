# Document editing notes # {#introduction-editing}

Documentation: https://dashif.org/DocumentAuthoring/

Example document repository: https://dashif.org/DocumentAuthoring/

Live discussion in #document-authoring on Slack.

# Chapter 1 # {#chapter1-the-real-intro}

Placeholder text. This document will eventually contain IOP v5.

# Addressing and timing # {#timing}

Constraints from proposals in [#166](https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/166) and [#178](https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/178) applied, concisely reworded in minimal form:

* There SHALL be an addressable segment for every instant of every period in every representation.
* The sample to be presented at the period start point (indicated by Representation@presentationTimeOffset) SHALL be contained in the first segment in the period if using the ISO BMFF Live profile (even if the first segment is no longer be available or no longer referenced by the MPD). The sample MAY be in any segment/subsegment if using the ISO BMFF On-demand profile.
* Clients SHOULD NOT present any samples before the period start point and SHALL NOT present any samples from segments entirely composed of samples before the period start point.
* Periods SHOULD NOT reference segments that fall entirely outside the bounds of the period. Such segments MAY be referenced when a period is only a partial view over existing content that has a larger scope (e.g. `SegmentBase` addressing is used with a segment index defining segments from which only a subset are the segments within the bounds of to the period).

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

* to insert an ad period in the middle of an existing period.
* parameters of one adaptation set change (e.g. KID or display aspect ratio), requiring a new period to update signaling.
* some adaptation sets become available or unavailable (e.g. different languages).

This example shows how an existing period can be split in a way that clients capable of period-continuous playback do not experience interruptions in playback among representations that are present both before and after the split.

Our starting point is a presentation with a single period that contains an audio representation with short samples and a video representation with slightly longer samples, so that segment start points do not always overlap.

<figure>
	<img src="Images/Timing/SplitInTwoPeriods - Before.png" />
	<figcaption>Presentation with one period, before splitting. Blue is a segment, yellow is a sample. Duration in arbitrary units is listed on samples. Segment durations are taken to be the sum of sample durations. `presentationTimeOffset` may have any value - it is listed because will be referenced later.</figcaption>
</figure>

Note: Splitting a period does not depend on any particular alignment between representations at the splitting point. Periods may be split anywhere. Furthermore, period splitting does not require manipulation of the segments themselves, only manipulation of the MPD.

Let's split this period at position 220. This split occurs during segment 3 for both representations and during sample 8 and sample 5 of the audio and video representation, respectively.

The mechanism that enables period splitting in the middle of a segment is the following:

* a segment that overlaps a period boundary exists in both periods.
* representations that are split are signaled in the MPD as period continuous.
* clients are expected to deduplicate boundary-overlapping segments for representations on which period continuity is signaled.
* clients are expected to present only the samples that are within the current period boundary (may be limited by client platform capabilities).

After splitting the example presentation, we arrive at the following structure.

<figure>
	<img src="Images/Timing/SplitInTwoPeriods - After.png" />
	<figcaption>Presentation with two periods, after splitting. Audio segment 3 and video segment 3 are shared by both periods, with the continuity signaling indicating that continuous playback with de-duplicating behavior is expected from clients.</figcaption>
</figure>

Issue: Which way does the continuity reference go? [#209](https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/209)

Depending on the segment addressing mode used, the two resulting periods may reference more segments than necessary. For example, if `SegmentBase` addressing is used, both periods will reference all segments as both periods will use the same unmodified segment index. Clients are expected to ignore segments that fall outside the period bounds.

Other periods (e.g. ads) may be inserted between the two periods resulting from the split. This does not affect the addressing and timing of the two periods.



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
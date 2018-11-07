# Basic constraints # {#constraints}

The standards and specifications that make up the DASH ecosystem are very flexible, enabling both interoperable and special-case scenarios. [=IOP=] only targets interoperable scenarios, which requires certain constraints to be defined to ensure a common interpretation. This chapter defines global constraints that are not specific to a particular feature or use case.

## CMAF and ISO BMFF ## {#cmaf-bmff-constraints}

The formats for many DASH data structures are defined by [[!MPEGCMAF]], which is largely based on [[!ISOBMFF]]. This chapter defines constraints on the use of [[!MPEGCMAF]] and [[!ISOBMFF]] features to limit them to a highly interoperable subset.

Default values set in the Track Extends (`trex`) box MAY be overridden by corresponding values set in movie fragments (in `tfhd` or `trun` boxes).

Movie Fragment (`moof`) boxes SHALL NOT use external data references. The flag `default-base-is-moof` SHALL be set (aka movie-fragment relative addressing) and `data-offset` SHALL be used (i.e. `base-data-offset-present` SHALL NOT be used).

Any Segment Index (`sidx`) and Subsegment Index (`ssix`) boxes SHALL be placed before any Movie Fragment (`moof`) boxes within [=media segments=]. There SHALL be at most one Segment Index (`sidx`) box for each [=representation=].

[=Media segments=] SHALL be non-multiplexed (contain only one track).

## Media segment duration ## {#segment-duration-constraints}

[=Media segments=] referenced by the same [=representation=] SHOULD be equal in duration. Occasional jitter MAY occur (e.g. due to encoder decisions on GOP size).

Note: [=Media segment=] durations must be expressed in the [=MPD=] in conformance to the rules of the selected [=addressing mode=].

Note: [[DVB-DASH]] defines some relevant constraints in section 4.5. Consider obeying these constraints to be compatible with [[DVB DASH]].

## Large timescales and time values ## {#timescale-constraints}

[[ECMASCRIPT]] is unable to accurately represent numeric values greater than 2<sup>53</sup> using built-in types. Therefore, interoperable services cannot use such values.

All timescales are start times used in a DASH presentations SHALL be sufficiently small that no timecode value exceeding 2<sup>53</sup> will be encountered, even during the publishing of long-lasting [[#svc-live|live services]].

Note: This may require the use of 64-bit fields, although the values must still be limited to under 2<sup>53</sup>.

## Segments must be aligned ## {#segment-alignment-constraints}

[=Media segments=] are said to be aligned if the start/end points of all [=media segments=] on the [=sample timeline=] are equal in all [=representations=] that belong to the same [=adaptation set=].

[=Media segments=] SHALL be aligned.

When using [=simple addressing=] or [=explicit addressing=], this SHALL be signaled by `AdaptationSet@segmentAlignment=true` in the [=MPD=]. When using [=indexed addressing=], this SHALL be signaled by `AdaptationSet@subsegmentAlignment=true` in the [=MPD=].

## Adaptation set contents ## {#adaptation-set-constraints}

[=Adaptation sets=] SHALL contain [=media segments=] compatible with a single decoder, although services MAY require the decoder to be re-initialized when switching to a new [=representation=]. See also [[#bitstream-switching]].

All [=representations=] in the same [=adaptation set=] SHALL have the same [=timescale=], both in the [=MPD=] and in the [=initialization segment=] `tkhd` boxes.

[[!ISOBMFF]] edit lists SHALL be identical for all [=representations=] in an [=adaptation set=].

Note: [[DVB-DASH]] defines some relevant constraints in section 4.5. Consider obeying these constraints to be compatible with [[DVB DASH]].

## Adaptation set types ## {#adaptation-set-types}

Each [=adaptation set=] SHALL match exactly one category from among the following:

* A <dfn>video adaptation set</dfn> contains visual information for display to the user. Such an adaptation set is identified by `@mimeType="video/mp4"`. The values for `@codecs` SHALL be restricted to values defined in [[#codecs]].
* An <dfn>audio adaptation set</dfn> contains sound information to be rendered to the user. Such an adaptation set is identified by `@mimeType="audio/mp4"`. The values for `@codecs` SHALL be restricted to values defined in [[#codecs]].
* A <dfn>text adaptation set</dfn> contains visual overlay information to be rendered as auxiliary or accessibility information. Such an [=adaptation set=] is identified by one of:
	* `@mimeType="application/mp4"` and a `@codecs` parameter of a text coding technology defined in [[#codecs]].
	* `@mimeType="application/ttml+xml"` with no `@codecs` parameter.
* A <dfn>metadata adaptation set</dfn> contains information that is not expected to be rendered by a specific media handler, but is interpreted by the application. Such an adaptation set is identified by `@mimeType="application/mp4"` and an appropriate sample entry identified by the `@codecs` parameter.
* A <dfn>thumbnail adaptation set</dfn> contains [[#thumbnails|thumbnail images for efficient display during seeking]]. Such an adaptation set is identified by `@mimeType="image/jpeg"` or `@mimeType="image/png"` in combination with an [=essential property descriptor=] with `@schemeIdUri="http://dashif.org/guidelines/thumbnail_tile"`.

Issue: What exactly is metadata `@codecs` supposed to be? https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/290

The [=adaptation set=] type SHALL be used by a DASH client to identify the appropriate handler for rendering. Typically, a DASH client selects at most one [=adaptation set=] of each type.

In addition, a DASH client SHOULD use the value of the `@codecs` parameter to determine whether the underlying media playback platform can play the media contained within the [=adaptation set=].

See [[#codecs]] for detailed codec-specific constraints.

## Video adaptation set constraints ## {#video-constraints}

All [=representations=] in the same [=video adaptation set=] SHALL be alternative encodings of the same source content, encoded such that switching between them does not produce visual glitches due to picture size or aspect ratio differences.

Issue: An illustration here would be very useful.

Issue: https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/284

To avoid visual glitches you must ensure that the sample aspect ratio is set correctly. For reasons of coding efficiency and due to technical constraints, different [=representations=] might use a different picture aspect ratio. Each [=representation=] signals a sample aspect ratio (e.g. in an [[!MPEGAVC]] `aspect_ratio_idc`) that is used to scale the picture so that every [=representation=] ends up at the same display aspect ratio. The formula is `display aspect ratio = picture aspect ratio / sample aspect ratio`.

In the [=MPD=], the display aspect ratio is `AdaptationSet@par` and the sample aspect ratio is `Respresentation@sar`. The picture aspect ratio is not directly present but is derived from `Representation@width` and `Representation@height`.

The encoded picture SHALL only contain the active video area, so that clients can frame the height and width of the encoded video to the size and shape of their currently selected display area without extraneous padding in the decoded video, such as "letterbox bars" or "pillarbox bars".

[=Representations=] in the same [=video adaptation set=] SHALL NOT differ in any of the following parameters:

* Color Primaries
* Transfer Characteristics
* Matrix Coefficients.

If different [=video adaptation sets=] differ in any of the above parameters, these parameters SHOULD be signaled in the [=MPD=] on the [=adaptation set=] level by a [=supplemental property descriptor=] or an [=essential property descriptor=] with `@schemeIdUri="urn:mpeg:mpegB:cicp:<Parameter>"` as defined in [[!iso23001-8]] and `<Parameter>` being one of the following: `ColourPrimaries`, `TransferCharacteristics`, or `MatrixCoefficients`. The `@value` attribute SHALL be set as defined in [[!iso23001-8]].

Issue: Why is the above a SHOULD? If it matters enough to signal, we should make it SHALL? https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/286

In any [=video adaptation set=], the following SHALL be present:

* `AdaptationSet@par` (the display aspect ratio)
* `Representation@sar` (the sample aspect ratio)
* Either `Representation@width` or `AdaptationSet@width` (but not both)
* Either `Representation@height` or `AdaptationSet@height` (but not both)
* Either `Representation@frameRate` or `AdaptationSet@frameRate` (but not both)

Note: `@width` and `@height` indicate the number of encoded pixels. `@par` indicates the final intended display aspect ratio and `@sar` is effectively the ratio of aspect ratios (ratio of `@width x @height` to `@par`).

<div class="example">
Given a coded picture of 720x576 pixels with an intended display aspect ratio of 16:9, we would have the following values:

* `@width=720`
* `@height=576`
* `@par=16:9`
* `@sar=45:64` (720x576 is 5:4, which gives `@sar=5:4/16:9=45:64`)

</div>

Issue: This chapter already includes changes from [#274](https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/274)

In any [=video adaptation set=], the following SHOULD NOT be present and SHALL be ignored by clients if present:

* `AdaptationSet@minWidth`
* `AdaptationSet@maxWidth`
* `AdaptationSet@minHeight`
* `AdaptationSet@maxHeight`
* `AdaptationSet@minFrameRate`
* `AdaptationSet@maxFrameRate`

The above min/max values are trivial to determine at runtime, so can be calculated by the client when needed.

`@scanType` SHOULD NOT be present and if present SHALL have the value `progressive`. Non-progressive video is not interoperable.

## Audio adaptation set constraints ## {#audio-constraints}

`AdaptationSet@lang` SHALL be present on every [=audio adaptation set=].

`@audioSamplingRate` SHALL be present either on the [=adaptation set=] or [=representation=] level (but not both).

The `AudioChannelConfiguration` element SHALL be present either on the [=adaptation set=] or [=representation=] level (but not both). The scheme and value SHALL conform to `ChannelConfiguration` as defined in [[!iso23001-8]].

## Text adaptation set constraints ## {#text-constraints}

[=Text adaptation sets=] SHOULD be annotated using descriptors defined by [[!MPEGDASH]], specifically `Role`, `Accessibility`, `EssentialProperty` and `SupplementalProperty` descriptors.

Guidelines for annotation are provided in [[#selection]] and section 7.1.2 of [[DVB-DASH]].

## Representing durations in XML ## {#xml-duration-constraints}

All units expressed in [=MPD=] fields of datatype `xs:duration` SHALL be treated as fixed size:

* 60S = 1M (minute)
* 60M = 1H
* 24H = 1D
* 30D = 1M (month)
* 12M = 1Y

[=MPD=] fields having datatype `xs:duration` SHALL NOT use the year and month units and SHOULD be expressed as a count of seconds, without using any of the larger units.

## Expanding URL template variables ## {#template-variable-constraints}

This section clarifies expansion rules for URL template variables such as `$Time$` and `$Number`, defined by [[!MPEGDASH]].

The set of string formatting suffixes used SHALL be restricted to `%0[width]d`.

Note: The string format suffixes are not intended for general-purpose string formatting. Restricting it to only this single suffix enables the functionality to be implemented without a string formatting library.

## Clock drift is forbidden ## {#no-clock-drift}

Some encoders experience clock drift - they do not produce exactly 1 second worth of output per 1 second of input, either stretching or compressing time.

A DASH service SHALL NOT publish content that suffers from clock drift.

If a packager receives input from an encoder at the wrong rate, it must take corrective action. For example, it might:

1. Drop a span of content if input is produced faster than real-time.
1. Insert regular padding content if input is produced slower than real-time. This padding can take different forms:
	* Silence or a blank picture.
	* Repeating frames.
	* Insertion of short-duration [=periods=] where the affected [=representations=] are not present.

Of course, such after-the-fact corrective actions can disrupt the end-user experience. The optimal solution is to fix the defective encoder.

## MPD size ## {#mpd-size-constraints}

No constraints are defined on [=MPD=] size, or on the number of elements. However, services SHOULD NOT create unnecessarily large [=MPDs=].

Note: [[DVB-DASH]] defines some relevant constraints in section 4.5. Consider obeying these constraints to be compatible with [[DVB DASH]].
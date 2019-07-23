## Adaptation set contents ## {#adaptation-set-constraints}

[=Adaptation sets=] SHALL contain [=media segments=] compatible with a single decoder, although services MAY require the decoder to be re-initialized when switching to a new [=representation=]. See also [[#bitstream-switching]].

All [=representations=] in the same [=adaptation set=] SHALL have the same [=timescale=], both in the [=MPD=] and in the [=initialization segment=] `tkhd` boxes.

[[!ISOBMFF]] edit lists SHALL be identical for all [=representations=] in an [=adaptation set=].

Note: [[DVB-DASH]] defines some relevant constraints in section 4.5. Consider obeying these constraints to be compatible with [[DVB-DASH]].

## Adaptation set types ## {#adaptation-set-types}

Each [=adaptation set=] SHALL match exactly one category from among the following:

* A <dfn>video adaptation set</dfn> contains visual information for display to the user. Such an adaptation set is identified by `@mimeType="video/mp4"`. The values for `@codecs` SHALL be restricted to values defined in [[#codecs]].
* An <dfn>audio adaptation set</dfn> contains sound information to be rendered to the user. Such an adaptation set is identified by `@mimeType="audio/mp4"`. The values for `@codecs` SHALL be restricted to values defined in [[#codecs]].
* A <dfn>text adaptation set</dfn> contains visual overlay information to be rendered as auxiliary or accessibility information. Such an [=adaptation set=] is identified by one of:
	* `@mimeType="application/mp4"` and a `@codecs` parameter of a text coding technology defined in [[#codecs]].
	* `@mimeType="application/ttml+xml"` with no `@codecs` parameter.
* A metadata adaptation set contains information that is not expected to be rendered by a specific media handler, but is interpreted by the application. Such an adaptation set is identified by `@mimeType="application/mp4"` and an appropriate sample entry identified by the `@codecs` parameter.
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
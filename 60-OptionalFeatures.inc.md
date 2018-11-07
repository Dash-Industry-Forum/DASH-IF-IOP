# Optional features # {#features}

This chapter describes requirements for publishing and consuming services that make use of optional DASH features.

These features might not be needed by all services and even if used by a service, might not be implemented by all clients. The requirements specified here attempt to define behavior that enables the features to be used in an interoperable way when present and ideally enable services to provide graceful degradation when encountering a client that does not implement a feature.

## Custom metadata in MPD ## {#mpd-custom-metadata}

In addition to metadata specified in [=IOP=], custom metadata MAY be added to MPDs using [=essential property descriptors=] and [=supplemental property descriptors=] defined in [[!MPEGDASH]]. Services SHALL NOT require clients to understand custom metadata in order to correctly play back a DASH presentation.

Note: In other words, use of custom metadata does not make a service nonconforming to this specification but neither is the use of custom metadata an interoperable feature.

Metadata identifiers are registered on the [DASH-IF website](https://dashif.org/).

## Preview thumbnails for seeking and navigation ## {#thumbnails}

Clients may wish to show timecode-associated preview thumbnails as part of the seeking experience. A typical use case is for enhancing a scrub bar with visual cues. Services that wish to support this SHOULD provide an [=adaptation set=] with thumbnails.

The thumbnails are published as a sequence of jpeg/png images containing grids of thumbnails. One grid of thumbnails is one [=media segment=]. To ensure efficent transfer, a thumbnail [=media segment=] SHOULD be at least 1 minute in duration.

A [=thumbnail adaptation set=] MAY offer multiple [=representations=] with different spatial resolutions.

The [=addressing mode=] SHALL be restricted to [=simple addressing=] with only the `$Number$` templating variable.

Note: The constraint on allowed [=addressing modes=] exists to limit the effort required to implement this feature in clients.

Detailed requirements on the thumbnail [=representations=] are defined in [[#codecs-thumbnails]].

## Trick mode ## {#trickmode}

Trick modes are used by DASH clients in order to support fast forward, seek, rewind and other operations in which typically the media, especially video, is displayed in a speed other than the normal playout speed. In order to support such operations, it is recommended that the content author adds [=representations=] at lower frame rates in order to support faster playout with the same decoding and rendering capabilities.

However, [=representations=] targeted for trick modes are typically not be suitable for regular playout. If the content author wants to explicitly signal that a [=representation=] is only suitable for trick mode cases, but not for regular playout, the service SHOULD be structured as follows:

* add [=adaptation sets=] that that only contain trick mode [=representations=]
* annotate each [=adaptation set=] with an [=essential property descriptor=] or [=supplemental property descriptor=] with URL `http://dashif.org/guidelines/trickmode` and the `@value` the value of `@id` attribute of the [=adaptation set=] with which these trick mode [=representations=] are associated. The trick mode [=representations=] must be time-aligned with the [=representations=] in the referenced [=adaptation set=]. The `@value` may also be a white-space separated list of `@id` values. In this case the trick mode [=adaptation set=] is associated to all [=adaptation sets=] with the values of the `@id`.
* signal the playout capabilities with the attribute `@maxPlayoutRate` for each [=representation=] in order to indicate the accelerated playout that is enabled by the signaled codec profile and level.
* If the [=representation=] is encoded without any coding dependency on the elementary stream level, i.e. each sample is a SAP type 1, then you SHOULD set the `Representation@codingDependency` attribute to `false`.
* If multiple trick mode [=adaptation sets=] are present for one regular [=adaptation set=], then sufficient signaling should be provided to differentiate the different trick mode [=adaptation sets=]. Different [=adaptation sets=] for example may be provided as thumbnails (low spatial resolution), for fast forward or rewind (no coding dependency with `@codingDependency` set to `false` and/or lower frame rates), longer values for `@duration` to improve download frequencies or different `@maxPlayoutRate` values. Note also that the `@bandwidth` value should be carefully documented to support faster than real-time download of Segments.

If an [=adaptation set=] in annotated with the [=essential property descriptor=] with URI `http://dashif.org/guidelines/trickmode` then the DASH client SHALL NOT select any of the contained [=representations=] for regular playout.

## Bitstream switching ## {#bitstream-switching}

Bitstream switching if a feature that allows a switched sequence of [=media segments=] from different [=representations=] in the same [=adaptation set=] to be decoded without resetting the decoder at switch points by ensuring that the resulting stream of [=media segments=] can be successfully decoded without the decoder even being aware of a switch.

An [=adaptation set=] that supports bitstream switching is a <dfn>bitstream switching adaptation set</dfn>.

The `AdaptationSet@bitstreamSwitching` attribute SHOULD be set to true on a [=bitstream switching adaptation set=]. Services SHALL NOT require clients to support bitstream switching in order to correctly present a [=bitstream switching adaptation set=].

The [[!ISOBMFF]] `track_id` SHALL be equal for all [=representations=] in the same [=bitstream switching adaptation set=].

The `AdaptationSet@codecs` attribute SHALL be present on a [=bitstream switching  adaptation set=] and indicate the maximum profile and level of any [=representation=].

The `Representation@codecs` attribute MAY be present on [=representations=] that belong to a [=bitstream switching adaptation set=]. If present, it SHALL indicate the maximum profile and level of any [=media segment=] in the [=representation=].

Issue: Allowing `Representation@codecs` to be absent might make it more difficult to make bitstream-switching-oblivious clients. If we require `Representation@codecs` to always be present, client developer life could be made simpler.

Clients that support bitstream switching SHALL initialize the decoder using the [=initialization segment=] of the [=representation=] with the highest `Representation@bandwidth` in a bitstream switching [=adaptation set=].

Note: A [=bitstream switching adaptation set=] fulfills the requirements of [[DVB-DASH]].

## Switching across adaptation sets ## {#seamless-switching-xas}

Note: This technology is expected to be available in [[!MPEGDASH]] Amd 4. Once published by MPEG, this section is expected to be replaced by a reference to the MPEG-DASH standard.

Representations in two or more [=adaptation sets=] may provide the same content. In addition, the content may be time-aligned and may be offered such that seamless switching across [=representations=] in different [=adaptation sets=] is possible. Typical examples are the offering of the same content with different codecs, for example H.264/AVC and H.265/HEVC and the content author wants to provide such information to the receiver in order to seamlessly switch [=representations=] across different [=adaptation sets=]. Such switching permission may be used by advanced clients.

A content author may signal such seamless switching property across [=adaptation sets=] by providing a [=supplemental property descriptor=] along with an [=adaptation set=] with `@schemeIdUri` set to `urn:mpeg:dash:adaptation-set-switching:2016` and the `@value` is a comma-separated list of [=adaptation set=] IDs that may be seamlessly switched to from this [=adaptation set=].

If the content author signals the ability of [=adaptation set=] switching and as `@segmentAlignment` or `@subsegmentAlignment` are set to true for one [=adaptation set=], the (sub)segment alignment shall hold for all [=representations=] in all [=adaptation sets=] for which the `@id` value is included in the `@value` attribute of the [=supplemental property descriptor=].

As an example, a content author may signal that seamless switching across an H.264/AVC [=adaptation set=] with `AdaptationSet@id="264"` and an HEVC [=adaptation set=] with `AdaptationSet@id="265"` is possible by adding a [=supplemental property descriptor=] to the H.264/AVC [=adaptation set=] with `@schemeIdUri` set to `urn:mpeg:dash:adaptationset-switching:2016` and the `@value="265"` and by adding a [=supplemental property descriptor=] to the HEVC [=adaptation set=] with `@schemeIdUri` set to `urn:mpeg:dash:adaptationset-switching:2016` and the `@value="264"`.

In addition, if the content author signals the ability of [=adaptation set=] switching for:

* any [=video adaptation set=] TODO
* any [=audio adaptation set=] TODO

Issue: What is the above talking about?

Note: This constraint may result that the switching may only be signaled with one [=adaptation set=], but not with both as for example one [=adaptation set=] signaling may include all spatial resolutions of another one, whereas it is not the case the other way round.

## XLink ## {#xlink-feature}

Some XML elements in an MPD may be external to the MPD itself, delay-loaded by clients based on different triggers. This mechanism is called <dfn>XLink</dfn> and it enables client-side MPD composition from different sources. For the purposes of timing and addressing, it is important to ensure that the duration of each [=period=] can be accurately determined both before and after XLink resolution.

Note: XLink functionality in DASH is defined by [[!MPEGDASH]] and [[!XLINK]]. This document provides a high level summary of the behavior and defines interoperability requirements.

<dfn>XLink elements</dfn> are those in the MPD that carry the `xlink:href` attribute. When XLink resolution is triggered, the client will query the URL referenced by this attribute. What happens next depends on the result of this query:

<dl class="switch">

: Non-empty result containing a valid XML fragment
:: The entire [=XLink element=] is replaced with the query result. A single XLink element MAY be replaced with multiple elements of the same type.

: Empty result or query failure
:: The [=XLink element=] remains as-is with the XLink attributes removed.

</dl>

When XLink resolution is triggered depends on the value of the `xlink:actuate` attribute. A value of `onLoad` indicates resolution at MPD load-time, whereas a value of `onRequest` indicates resolution on-demand at the time the client wishes to use the element. The default value is `onRequest`.

Services SHALL publish MPDs that conform to the requirements in this document even before XLink resolution. This is necessary because the behavior in case of XLink resolution failure is to retain the element as-is.

<div class="example">
The below MPD example contains an XLink period. The real duration of the XLink [=period=] will only become known once the XLink is resolved by the client and the XLink element replaced with real content.

The first [=period=] has an explicit duration defined because the XLink resolver has no knowledge of the MPD and is unlikely to know the appropriate value to define for the second period's `Period@start` (unless this data is provided in the XLink URL as a parameter).

The explicitly defined duration of the second [=period=] will only be used as a fallback if the XLink resolver decides not to define a period. In this case the existing element in the MPD is preserved.

<xmp highlight="xml">
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011" xmlns:xlink="http://www.w3.org/1999/xlink" type="static">
	<Period duration="PT30S">
		...
	</Period>
	<Period duration="PT0S" xlink:href="https://example.com/256479/clips/53473/as_period">
	</Period>
</MPD>
</xmp>

After XLink resolving, the entire `<Period>` element will be replaced, except when the XLink result is empty, in which case the client preserves the existing element (which in this case is a [=period=] with zero duration, ignored by clients).

Parts of the MPD structure that are not relevant for this chapter have been omitted - this is not a fully functional MPD file.
</div>

## Update signaling via in-band events ## {#inband}

Services MAY signal the [=MPD=] validity duration by embedding in-band messages into [=representations=] instead of specifying a fixed validity duration in the MPD. This allows services to trigger [=MPD refreshes=] at exactly the desired time and to avoid needless [=MPD refreshes=].

The rest of this chapter only applies to services and clients that use in-band MPD validity signaling.

Services SHALL define `MPD@minimumUpdatePeriod=0` and add an in-band event stream to every audio [=representation=] or, if no audio [=representations=] are present, to every video [=representation=]. The in-band event stream MAY also be added to other [=representations=]. The in-band event stream SHALL be identical in every [=representation=] where it is present.

The in-band event stream SHALL be signaled on the [=adaptation set=] level by an `InbandEventStream` element with `@scheme_id_uri="urn:mpeg:dash:event:2012"` and a `@value` of 1 or 3, where:

* A value of `1` indicates that in-band events only extend the MPD validity duration.
* A value of `3` indicates that in-band events also contain the updated MPD snapshot when updates occur.

Services SHALL update `MPD@publishTime` to an unique value after every MPD update.

Note: `MPD@publishTime` is merely a version label. The value is not used in timing calculations.

<div class="example">
Using in-band signaling and `MPD@minimumUpdatePeriod=0`, each [=media segment=] increases the validity period of the [=MPD=] by the duration of the [=media segment=] by default. When a validity event arrives, it carries the validity end timestamp of the [=MPD=], enabling the client to determine when a new [=MPD refresh=] is needed.
</div>

For a detailed definition of the mechanism and the event message data structures, see [[!MPEGDASH]]. This chapter is merely a high level summary of the most important aspects relevant to interoperability.

<figure>
	<img src="Images/Timing/EmsgUpdates.png" />
	<figcaption>Illustration of MPD expiration signaling using in-band events.</figcaption>
</figure>

Services SHALL emit in-band events as [[!MPEGDASH]] `emsg` boxes to signal the [=MPD=] validity duration using the following logic:

* Lack of an in-band MPD validity event in a [=media segment=] indicates that an MPD that was valid at the start of the [=media segment=] remains valid up to the end of the [=media segment=].
* The presence of an in-band MPD validity event in a [=media segment=] indicates that the MPD with `MPD@publishTime` equal to the event's `publish_time` field remains valid up to the event start time.

The in-band events used for signaling MPD validity duration SHALL have `scheme_id_uri` and `value` matching the `InbandEventStream` element. Clients SHALL NOT use in-band events for MPD validity update signaling if these fields on the events do not match the `InbandEventStream` element or if the `InbandEventStream` element is not present in the [=MPD=].

In-band events with `value=3` SHALL provide an updated MPD in the event's `mpd` field as UTF-8 encoded text without a byte order mark.

Clients MAY perofrm [=MPD refreshes=] or process an event-embedded [=MPD=] immediately upon reading the event, without waiting for the moment signaled by the event timestamp. Services SHALL ensure that an updated [=MPD=] is available and valid starting from the moment a validity event is signaled.

Multiple [=media segments=] MAY signal the same validity update event (identified by matching `id` field on event), enabling the signal to be delivered several segments in advance of the MPD expiration.

In-band MPD validity events SHALL NOT be signaled in a static MPD but MAY be present in the [=media segments=] referenced by a static MPD, in which case they SHALL be ignored by clients.

Note: The above may happen when a live service is converted to an on-demand service for catchup/recording purposes.

## Specifying initial position in presentation URL ## {#mpd-anchors}

Issue: This section could use another pass to make it easier to read.

By default, a client would want to start playback from the start of the presentation (if `MPD@type="static"`) or from near the live edge (if `MPD@type="dynamic"`). However, in some situations it may be desirable to instruct clients to start playback from a specific position. In [[#svc-live|live services]], where content has a fixed mapping to real time, this means an initial time-shift is applied.

The interoperable mechanism for this is to add an MPD anchor to the presentation URL. Details of this feature are defined in [[!MPEGDASH]], with this chapter offering a summary of the feature and constraining its use to interoperable cases.

An initial position MAY be signalled to the DASH client by including an MPD anchor in the presentation URL. If an anchor is used, it SHALL be specified with one of the following sets of parameters:

* the `t` parameter
* both the `period` and `t` parameter

The `t` parameter indicates offset from [=period=] start or a moment in real-time, with `period` referencing a `Period@id` (defaulting to the first period).

Advisement: The value of `Period@id` must be URL-encoded.

The time indicated using the `t` parameter SHALL be a single `npttime` value as specified in [[!media-frags]]. This is a narrower definition than accepted by [[!MPEGDASH]].

<div class="example">
To start from the beginning of the first [=period=] the following would be added to the end of the MPD URL provided to the DASH client: `#t=0`

To start with a fixed offset from the start of a specific [=period=], in this case 50 minutes from the beginning of the period with ID `program_part_2`, use the following syntax: `#period=program_part_2&t=50:00`

When accessing a [[#svc-live|live service]], you can instruct the client to use an initial time-shift so that content from a specific moment is played back by providing a POSIX timestamp with the `t` parameter. For example, starting playback from Wed, 08 Jun 2016 17:29:06 GMT would be expressed as `#t=posix:1465406946`. Starting playback from the live edge can be signaled as `#t=posix:now`.

</div>

When referencing a moment in real time using `t=posix`, the `period` parameter SHALL NOT be used.

Issue: How do leap seconds tie into this? See #161

## Extended segment information ## {#extended-segment-info}

Issue: porposal to deprecate https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/258

## Last segment signaling ## {#lmsg}

Issue: https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/276
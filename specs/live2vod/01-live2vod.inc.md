# Provisioning of Live Content in On-Demand Mode # {#live2vod}

## Introduction ## {#live2vod:introduction}

This feature description is an update to DASH-IF IOP Guidelines v4.3 [[!IOP43]],
clause 4.6. It obsoletes clause 4.6 of DASH-IF IOP Guidelines v4.3 [[!IOP43]].

## Scenarios ## {#live2vod:scenarios}

### Common aspects ### {#live2vod:scenario-common-aspects}

A common scenario for DASH distribution is that a live distributed content is
also made available On-Demand. Common to the different use cases presented in
the following is the

  * desire to re-use the Segments as generated for the live service are also
    used for the On-Demand case. This avoids reformatting and also permits to
    reuse the Segments that are already cached.

  * the re-use of the live MPD, but requiring some modifications

  * Problems from live delivery may be solved, e.g. variable segment durations,
    or issues of segment unavailability.

  * The content may be augmented with ads.

In both cases, the VoD asset is defined by a time window in the live
presentation, whereby each, the start time and end time are defined a Period in
the MPD and a media time within the Period. Specifically,

  * the first media presentation time of the new On-Demand presentation is
    specified by a Period <em>P<sub>0</sub></em> of the live service, and the
    media presentation time <em>T<sub>0</sub></em> within this Period
    <em>P<sub>0</sub></em>.

  * the end time of the new On-Demand presentation is specified by a Period
    <em>P<sub>1</sub></em> that is not earlier than Period
    <em>P<sub>1</sub></em> of the live service, and the media presentation time
    <em>T<sub>1</sub></em> within this Period <em>P<sub>1</sub></em>.

### Scheduled and Bounded Live Service transitioned to VoD ### {#live2vod:scenario-scheduled-and-bounded}

A first scenario for Live Content being converted to VOD is the case that a
scheduled live event starting at a known date and time is also made available
for On-Demand offering after the live program is completed.

### Extracting a time period from continuous live ### {#live2vod:scenario-extraction}

In the second scenario, the content is trimmed from a longer, e.g. 24/7 stream,
at the beginning, the end, or in between. This allows that the content is
offered in a recorded fashion to users. For this purpose, it is assumed that
there is a start time and end time defined in the live asset.

### Transition between Live and On-Demand ### {#live2vod:scenario-transition}

There may be scenarios, for which service provided in live and on-demand
concurrently, or there may be a transition phase. Assume towards the end of a
live service, the content and service remains on the portal, but the clients are
no longer experience the joining of the live service at the live edge, but the
On-Demand service from the start.

## Content Offering Requirements and Recommendations ## {#live2vod:content-offering}

### Common aspects ### {#live2vod:content-offering-common-aspects}

A live service is offered with an MPD, where for the MPD the `MPD@type` is set
to `dynamic`. In addition, the MPD may be updated by having the
`MPD@minimumUpdatePeriod` present. The live service may use different types of
profiles, including multi-Period content, number-based or time-based templating,
as well using `@duration` or Segment Timeline based signaling. The live service
may include events in the MPD and/or Inband Event Streams. Segments get
available over time, signaled by the sum of the `MPD@availabilityStartTime`, the
start of the Period provided in *PeriodStart* as defined in [[!DASH]], clause
5.3.2.

In order to provide live content as On-Demand in the above scenario, the
following is recommended:

  * The same Segments as generated for the live distribution are reused also for
    VoD distribution.

  * The Segments for live and VoD services share the same URLs in order to
    exploit caching advantages.

  * An MPD for the VOD service is created using the MPD for the live service
    with the following modifications

    * The `MPD@type` is set to `static`.

    * The `MPD@availabilityStartTime` may be removed, but could also be
      maintained from the live MPD since all resources referenced in the MPD are
      available assuming that the resources of the live program are available.
      The content author may also set the `MPD@availabilityStartTime` to a later
      time, for example to the largest availability time of any Segment in the
      live Media Presentation.

    * The attributes `@timeShiftBufferDepth` and `@minimumUpdatePeriod` should
      not be present (in contrast to the live MPD), i.e. it is expected that
      such attributes are removed. Note that according to ISO/IEC 23009-1
      [[!DASH]], that if present, a client is expected to ignore these
      attributes for `MPD@type` set to `static`.

    * Content may be offered in the same Period structure as for live or in a
      different one. However,

      * if Periods were only added to provide ad insertions opportunities and
        are signaled to be period-continuous [[!IOP5-PART5]], it is preferable
        to remove the Period structure.

      * if new Periods are added for Ad Insertion, the Periods are preferably
        added in a way that they are at Segment boundaries of video Adaptation
        Sets following the recommendations in [[!IOP5-PART5]].

    * The presentation duration is determined through either the
      `@mediaPresentationDuration` attribute or, if not present, through the sum
      of the *PeriodStart* and the `Period@duration` attribute of the last
      Period in the MPD. Details on this setting are defined specifically for
      each scenario.

    * Independent whether the `@duration` attribute or the `SegmentTimeline`
      element was used for the live distribution, the static distribution
      version preferably uses the `SegmentTimeline` with accurate timing to
      support seeking and to possibly also signal any gaps in the Segment
      timeline. However, to obtain the accurate timeline, the segments may have
      to be parsed (at least up to the `tfdt`) to extract the accurate start
      time and duration of each Segment.

    * The same templating mode as used in the live service should also be used
      for static distribution in order to reuse the URLs of the cached Segments.

    * MPD validity expiration events should not be present in the MPD. However,
      it is not recommended that `emsg` boxes are removed from Segments as this
      would result in change of Segments and invalidate caches.

Specifically on the timing of the Periods,

  * for first period <em>P<sub>0</sub></em> in the live period,

    * `Period@start` shall be either be removed or set to zero.

    * the `@presentationTimeOffset` for each Adaptation Set is set to the media
      presentation time included in the Segment at <em>T<sub>0</sub></em>,
      normalized by the value of the `@timescale` of the Adaptation Set.

    * The value of the `Period@duration` attribute shall be set as follows. If
      the first Period and the last Period are identical, i.e.
      <em>P<sub>0</sub></em> is <em>P<sub>1</sub></em>, then *PeriodDuration* is
      set to <em>T<sub>1</sub></em> – <em>T<sub>0</sub></em>. If the first
      Period is different than the last Period, i.e. <em>P<sub>1</sub></em> is
      not <em>P<sub>0</sub></em>, then the *PeriodDuration* is set to the
      difference of *PeriodStart* value of the second Period minus
      <em>T<sub>0</sub></em>.

  * For all remaining Periods except the last one, the *PeriodDuration* shall be
    set to the difference of the *PeriodStart* of the next Period and the
    *PeriodStart* value of the this Period in the live MPD.

  * For the last Period, if it is not the identical to the first Period, the
    *PeriodDuration* is set to the difference of <em>T<sub>1</sub></em> and the
    *PeriodStart* of this last Period <em>P<sub>1</sub></em> in the live MPD. If
    the first Period is different than the last Period, then the
    *PeriodDuration* is set to the difference of *PeriodStart* value of the
    second Period minus <em>T<sub>0</sub></em>.

  * For all cases the *PeriodDuration* is preferably signaled by removing the
    `Period@start` attribute for each Period and setting the `Period@duration`
    attribute to *PeriodDuration*. However, setting the `Period@start`attribute
    may also be used. Also, to signal the *PeriodDuration* of the last Period,
    the `MPD@mediaPresentationDuration` attribute may be used.

    Note: Check precedence here

### Scheduled and Bounded Live Service transitioned to VoD ### {#live2vod:content-offering-scheduled-and-bounded}

In the specific scenario for a scheduled service, for which the start and end
times of the live and VOD service coincide, it is recommended that for the live
service, the `MPD@availabilityStartTime` is set as the availability time of the
initial Period, and the `Period@start` of the first Period of the live service
is set to 0.

If this is the case, the operations documented in the common aspects in clause
[[#live2vod:content-offering-common-aspects]] are significantly simplified and
no changes to period timing are needed. The only modifications to the MPD are as
follows:

  * adding the attribute `MPD@mediaPresentationDuration`

  * removing the attribute `MPD@minimumUpdatePeriod`

  * changing the `MPD@type` from `dynamic` to `static`

### Extracting a time period from continuous live ### {#live2vod:content-offering-extraction}

In the scenario, for which a part from the live service extracted and made
available as On-Demand content, basically all recommendations from the common
aspects in clause [[#live2vod:content-offering-common-aspects]] apply.

### Transition between Live and On-Demand ### {#live2vod:content-offering-transition}

In the case of transitioning the services, the content offering should take into
account the following guidelines. 

Generally, in particular in 24/7 live service,
or if the VOD service starts before the live service ends, it is discouraged
that the the same MPD URL is used for live and On-Demand content. It is
preferred to create a new MPD URL for the On-demand content to not confuse
clients when transitioning from live to VoD MPD. Note that the same Segments may
and should be shared across live and VOD MPD.

However, there are cases for which a transition from live to On-demand content
can be considered at the end of a live service and re-using the existing MPD
URL, in particular when the live service follows the specific restrictions in
section [[#live2vod:content-offering-scheduled-and-bounded]].

In this transitioning phase, as a first action, once the URL and publish time of
the last Segment is known for the live service, and the duration of the service
is known as well, the live MPD should be changed as follows as defined in clause
4.4.3.1 of [[!IOP43]],, i.e.,

  * adds the attribute `MPD@mediaPresentationDuration`

  * removes the attribute `MPD@minimumUpdatePeriod`

This action is the normal action when terminating a live service.

In this case and at this time, all Segments are available and clients playing the live
service can complete the playback of the service until the end. Clients may also
use the timeshift buffer to go back to earlier media times. The beneficial
aspect of this action is, that the DASH clients are expected stop updating the
MPD for operational reasons.

However, clients joining the service for the first time seeing the above MPD
will see the type `dynamic` and will attempt to access the live edge, but the
live edge does not exist. For this case, the client is expected to only show the
last few video frames of the last segment, but this user experience less preferred.

In order for clients to join at the start of the live service, the `MPD@type`
needs to change from `dynamic` to `static`. While this change may confuse
clients that update the MPD, as long as this action happens only at a time when
clients no longer update the MPD, it will not create issues. For clients that
play back, MPD updates are expected to not happen anymore after the MPD change
from `@minimumUpdatePeriod` to `@mediaPresentationDuration` has been done, with
some grace period. The grace period can be estimated as the value of
`@minimumUpdatePeriod` plus the value of the `@maxSegmentDuration`. After this
time, it is expected that only clients would update the MPD that have paused
playback of live, and have not implemented MPD updates in pause state.

Hence, it is recommended that in the general case, service providers are
permitted to change the MPD and replace the `@type` to be `static` and apply all
of the modifications as documented in clause 4.6.2.

In the specific service offering above for which the `MPD@availabilityStartTime` is
set to a value that is aligned with the start of the live presentation, and for
which the `Period@start` of the first Period is set to 0, none of the Period
modifications described in 4.6.2 need to be done and the MPD can be used as is.
In this case, the change from `static` to `dynamic` may happen even earlier.

## Client Behavior ## {#live2vod:client}

For a DASH client, there is basically no difference on whether the content was
generated from a live service or the content is provided as On-Demand. However,
there are some aspects that may be “left-overs” from a live service distribution
that a DASH client should be aware of:

  * The Representations may show gaps in the Segment Timeline. Such gaps should
    be recognized and properly handled. For example a DASH client may find a gap
    only in one Representation of the content and therefore switches to another
    Representation that has no gap.

  * The DASH client shall ignore any possibly present DASH Event boxes `emsg`
    (e.g., MPD validity expirations) for which no Inband Event Stream is present
    in the MPD.

  * clients that access an MPD with `MPD@type='static'` for first time will
    start playback from the beginning (unless a specific start time is chosen
    using an MPD anchor). Clients that access an `MPD@type='dynamic'` for the
    first time will start from the live edge (unless a specific start time is
    chosen using an MPD anchor).

DASH clients should support the transition from `MPD@type` being `dynamic` to
`static` in the case when the `@minimumUpdatePeriod` is no longer present in the
MPD, as long as the Period structure is not changed.

## Examples ## {#live2vod:examples}

NOTE: Add some MPD examples

## Reference Tools ## {#live2vod:reference-tools}

NOTE: provide status for the following functionalities
  * Dash.js
  * Live Sim
  * Test Vectors
  * JCCP

## Additional Information ## {#live2vod:additional-information}




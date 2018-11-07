# Core features # {#core-features}

This chapter describes requirements for using the most important features of DASH. All clients and services must conform to these requirements in order to exhibit interoperable behavior.

## Seamless switching ## {#seamless-switching-feature}

A key feature of DASH is the ability for clients to seamlessly switch between compatible [=representations=] at predetermined points on the [=MPD timeline=], enabling content from different [=representations=] to be interleaved according to the wishes of the client. This enables adaptive streaming - changing the active quality level in accordance with dynamically changing network conditions. Most DASH presentations define switching points at 1-10 second intervals.

Note: Decoder reinitialization during [=representation=] switches may result in visible or audible artifacts on some clients.

There SHALL be IDR-like SAPs (i.e. SAPs of type 1 or 2) at the start of each [=media segment=]. This enables seamless switching. The presence of such SAPs SHALL be signaled in the [=MPD=] by providing a value of `1` or `2`, depending on the sample structure of the [=media segments=], for either `AdaptationSet@subsegmentStartsWithSAP` (if [=indexed addressing=] is used) or `AdaptationSet@segmentStartsWithSAP` (if any other [=addressing mode=] is used).

Issue: We need to clarify how to determine the right value for startsWithSAP. [#235](https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/235)

Issue: Add a reference here to help readers understand what are "IDS-like SAPs (i.e. SAPs of type 1 or 2)".

See also [[#bitstream-switching]].

## Multiple periods ## {#multiperiod-feature}

Services MAY be offered with multiple [=periods=]. Clients SHOULD support playback of multi-period presentations.

To understand the role of [=periods=] and why multiple [=periods=] might be used, see [[#timing]].

## Segment URL resolution ## {#segment-url-resolution-feature}

A service MAY publish [=media segments=] on URLs unrelated to the [=MPD=] URL. A service MAY use multiple `BaseURL` elements on any level of the MPD to offer content on multiple URLs (e.g. via multiple CDNs). HTTP redirection MAY be used when responding to client requests.

For [=media segment=] requests, the DASH client SHALL determine the URL according to the following algorithm:

<div algorithm="Segment request">
1. If an absolute [=media segment=] URL is present in the MPD, it is used as-is (after [[#template-variable-constraints|template variable substitution]], if appropriate).
1. If an absolute `BaseURL` element is present in the MPD, it is used as the base URL.
1. Otherwise the MPD URL is used as the base URL, taking into account any MPD URL updates that occurred due to [=MPD refreshes=].
1. The base URL is combined with the relative [=media segment=] URL.

</div>

Note: The client may use any logic to determine which `BaseURL` to use if multiple are provided.

The same logic SHALL be used for [=initialization segments=] and [=index segments=].

Issue: What do relative BaseURLs do? Do they just incrementally build up the URL? Or are they ignored? This algorithm leaves it unclear, only referencing absolute BaseURLs. We should make it explicit.

## Minimum buffer time signaling ## {#minbuffertime-feature}

Issue: The text here is technically correct but could benefit from being reworded in a simpler and more understandable way. If anyone finds themselves with the time, an extra pass over this would be helpful.

The MPD contains a pair of values for a bandwidth and buffering description, namely the Minimum Buffer Time (MBT) expressed by the value of `MPD@minBufferTime` and bandwidth (`BW`) expressed by the value of `Representation@bandwidth`. The following holds:

* the value of the minimum buffer time **does not provide any instructions to the client on how long to buffer the media**. The value however describes how much buffer a client should have under **ideal** network conditions. As such, MBT is not describing the burstiness or jitter in the network, it is describing the burstiness or jitter in the **content encoding**. Together with the BW value, it is a property of the content. Using the "leaky bucket" model, it is the size of the bucket that makes BW true, given the way the content is encoded.
* The minimum buffer time provides information that for each Stream Access Point (and in the case of DASH-IF therefore each start of the [=media segment=]), the property of the stream: If the Representation (starting at any segment) is delivered over a constant bitrate channel with bitrate equal to value of the BW attribute then each presentation time PT is available at the client latest at time with a delay of at most PT + MBT.
* In the absence of any other guidance, **the MBT should be set** to the maximum GOP size (coded video sequence) of the content, which quite often is identical **to the maximum [=media segment=] duration**. The MBT may be set to a smaller value than maximum [=media segment=] duration, but should not be set to a higher value.

In a simple and straightforward implementation, a DASH client decides downloading the next segment based on the following status information:

* the currently available buffer in the media pipeline, buffer
* the currently estimated download rate, rate
* the value of the attribute `@minBufferTime`, `MBT`
* the set of values of the `@bandwidth` attribute for each Representation `i`, `BW[i]`

The task of the client is to select a suitable Representation `i`.

The relevant issue is that starting from a SAP on, the DASH client can continue to playout the data. This means that at the current time it does have `buffer` data in the buffer. Based on this model the client can download a Representation `i` for which `BW[i] ≤ rate*buffer/MBT` without emptying the buffer.

Note that in this model, some idealizations typically do not hold in practice, such as constant bitrate channel, progressive download and playout of Segments, no blocking and congestion of other HTTP requests, etc. Therefore, a DASH client should use these values with care to compensate such practical circumstances; especially variations in download speed, latency, jitter, scheduling of requests of media components, as well as to address other practical circumstances.

One example is if the DASH client operates on [=media segment=] granularity. As in this case, not only parts of the [=media segment=] (i.e., MBT worth of data) needs to be downloaded, but the entire Segment, and if the MBT is smaller than the [=media segment=] duration, then rather the [=media segment=] duration needs to be used instead of the MBT for the required buffer size and the download scheduling, i.e. download a Representation `i` for which `BW[i] ≤ rate*buffer/max_segment_duration`.

## Dynamic MPDs ## {#dynamic-mpd-features}

Features in this chapter are specific to presentation of [=dynamic MPDs=], which can change over time and have a fixed mapping to real time.

Client support for [=dynamic MPD=] presentation is optional - features in this section are only critical if the client supports [=dynamic MPDs=].

### MPD refreshes ### {#mpd-refreshing-feature}

[[#timing-mpd-updates|Dynamic MPDs may be updated]] as the content of the presentation changes. In order to stay informed of the updates, clients need to perform <dfn>MPD refreshes</dfn> at appropriate moments to download the updated [=MPD=] snapshots.

Clients presenting dynamic [=MPDs=] SHALL execute the following [=MPD=] refresh logic:

1. When an [=MPD=] snapshot is downloaded, it is valid for the present moment and at least `MPD@minimumUpdatePeriod` after that.
1. A client can expect to be able to successfully download any [=media segments=] that the [=MPD=] defines as [=available=] at any point during the [=MPD validity duration=].
1. The clients MAY refresh the [=MPD=] at any point. Typically this will occur because the client wants to obtain more [=segment references=] or make more [=media segments=] (for which it might already have references) [=available=] by extending the [=MPD=] validity duration.
    * This may result in a different [=MPD=] snapshot being downloaded, with updated information.
    * Or it may be that the [=MPD=] has not changed, in which case its validity period is extended to `now + MPD@minimumUpdatePeriod`.

Note: There is no requirement that clients poll for updates at `MPD@minimumUpdatePeriod` interval. They can do so as often or as rarely as they wish - this attribute simply defines the [=MPD=] validity duration.

[[#inband|Services MAY publish in-band events to explicitly signal MPD validity]], instead of expecting clients to regularly refresh on their own initiative. This enables finer control by the service but might not be supported by all clients.

For more details, see [[#timing-dynamic]] and [[#inband]].

### MPD URL resolution ### {#mpd-location-feature}

A service MAY use the `MPD/Location` element to redirect clients to a different URL to perform [=MPD refreshes=]. HTTP redirection MAY be used when responding to client requests.

A DASH client performing an [=MPD refresh=] SHALL determine the MPD URL according to the following algorithm:

<div algorithm="MPD refresh">
1. If at least one `MPD/Location` element is present, the value of any `MPD/Location` element is used as the MPD URL. Otherwise the original MPD URL is used as the MPD URL.
1. If the HTTP request results in an HTTP redirect using a 3xx response code, the redirected URL replaces the MPD URL.

</div>

The MPD URL as defined by the above algorithm SHALL be used as an implicit base URL for [=media segment=] requests.

Any present `BaseURL` element SHALL NOT affect MPD location resolution.

### Conditional MPD downloads ### {#conditional-mpd-downloads-feature}

It can often be the case that a [[#svc-live|live service]] signals a short [=MPD=] validity period to allow for the possibility of terminating the last [=period=] with minimal end-to-end latency. At the same time, generating future [=segment references=] might not require any additional information to be obtained by c7lients. That is, a situation might occur where constant [=MPD refreshes=] are required but the [=MPD=] content rarely changes.

Clients using HTTP to perform [=MPD refreshes=] SHOULD use conditional GET requests as specified in [[!RFC7232]] to avoid unnecessary data transfers when the contents of the [=MPD=] do not change between refreshes.

### Real time clock synchronization ### {#clock-sync-feature}

It is critical for [[#timing-dynamic|dynamic MPDs]] to synchronize the clocks of the service and the client. The time indicated by the clock does not necessarily need to match some universal standard as long as the two are mutually synchronized.

A dynamic MPD SHALL include at least one `UTCTiming` element that defines a clock synchronization mechanism. If multiple `UTCTiming` elements are listed, their order determines the order of preference.

A client presenting a dynamic MPD SHALL synchronize its local clock according to the `UTCTiming` elements in the MPD and SHALL emit a warning or error to application developers when clock synchronization fails, no `UTCTiming` elements are defined or none of the referenced clock synchronization mechanisms are supported by the client.

Note: The use of a "default time source" is not allowed. The mechanism of time synchronization must always be explicitly defined in the MPD by every service and interoperable clients cannot assume a default time source.

The set of time synchronization mechanisms SHALL be restricted to the following schemes defined in [[!MPEGDASH]]:

* urn:mpeg:dash:utc:http-xsdate:2014
* urn:mpeg:dash:utc:http-iso:2014
* urn:mpeg:dash:utc:http-ntp:2014
* urn:mpeg:dash:utc:ntp:2014
* urn:mpeg:dash:utc:http-head:2014
* urn:mpeg:dash:utc:direct:2014

Issue: We could use some detailed examples here, especially as clock sync is such a critical element of live services.
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

## Large timescales and time values ## {#timescale-constraints}

[[ECMASCRIPT]] is unable to accurately represent numeric values greater than 2<sup>53</sup> using built-in types. Therefore, interoperable services cannot use such values.

All timescales are start times used in a DASH presentations SHALL be sufficiently small that no timecode value exceeding 2<sup>53</sup> will be encountered, even during the publishing of long-lasting [[#svc-live|live services]].

Note: This may require the use of 64-bit fields, although the values must still be limited to under 2<sup>53</sup>.

## MPD size ## {#mpd-size-constraints}

No constraints are defined on [=MPD=] size, or on the number of elements. However, services SHOULD NOT create unnecessarily large [=MPDs=].

Note: [[DVB-DASH]] defines some relevant constraints in section 4.5. Consider obeying these constraints to be compatible with [[DVB DASH]].

## Representing durations in XML ## {#xml-duration-constraints}

All units expressed in [=MPD=] fields of datatype `xs:duration` SHALL be treated as fixed size:

* 60S = 1M (minute)
* 60M = 1H
* 24H = 1D
* 30D = 1M (month)
* 12M = 1Y

[=MPD=] fields having datatype `xs:duration` SHALL NOT use the year and month units and SHOULD be expressed as a count of seconds, without using any of the larger units.
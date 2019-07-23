## Accessing resources over HTTP ## {#http}

[[!MPEGDASH]] defines the structure of DASH presentations. Combined with an understanding of the [[=addressing modes=]], this enables DASH clients to determine a set of HTTP requests that must be made to acquire the resources needed for playback of a DASH presentation. This section defines rules for performing the HTTP requests and signaling the relevant parameters in an interoperable manner.

Issue: https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/333

### MPD URL resolution ### {#mpd-location-feature}

A service MAY use the `MPD/Location` element to redirect clients to a different URL to perform [=MPD refreshes=]. HTTP redirection MAY be used when responding to client requests.

A DASH client performing an [=MPD refresh=] SHALL determine the MPD URL according to the following algorithm:

<div algorithm="MPD refresh">
1. If at least one `MPD/Location` element is present, the value of any `MPD/Location` element is used as the MPD URL. Otherwise the original MPD URL is used as the MPD URL.
1. If the HTTP request results in an HTTP redirect using a 3xx response code, the redirected URL replaces the MPD URL.

</div>

The MPD URL as defined by the above algorithm SHALL be used as an implicit base URL for [=media segment=] requests.

Any present `BaseURL` element SHALL NOT affect MPD location resolution.

### Segment URL resolution ### {#segment-url-resolution-feature}

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

### Conditional MPD downloads ### {#conditional-mpd-downloads-feature}

It can often be the case that a [[#svc-live|live service]] signals a short [=MPD=] validity period to allow for the possibility of terminating the last [=period=] with minimal end-to-end latency. At the same time, generating future [=segment references=] might not require any additional information to be obtained by c7lients. That is, a situation might occur where constant [=MPD refreshes=] are required but the [=MPD=] content rarely changes.

Clients using HTTP to perform [=MPD refreshes=] SHOULD use conditional GET requests as specified in [[!RFC7232]] to avoid unnecessary data transfers when the contents of the [=MPD=] do not change between refreshes.

### Expanding URL template variables ### {#template-variable-constraints}

This section clarifies expansion rules for URL template variables such as `$Time$` and `$Number`, defined by [[!MPEGDASH]].

The set of string formatting suffixes used SHALL be restricted to `%0[width]d`.

Note: The string format suffixes are not intended for general-purpose string formatting. Restricting it to only this single suffix enables the functionality to be implemented without a string formatting library.
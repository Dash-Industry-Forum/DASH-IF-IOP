# Content protection and security # {#security}

## Introduction ## {#CPS-Intro}

DASH-IF do not intend to specify a full end-to-end DRM system. However DASH-IF provides a framework allowing multiple DRM systems to protect DASH content by adding private information in predetermined locations in MPDs and DASH content that is encrypted with Common Encryption as defined in [[!MPEGCENC]].

Common Encryption specifies several protection schemes and associated parameters. These can be applied by a scrambling system and used by key mapping methods part of different DRM systems, thanks to common key identifiers (`KID` and `default_KID`). The same encrypted version of DASH content can be combined with different DRM systems private information allowing licenses and keys retrieval (Protection System Specific Header Box `pssh` in the ISOBMFF file and  `ContentProtection` elements in the MPD. The DRM systems are identified by specific DRM systemID.

The recommendations in this document constrain the encryption parameters and use of the encryption metadata to specific use cases for VOD and live content with key rotation.

## HTTPS and DASH ## {#CPS-HTTPS}

Transport security in HTTP-based delivery may be achieved by using HTTP over TLS (HTTPS) as specified in [[!RFC8446]]. HTTPS is a protocol for secure communication which is widely used on the Internet and also increasingly used for content streaming, mainly for protectiing:

* The privacy of the exchanged data from eavesdropping by providing encryption of bidirectional communications between a client and a server, and
* The integrity of the exchanged data against forgery and tampering.

As an MPD carries links to media resources, web browsers follow the W3C recommendation [[!mixed-content]]. To ensure that HTTPS benefits are maintained once the MPD is delivered, it is recommended that if the MPD is delivered with HTTPS, then the media also be delivered with HTTPS.

DASH also explicitly permits the use of HTTPS as a URI scheme and hence, HTTP over TLS as a transport protocol. When using HTTPS in an MPD, one can for instance specify that all media segments are delivered over HTTPS, by declaring that all the `BaseURL`'s are HTTPS based, as follow:

```xml
<BaseURL>https://cdn1.example.com/</BaseURL>
<BaseURL>https://cdn2.example.com/</BaseURL>
```

One can also use HTTPS for retrieving other types of data carried with a MPD that are HTTP-URL based, such as, for example, DRM licenses specified within the `ContentProtection` element:

```xml
<ContentProtection
  schemeIdUri="urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  value="DRMNAME version"
  <drm:License>https://MoviesSP.example.com/protect?license=kljklsdfiowek</drm:License>
</ContentProtection>
```

It is recommended that HTTPS be adopted for delivering DASH content. It should be noted nevertheless, that HTTPS does interfere with proxies that attempt to intercept, cache and/or modify content between the client and the TLS termination point within the CDN. Since the HTTPS traffic is opaque to these intermediate nodes, they can lose much of their intended functionality when faced with HTTPS traffic.

While using HTTPS in DASH provides good protection for data exchanged between DASH servers and clients, HTTPS only protects the transport link, but does not by itself provide an enforcement mechanism for access control and usage policies on the streamed content. HTTPS itself does not imply user authentication and content authorization (or access control). This is especially the case that HTTPS provides no protection to any streamed content cached in a local buffer at a client for playback. HTTPS does not replace a DRM.

## Content Encryption ## {#CPS-Encryption}

DASH content SHALL be encrypted with either the cenc or the cbcs Common Encryption protection schemes. Full specification of these protection schemes is given in [[!MPEGCENC]] sections 10.1 and 10.4 respectively.

Note: These are two non-interoperable encryption modes. DASH content encrypted with the cenc protection scheme cannot be decrypted by a device supporting only the cbcs protection scheme and vice versa.

DASH content associated to Representations contained in one Adaptation Set SHALL be encrypted with the same protection scheme, either cenc or cbcs.

Note: This is to facilitate seamless switching within Adaptation Sets, out of concern that some clients may not be able to switch between Representations seamlessly if the Representations are not all encrypted using the same algorithm.

DASH content represented by an MPD MAY be encrypted with different protection schemes in different Adaptation Sets.
There MAY be unencrypted Period, hence clear to encrypted transitions and the opposite are possible.

Note: It is up to the client to select Adaptation Sets that it is able to process in each Period based on the MPD and the client’s capabilities. A client may select Adaptation Sets that are all encrypted using the same protection scheme but this is not mandatory.

Issue: Clients in browsers must assume what the CDM support as there is no standardized API for probing the platform for knowning which Common Encryption proteciton scheme is supported. A bug is open on W3C EME and a pull request exists [here](https://github.com/w3c/encrypted-media/pull/392) for the ISOBMFF file format bytestream and a proposal is open for probing the platform on the encryption mode supported.

## ISOBMFF Support for Common Encryption and DRM ## {#CPS-ISO4CENC}

### ISOBMFF Structure Overview ### {#CPS-ISO4CENC-Overview}

ISOBMFF carries content protection information in different locations. The following shows the boxes hierarchy and composition for relevant boxes, when using common encryption:

* `moov/pssh` (zero or one per DRM system)

    Protection System Specific Header box, see [[!MPEGCENC]] section 8.1.1.

    It contains license acquisition data and/or keys for each DRM system in a format that is proprietary. `pssh` boxes may be stored in Initialization Segment in the Movie Header box `moov` or in Media Segments in the Movie Fragment box `moof`.

* `moof/traf/senc` (one if encrypted)

    Sample Encryption box, see [[!MPEGCENC]] section 7.1.

    It may store initialization vectors (IVs) and subsample encryption ranges. It is stored in each Track Fragment box of an encrypted track, and the stored parameters are accessed using the Sample Auxiliary Information Offset box (`saio`) and the Sample Auxiliary Information Size box (`saiz`).

* `moof/traf/saio` (one if encrypted)

    Sample Auxiliary Information Offset box, see [[!MPEG4]] section 8.7.9.

    It contains the offset to the IVs and of the subsample encryption byte ranges.

* `moof/traf/saiz` (one if encrypted)

    Sample Auxiliary Information Size box, see [[!MPEG4]] section 8.7.8.

    It contains the size of the IVs and of the subsample encryption byte ranges.

* `moov/trak/mdia/minf/stbl/stsd/sinf/schm` (one if encrypted)

    Scheme Type box, see [[!MPEG4]] section 8.12.5 and [[!MPEGCENC]] section 4.

    It contains the encryption scheme, identified by a 4-character code, `cenc` or `cbcs`. It is stored in the Protection Scheme Information box (`sinf` see [[!MPEG4]] section 8.12.1 and [[!MPEGCENC]] section 4) that signals that the track is encrypted.

* `moov/trak/mdia/minf/stbl/stsd/sinf/schi/tenc` (one if encrypted)

    Track Encryption box, see [[!MPEGCENC]] section 8.2.1.

    It specifies encryption parameters and a `KID` named `default_KID` valid for the entire track. It is in the Initialization Segment. Any `KID` in Sample Group Description boxes (`sgpd`) override the `tenc` parameters (`default_KID` as well as `default_isProtected`).

For key rotation (see section [[#CPS-AdditionalConstraints-PeriodReauth]]), these additional boxes are used:

* `moof/pssh` (zero or one per DRM system)

    Protection System Specific Header box, see [[!MPEGCENC]] section 8.1.1.

    It contains license acquisition data and/or keys for each DRM system in a format that is proprietary. `pssh` boxes may be stored in Initialization Segment in the Movie Header box `moov` or in Media Segments in the Movie Fragment box `moof`.

* `moof/traf/sbgp` (one per sample group)

    Sample to Group box, see [[!MPEG4]] and [[!MPEGCENC]] section 5.

    With `sgpd` of type `seig` it is used to indicate the `KID` applied to each sample and allow changing `KID` over time (i.e. “key rotation”, see [[!MPEGDASH]] section 8.9.4). The keys corresponding to the `KIDs` referenced by sample groups must be available when the samples in a Segment are ready for decryption. Those keys may be conveyed in that Segment in `pssh` boxes.  A version 1 `pssh` box may be used to list all `KIDs` values to enable removal of duplicate boxes if a file is defragmented.

* `moof/traf/sgpd ‘seig’`(sample group entry) (one per sample group)

    Sample Group Description box, see [[!MPEG4]] section 8.9.3 and [[!MPEGCENC]].

    When of type `seig`,it is used to indicate the `KID` applied to each sample and allow changing `KID` over time (i.e. “key rotation”, see [[!MPEGDASH]] section 8.9.4).

### ISOBMFF Content Protection Constraints ### {#CPS-ISO4CENC-Constraints}

There SHALL be identical values of `default_KID` in the Track Encryption box (`tenc`) of all DASH content in Representation referenced by one Adaptation Set, when the Adpatation Set is protected by encryption. Different Adaptation Sets MAY have equal or different values of `default_KID`.

Note: In cases where, for example, SD and HD and UHD content in Representations are available in one Presentation, different license rights may be required for each quality level. In such case, separate Adaptation Sets should be created for each quality level, each with a different value of `default_KID`.

Issue: In this context, it is possible that the several quality levels are available under the same license right. Add text explaining why a shall is the way to do.

`pssh` boxes SHOULD NOT be present in Initialization Segments, and `cenc:pssh` elements in `ContentProtection` elements SHOULD be used instead. If `pssh` boxes are present in the Initialization Segment, each Initialization Segment within one Adaptation Set SHALL contain an equivalent `pssh` box for each DRM systemID, i.e. license acquisition from any Representation is sufficient to allow switching between Representations within the Adaptation Set without acquiring a new license.

Note: `pssh` boxes in Initialization Segments may result in playback failure when a license request is initiated each time an Initialization Segment is processed, such as the start of each protected Representation, each track selection, and each bitrate switch. This content requires DASH clients that can parse the `pssh` box contents to determine the duplicate license requests and block them.

Issue: This seems like an unlikely problem in real client implementations. Do we know of clients that actualy exhibit the problematic behavior? Look at EME and define if this is still a problem. Take advantage of the meeting in May with W3C

Note: The duplication of the `pssh` information in the Initialization Segment may cause difficulties in playback with EME based clients, i.e. content will fail unless clients build complex DRM specific license handling.

## DASH MPD Support for Common Encryption and DRM ## {#CPS-MPD4CENC}

### MPD Structure Overview ### {#CPS-MPD4CENC-Overview}

The main DRM components in the MPD are the `ContentProtection` element (see [[!MPEGDASH]] section 5.3.7.2 - table 9, section 5.8.5.2 and section 5.8.4.1) that contains the URI for signaling the use of Common Encryption or the use of a specific DRM and the `cenc:` namespace extension ([[!MPEGCENC]] section 11.2). The MPD contains such information to help the client to determine if it can possibly play back content.

#### `ContentProtection` Element for the `mp4protection` Scheme #### {#CPS-MPD4CENC-Overview-mp4protection}

A `ContentProtection` element with the `@schemeIdUri` value "urn:mpeg:dash:mp4protection:2011" signals that content is encrypted with the scheme indicated in the `@value`, either `cenc` or `cbcs` for the Common Encryption schemes supported by this guidelines, as specified in [[!MPEGCENC]]. It may be used to identify the KID values using the `@cenc:default_KID` attribute (see [[#CPS-MPD4Cenc-Overview-CENCSpace]]), also present in the ‘tenc‘ box. The values of this attribute are the KIDs expressed in UUID string notation.

This element may be sufficient to acquire a license or identify a previously acquired license that can be used to decrypt the Adaptation Set. It may also be sufficient to identify encrypted content in the MPD when combined with license acquisition information stored in `pssh` boxes in Initialization Segments.

```xml
<ContentProtection
 schemeIdUri="urn:mpeg:dash:mp4protection:2011"
 value="cenc"
 cenc:default_KID="34e5db32-8625-47cd-ba06-68fca0655a72"/>
```

#### `ContentProtection` Element for the UUID Scheme #### {#CPS-MPD4CENC-Overview-UUID}

A `ContentProtection` element with the `@schemeIdUri` value equal to a UUID value signals that content keys can be obtained through a DRM system identified by the UUID. The `@schemeIdUri` uses a UUID URN with the UUID string equal to the registered DRM systemID for a particular DRM system. This is specified in [[!MPEG4]] section 5.8.5.2. An example is:

```xml
<ContentProtection
  schemeIdUri="urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  value="DRMNAME version"/>
```

#### `cenc:` Namespace Extension #### {#CPS-MPD4Cenc-Overview-CENCSpace}

[[!MPEGCENC]] section 11.2 defines the namespace "urn:mpeg:cenc:2013", for which the usual namespace prefix is `cenc`.

A `pssh` box is defined by each DRM system for use with their registered DRM systemID, and the same box can be stored in the MPD within a `ContentProtection` element using an extension element in the `cenc:` namespace. Examples are provided in [[!MPEGCENC]] section 11.2. A `@cenc:default_KID` can also be stored under the `ContentProtection` element using the same `cenc:` namespace.

Carrying `@cenc:default_KID` attribute and a `cenc:pssh` element is useful to allow key identification, license evaluation, and license retrieval before Initialization Segments carrying the same information become available. This allows clients to spread license requests and avoid simultaneous requests from all clients at the instant that an Initialization Segment containing the `default_KID` values becomes available. With `@cenc:default_KID` indicated in the `mp4protection` `ContentProtection` element on each Adaptation Set, clients can determine if the required content key is available, or which licenses the client needs to obtained before the `@availabilityStartTime` of the Presentation based on the `default_KID` of each `AdaptationSet` element selected.

Carrying `@cenc:default_KID` attribute and a `cenc:pssh` element is useful to allow key identification, license evaluation, and license retrieval before live availability of Initialization Segments. This allows clients to spread license requests and avoid simultaneous requests from all viewers at the instant that an Initialization Segments containing the `default_KID` values becomes available.  With `@cenc:default_KID` indicated in the `mp4protection` `ContentProtection` element on each Adaptation Set, clients can determine if that key and this Presentation is not available to the viewer (e.g. without a purchase or a subscription), if the key is already downloaded, or which licenses the client SHOULD download before the `@availabilityStartTime` of the Presentation based on the `default_KID` of each `AdaptationSet` element selected.

### MPD Content Protections Constraints ### {#CPS-MPD4CENC-Constraints}

For an encrypted Adaptation Set, At least one `ContentProtection` element SHALL be present in the `AdaptationSet` element and apply to all contained Representations.

A `ContentProtection` element for the `mp4Protection` Scheme (`@schemeIdUri` equals to "urn:mpeg:dash:mp4protection:2011" and `@value`=`cenc` or `cbcs`) SHALL be present in the AdaptationSet element if DASH content represented by the contained Representations are encrypted. This allows clients to recognize the Adaptation Set is encrypted with a Common Encryption scheme without the need to understand any DRM system specific UUID element. This `ContentProtection` element SHALL contain the attribute `@cenc:default_KID`. The `tenc` box that specifies the encoded track encryption parameters shall be considered the definitive source of the default KID since it contains the `default_KID` field.  The `@cenc:default_KID` attribute SHALL match the `tenc` `default_KID` value. This allows general-purpose clients to identify the default `KID` from the MPD using a standard location and format without the need to understand any DRM system specific information format.

The `cenc:pssh` element SHOULD be present in the `ContentProtection` element for each DRM system identified by a DRM system encoded as a UUID. The base64 encoded contents of the element SHALL be equivalent to a `pssh` box including its header. The information in the `pssh` box SHOULD be sufficient for license acquisition.

Note:  A client such as DASH.js hosted by a browser may pass the contents of this element through the Encrypted Media Extension (EME) API to the DRM system Content Decryption Module (CDM) with a DRM systemID equal to the element's UUID value. This allows clients to acquire a license using only information in the MPD, prior to downloading Segments.

The `@value` attribute of the `ContentProtection` element for UUID Scheme SHOULD contain the DRM system name and version number in a human readable form.

Below is an example of the recommended format for a hypothetical acme DRM service

```xml
<ContentProtection
  schemeIdUri=”urn:uuid:d0ee2730-09b5-459f-8452-200e52b37567”
  value=”acme DRM 2.0”>
  <!-- base64 encoded ‘pssh’ box with SystemID matching the containing ContentProtection Element -->
  <cenc:pssh>
    YmFzZTY0IGVuY29kZWQgY29udGVudHMgb2YgkXBzc2iSIGJveCB3aXRoIHRoaXMgU3lzdGVtSUQ=
  </cenc:pssh>
</ContentProtection>
```

## Mix ISOBMFF and MPD Content Protections Constraints ## {#CPS-MixConstraints}

For a DRM system uniquely identified by its DRM systemID, in the case where the `cenc:pssh` element is present in the MPD and the `pssh` box is present in the Initialization Segment, the `cenc:pssh` element in the MPD SHALL take precedence because the parameters in the MPD will be processed first, are easier to update, and can be assumed to be up to date at the time the MPD is fetched.

The DRM systems allowing to access to protected DASH content are signaled in the MPD and possibly also in the ISOBMFF file. In both cases, the DRM system is uniquely identified with a DRM systemID. A list of known identifiers can be found in the DASH identifier [repository](https://dashif.org/identifiers/content_protection/).

If the default KID changes (this requires a new content key acquistion) and therefore the `@cenc:default_KID` value needs to be updated, it SHALL be at the beginning of a Period. A different Initialization Segment is then indicated with a different `default_KID` signaled in the `tenc` box.

Note: A file associated with a single content key may be continued over multiple Periods by being referenced by multiple Representations over multiple Periods (for instance, a program interspersed with ad Periods). A client can recognize the same `@cenc:default_KID` value and avoid requesting the same license again; but it is possible that some the DRM systems may require a complete erase and rebuild of the security context, including all key material, samples in process, etc., between `Periods` with different licenses or no license (between protected and clear Periods).

## Client Interactions with DRM Systems ## {#CPS-ClientDRMSystem}

A client interacts with one or more DRM systems during playback in order to control the decryption of content. The interaction is made through a DRM client that is responsible of enabling connection to a DRM server. Some of the most important interactions are:

* Determining the availability of content keys.
* Communicating with the DRM system to acquire content keys, most of the time through a license request.

In these interactions, the client and DRM system use the `default_KID` values as a mechanism to communicate information regarding the capability to decrypt DASH content described by Adaptation Sets. A DRM system MAY also make use of other keys in addition to the one signalled by the `default_KID` value (e.g. in key derivation or sample variant schemes) but this SHALL be transparent to the client.

When starting playback of Adaptation Sets, a client SHALL determine the required set of content keys based on the `default_KID` values.

Upon determining that one or more required content keys are not in its possession, the client SHOULD interact with the DRM system and request them. The client MAY also request content keys that are known to be usable. Clients SHALL request all required content keys signaled by the `default_KID` values. The client and/or DRM system MAY batch multiple requests (and the respective responses) into a single transaction (for example to reduce the chattiness of license acquisition traffic).

For efficient license delivery, it is recommended that clients:

* Request content keys on the initial processing of an MPD or ISOBMFF if `ContentProtection` elements or Initialization Segments are available with license acquisition information. This is intended to avoid a large number of simultaneous license requests at `MPD@availabilityStartTime`.
* Prefetch licenses for a new Period in advance of its presentation time to allow license download and processing time and prevent interruption of continuous decryption and playback. Advanced requests will also help prevent a large number of simultaneous license requests during a live presentation at `Period@startTime`.

## Additional Constraints for Specific Use Cases ## {#CPS-AdditionalConstraints}

### Periodic Re-Authorization ### {#CPS-AdditionalConstraints-PeriodReauth}

This section explains different options and tradeoffs to enable change in content keys (a.k.a. key rotation) on a given piece of content.

Note: The main motivation is to enable access rights changes at program boundaries, not as a measure to increase security of content encryption. The term *Periodic re-authorization* is therefore used here instead of *key rotation*. Note that periodic re-authorization is also one of the ways to implement counting of active streams as this triggers a connection to a license server.

The following use cases are considered:

* Consumption models such as live content, PPV, PVR, VOD, SVOD, live to VOD, network DVR. This includes cases where live content is converted into another consumption model for e.g. catch up TV.
* Regional blackout where client location may be taken into account to deny access to content in a geographical area.

The following requirements are considered:

* Ability to force a client to re-authorize to verify that it is still authorized for content consumption.
* Support seamless and uninterrupted playback when content keys are rotated by preventing storms of license requests from clients (these should be spread out temporally where possible to prevent spiking loads at isolated times), by allowing quick recovery (the system should be resilient if the server or many clients fail), and by providing to the clients visibility into the key rotation signaling.
* Support of hybrid broadcast/unicast networks in which client may operate in broadcast-only mode at least some of the time, e.g. where clients may not  always be able to download licenses on demand through unicast.

This also should not require changes to DASH and the standard processing and validity of MPDs.

#### Periodic Re-Authorization Content Protections Constraints #### {#CPS-AdditionalConstraints-PeriodReauth-Constraints}

Key rotation SHOULD not occur within individual segments. It is usually not necessary to rotate keys within individual segments. This is because segment durations are typically short in live streaming services (on the order of a few seconds), meaning that a segment boundary is usually never too far from the point where key rotation is otherwise desired to take effect.

When key hierarchy is used (see [[#CPS-AdditionalConstraints-PeriodReauth-Implementation]])

* Each Movie Fragment box (`moof`) box SHOULD contain one `pssh` box per DRM system. This `pssh` box SHALL contains sufficient information for obtaining content keys for this fragment when combined with information, for this DRM system, from either the `pssh` box obtained from the Initialization Segment or the `cenc:pssh` element from the MPD and the `KID` value associated with each sample from the `seig` Sample Group Description box and `sbgp` Sample to Group box that lists all the samples that use a given `KID` value.
* Constraints defined in [[#CPS-ISO4CENC-Constraints]] SHALL apply to the EMM/root license (one license is needed per Adaptation Set for each DRM system).

Issue: To be reviewed in light of CMAF and segment/chunk and low latency.

#### Implementation Options #### {#CPS-AdditionalConstraints-PeriodReauth-Implementation}

This section describes recommended approaches for periodic re-authorization. They best cover the use cases and allow interoperable implementation.

Note: Other approaches are possible and may be considered by individual implementers. An example is explicit signaling using e.g. esmg messages, and a custom key rotation signal to indicate future KIDs.

**Period**: A `Period` element is used as the minimum content key duration interval. Content key is rotated at the period boundary. This is a simple implementation and has limitations in the flexibility:

* The existing signaling in the MPD does not allow for early warning of change of the content key and associated decryption context, hence seamless transition between periods is not ensured.
* The logic for the creation of the periods is decided by content creation not DRM systems, hence boundaries may not be suited properly and periods may be longer than the desired key interval.

**Key Hierarchy**: Each DRM system has its own key hierarchy. In general, the number of levels in the key hierarchy varies among DRM systems. For interoperability purposes, only two levels need to be considered:

* Licenses for managing the rights of a user: This can be issued once for enforcing some scope of accessing content, such as a channel or library of shows (existing and future). It is cryptographically bound to one DRM system and is associated with one user ID. It enables access to licenses that control the content keys associated with each show it authorizes. There are many names for this type of licenses. In conditional access systems, a data construct of this type is called an entitlement management message (EMM). In the PlayReady DRM system, a license of this type is called a “root license”. There is no agreement on a common terminology.
* Licenses for accessing the content: This is a license that contains content keys and can only be accessed by devices that have been authorized. While licenses for managing rights are most of the time unique per user, the licenses for accessing the content are not expected to be unique and are tied to the content and not a user, therefore these may be delivered with content in a broadcast distribution. In addition doing so allows real time license acquisition, and do not require repeating client authentication, authorization, and rebuilding the security context with each content key change in order to enable continuous playback without interruption cause be key acquisition or license processing. In conditional access systems, a data construct of this type is called an entitlement control message (ECM). In the PlayReady DRM system,  a license of this type is called a “leaf license”. There is no agreement on a common terminology.

When using key hierarchy, the `@cenc:default_KID` value in the `ContentProtection` element, which is also in the `tenc` box, is the ID of the key requested by the DRM client. These keys are delivered as part of acquisition of the rights for a user. The use of key hierarchy is optional and DRM system specific.

Issue: For key hierarchy, add a sentence explaining that mixing DRM systems is possible with system constraints.

### Low Latency ### {#CPS-AdditionalConstraints-LowLatency}

Low latency content delivery requires that all components of the end-to-end systems are optimized for reaching that goal. DRM systems and the mechanisms used for granting access also need to be used in specific manners to minimize the impact on the latency. DRM systems are involved in the access to content in several manners:

* Device initialization
* Device authorization
* Content access granting

Each of these steps can have from an impact on latency ranging from low to high. The following describes possible optimizations for minimizing the latency.

#### Licenses Pre-Delivery #### {#CPS-AdditionalConstraints-LowLatency-Predelivery}

In a standard playback session, a client, after receiving the DASH MPD, checks the `@cenc:default_KID` value (either part of the `mp4protection` element or part of a DRM system element). If the client already has a content key associated to this `KID` value, it can safely assume that it is able to get access to content. If it does not have such content key, then a license request is triggered. This process is done every time a MPD is received (change of `Period`, change of Live service, notification of MPD change …). It would therefore be better that the client always has all keys associated to `@cenc:default_KID` values. One mechanism is license pre-delivery. Predelivery can be performed in different occasions:

* When launching the application, the client needs to perform some initialization and refresh of data, it therefore connects to many servers for getting updated information. The license server SHOULD allow the client to receive licenses for accessing content the client is entitled to. Typically, for subscription services, all licenses for all Live services SHOULD be delivered during this initialization step. It is the DRM system client responsibility to properly store the received information.
* The DRM system SHOULD have a notification mechanism allowing to trigger a client or a set of clients to out-of-band initiate licenses request, so that it is possible to perform license updates in advance. This typically allows pre-delivery of licenses when a change will occur at a `Period` boundary and, in this case, this also allow avoiding all clients connecting at almost the same time to the license server if not triggered in advance randomly.
* In case a device needs nevertheless to retrieve a license, the DRM system MAY also batch responses into a single transaction allowing to provide additional licenses (as explained in Section [[#CPS-ClientDRMSystem]]) that can be used in the future.

#### Key Hierarchy and CMAF Chunked Content #### {#CPS-AdditionalConstraints-Low-chunkedContent}

When a DRM system uses key hierarchy for protecting content, it adds DRM information in both possibly the Initialization Segment and in the content (in the `moof` box). The information in the `moof` box can allow the DRM client to know which root key to use decrypt the leaf license or to identify the already decrypted content key from a local protected storage. Most of the processing and logic is DRM system-specific and involves DRM system defined encryption and signaling. It may also include additional steps such as evaluating leaf license usage rules. Key hierarchy is one technique for enabling key rotation and it is not required to rotate content key at high frequency, typically broadcast TV has content key cryptoperiods of 10 seconds to few minutes.

CMAF chunked Content introduces `moof` boxes at a high frequency as it appears within segments and not only at the beginning of a segment. One can therefore expect to have several `moof` boxes every second. Adding signaling SHOULD be done only in the `moof` box of the first chunk in a segment.

Issue: To be completed. Look at encryption: Key available for license server “early” for been able to generate licenses (root or leaf licenses). Avoid the license server been on the critical path. Encourage license persistence in the client.

### Use of W3C Clear Key with DASH ### {#CPS-AdditionalConstraints-W3C}

When using W3C Clear Key key system with DASH [[!encrypted-media]], Clear Key related signaling is included in the MPD with a `ContentProtection` element that has the following format.

The Clear Key `ContentProtection` element attributes SHALL take the following values:

* The UUID e2719d58-a985-b3c9-781a-b030af78d30e is used for the `@schemeIdUri` attribute.
* The `@value` attribute is equal to the string “ClearKey1.0”

W3C also specifies the use of the DRM systemID=”1077efec-c0b2-4d02-ace3-3c1e52e2fb4b” in [[!eme-initdata-cenc]] section 4 to indicate that tracks are encrypted with Common Encryption [[!MPEGCENC]], and list the `KID` of content keys used to encrypt the track in a version 1 `pssh` box with that DRM systemID.  However, the presence of this Common `pssh` box does not indicate whether content keys are managed by DRM systems or Clear Key management specified in this section. Browsers are expected to provide decryption in the case where Clear Key management is used, and a DRM system where a DRM key management system is used. Therefore, clients SHALL NOT rely on the signalling of DRM systemID 1077efec-c0b2-4d02-ace3-3c1e52e2fb4b as an indication that the Clear Key mechanism is to be used.

W3C specifies that in order to activate the Clear Key mechanism, the client must provide Clear Key initialization data to the browser. The Clear Key initialization data consists of a listing of the default KIDs required to decrypt the content.

The MPD SHOULD NOT contain Clear Key initialization data. Instead, clients SHALL construct Clear Key initialization data at runtime, based on the default KIDs signaled in the MPD using `ContentProtection` elements with the urn:mpeg:dash:mp4protection:2011 scheme.

When requesting a Clear Key license to the license server, it is recommended to use a secure connection as described in Section [[#CPS-HTTPS]].

When used with a license type equal to “EME-1.0”:

* The GET request for the license includes in the body the JSON license request format defined in [[!encrypted-media]] section 9.1.3. The license request MAY also include additional authentication elements such as access token, device or user ID.
* The response from the license server includes in the body the Clear Key license in the format defined in [[!encrypted-media]] section 9.1.4 if the device is entitled to receive the Content Keys.

It should be noted that clients receiving content keys through the Clear Key key system may not have the same robustness that typical DRM clients are required to have. When the same content keys are distributed to DRM clients and to weakly-protected or unprotected clients, the weakly-protected or unprotected clients become a weak link in the system and limits the security of the overall system.

### License Acquisition URL XML Element Laurl ### {#Laurl}

The `Laurl` element MAY be added under the `ContentProtection` element. This element specifies the URL for a license server allowing to receive a license. It has the optional attribute `@licenseType` that is a string that provides additional information that is DRM-specific. 

The name space for the `Laurl` element is `http://dashif.org/guidelines/ContentProtection`

The XML schema for this element is:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns="http://dashif.org/guidelines/ContentProtection" 
targetNamespace="http://dashif.org/guidelines/ContentProtection">
	<xs:complexType name="Laurl">
		<xs:simpleContent>
			<xs:extension base="xs:anyURI">
				<xs:attribute name="licenseType" type="xs:string"/>
				<xs:anyAttribute namespace="##other" processContents="lax"/>
			</xs:extension>
		</xs:simpleContent>
	</xs:complexType>
</xs:schema>
```

#### ClearKey Example Using Laurl #### {#ClearKey-Laurl}
  
An example of a Clear Key `ContentProtection` element using `Laurl` is as follows. One possible value of `@licenseType` is “EME-1.0” when the license served by the Clear Key license server is in the format defined in [[!encrypted-media]].

```xml
<?xml version="1.0" encoding="UTF-8"?>
<MPD xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="urn:mpeg:dash:schema:mpd:2011 DASH-MPD.xsd http://dashif.org/guidelines/ContentProtection laurl.xsd"
xmlns="urn:mpeg:dash:schema:mpd:2011"
xmlns:dashif="http://dashif.org/guidelines/ContentProtection"
type="static" profiles="urn:mpeg:dash:profile:mp2t-simple:2011" minBufferTime="PT1.4S">
	<Period id="42" duration="PT6158S">
		<AdaptationSet mimeType="video/mp2t" codecs="avc1.4D401F,mp4a">
			<ContentProtection  schemeIdUri="urn:uuid:1077efec-c0b2-4d02-ace3-3c1e52e2fb4b"  value="ClearKey1.0">
				 <dashif:Laurl>https://clearKeyServer.foocompany.com</dashif:Laurl>
				 <dashif:Laurl licenseType="EME-1.0">file://cache/licenseInfo.txt</dashif:Laurl>
			</ContentProtection>
		</AdaptationSet>
	</Period>
</MPD>
```

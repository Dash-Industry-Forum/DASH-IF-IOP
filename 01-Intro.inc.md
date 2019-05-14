# Purpose # {#why-iop}

This document (<dfn>IOP</dfn>) builds on top of [[!MPEGDASH]] and related standards and specifications to:

1. Provide guidelines connecting them in ways that conform to industry best practices.
1. Constrain the usage of standards-defined features to a subset that DASH-IF members believe to be highly interoperable.

While alternative interpretations may be equally valid in terms of standards conformance, services and clients created following the guidelines defined in this document can be expected to exhibit highly interoperable behavior between different implementations.

# Interpretation # {#how-iop}

Requirements in this document describe client and service behavior that DASH-IF considers interoperable. If you choose to follow these requirements in a published DASH service, that service is likely to experience successful playback on a wide variety of clients and exhibit graceful degradation when a client does not support all features used by the service. Client-oriented requirements describe the mechanisms for consuming services that conform to this document.

This document assumes that the entire DASH presentation conforms to these guidelines. Interoperable behavior cannot be expected from partially conforming presentations.

There is no strict backward compatibility with previous versions - best practices change over time and what was once considered sensible may be replaced by a superior approach later on. Therefore, clients and services that were conforming to version N of this document are not guaranteed to conform to version N+1.

All DASH presentations are assumed to be conforming to [=IOP=]. A service MAY explicitly signal itself as conforming by including the string `https://dashif.org/guidelines/` in `MPD@profiles`.

# Disclaimer # {#legal}

This is a document made available by DASH-IF. The technology embodied in this document may involve the use of intellectual property rights, including patents and patent applications owned or controlled by any of the authors or developers of this document. No patent license, either implied or express, is granted to you by this document. DASH-IF has made no search or investigation for such rights and DASH-IF disclaims any duty to do so. The rights and obligations which apply to DASH-IF documents, as such rights and obligations are set forth and defined in the DASH-IF Bylaws and IPR Policy including, but not limited to, patent and other intellectual property license rights and obligations. A copy of the DASH-IF Bylaws and IPR Policy can be obtained at http://dashif.org/.

The material contained herein is provided on an "AS IS" basis and to the maximum extent permitted by applicable law, this material is provided AS IS, and the authors and developers of this material and DASH-IF hereby disclaim all other warranties and conditions, either express, implied or statutory, including, but not limited to, any (if any) implied warranties, duties or conditions of merchantability, of fitness for a particular purpose, of accuracy or completeness of responses, of workmanlike effort, and of lack of negligence.

In addition, this document may include references to documents and/or technologies controlled by third parties. Those third party documents and technologies may be subject to third party rules and licensing terms. No intellectual property license, either implied or express, to any third party material is granted to you by this document or DASH-IF. DASH-IF makes no any warranty whatsoever for such third party material.

Note that technologies included in this document and for which no test and conformance material is provided, are only published as a candidate technologies, and may be removed if no test material is provided before releasing a new version of this guidelines document. For the availability of test material, please check http://www.dashif.org.

# DASH and related standards # {#dash-is-important}

DASH is an adaptive media delivery technology defined in [[!MPEGDASH]]. DASH together with related standards and specifications is the foundation for an ecosystem of services and clients that work together to enable audio/video/text and related content to be presented to end-users.

<figure>
	<img src="Images/RoleOfIop.png" />
	<figcaption>This document connects DASH with international standards, industry specifications and DASH-IF guidelines.</figcaption>
</figure>

[[!MPEGDASH]] defines a highly flexible set of building blocks that needs to be constrained to a meaningful subset to ensure interoperable behavior in common scenarios. This document defines constraints that limit DASH features to those that are considered appropriate for use in interoperable clients and services.

This document was generated in close coordination with [[DVB-DASH]]. The features are aligned to the extent considered reasonable. To support implementers, this document attempts to highlight differences between [[=IOP=]] and [[DVB-DASH]].

## Structure of a DASH presentation ## {#what-is-dash}

[[!MPEGDASH]] specifies the structure of a DASH presentation, which consists primarily of:

1. The manifest or <dfn>MPD</dfn>, which describes the content and how it can be accessed.
1. Data containers that clients will download over the course of a presentation in order to obtain media samples.

<figure>
	<img src="Diagrams/DashStructure.png" />
	<figcaption>Relationships of primary DASH data structure and the standards they are defined in.</figcaption>
</figure>

The MPD is an XML file that follows a schema defined by [[!MPEGDASH]]. This schema contains various extension points for 3rd parties. [=IOP=] defines some extensions, as do other industry specifications.

[[!MPEGDASH]] defines two data container formats, one based on [[!ISOBMFF]] and the other [[MPEG2TS]]. However, only the former is used in modern solutions. Services SHALL NOT make use of the [[MPEG2TS]] container format.

[[!MPEGCMAF]] is the modern successor to [[!ISOBMFF]]. DASH services SHALL use [[!MPEGCMAF]] compatible data containers. To ensure backward compatibility with legacy services, clients SHOULD also support [[!ISOBMFF]] that does not conform to [[!MPEGCMAF]].

Note: The relationship to [[!MPEGCMAF]] is constrained to the container format. In particular, there is no requirement to conform to [[!MPEGCMAF]] media profiles.

The data container format defines the physical structure of the following elements described by the MPD:

1. Each [=representation=] in the [=MPD=] references an [=initialization segment=].
1. Each [=representation=] in the [=MPD=] references any number of [=media segments=].
1. Some [=representations=] in the [=MPD=] may reference an [=index segment=], depending on the [=addressing mode=] used.

There are strong parallels between [[!MPEGDASH]] and [[RFC8216|HLS]], both being adaptive streaming technologies that in their modern form use a mutually compatible container format ([[!MPEGCMAF]]).

<figure id="cmaf-terms">
	<table class="data">
		<thead>
			<tr>
				<th>[[!MPEGDASH]]
				<th>[[!MPEGCMAF]]
				<th>[[!ISOBMFF]]
		<tbody>
			<tr>
				<td>(media) segment, subsegment
				<td>CMAF segment
				<td>
			<tr>
				<td>initialization segment
				<td>CMAF header
				<td>
			<tr>
				<td>index segment, segment index
				<td>
				<td>segment index box (`sidx`)
	</table>
	<figcaption>Quick reference of closely related terms in different standards.</figcaption>
</figure>

Note: [[!MPEGDASH]] has the concept of "segment" (URL-addressable media object) and "subsegment" (byte range of URL-addressable media object), whereas [[!MPEGCMAF]] does not make such a distinction. [=IOP=] uses [[!MPEGCMAF]] segment terminology, with the term segment in [=IOP=] being equivalent to "CMAF segment" which in turns means "DASH media segment or media subsegment".
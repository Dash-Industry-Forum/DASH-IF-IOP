# Interoperability requirements # {#interoperability}

The DASH-related standards enable various different interpretations of critical factors. A single interpretation is necessary in order to establish interoperable behavior.

This chapter defines the requirements that enable DASH clients and services to provide interoperable behavior. All clients and services are expected to conform to these requirements.

## CMAF and ISO BMFF ## {#cmaf-bmff-constraints}

Issue: Can we omit some or all of this heading if we assume CMAF conformance?

The formats for many DASH data structures are defined by [[!MPEGCMAF]], which is largely based on [[!ISOBMFF]]. This chapter defines constraints on the use of [[!MPEGCMAF]] and [[!ISOBMFF]] features to limit them to a highly interoperable subset.

Default values set in the Track Extends (`trex`) box MAY be overridden by corresponding values set in movie fragments (in `tfhd` or `trun` boxes).

Movie Fragment (`moof`) boxes SHALL NOT use external data references. The flag `default-base-is-moof` SHALL be set (aka movie-fragment relative addressing) and `data-offset` SHALL be used (i.e. `base-data-offset-present` SHALL NOT be used).

Any Segment Index (`sidx`) and Subsegment Index (`ssix`) boxes SHALL be placed before any Movie Fragment (`moof`) boxes within [=media segments=]. There SHALL be at most one Segment Index (`sidx`) box for each [=representation=].

[=Media segments=] SHALL be non-multiplexed (contain only one track).
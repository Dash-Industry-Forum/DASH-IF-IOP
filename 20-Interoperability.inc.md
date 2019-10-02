# Interoperability requirements # {#interoperability}

The DASH-related standards enable various options for each feature supported by these standards. Limiting options and in some cases additional constraints are needed to establish interoperable behavior between service offerings and client implementations.

This chapter defines the requirements that enable DASH services and clients to provide interoperable behavior. To be compliant to a feature in this document, each service offering or client must conform to specific requirements of that feature, outline in this document.

Issue: Need to add a paragraph on interoperability on baseline, if we have any

## CMAF and ISO BMFF Requirements## {#cmaf-bmff-constraints}

Media segments SHALL be compliant to [[!MPEGDASHCMAFPROFILE]].

Note: [[!MPEGDASHCMAFPROFILE]] defines the media segment format using [[!MPEGCMAF]], which is largely based on [[!ISOBMFF]]. 
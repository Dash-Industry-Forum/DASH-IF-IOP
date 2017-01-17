# WebVTT metadata track with Images

In this proposal, a new AdapationSet specifying a WebVTT file with metadata is used.
One can then use one or more representation corresponding to thumbnails with different resolutions.


    <AdaptationSet id="3" mimeType="text/vtt" contentType="metadata">
      <Role schemeIdUri="urn:mpeg:dash:role:2011" value="thumbnail"/>      <Representation id="thumbs_qvga" bandwidth="10000">         <BaseURL>thumbs_qvga.vtt</BaseURL>      </Representation>    </AdaptationSet>Here only one side-loaded WebVTT file is specified as can be done to provide WebVTT subtitles for a whole VoD asset. A minimalistic approach to such a WebVTT file could be:
    WEBVTT
    00:00:00.000 --> 00:00:03.999
	{
		"image": "thumb1.jpg"
	}
	
    00:00:04.000 --> 00:00:07.999
	{
		"image": "thumb2.jpg"
	}

The timing mechanism is then the same as is used in HTML 5 track element which means that some browser player engines may automatically trigger the right callback with the structured data as the scrub bar is moved (or at least as the media is played). 

## Explanation
* A new contentType `metadata`is introduced to describe this content* A new Role `thumbnail`is introduced to specify the content* Individual (relative) URLs are used for each image## Pros and Cons
### Pros
* Less changes to the DASH manifest
* Established timing mechanism for HTML metadata
### Cons
* Less well-defined since no structure to fall back on
* No tile support
* Not obvious how to specify resolution of thumbnails
* Requires new contentType and or Role
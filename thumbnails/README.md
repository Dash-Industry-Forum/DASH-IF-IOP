# Thumbnails for scrollbars

DASH has `trickplay tracks` for providing video with lower framerate that can be used for fast forwarding. However, when navigating with a scrollbar, it is very useful to see thumbnails over the scrollbasr to choose a new play point. This can be implemented using trickplay tracks, but requires a video decoder to render the images, and is therefore relatively difficult to implement in a browser.

For dash.js, and other browser players, it would therefore be nice to have another mechanism for retrieving thumbnail images, for example, a new image very 10sec, or at each segment start.

This need was raised in [Issue 119 of DASH-IF-IOP](https://github.com/Dash-Industry-Forum/DASH-IF-IOP/issues/119)

In particular, there were proposals for how to extend the DASH manifest with additional tracks for the thumbnails.

This was further discussed at the dash.js face-2-face meeting in San Francisco in Dec. 2017, where a [presentation](dashjs_thumbnails.pdf) including a proposal was made. That follows the ideas in the DASH-IF-IOP issue, and extends the DASH manifest to a new `image`contentType.
Such an example is given in the [dash_image_adaptation_set.md](dash_image_adaptation_set.md) file.

There were some discussions on small changes to this approach, but also a completely different approch using a `<track>` element with WebVTT time intervals with json data for each thumbnail.
The latter would not use the DASH for timing. An example of this approach is given in the [dash_webvtt_image_track.md](dash_webvtt_image_track.md) file.

We need to get to an agreement of which approach to pursue.


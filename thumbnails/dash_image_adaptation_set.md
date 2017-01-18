# New AdaptationSet for Images

In this proposal, a new AdapationSet using SegmentTemplate with $Number$ is used.
One can then use one or more representation corresponding to thumbnails with different resolutions.


    <AdaptationSet id="3" mimeType="image/jpeg" contentType="image">      <SegmentTemplate media="$RepresentationID$/tile$Number$.jpg” duration="125" startNumber="1"/>      <Representation bandwidth="30000" id="thumbnails" width="6400" height="180">        <EssentialProperty schemeIdUri=“dashif.org/thumbnail_tile” value="25x1"/>      </Representation>    </AdaptationSet>The thumbnails can also be combined into `tiles`. This is a technique commonly used since it reduces the number of HTTP GET requests which are needed. In this particular example, a tile consisting of 25 images in one row is used. For live, one could instead use 1x1 tiles corresponding to individual images.
## Explanation
* Duration tells duration of tile
* bandwidth is average_tile_size_in_bits/duration. In the example about, the average_tile_size_in_bytes would be 458kB (458*1024B/8/125s = 30015kbps) * width and height are resolution of the tile (max jpeg resolution is 64k x 64k)* Value of EssentialProperty is the number of thumbnails (horizontal x vertical)* Duration of each thumbnail is tile_duration/nr_of_thumbnails* Size of thumbnail is derived from tile resolution* Last tile may have thumbnails outside time interval (add black thumbnails or possibly make smaller tile)* Only equidistant (in time) thumbnails* Multiple resolutions (representations) can be used (see BBC’s example)
## Pros and Cons
### Pros
* Relatively simple to implement
* Can reuse MPD parsing
* Works for live
* Supports multiple resolutions

### Cons
* Only equidistant thumbnails
* Violates DASH principles of timeline inside the media samples
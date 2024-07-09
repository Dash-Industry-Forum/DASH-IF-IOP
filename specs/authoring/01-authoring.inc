# Authoring Documentation

This is intended to be used as an example of how to write a document.

## Figures and Images

Bikeshed does currently not support markdown to integrate images directly. Use
HTML for this purpose instead. This also brings the additional benefit that you
get Figure numbers and can set captions. This

```html
<figure>
  <img src="Images/Math.png" >
  <figcaption>Example for Live Content preparation.</figcaption>
</figure>
```

results in the following image.

<figure>
  <img src="Images/Math.png" >
  <figcaption>Example for Live Content preparation.</figcaption>
</figure>

## Math with MatchJax

[MathJax](https://www.mathjax.org/) is integrated and you can use it to render


When \(a \ne 0\) there are two solutions to \(ax^2 + bx + c = 0\) $a \ne 0$
and they are

$$x = {-b \pm \sqrt{b^2-4ac} \over 2a}$$

## References

Normative [[!DASH]].


# Similarity measure in the space of color palettes

* 2018-09-25
* Speaker: Emil Hvitfeldt

## Abstract
Related to my project of creating a catalog of all available color palettes in r https://github.com/EmilHvitfeldt/ r-color-palettes and its associated r package https://CRAN.R-project.org/package=paletteer I wanted to expand the project to support a higher degree of explorability. There is already quite a bit theory of color similarity and image similarity that will provide useful but unfortunately insufficient. For standard color similarity using some kind of space measure in a perceptual color space will likely give you what you need, but this approach will start to struggle when you need to compare groups of colors since ordering starts making a difference. Image similarity can likewise be done by comparing color histograms, this approach does still not capture the number of colors or other qualities such as classifying according to type (Sequential, Diverging or Qualitative). My goal is to use expert knowledge to calculate features that can be used to calculates similarities

`tesseractgt`: Generate Ground Truth Data for Tesseract
================

In an early stage (v0.0.4). Check out the [blog post with a fully developed example](https://arcruz0.github.io/posts/finetuning-tess/index.html) and the [package documentation](https://arcruz0.github.io/tesseractgt/index.html).

![tesseractgt](https://user-images.githubusercontent.com/28851411/211395669-eee044c2-7da1-4651-828e-5d6863f10133.gif)

## Step-by-step summary

(Go to the [blog post](https://arcruz0.github.io/posts/finetuning-tess/index.html) for more detailed explanations of each step.)

0. Install the [Tesseract engine](https://tesseract-ocr.github.io/), [`tesseract`](https://docs.ropensci.org/tesseract/), and `tesseractgt`.

1. Take screenshots to serve as fine-tuning images, and save them in a folder.

2. Use `tesseractgt::create_gt_txt()` to create and pre-fill files with the text in the images.

3. Call the GUI from "Addins > Correct ground truth files" in RStudio or `tesseractgt::correct_gt_txt()`. Use it to correct the text files created in step 2.

4. Fine-tune using [`tesstrain`](https://github.com/tesseract-ocr/tesstrain).

## Installation

``` r
install.packages("remotes") # if `remotes` is not installed
remotes::install_github("arcruz0/tesseractgt")
```

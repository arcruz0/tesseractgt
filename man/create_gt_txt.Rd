% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_gt_txt.R
\name{create_gt_txt}
\alias{create_gt_txt}
\title{Create "ground truth" .gt.txt files in a folder of images}
\usage{
create_gt_txt(folder, extension, engine = NULL)
}
\arguments{
\item{folder}{A path to a folder with images.}

\item{extension}{A file extension, e.g., "png". Also accepts regex, e.g., "png|tif".}

\item{engine}{A Tesseract engine, made with `tesseract::tesseract()`.}
}
\value{
Nothing. But .gt.txt "ground truth" files are created in the specified folder.
}
\description{
Create "ground truth" .gt.txt files in a folder of images
}

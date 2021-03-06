% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aoi.R
\name{GetFramesWithGazeInAOI}
\alias{GetFramesWithGazeInAOI}
\title{Get frames with gazedata within an Area of interest}
\usage{
GetFramesWithGazeInAOI(trial, img_AOI)
}
\arguments{
\item{trial}{a Trial with \code{XMean} and \code{YMean} columns.}

\item{img_AOI}{the coordinates of a rectangular Area of Interest given in
screen proportions.}
}
\value{
a vector of boolean values indicating whether the gaze values fall
  into the AOI at each time point in the trial.
}
\description{
Get frames with gazedata within an Area of interest
}
\keyword{internal}

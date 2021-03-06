% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/missing.R
\name{CalculateBias}
\alias{CalculateBias}
\title{Calculate image bias within a window of time}
\usage{
CalculateBias(x, window)
}
\arguments{
\item{x}{a Trial with a \code{GazeByImageAOI} column or a TrialList where
each Trial has a \code{GazeByImageAOI} column}

\item{window}{a twq-element vector specifying the window of time within which
to calculate the image bias.}
}
\value{
the Trial object(s) updated to include two new attributes:
  \code{Bias}, the name of the AOI with the highest bias or \code{NA} if
  there are no looks to the AOIs during the time window; and
  \code{BiasSummary}, a data-frame detailing the bias calculation.
}
\description{
Bias answers the question, "Which image was this subject viewing during a
certain window of time?" For this calculation, we count the number of frames
spent on each AOI and multiply the frame-counts by the duration of the
window. Over a 100ms (6 frame) window, 3 frames on one AOI would receive a
weight of 300. Ties are broken by choosing the image with the earliest
fixation. In that same 6 frame window, if 3 frames are spent each on 2 AOIs,
the weights would be tied, so the AOI that was fixated on first would be
chosen.
}

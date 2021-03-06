% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/melting.R
\name{AssignBins}
\alias{AssignBins}
\title{Assign bin numbers to a vector}
\usage{
AssignBins(xs, bin_width = 3, na_location = "tail", partial = FALSE)
}
\arguments{
\item{xs}{a vector}

\item{bin_width}{the number of items to put in each bin. Default is 3.}

\item{na_location}{Where to assign \code{NA} bin numbers. \code{"head"} and
\code{"tail"} respectively put the NA elements at the head and tail of the
vector; \code{"split"} alternates between \code{"tail"} and \code{"head"}.}

\item{partial}{whether to exclude values that don't fit evenly into bins.
Defaults to FALSE, so that the user is warned if a bin is incomplete.}
}
\value{
a vector of bin-numbers. If \code{bin_width} does not evenly divide
  \code{xs}, the remainder elements are given a bin number of \code{NA}.
}
\description{
The first step in binning/down-sampling some data is assigning items to bins.
This function takes a vector and a bin size and returns the bin assignments.
}
\examples{
AssignBins(1:14, bin_width = 3, "head")
# [1] NA NA  1  1  1  2  2  2  3  3  3  4  4  4
AssignBins(1:14, bin_width = 3, "tail")
# [1]  1  1  1  2  2  2  3  3  3  4  4  4 NA NA
AssignBins(1:7, bin_width = 5, "split")
# [1] NA  1  1  1  1  1 NA
AssignBins(1:8, bin_width = 5, "split")
# [1] NA  1  1  1  1  1 NA NA
}

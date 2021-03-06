% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aoi.R
\name{AOI}
\alias{AOI}
\title{Convert pixel locations of an image to proportion-on-screen location}
\usage{
AOI(x_pix, y_pix, width = lwl_constants$screen_width,
  height = lwl_constants$screen_height)
}
\arguments{
\item{x_pix}{location (in pixels) of the left and right edges of the AOI}

\item{y_pix}{location (in pixels) of the upper and lower edges of the AOI}

\item{width}{width of the screen (in pixels)}

\item{height}{height of the screen (in pixels)}
}
\value{
A list of the form \code{list(x = (left_prop, right_prop), y =
  (lower_prop, upper_prop))}, where \code{prop} values describe the locations
  of the boundaries in terms of screen proportion.
}
\description{
AOI is a utility function for converting the pixel locations of the x- and
y-boundaries of an image to screen proportions. Note that the coordinate
(0,0) is the lower-left corner of the screen.
}
\keyword{internal}

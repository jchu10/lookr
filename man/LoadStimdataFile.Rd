% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stimdata.R
\name{LoadStimdataFile}
\alias{LoadStimdataFile}
\title{Open a stimulus log file outputted by Eprime}
\usage{
LoadStimdataFile(stimdata_path)
}
\arguments{
\item{stimdata_path}{Either the full or relative path to the \code{.txt} file
that is to be parsed.}
}
\value{
the raw contents of the stimdata file. The basename of
  \code{stimdata_path} is attached as an attribute called \code{"Basename"}.
}
\description{
Open a stimulus log file outputted by Eprime
}
\details{
Historically, we have had issues with the encoding of these .txt
files, so now we include some exception-handling measures. The procedure is
to first try to load the file with UCS-2 Little Endian encoding. If a warning
is encountered, the warning is muffled and the file is loaded again, this
time without specifying the encoding beforehand. If a warning is encountered
on this second attempt, it is printed to the console.
}

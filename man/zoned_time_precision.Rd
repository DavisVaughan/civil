% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zoned-time.R
\name{zoned_time_precision}
\alias{zoned_time_precision}
\title{Precision: zoned-time}
\usage{
zoned_time_precision(x)
}
\arguments{
\item{x}{\verb{[clock_zoned_time]}

A zoned-time.}
}
\value{
A single string holding the precision of the zoned-time.
}
\description{
\code{zoned_time_precision()} extracts the precision from a zoned-time. It
returns the precision as a single string.
}
\examples{
zoned_time_precision(zoned_time_now("America/New_York"))
}

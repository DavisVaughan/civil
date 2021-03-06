% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/naive-time.R
\name{is_naive_time}
\alias{is_naive_time}
\title{Is \code{x} a naive-time?}
\usage{
is_naive_time(x)
}
\arguments{
\item{x}{\verb{[object]}

An object.}
}
\value{
\code{TRUE} if \code{x} inherits from \code{"clock_naive_time"}, otherwise \code{FALSE}.
}
\description{
This function determines if the input is a naive-time object.
}
\examples{
is_naive_time(1)
is_naive_time(as_naive_time(duration_days(1)))
}

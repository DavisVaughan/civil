% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/date.R
\name{date-zone}
\alias{date-zone}
\alias{date_zone}
\alias{date_set_zone}
\title{Get or set the time zone}
\usage{
date_zone(x)

date_set_zone(x, zone)
}
\arguments{
\item{x}{\verb{[Date / POSIXct / POSIXlt]}

A date or date-time vector.}

\item{zone}{\verb{[character(1)]}

A valid time zone to switch to.}
}
\value{
\itemize{
\item \code{date_zone()} returns a string containing the time zone.
\item \code{date_set_zone()} returns \code{x} with an altered printed time. The
underlying duration is not changed.
}
}
\description{
\itemize{
\item \code{date_zone()} gets the time zone.
\item \code{date_set_zone()} sets the time zone. This retains the \emph{underlying
duration}, but changes the \emph{printed time} depending on the zone that is
chosen.
}

Note that attempting to call \code{date_set_zone()} on a Date is an error, as R
assumes that Date objects are always UTC.
}
\examples{
library(magrittr)

x <- as.Date("2019-01-01")

# Dates are always UTC
date_zone(x)

# You can't change this!
try(date_set_zone(x, "America/New_York"))

x <- as.POSIXct("2019-01-02 01:30:00", tz = "America/New_York")
x

# If it is 1:30am in New York, what time is it in Los Angeles?
# Same underlying duration, new printed time
date_set_zone(x, "America/Los_Angeles")

# If you want to retain the printed time, but change the underlying duration,
# convert to a naive-time to drop the time zone, then convert back to a
# date-time. Be aware that this requires that you handle daylight saving time
# irregularities with the `nonexistent` and `ambiguous` arguments to
# `as.POSIXct()`!
x \%>\%
  as_naive_time() \%>\%
  as.POSIXct("America/Los_Angeles")

y <- as.POSIXct("2021-03-28 03:30:00", "America/New_York")
y

y_nt <- as_naive_time(y)
y_nt

# Helsinki had a daylight saving time gap where they jumped from
# 02:59:59 -> 04:00:00
try(as.POSIXct(y_nt, "Europe/Helsinki"))

as.POSIXct(y_nt, "Europe/Helsinki", nonexistent = "roll-forward")
as.POSIXct(y_nt, "Europe/Helsinki", nonexistent = "roll-backward")
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/date.R
\name{date-rounding}
\alias{date-rounding}
\alias{date_floor.Date}
\alias{date_ceiling.Date}
\alias{date_round.Date}
\title{Rounding: date}
\usage{
\method{date_floor}{Date}(x, precision, ..., n = 1L, origin = NULL)

\method{date_ceiling}{Date}(x, precision, ..., n = 1L, origin = NULL)

\method{date_round}{Date}(x, precision, ..., n = 1L, origin = NULL)
}
\arguments{
\item{x}{\verb{[Date]}

A date vector.}

\item{precision}{\verb{[character(1)]}

One of:
\itemize{
\item \code{"week"}
\item \code{"day"}
}

\code{"week"} is an alias for \code{"day"} with \code{n * 7}.}

\item{...}{These dots are for future extensions and must be empty.}

\item{n}{\verb{[positive integer(1)]}

A single positive integer specifying a multiple of \code{precision} to use.}

\item{origin}{\verb{[Date(1) / NULL]}

An origin to start counting from. The default \code{origin} is
1970-01-01.}
}
\value{
\code{x} rounded to the specified \code{precision}.
}
\description{
These are Date methods for the
\link[=date-and-date-time-rounding]{rounding generics}.
\itemize{
\item \code{date_floor()} rounds a date down to a multiple of
the specified \code{precision}.
\item \code{date_ceiling()} rounds a date up to a multiple of
the specified \code{precision}.
\item \code{date_round()} rounds up or down depending on what is closer,
rounding up on ties.
}

The only supported rounding \code{precision}s for Dates are \code{"day"} and \code{"week"}.
You can group by irregular periods such as \code{"month"} or \code{"year"} by using
\code{\link[=date_group]{date_group()}}.
}
\details{
When rounding by \code{"week"}, remember that the \code{origin} determines the "week
start". By default, 1970-01-01 is the implicit origin, which is a
Thursday. If you would like to round by weeks with a different week start,
just supply an origin on the weekday you are interested in.
}
\examples{
x <- as.Date("2019-03-31") + 0:5
x

# Flooring by 2 days, note that this is not tied to the current month,
# and instead counts from the specified `origin`, so groups can cross
# the month boundary
date_floor(x, "day", n = 2)

# Compare to `date_group()`, which groups by the day of the month
date_group(x, "day", n = 2)

y <- as.Date("2019-01-01") + 0:20
y

# Flooring by week uses an implicit `origin` of 1970-01-01, which
# is a Thursday
date_floor(y, "week")
as_weekday(date_floor(y, "week"))

# If you want to round by weeks with a different week start, supply an
# `origin` that falls on the weekday you care about. This uses a Monday.
origin <- as.Date("1970-01-05")
as_weekday(origin)

date_floor(y, "week", origin = origin)
as_weekday(date_floor(y, "week", origin = origin))
}

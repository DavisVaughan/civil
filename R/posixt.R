#' @export
as_sys_time.POSIXt <- function(x) {
  # The sys-time that would give the equivalent zoned-time when a tz is attached
  as_sys_time(as_zoned_time(x))
}

#' @export
as_naive_time.POSIXt <- function(x) {
  as_naive_time(as_zoned_time(x))
}

#' Convert to a zoned-time from a date-time
#'
#' @description
#' This is a POSIXct/POSIXlt method for the [as_zoned_time()] generic.
#'
#' Converting from one of R's native date-time classes (POSIXct or POSIXlt)
#' will retain the time zone of that object. There is no `zone` argument.
#'
#' @inheritParams ellipsis::dots_empty
#'
#' @param x `[POSIXct / POSIXlt]`
#'
#'   A date-time.
#'
#' @return A zoned-time.
#'
#' @name as-zoned-time-posixt
#' @export
#' @examples
#' x <- as.POSIXct("2019-01-01", tz = "America/New_York")
#' as_zoned_time(x)
as_zoned_time.POSIXt <- function(x, ...) {
  check_dots_empty()

  x <- to_posixct(x)

  names <- names(x)
  zone <- posixt_tzone(x)

  fields <- to_sys_duration_fields_from_sys_seconds_cpp(x)

  new_zoned_time_from_fields(fields, PRECISION_SECOND, zone, names)
}

#' @export
as_year_month_day.POSIXt <- function(x) {
  # Assumes zoned -> naive -> calendar is what the user expects
  x <- as_naive_time(x)
  as_year_month_day(x)
}

#' @export
as_year_month_weekday.POSIXt <- function(x) {
  # Assumes zoned -> naive -> calendar is what the user expects
  x <- as_naive_time(x)
  as_year_month_weekday(x)
}

#' @export
as_year_quarter_day.POSIXt <- function(x, ..., start = NULL) {
  # Assumes zoned -> naive -> calendar is what the user expects
  x <- as_naive_time(x)
  as_year_quarter_day(x, ..., start = start)
}

#' @export
as_iso_year_week_day.POSIXt <- function(x) {
  # Assumes zoned -> naive -> calendar is what the user expects
  x <- as_naive_time(x)
  as_iso_year_week_day(x)
}

#' @export
as_year_day.POSIXt <- function(x) {
  # Assumes zoned -> naive -> calendar is what the user expects
  x <- as_naive_time(x)
  as_year_day(x)
}

#' @export
as_weekday.POSIXt <- function(x) {
  # Assumes zoned -> naive is what the user expects
  x <- as_naive_time(x)
  as_weekday(x)
}

# ------------------------------------------------------------------------------

# Not using `check_dots_empty()` because that might
# be too aggressive with base generics. Also not passing `...` on to methods
# that do check empty dots.

# Using `tz = ""` to be compatible with the generic of `as.POSIXct()`

#' @export
as.POSIXct.clock_calendar <- function(x,
                                      tz = "",
                                      ...,
                                      nonexistent = NULL,
                                      ambiguous = NULL) {
  x <- as_naive_time(x)
  as.POSIXct(x, tz = tz, nonexistent = nonexistent, ambiguous = ambiguous)
}

#' @export
as.POSIXct.clock_sys_time <- function(x, tz = "", ...) {
  zone <- zone_validate(tz)
  x <- time_point_cast(x, "second")
  seconds <- to_sys_seconds_from_sys_duration_fields_cpp(x)
  names(seconds) <- clock_rcrd_names(x)
  new_datetime(seconds, zone)
}

#' @export
as.POSIXct.clock_naive_time <- function(x,
                                        tz = "",
                                        ...,
                                        nonexistent = NULL,
                                        ambiguous = NULL) {
  x <- as_zoned_time(x, zone = tz, nonexistent = nonexistent, ambiguous = ambiguous)
  as.POSIXct(x)
}

#' @export
as.POSIXct.clock_zoned_time <- function(x, ...) {
  zone <- zoned_time_zone_attribute(x)
  x <- as_sys_time(x)
  as.POSIXct(x, tz = zone)
}

# ------------------------------------------------------------------------------

#' @export
as.POSIXlt.clock_calendar <- function(x,
                                      tz = "",
                                      ...,
                                      nonexistent = NULL,
                                      ambiguous = NULL) {
  x <- as.POSIXct(x, tz = tz, ..., nonexistent = nonexistent, ambiguous = ambiguous)
  as.POSIXlt(x)
}

#' @export
as.POSIXlt.clock_sys_time <- function(x, tz = "", ...) {
  x <- as.POSIXct(x, tz = tz, ...)
  as.POSIXlt(x)
}

#' @export
as.POSIXlt.clock_naive_time <- as.POSIXlt.clock_calendar

#' @export
as.POSIXlt.clock_zoned_time <- function(x, ...) {
  x <- as.POSIXct(x, ...)
  as.POSIXlt(x)
}

# ------------------------------------------------------------------------------

#' Getters: date-time
#'
#' @description
#' These are POSIXct/POSIXlt methods for the [getter generics][clock-getters].
#'
#' - `get_year()` returns the Gregorian year.
#'
#' - `get_month()` returns the month of the year.
#'
#' - `get_day()` returns the day of the month.
#'
#' - There are sub-daily getters for extracting more precise components, up to
#'   a precision of seconds.
#'
#' For more advanced component extraction, convert to the calendar type
#' that you are interested in.
#'
#' @param x `[POSIXct / POSIXlt]`
#'
#'   A date-time type to get the component from.
#'
#' @return The component.
#'
#' @name posixt-getters
#' @examples
#' x <- as.POSIXct("2019-01-01", tz = "America/New_York")
#'
#' x <- add_days(x, 0:5)
#' x <- set_second(x, 10:15)
#'
#' get_day(x)
#' get_second(x)
NULL

#' @rdname posixt-getters
#' @export
get_year.POSIXt <- function(x) {
  get_posixt_field_year_month_day(x, get_year)
}
#' @rdname posixt-getters
#' @export
get_month.POSIXt <- function(x) {
  get_posixt_field_year_month_day(x, get_month)
}
#' @rdname posixt-getters
#' @export
get_day.POSIXt <- function(x) {
  get_posixt_field_year_month_day(x, get_day)
}
#' @rdname posixt-getters
#' @export
get_hour.POSIXt <- function(x) {
  get_posixt_field_year_month_day(x, get_hour)
}
#' @rdname posixt-getters
#' @export
get_minute.POSIXt <- function(x) {
  get_posixt_field_year_month_day(x, get_minute)
}
#' @rdname posixt-getters
#' @export
get_second.POSIXt <- function(x) {
  get_posixt_field_year_month_day(x, get_second)
}
get_posixt_field_year_month_day <- function(x, get_fn) {
  x <- as_year_month_day(x)
  get_fn(x)
}

# ------------------------------------------------------------------------------

#' Setters: date-time
#'
#' @description
#' These are POSIXct/POSIXlt methods for the [setter generics][clock-setters].
#'
#' - `set_year()` sets the year.
#'
#' - `set_month()` sets the month of the year. Valid values are in the range
#'   of `[1, 12]`.
#'
#' - `set_day()` sets the day of the month. Valid values are in the range
#'   of `[1, 31]`.
#'
#' - There are sub-daily setters for setting more precise components, up to
#'   a precision of seconds.
#'
#' @inheritParams ellipsis::dots_empty
#' @inheritParams invalid_resolve
#' @inheritParams as-zoned-time-naive-time
#'
#' @param x `[POSIXct / POSIXlt]`
#'
#'   A date-time vector.
#'
#' @param value `[integer / "last"]`
#'
#'   The value to set the component to.
#'
#'   For `set_day()`, this can also be `"last"` to set the day to the
#'   last day of the month.
#'
#' @return `x` with the component set.
#'
#' @name posixt-setters
#' @examples
#' x <- as.POSIXct("2019-02-01", tz = "America/New_York")
#'
#' # Set the day
#' set_day(x, 12:14)
#'
#' # Set to the "last" day of the month
#' set_day(x, "last")
#'
#' # You cannot set a date-time to an invalid date like you can with
#' # a year-month-day. Instead, the default strategy is to error.
#' try(set_day(x, 31))
#' set_day(as_year_month_day(x), 31)
#'
#' # You can resolve these issues while setting the day by specifying
#' # an invalid date resolution strategy with `invalid`
#' set_day(x, 31, invalid = "previous")
#'
#' y <- as.POSIXct("2020-03-08 01:30:00", tz = "America/New_York")
#'
#' # Nonexistent and ambiguous times must be resolved immediately when
#' # working with R's native date-time types. An error is thrown by default.
#' try(set_hour(y, 2))
#' set_hour(y, 2, nonexistent = "roll-forward")
#' set_hour(y, 2, nonexistent = "roll-backward")
NULL

#' @rdname posixt-setters
#' @export
set_year.POSIXt <- function(x, value, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  set_posixt_field_year_month_day(x, value, invalid, nonexistent, ambiguous, set_year, ...)
}
#' @rdname posixt-setters
#' @export
set_month.POSIXt <- function(x, value, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  set_posixt_field_year_month_day(x, value, invalid, nonexistent, ambiguous, set_month, ...)
}
#' @rdname posixt-setters
#' @export
set_day.POSIXt <- function(x, value, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  set_posixt_field_year_month_day(x, value, invalid, nonexistent, ambiguous, set_day, ...)
}
#' @rdname posixt-setters
#' @export
set_hour.POSIXt <- function(x, value, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  set_posixt_field_year_month_day(x, value, invalid, nonexistent, ambiguous, set_hour, ...)
}
#' @rdname posixt-setters
#' @export
set_minute.POSIXt <- function(x, value, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  set_posixt_field_year_month_day(x, value, invalid, nonexistent, ambiguous, set_minute, ...)
}
#' @rdname posixt-setters
#' @export
set_second.POSIXt <- function(x, value, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  set_posixt_field_year_month_day(x, value, invalid, nonexistent, ambiguous, set_second, ...)
}
set_posixt_field_year_month_day <- function(x, value, invalid, nonexistent, ambiguous, set_fn, ...) {
  check_dots_empty()
  zone <- posixt_tzone(x)
  x <- as_year_month_day(x)
  x <- set_fn(x, value)
  x <- invalid_resolve(x, invalid = invalid)
  as.POSIXct(x, tz = zone, nonexistent = nonexistent, ambiguous = ambiguous)
}

# ------------------------------------------------------------------------------

#' @method vec_arith.POSIXct clock_duration
#' @export
vec_arith.POSIXct.clock_duration <- function(op, x, y, ...) {
  arith_posixt_and_duration(op, x, y, ...)
}

#' @method vec_arith.clock_duration POSIXct
#' @export
vec_arith.clock_duration.POSIXct <- function(op, x, y, ...) {
  arith_duration_and_posixt(op, x, y, ...)
}

#' @method vec_arith.POSIXlt clock_duration
#' @export
vec_arith.POSIXlt.clock_duration <- function(op, x, y, ...) {
  arith_posixt_and_duration(op, x, y, ...)
}

#' @method vec_arith.clock_duration POSIXlt
#' @export
vec_arith.clock_duration.POSIXlt <- function(op, x, y, ...) {
  arith_duration_and_posixt(op, x, y, ...)
}

arith_posixt_and_duration <- function(op, x, y, ...) {
  switch(
    op,
    "+" = add_duration(x, y),
    "-" = add_duration(x, -y),
    stop_incompatible_op(op, x, y, ...)
  )
}

arith_duration_and_posixt <- function(op, x, y, ...) {
  switch(
    op,
    "+" = add_duration(y, x, swapped = TRUE),
    "-" = stop_incompatible_op(op, x, y, details = "Can't subtract a POSIXct/POSIXlt from a duration.", ...),
    stop_incompatible_op(op, x, y, ...)
  )
}

# ------------------------------------------------------------------------------

#' Arithmetic: date-time
#'
#' @description
#' These are POSIXct/POSIXlt methods for the
#' [arithmetic generics][clock-arithmetic].
#'
#' Calendrical based arithmetic:
#'
#' These functions convert to a naive-time, then to a year-month-day, perform
#' the arithmetic, then convert back to a date-time.
#'
#' - `add_years()`
#'
#' - `add_quarters()`
#'
#' - `add_months()`
#'
#' Naive-time based arithmetic:
#'
#' These functions convert to a naive-time, perform the arithmetic, then
#' convert back to a date-time.
#'
#' - `add_weeks()`
#'
#' - `add_days()`
#'
#' Sys-time based arithmetic:
#'
#' These functions convert to a sys-time, perform the arithmetic, then
#' convert back to a date-time.
#'
#' - `add_hours()`
#'
#' - `add_minutes()`
#'
#' - `add_seconds()`
#'
#' @details
#' Adding a single quarter with `add_quarters()` is equivalent to adding
#' 3 months.
#'
#' `x` and `n` are recycled against each other.
#'
#' Calendrical based arithmetic has the potential to generate invalid dates
#' (like the 31st of February), nonexistent times (due to daylight saving
#' time gaps), and ambiguous times (due to daylight saving time fallbacks).
#'
#' Naive-time based arithmetic will never generate an invalid date, but
#' may generate a nonexistent or ambiguous time (i.e. you added 1 day and
#' landed in a daylight saving time gap).
#'
#' Sys-time based arithmetic operates in the UTC time zone, which means
#' that it will never generate any invalid dates or nonexistent / ambiguous
#' times.
#'
#' The conversion from POSIXct/POSIXlt to the corresponding clock type uses
#' a "best guess" about whether you want to do the arithmetic using a naive-time
#' or a sys-time. For example, when adding months, you probably want to
#' retain the printed time when converting to a year-month-day to perform
#' the arithmetic, so the conversion goes through naive-time. However,
#' when adding smaller units like seconds, you probably want
#' `"2020-03-08 01:59:59" + 1 second` in the America/New_York time zone to
#' return `"2020-03-08 03:00:00"`, taking into account the fact that there
#' was a daylight saving time gap. This requires doing the arithmetic in
#' sys-time, so that is what clock converts to. If you disagree with this
#' heuristic for any reason, you can take control and perform the conversions
#' yourself. For example, you could convert the previous example to a
#' naive-time instead of a sys-time manually with [as_naive_time()], add
#' 1 second giving `"2020-03-08 02:00:00"`, then convert back to a
#' POSIXct/POSIXlt, dealing with the nonexistent time that get's created by
#' using the `nonexistent` argument of `as.POSIXct()`.
#'
#' @inheritParams add_years
#' @inheritParams invalid_resolve
#' @inheritParams as-zoned-time-naive-time
#'
#' @param x `[POSIXct / POSIXlt]`
#'
#'   A date-time vector.
#'
#' @return `x` after performing the arithmetic.
#'
#' @name posixt-arithmetic
#'
#' @examples
#' x <- as.POSIXct("2019-01-01", tz = "America/New_York")
#'
#' add_years(x, 1:5)
#'
#' y <- as.POSIXct("2019-01-31 00:30:00", tz = "America/New_York")
#'
#' # Adding 1 month to `y` generates an invalid date. Unlike year-month-day
#' # types, R's native date-time types cannot handle invalid dates, so you must
#' # resolve them immediately. If you don't you get an error:
#' try(add_months(y, 1:2))
#' add_months(as_year_month_day(y), 1:2)
#'
#' # Resolve invalid dates by specifying an invalid date resolution strategy
#' # with the `invalid` argument. Using `"previous"` here sets the date-time to
#' # the previous valid moment in time - i.e. the end of the month. The
#' # time is set to the last moment in the day to retain the relative ordering
#' # within your input. If you are okay with potentially losing this, and
#' # want to retain your time of day, you can use `"previous-day"` to set the
#' # date-time to the previous valid day, while keeping the time of day.
#' add_months(y, 1:2, invalid = "previous")
#' add_months(y, 1:2, invalid = "previous-day")
NULL

#' @rdname posixt-arithmetic
#' @export
add_years.POSIXt <- function(x, n, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  add_posixt_duration_year_month_day(x, n, invalid, nonexistent, ambiguous, add_years, ...)
}
#' @rdname posixt-arithmetic
#' @export
add_quarters.POSIXt <- function(x, n, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  add_posixt_duration_year_month_day(x, n, invalid, nonexistent, ambiguous, add_quarters, ...)
}
#' @rdname posixt-arithmetic
#' @export
add_months.POSIXt <- function(x, n, ..., invalid = NULL, nonexistent = NULL, ambiguous = x) {
  add_posixt_duration_year_month_day(x, n, invalid, nonexistent, ambiguous, add_months, ...)
}
add_posixt_duration_year_month_day <- function(x, n, invalid, nonexistent, ambiguous, add_fn, ...) {
  check_dots_empty()
  zone <- posixt_tzone(x)
  x <- as_year_month_day(x)
  x <- add_fn(x, n)
  x <- invalid_resolve(x, invalid = invalid)
  as.POSIXct(x, tz = zone, nonexistent = nonexistent, ambiguous = ambiguous)
}

#' @rdname posixt-arithmetic
#' @export
add_weeks.POSIXt <- function(x, n, ..., nonexistent = NULL, ambiguous = x) {
  add_posixt_duration_naive_time_point(x, n, nonexistent, ambiguous, add_weeks, ...)
}
#' @rdname posixt-arithmetic
#' @export
add_days.POSIXt <- function(x, n, ..., nonexistent = NULL, ambiguous = x) {
  add_posixt_duration_naive_time_point(x, n, nonexistent, ambiguous, add_days, ...)
}
add_posixt_duration_naive_time_point <- function(x, n, nonexistent, ambiguous, add_fn, ...) {
  check_dots_empty()
  zone <- posixt_tzone(x)
  x <- as_naive_time(x)
  x <- add_fn(x, n)
  as.POSIXct(x, tz = zone, nonexistent = nonexistent, ambiguous = ambiguous)
}

#' @rdname posixt-arithmetic
#' @export
add_hours.POSIXt <- function(x, n, ...) {
  add_posixt_duration_sys_time_point(x, n, add_hours, ...)
}
#' @rdname posixt-arithmetic
#' @export
add_minutes.POSIXt <- function(x, n, ...) {
  add_posixt_duration_sys_time_point(x, n, add_minutes, ...)
}
#' @rdname posixt-arithmetic
#' @export
add_seconds.POSIXt <- function(x, n, ...) {
  add_posixt_duration_sys_time_point(x, n, add_seconds, ...)
}
add_posixt_duration_sys_time_point <- function(x, n, add_fn, ...) {
  check_dots_empty()
  zone <- posixt_tzone(x)
  x <- as_sys_time(x)
  x <- add_fn(x, n)
  as.POSIXct(x, tz = zone)
}

# ------------------------------------------------------------------------------

#' Group date-time components
#'
#' @description
#' This is a POSIXct/POSIXlt method for the [date_group()] generic.
#'
#' `date_group()` groups by a single component of a date-time, such as month
#' of the year, day of the month, or hour of the day.
#'
#' If you need to group by more complex components, like ISO weeks, or quarters,
#' convert to a calendar type that contains the component you are interested
#' in grouping by.
#'
#' @inheritParams date_group
#' @inheritParams invalid_resolve
#' @inheritParams as-zoned-time-naive-time
#'
#' @param x `[POSIXct / POSIXlt]`
#'
#'   A date-time vector.
#'
#' @param precision `[character(1)]`
#'
#'   One of:
#'
#'   - `"year"`
#'
#'   - `"month"`
#'
#'   - `"day"`
#'
#'   - `"hour"`
#'
#'   - `"minute"`
#'
#'   - `"second"`
#'
#' @return `x`, grouped at `precision`.
#'
#' @name posixt-group
#'
#' @export
#' @examples
#' x <- as.POSIXct("2019-01-01", "America/New_York")
#' x <- add_days(x, -3:5)
#'
#' # Group by 2 days of the current month.
#' # Note that this resets at the beginning of the month, creating day groups
#' # of [29, 30] [31] [01, 02] [03, 04].
#' date_group(x, "day", n = 2)
#'
#' # Group by month
#' date_group(x, "month")
#'
#' # Group by hour of the day
#' y <- as.POSIXct("2019-12-30", "America/New_York")
#' y <- add_hours(y, 0:12)
#' y
#'
#' date_group(y, "hour", n = 3)
date_group.POSIXt <- function(x,
                              precision,
                              ...,
                              n = 1L,
                              invalid = NULL,
                              nonexistent = NULL,
                              ambiguous = x) {
  force(ambiguous)
  zone <- date_zone(x)
  x <- as_year_month_day(x)
  x <- calendar_group(x, precision, ..., n = n)
  x <- calendar_widen(x, "second")
  as.POSIXct(x, zone, invalid = invalid, nonexistent = nonexistent, ambiguous = ambiguous)
}

# ------------------------------------------------------------------------------

#' @export
date_leap_year.POSIXt <- function(x) {
  x <- as_year_month_day(x)
  calendar_leap_year(x)
}

# ------------------------------------------------------------------------------

#' Rounding: date-time
#'
#' @description
#' These are POSIXct/POSIXlt methods for the
#' [rounding generics][date-and-date-time-rounding].
#'
#' - `date_floor()` rounds a date-time down to a multiple of
#'   the specified `precision`.
#'
#' - `date_ceiling()` rounds a date-time up to a multiple of
#'   the specified `precision`.
#'
#' - `date_round()` rounds up or down depending on what is closer,
#'   rounding up on ties.
#'
#' You can group by irregular periods such as `"month"` or `"year"` by using
#' [date_group()].
#'
#' @details
#' When rounding by `"week"`, remember that the `origin` determines the "week
#' start". By default, 1970-01-01 is the implicit origin, which is a
#' Thursday. If you would like to round by weeks with a different week start,
#' just supply an origin on the weekday you are interested in.
#'
#' @inheritParams date_floor
#' @inheritParams as-zoned-time-naive-time
#'
#' @param x `[POSIXct / POSIXlt]`
#'
#'   A date-time vector.
#'
#' @param precision `[character(1)]`
#'
#'   One of:
#'
#'   - `"week"`
#'
#'   - `"day"`
#'
#'   - `"hour"`
#'
#'   - `"minute"`
#'
#'   - `"second"`
#'
#'   `"week"` is an alias for `"day"` with `n * 7`.
#'
#' @param origin `[POSIXct(1) / POSIXlt(1) / NULL]`
#'
#'   An origin to start counting from.
#'
#'   `origin` must have exactly the same time zone as `x`.
#'
#'   `origin` will be floored to `precision`. If information is lost when
#'   flooring, a warning will be thrown.
#'
#'   If `NULL`, defaults to midnight on 1970-01-01 in the time zone of `x`.
#'
#' @return `x` rounded to the specified `precision`.
#'
#' @name posixt-rounding
#'
#' @examples
#' x <- as.POSIXct("2019-03-31", "America/New_York")
#' x <- add_days(x, 0:5)
#'
#' # Flooring by 2 days, note that this is not tied to the current month,
#' # and instead counts from the specified `origin`, so groups can cross
#' # the month boundary
#' date_floor(x, "day", n = 2)
#'
#' # Compare to `date_group()`, which groups by the day of the month
#' date_group(x, "day", n = 2)
#'
#' # Note that daylight saving time gaps can throw off rounding
#' x <- as.POSIXct("1970-04-26 01:59:59", "America/New_York") + c(0, 1)
#' x
#'
#' # Rounding is done in naive-time, which means that rounding by 2 hours
#' # will attempt to generate a time of 1970-04-26 02:00:00, which doesn't
#' # exist in this time zone
#' try(date_floor(x, "hour", n = 2))
#'
#' # You can handle this by specifying a nonexistent time resolution strategy
#' date_floor(x, "hour", n = 2, nonexistent = "roll-forward")
NULL

#' @rdname posixt-rounding
#' @export
date_floor.POSIXt <- function(x,
                              precision,
                              ...,
                              n = 1L,
                              origin = NULL,
                              nonexistent = NULL,
                              ambiguous = x) {
  date_time_rounder(x, precision, n, origin, nonexistent, ambiguous, time_point_floor, ...)
}

#' @rdname posixt-rounding
#' @export
date_ceiling.POSIXt <- function(x,
                                precision,
                                ...,
                                n = 1L,
                                origin = NULL,
                                nonexistent = NULL,
                                ambiguous = x) {
  date_time_rounder(x, precision, n, origin, nonexistent, ambiguous, time_point_ceiling, ...)
}

#' @rdname posixt-rounding
#' @export
date_round.POSIXt <- function(x,
                              precision,
                              ...,
                              n = 1L,
                              origin = NULL,
                              nonexistent = NULL,
                              ambiguous = x) {
  date_time_rounder(x, precision, n, origin, nonexistent, ambiguous, time_point_round, ...)
}

date_time_rounder <- function(x,
                              precision,
                              n,
                              origin,
                              nonexistent,
                              ambiguous,
                              time_point_rounder,
                              ...) {
  result <- tweak_date_rounder_precision(precision, n)
  precision <- result$precision
  n <- result$n

  zone <- date_zone(x)

  x <- as_naive_time(x)

  if (!is_null(origin)) {
    origin <- collect_date_time_rounder_origin(origin, zone, precision)
  }

  x <- time_point_rounder(x, precision, ..., n = n, origin = origin)

  as.POSIXct(x, zone, nonexistent = nonexistent, ambiguous = ambiguous)
}

collect_date_time_rounder_origin <- function(origin, zone, precision) {
  if (!inherits(origin, "POSIXt")) {
    abort("`origin` must be a 'POSIXt'.")
  }

  origin <- to_posixct(origin)

  if (length(origin) != 1L) {
    abort("`origin` must have length 1.")
  }
  if (!is.finite(origin)) {
    abort("`origin` must not be `NA` or an infinite date.")
  }

  if (!identical(date_zone(origin), zone)) {
    abort("`origin` must have the same time zone as `x`.")
  }

  origin <- as_naive_time(origin)

  # Floor to match the precision of `precision`
  origin_old <- origin
  origin <- time_point_floor(origin, precision)

  # If we lost information while flooring, let the user know
  if (origin_old != time_point_cast(origin, "second")) {
    warn_clock_invalid_rounding_origin(precision)
  }

  origin
}

warn_clock_invalid_rounding_origin <- function(precision) {
  message <- paste0(
    "`origin` has been floored from 'second' precision to '", precision, "' ",
    "precision to match `precision`. This floor has lost information."
  )

  rlang::warn(message, class = "clock_warning_invalid_rounding_origin")
}

# ------------------------------------------------------------------------------

#' @export
date_weekday_factor.POSIXt <- function(x,
                                       ...,
                                       labels = "en",
                                       abbreviate = TRUE,
                                       encoding = "western") {
  x <- as_weekday(x)
  weekday_factor(x, ..., labels = labels, abbreviate = abbreviate, encoding = encoding)
}

# ------------------------------------------------------------------------------

#' @export
date_month_factor.POSIXt <- function(x,
                                     ...,
                                     labels = "en",
                                     abbreviate = FALSE) {
  x <- as_year_month_day(x)
  calendar_month_factor(x, ..., labels = labels, abbreviate = abbreviate)
}

# ------------------------------------------------------------------------------

#' @export
date_format.POSIXt <- function(x,
                               ...,
                               format = NULL,
                               locale = clock_locale(),
                               abbreviate_zone = FALSE) {
  check_dots_empty()
  x <- as_zoned_time(x)
  format(x, format = format, locale = locale, abbreviate_zone = abbreviate_zone)
}

# ------------------------------------------------------------------------------

#' @export
date_zone.POSIXt <- function(x) {
  posixt_tzone(x)
}

#' @export
date_set_zone.POSIXt <- function(x, zone) {
  x <- to_posixct(x)
  zone <- zone_validate(zone)
  posixt_set_tzone(x, zone)
}

# ------------------------------------------------------------------------------

#' Parsing: date-time
#'
#' @description
#' There are three parsers for parsing strings into POSIXct date-times,
#' `date_time_parse()`, `date_time_parse_complete()`, and
#' `date_time_parse_abbrev()`.
#'
#' ## date_time_parse()
#'
#' `date_time_parse()` is useful for strings like `"2019-01-01 00:00:00"`, where
#' the UTC offset and full time zone name are not present in the string. The
#' string is first parsed as a naive-time without any time zone assumptions, and
#' is then converted to a POSIXct with the supplied `zone`.
#'
#' Because converting from naive-time to POSIXct may result in nonexistent or
#' ambiguous times due to daylight saving time, these must be resolved
#' explicitly with the `nonexistent` and `ambiguous` arguments.
#'
#' `date_time_parse()` completely ignores the `%z` and `%Z` commands. The only
#' time zone specific information that is used is the `zone`.
#'
#' The default `format` used is `"%Y-%m-%d %H:%M:%S"`.
#'
#' ## date_time_parse_complete()
#'
#' `date_time_parse_complete()` is a parser for _complete_ date-time strings,
#' like `"2019-01-01 00:00:00-05:00[America/New_York]"`. A complete date-time
#' string has both the time zone offset and full time zone name in the string,
#' which is the only way for the string itself to contain all of the information
#' required to construct a zoned-time. Because of this,
#' `date_time_parse_complete()` requires both the `%z` and `%Z` commands to be
#' supplied in the `format` string.
#'
#' The default `format` used is `"%Y-%m-%d %H:%M:%S%Ez[%Z]"`.
#'
#' ## date_time_parse_abbrev()
#'
#' `date_time_parse_abbrev()` is a parser for date-time strings containing only
#' a time zone abbreviation, like `"2019-01-01 00:00:00 EST"`. The time zone
#' abbreviation is not enough to identify the full time zone name that the
#' date-time belongs to, so the full time zone name must be supplied as the
#' `zone` argument. However, the time zone abbreviation can help with resolving
#' ambiguity around daylight saving time fallbacks.
#'
#' For `date_time_parse_abbrev()`, `%Z` must be supplied and is interpreted as
#' the time zone abbreviation rather than the full time zone name.
#'
#' If used, the `%z` command must parse correctly, but its value will be
#' completely ignored.
#'
#' The default `format` used is `"%Y-%m-%d %H:%M:%S %Z"`.
#'
#' @details
#' If `date_time_parse_complete()` is given input that is length zero, all
#' `NA`s, or completely fails to parse, then no time zone will be able to be
#' determined. In that case, the result will use `"UTC"`.
#'
#' @inheritParams zoned-parsing
#' @inheritParams as-zoned-time-naive-time
#'
#' @return A POSIXct.
#'
#' @name date-time-parse
#'
#' @examples
#' # Parse with a known `zone`, even though that information isn't in the string
#' date_time_parse("2020-01-01 05:06:07", "America/New_York")
#'
#' # Same time as above, except this is a completely unambiguous parse that
#' # doesn't require a `zone` argument, because the zone name and offset are
#' # both present in the string
#' date_time_parse_complete("2020-01-01 05:06:07-05:00[America/New_York]")
#'
#' # Only day components
#' date_time_parse("2020-01-01", "America/New_York", format = "%Y-%m-%d")
#'
#' # `date_time_parse()` may have issues with ambiguous times due to daylight
#' # saving time fallbacks. For example, there were two 1'oclock hours here:
#' x <- date_time_parse("1970-10-25 00:59:59", "America/New_York")
#'
#' # First (earliest) 1'oclock hour
#' add_seconds(x, 1)
#' # Second (latest) 1'oclock hour
#' add_seconds(x, 3601)
#'
#' # If you try to parse this ambiguous time directly, you'll get an error:
#' ambiguous_time <- "1970-10-25 01:00:00"
#' try(date_time_parse(ambiguous_time, "America/New_York"))
#'
#' # Resolve it by specifying whether you'd like to use the
#' # `earliest` or `latest` of the two possible times
#' date_time_parse(ambiguous_time, "America/New_York", ambiguous = "earliest")
#' date_time_parse(ambiguous_time, "America/New_York", ambiguous = "latest")
#'
#' # `date_time_parse_complete()` doesn't have these issues, as it requires
#' # that the offset and zone name are both in the string, which resolves
#' # the ambiguity
#' complete_times <- c(
#'   "1970-10-25 01:00:00-04:00[America/New_York]",
#'   "1970-10-25 01:00:00-05:00[America/New_York]"
#' )
#' date_time_parse_complete(complete_times)
#'
#' # `date_time_parse_abbrev()` also doesn't have these issues, since it
#' # uses the time zone abbreviation name to resolve the ambiguity
#' abbrev_times <- c(
#'   "1970-10-25 01:00:00 EDT",
#'   "1970-10-25 01:00:00 EST"
#' )
#' date_time_parse_abbrev(abbrev_times, "America/New_York")
NULL

#' @rdname date-time-parse
#' @export
date_time_parse <- function(x,
                            zone,
                            ...,
                            format = NULL,
                            locale = clock_locale(),
                            nonexistent = NULL,
                            ambiguous = NULL) {
  x <- naive_time_parse(x, ..., format = format, precision = "second", locale = locale)
  as.POSIXct(x, tz = zone, nonexistent = nonexistent, ambiguous = ambiguous)
}

#' @rdname date-time-parse
#' @export
date_time_parse_complete <- function(x, ..., format = NULL, locale = clock_locale()) {
  x <- zoned_time_parse_complete(x, ..., format = format, precision = "second", locale = locale)
  as.POSIXct(x)
}

#' @rdname date-time-parse
#' @export
date_time_parse_abbrev <- function(x, zone, ..., format = NULL, locale = clock_locale()) {
  x <- zoned_time_parse_abbrev(x, zone, ..., format = format, precision = "second", locale = locale)
  as.POSIXct(x)
}

# ------------------------------------------------------------------------------

#' Shifting: date and date-time
#'
#' @description
#' `date_shift()` shifts `x` to the `target` weekday. You can shift to the next
#' or previous weekday. If `x` is currently on the `target` weekday, you can
#' choose to leave it alone or advance it to the next instance of the `target`.
#'
#' Shifting with date-times retains the time of day where possible. Be aware
#' that you can run into daylight saving time issues if you shift into a
#' daylight saving time gap or fallback period.
#'
#' @inheritParams time_point_shift
#' @inheritParams as-zoned-time-naive-time
#'
#' @param x `[POSIXct / POSIXlt]`
#'
#'   A date-time vector.
#'
#' @return `x` shifted to the `target` weekday.
#'
#' @name posixt-shifting
#'
#' @export
#' @examples
#' tuesday <- weekday(clock_weekdays$tuesday)
#'
#' x <- as.POSIXct("1970-04-22 02:30:00", "America/New_York")
#'
#' # Shift to the next Tuesday
#' date_shift(x, tuesday)
#'
#' # Be aware that you can run into daylight saving time issues!
#' # Here we shift directly into a daylight saving time gap
#' # from 01:59:59 -> 03:00:00
#' sunday <- weekday(clock_weekdays$sunday)
#' try(date_shift(x, sunday))
#'
#' # You can resolve this with the `nonexistent` argument
#' date_shift(x, sunday, nonexistent = "roll-forward")
date_shift.POSIXt <- function(x,
                              target,
                              ...,
                              which = "next",
                              boundary = "keep",
                              nonexistent = NULL,
                              ambiguous = x) {
  force(ambiguous)
  zone <- date_zone(x)
  x <- as_naive_time(x)
  x <- time_point_shift(x, target, ..., which = which, boundary = boundary)
  as.POSIXct(x, tz = zone, nonexistent = nonexistent, ambiguous = ambiguous)
}

# ------------------------------------------------------------------------------

#' Building: date-time
#'
#' @description
#' `date_time_build()` builds a POSIXct from it's individual components.
#'
#' To build a POSIXct, it is required that you specify the `zone`.
#'
#' @details
#' Components are recycled against each other.
#'
#' @inheritParams invalid_resolve
#' @inheritParams as-zoned-time-naive-time
#'
#' @param year `[integer]`
#'
#'   The year. Values `[-32767, 32767]` are generally allowed.
#'
#' @param month `[integer]`
#'
#'   The month. Values `[1, 12]` are allowed.
#'
#' @param day `[integer / "last"]`
#'
#'   The day of the month. Values `[1, 31]` are allowed.
#'
#'   If `"last"`, then the last day of the month is returned.
#'
#' @param hour `[integer]`
#'
#'   The hour. Values `[0, 23]` are allowed.
#'
#' @param minute `[integer]`
#'
#'   The minute. Values `[0, 59]` are allowed.
#'
#' @param second `[integer]`
#'
#'   The second. Values `[0, 59]` are allowed.
#'
#' @param zone `[character(1)]`
#'
#'   A valid time zone name.
#'
#'   This argument is required, and must be specified by name.
#'
#' @return A POSIXct.
#'
#' @export
#' @examples
#' # The zone argument is required!
#' # clock always requires you to be explicit about your choice of `zone`.
#' try(date_time_build(2020))
#'
#' date_time_build(2020, zone = "America/New_York")
#'
#' # Nonexistent time due to daylight saving time gap from 01:59:59 -> 03:00:00
#' try(date_time_build(1970, 4, 26, 1:12, 30, zone = "America/New_York"))
#'
#' # Resolve with a nonexistent time resolution strategy
#' date_time_build(
#'   1970, 4, 26, 1:12, 30,
#'   zone = "America/New_York",
#'   nonexistent = "roll-forward"
#' )
date_time_build <- function(year,
                            month = 1L,
                            day = 1L,
                            hour = 0L,
                            minute = 0L,
                            second = 0L,
                            ...,
                            zone,
                            invalid = NULL,
                            nonexistent = NULL,
                            ambiguous = NULL) {
  check_dots_empty()

  if (is_missing(zone)) {
    abort("`zone` is a required argument to `date_time_build()`.")
  }

  x <- year_month_day(year, month, day, hour, minute, second)
  x <- invalid_resolve(x, invalid = invalid)
  as.POSIXct(x, tz = zone, nonexistent = nonexistent, ambiguous = ambiguous)
}

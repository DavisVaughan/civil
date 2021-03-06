# ------------------------------------------------------------------------------

#' @export
print.clock_calendar <- function(x, ..., max = NULL) {
  clock_print(x, max)
}

# - Each subclass implements a `format()` method
# - Unlike vctrs, don't use `print(quote = FALSE)` since we want to match base R
#' @export
obj_print_data.clock_calendar <- function(x, ..., max) {
  if (vec_is_empty(x)) {
    return(invisible(x))
  }

  x <- max_slice(x, max)

  out <- format(x)

  # Pass `max` to avoid base R's default footer
  print(out, max = max)

  invisible(x)
}

#' @export
obj_print_footer.clock_calendar <- function(x, ..., max) {
  clock_print_footer(x, max)
}

# Align left to match pillar_shaft.Date
# @export - lazy in .onLoad()
pillar_shaft.clock_calendar <- function(x, ...) {
  out <- format(x)
  pillar::new_pillar_shaft_simple(out, align = "left")
}

# ------------------------------------------------------------------------------

# Note: Cannot cast between calendar precisions. Casting to a more precise
# precision is undefined because we consider things like year-month to be
# a range of days over the whole month, and it would be impossible to map
# that to just one day.

ptype2_calendar_and_calendar <- function(x, y, ...) {
  if (calendar_precision_attribute(x) == calendar_precision_attribute(y)) {
    x
  } else {
    stop_incompatible_type(x, y, ..., details = "Can't combine calendars with different precisions.")
  }
}

cast_calendar_to_calendar <- function(x, to, ...) {
  if (calendar_precision_attribute(x) == calendar_precision_attribute(to)) {
    x
  } else {
    stop_incompatible_cast(x, to, ..., details = "Can't cast between calendars with different precisions.")
  }
}

# ------------------------------------------------------------------------------

#' Is the calendar year a leap year?
#'
#' `calendar_leap_year()` detects if the year is a leap year according to
#' the Gregorian calendar. It is only relevant for calendar types that use
#' a Gregorian year, i.e. [year_month_day()], [year_month_weekday()], and
#' [year_day()].
#'
#' @param x `[calendar]`
#'
#'   A calendar type to detect leap years in.
#'
#' @return A logical vector the same size as `x`. Returns `TRUE` if in a leap
#'   year, `FALSE` if not in a leap year, and `NA` if `x` is `NA`.
#'
#' @examples
#' x <- year_month_day(c(2019:2024, NA))
#' calendar_leap_year(x)
#' @export
calendar_leap_year <- function(x) {
  UseMethod("calendar_leap_year")
}

#' @export
calendar_leap_year.clock_calendar <- function(x) {
  stop_clock_unsupported_calendar_op("calendar_leap_year")
}

# ------------------------------------------------------------------------------

#' Convert a calendar to an ordered factor of month names
#'
#' @description
#' `calendar_month_factor()` extracts the month values from a calendar and
#' converts them to an ordered factor of month names. This can be useful in
#' combination with ggplot2, or for modeling.
#'
#' This function is only relevant for calendar types that use a month field,
#' i.e. [year_month_day()] and [year_month_weekday()]. The calendar type must
#' have at least month precision.
#'
#' @inheritParams ellipsis::dots_empty
#' @inheritParams clock_locale
#'
#' @param x `[calendar]`
#'
#'   A calendar vector.
#'
#' @param abbreviate `[logical(1)]`
#'
#'   If `TRUE`, the abbreviated month names from `labels` will be used.
#'
#'   If `FALSE`, the full month names from `labels` will be used.
#'
#' @return An ordered factor representing the months.
#'
#' @export
#' @examples
#' x <- year_month_day(2019, 1:12)
#'
#' calendar_month_factor(x)
#' calendar_month_factor(x, abbreviate = TRUE)
#' calendar_month_factor(x, labels = "fr")
calendar_month_factor <- function(x,
                                  ...,
                                  labels = "en",
                                  abbreviate = FALSE) {
  UseMethod("calendar_month_factor")
}

#' @export
calendar_month_factor.clock_calendar <- function(x,
                                                 ...,
                                                 labels = "en",
                                                 abbreviate = FALSE) {
  stop_clock_unsupported_calendar_op("calendar_month_factor")
}

calendar_month_factor_impl <- function(x, labels, abbreviate, ...) {
  check_dots_empty()

  if (calendar_precision_attribute(x) < PRECISION_MONTH) {
    abort("`x` must have at least 'month' precision.")
  }

  if (is_character(labels)) {
    labels <- clock_labels_lookup(labels)
  }
  if (!is_clock_labels(labels)) {
    abort("`labels` must be a 'clock_labels' object.")
  }

  if (!is_bool(abbreviate)) {
    abort("`abbreviate` must be `TRUE` or `FALSE`.")
  }

  if (abbreviate) {
    labels <- labels$month_abbrev
  } else {
    labels <- labels$month
  }

  x <- get_month(x)
  x <- labels[x]

  factor(x, levels = labels, ordered = TRUE)
}

# ------------------------------------------------------------------------------

#' Group calendar components
#'
#' @description
#' `calendar_group()` groups at a multiple of the specified precision. Grouping
#' alters the value of a single component (i.e. the month component
#' if grouping by month). Components that are more precise than the precision
#' being grouped at are dropped altogether (i.e. the day component is dropped
#' if grouping by month).
#'
#' Each calendar has its own help page describing the grouping process in more
#' detail:
#'
#' - [year-month-day][year-month-day-group]
#'
#' - [year-month-weekday][year-month-weekday-group]
#'
#' - [iso-year-week-day][iso-year-week-day-group]
#'
#' - [year-quarter-day][year-quarter-day-group]
#'
#' - [year-day][year-day-group]
#'
#' @inheritParams ellipsis::dots_empty
#'
#' @param x `[calendar]`
#'
#'   A calendar vector.
#'
#' @param precision `[character(1)]`
#'
#'   A precision. Allowed precisions are dependent on the calendar used.
#'
#' @param n `[positive integer(1)]`
#'
#'   A single positive integer specifying a multiple of `precision` to use.
#'
#' @return `x` grouped at the specified `precision`.
#'
#' @export
#' @examples
#' # See the calendar specific help pages for more examples
#' x <- year_month_day(2019, c(1, 1, 2, 2, 3, 3, 4, 4), 1:8)
#' x
#'
#' # Group by two months
#' calendar_group(x, "month", n = 2)
#'
#' # Group by two days of the month
#' calendar_group(x, "day", n = 2)
calendar_group <- function(x, precision, ..., n = 1L) {
  check_dots_empty()

  precision <- validate_precision_string(precision)

  if (!calendar_is_valid_precision(x, precision)) {
    message <- paste0(
      "`precision` must be a valid precision for a '", calendar_name(x), "'."
    )
    abort(message)
  }

  x_precision <- calendar_precision_attribute(x)

  if (precision > x_precision) {
    precision <- precision_to_string(precision)
    x_precision <- precision_to_string(x_precision)

    message <- paste0(
      "Can't group at a precision (", precision, ") ",
      "that is more precise than `x` (", x_precision, ")."
    )
    abort(message)
  }

  if (precision > PRECISION_SECOND && x_precision != precision) {
    # Grouping nanosecond precision by millisecond would be inconsistent
    # with our general philosophy that you "lock in" the subsecond precision.
    precision <- precision_to_string(precision)
    x_precision <- precision_to_string(x_precision)

    message <- paste0(
      "Can't group a subsecond precision `x` (", x_precision, ") ",
      "by another subsecond precision (", precision, ")."
    )
    abort(message)
  }

  UseMethod("calendar_group")
}

#' @export
calendar_group.clock_calendar <- function(x, precision, ..., n = 1L) {
  stop_clock_unsupported_calendar_op("calendar_group")
}

calendar_group_time <- function(x, n, precision) {
  if (precision == PRECISION_HOUR) {
    value <- get_hour(x)
    value <- group_component0(value, n)
    x <- set_hour(x, value)
    return(x)
  }
  if (precision == PRECISION_MINUTE) {
    value <- get_minute(x)
    value <- group_component0(value, n)
    x <- set_minute(x, value)
    return(x)
  }
  if (precision == PRECISION_SECOND) {
    value <- get_second(x)
    value <- group_component0(value, n)
    x <- set_second(x, value)
    return(x)
  }

  # Generic ensures that if `x_precision > PRECISION_SECOND`,
  # then `precision == x_precision`, making this safe.
  if (precision == PRECISION_MILLISECOND) {
    value <- get_millisecond(x)
    value <- group_component0(value, n)
    x <- set_millisecond(x, value)
    return(x)
  }
  if (precision == PRECISION_MICROSECOND) {
    value <- get_microsecond(x)
    value <- group_component0(value, n)
    x <- set_microsecond(x, value)
    return(x)
  }
  if (precision == PRECISION_NANOSECOND) {
    value <- get_nanosecond(x)
    value <- group_component0(value, n)
    x <- set_nanosecond(x, value)
    return(x)
  }

  abort("Internal error: Unknown precision.")
}

group_component0 <- function(x, n) {
  (x %/% n) * n
}
group_component1 <- function(x, n) {
  ((x - 1L) %/% n) * n + 1L
}

validate_calendar_group_n <- function(n) {
  n <- vec_cast(n, integer(), x_arg = "n")
  if (!is_number(n)) {
    abort("`n` must be a single number.")
  }
  if (n <= 0L) {
    abort("`n` must be a positive number.")
  }
  n
}

# ------------------------------------------------------------------------------

#' Narrow a calendar to a less precise precision
#'
#' @description
#' `calendar_narrow()` narrows `x` to the specified `precision`. It does so
#' by dropping components that represent a precision that is finer than
#' `precision`.
#'
#' Each calendar has its own help page describing the precisions that you
#' can narrow to:
#'
#' - [year-month-day][year-month-day-narrow]
#'
#' - [year-month-weekday][year-month-weekday-narrow]
#'
#' - [iso-year-week-day][iso-year-week-day-narrow]
#'
#' - [year-quarter-day][year-quarter-day-narrow]
#'
#' - [year-day][year-day-narrow]
#'
#' @details
#' A subsecond precision `x` cannot be narrowed to another subsecond precision.
#' You cannot narrow from, say, `"nanosecond"` to `"millisecond"` precision.
#' clock operates under the philosophy that once you have set the subsecond
#' precision of a calendar, it is "locked in" at that precision. If you
#' expected this to use integer division to divide the nanoseconds by 1e6 to
#' get to millisecond precision, you probably want to convert to a time point
#' first, and use [time_point_floor()].
#'
#' @inheritParams calendar_group
#'
#' @return `x` narrowed to the supplied `precision`.
#'
#' @export
#' @examples
#' # Hour precision
#' x <- year_month_day(2019, 1, 3, 4)
#' x
#'
#' # Narrowed to day precision
#' calendar_narrow(x, "day")
#'
#' # Or month precision
#' calendar_narrow(x, "month")
calendar_narrow <- function(x, precision) {
  precision <- validate_precision_string(precision)

  if (!calendar_is_valid_precision(x, precision)) {
    message <- paste0(
      "`precision` must be a valid precision for a '", calendar_name(x), "'."
    )
    abort(message)
  }

  x_precision <- calendar_precision_attribute(x)

  if (precision > x_precision) {
    precision <- precision_to_string(precision)
    x_precision <- precision_to_string(x_precision)

    message <- paste0(
      "Can't narrow to a precision (", precision, ") ",
      "that is wider than `x` (", x_precision, ")."
    )
    abort(message)
  }

  if (precision > PRECISION_SECOND && x_precision != precision) {
    # Allowing Nanosecond -> Millisecond wouldn't be consistent with us
    # disallowing `set_millisecond(<calendar<nanosecond>>)`, and is ambiguous.
    precision <- precision_to_string(precision)
    x_precision <- precision_to_string(x_precision)

    message <- paste0(
      "Can't narrow a subsecond precision `x` (", x_precision, ") ",
      "to another subsecond precision (", precision, ")."
    )
    abort(message)
  }

  UseMethod("calendar_narrow")
}

#' @export
calendar_narrow.clock_calendar <- function(x, precision) {
  stop_clock_unsupported_calendar_op("calendar_narrow")
}

calendar_narrow_time <- function(out_fields, out_precision, x_fields) {
  if (out_precision >= PRECISION_HOUR) {
    out_fields[["hour"]] <- x_fields[["hour"]]
  }
  if (out_precision >= PRECISION_MINUTE) {
    out_fields[["minute"]] <- x_fields[["minute"]]
  }
  if (out_precision >= PRECISION_SECOND) {
    out_fields[["second"]] <- x_fields[["second"]]
  }
  if (out_precision > PRECISION_SECOND) {
    out_fields[["subsecond"]] <- x_fields[["subsecond"]]
  }

  out_fields
}

# ------------------------------------------------------------------------------

#' Widen a calendar to a more precise precision
#'
#' @description
#' `calendar_widen()` widens `x` to the specified `precision`. It does so
#' by setting new components to their smallest value.
#'
#' Each calendar has its own help page describing the precisions that you
#' can widen to:
#'
#' - [year-month-day][year-month-day-widen]
#'
#' - [year-month-weekday][year-month-weekday-widen]
#'
#' - [iso-year-week-day][iso-year-week-day-widen]
#'
#' - [year-quarter-day][year-quarter-day-widen]
#'
#' - [year-day][year-day-widen]
#'
#' @details
#' A subsecond precision `x` cannot be widened. You cannot widen from, say,
#' `"millisecond"` to `"nanosecond"` precision. clock operates under the
#' philosophy that once you have set the subsecond precision of a calendar,
#' it is "locked in" at that precision. If you expected this to multiply
#' the milliseconds by 1e6 to get to nanosecond precision, you probably
#' want to convert to a time point first, and use [time_point_cast()].
#'
#' Generally, clock treats calendars at a specific precision as a _range_ of
#' values. For example, a month precision year-month-day is treated as a range
#' over `[yyyy-mm-01, yyyy-mm-last]`, with no assumption about the day of the
#' month. However, occasionally it is useful to quickly widen a calendar,
#' assuming that you want the beginning of this range to be used for each
#' component. This is where `calendar_widen()` can come in handy.
#'
#' @inheritParams calendar_group
#'
#' @return `x` widened to the supplied `precision`.
#'
#' @export
#' @examples
#' # Month precision
#' x <- year_month_day(2019, 1)
#' x
#'
#' # Widen to day precision
#' calendar_widen(x, "day")
#'
#' # Or second precision
#' calendar_widen(x, "second")
calendar_widen <- function(x, precision) {
  precision <- validate_precision_string(precision)

  if (!calendar_is_valid_precision(x, precision)) {
    message <- paste0(
      "`precision` must be a valid precision for a '", calendar_name(x), "'."
    )
    abort(message)
  }

  x_precision <- calendar_precision_attribute(x)

  if (x_precision > precision) {
    precision <- precision_to_string(precision)
    x_precision <- precision_to_string(x_precision)

    message <- paste0(
      "Can't widen to a precision (", precision, ") ",
      "that is narrower than `x` (", x_precision, ")."
    )
    abort(message)
  }

  if (x_precision > PRECISION_SECOND && x_precision != precision) {
    # Allowing Millisecond -> Nanosecond wouldn't be consistent with us
    # disallowing `set_nanosecond(<calendar<millisecond>>)`, and is ambiguous.
    precision <- precision_to_string(precision)
    x_precision <- precision_to_string(x_precision)

    message <- paste0(
      "Can't widen a subsecond precision `x` (", x_precision, ") ",
      "to another subsecond precision (", precision, ")."
    )
    abort(message)
  }

  UseMethod("calendar_widen")
}

#' @export
calendar_widen.clock_calendar <- function(x, precision) {
  stop_clock_unsupported_calendar_op("calendar_widen")
}

calendar_widen_time <- function(x, x_precision, precision) {
  if (precision >= PRECISION_HOUR && x_precision < PRECISION_HOUR) {
    x <- set_hour(x, 0L)
  }
  if (precision >= PRECISION_MINUTE && x_precision < PRECISION_MINUTE) {
    x <- set_minute(x, 0L)
  }
  if (precision >= PRECISION_SECOND && x_precision < PRECISION_SECOND) {
    x <- set_second(x, 0L)
  }

  # `x` is required to fulfill:
  # `x_precision < PRECISION_SECOND` or `x_precision == precision`
  if (precision == PRECISION_MILLISECOND && x_precision != precision) {
    x <- set_millisecond(x, 0L)
  }
  if (precision == PRECISION_MICROSECOND && x_precision != precision) {
    x <- set_microsecond(x, 0L)
  }
  if (precision == PRECISION_NANOSECOND && x_precision != precision) {
    x <- set_nanosecond(x, 0L)
  }

  x
}

# ------------------------------------------------------------------------------

#' Precision: calendar
#'
#' `calendar_precision()` extracts the precision from a calendar object. It
#' returns the precision as a single string.
#'
#' @param x `[clock_calendar]`
#'
#'   A calendar.
#'
#' @return A single string holding the precision of the calendar.
#'
#' @export
#' @examples
#' calendar_precision(year_month_day(2019))
#' calendar_precision(year_month_day(2019, 1, 1))
#' calendar_precision(year_quarter_day(2019, 3))
calendar_precision <- function(x) {
  UseMethod("calendar_precision")
}

#' @export
calendar_precision.clock_calendar <- function(x) {
  precision <- calendar_precision_attribute(x)
  precision <- precision_to_string(precision)
  precision
}

# ------------------------------------------------------------------------------

# Internal generic
calendar_name <- function(x) {
  UseMethod("calendar_name")
}

# ------------------------------------------------------------------------------

# Internal generic
calendar_is_valid_precision <- function(x, precision) {
  UseMethod("calendar_is_valid_precision")
}

# ------------------------------------------------------------------------------

calendar_precision_attribute <- function(x) {
  attr(x, "precision", exact = TRUE)
}

# ------------------------------------------------------------------------------

calendar_require_minimum_precision <- function(x, precision, fn) {
  if (!calendar_has_minimum_precision(x, precision)) {
    precision_string <- precision_to_string(precision)
    msg <- paste0("`", fn, "()` requires a minimum precision of '", precision_string, "'.")
    abort(msg)
  }
  invisible(x)
}
calendar_has_minimum_precision <- function(x, precision) {
  calendar_precision_attribute(x) >= precision
}

calendar_require_precision <- function(x, precision, fn) {
  if (!calendar_has_precision(x, precision)) {
    precision_string <- precision_to_string(precision)
    msg <- paste0("`", fn, "()` requires a precision of '", precision_string, "'.")
    abort(msg)
  }
  invisible(x)
}
calendar_require_any_of_precisions <- function(x, precisions, fn) {
  results <- vapply(precisions, calendar_has_precision, FUN.VALUE = logical(1), x = x)
  if (!any(results)) {
    precision_string <- precision_to_string(calendar_precision_attribute(x))
    msg <- paste0("`", fn, "()` does not support a precision of '", precision_string, "'.")
    abort(msg)
  }
  invisible(x)
}
calendar_has_precision <- function(x, precision) {
  calendar_precision_attribute(x) == precision
}

# For use in calendar constructor helpers
calendar_validate_subsecond_precision <- function(subsecond_precision) {
  if (is_null(subsecond_precision)) {
    abort("If `subsecond` is provided, `subsecond_precision` must be specified.")
  }

  subsecond_precision <- validate_precision_string(subsecond_precision, "subsecond_precision")

  if (!is_valid_subsecond_precision(subsecond_precision)) {
    abort("`subsecond_precision` must be a valid subsecond precision.")
  }

  subsecond_precision
}

# ------------------------------------------------------------------------------

calendar_require_all_valid <- function(x) {
  if (invalid_any(x)) {
    message <- paste0(
      "Conversion from a calendar requires that all dates are valid. ",
      "Resolve invalid dates by calling `invalid_resolve()`."
    )
    abort(message)
  }

  invisible(x)
}

# ------------------------------------------------------------------------------

calendar_ptype_full <- function(x, class) {
  precision <- calendar_precision_attribute(x)
  precision <- precision_to_string(precision)
  paste0(class, "<", precision, ">")
}

calendar_ptype_abbr <- function(x, abbr) {
  precision <- calendar_precision_attribute(x)
  precision <- precision_to_string(precision)
  precision <- precision_abbr(precision)
  paste0(abbr, "<", precision, ">")
}

# ------------------------------------------------------------------------------

arith_calendar_and_missing <- function(op, x, y, ...) {
  switch (
    op,
    "+" = x,
    stop_incompatible_op(op, x, y, ...)
  )
}

arith_calendar_and_calendar <- function(op, x, y, ..., calendar_minus_calendar_fn) {
  switch (
    op,
    "-" = calendar_minus_calendar_fn(op, x, y, ...),
    stop_incompatible_op(op, x, y, ...)
  )
}

arith_calendar_and_duration <- function(op, x, y, ...) {
  switch (
    op,
    "+" = add_duration(x, y),
    "-" = add_duration(x, -y),
    stop_incompatible_op(op, x, y, ...)
  )
}

arith_duration_and_calendar <- function(op, x, y, ...) {
  switch (
    op,
    "+" = add_duration(y, x, swapped = TRUE),
    "-" = stop_incompatible_op(op, x, y, details = "Can't subtract a calendar from a duration.", ...),
    stop_incompatible_op(op, x, y, ...)
  )
}

arith_calendar_and_numeric <- function(op, x, y, ...) {
  switch (
    op,
    "+" = add_duration(x, duration_helper(y, calendar_precision_attribute(x), retain_names = TRUE)),
    "-" = add_duration(x, duration_helper(-y, calendar_precision_attribute(x), retain_names = TRUE)),
    stop_incompatible_op(op, x, y, ...)
  )
}

arith_numeric_and_calendar <- function(op, x, y, ...) {
  switch (
    op,
    "+" = add_duration(y, duration_helper(x, calendar_precision_attribute(y), retain_names = TRUE), swapped = TRUE),
    "-" = stop_incompatible_op(op, x, y, details = "Can't subtract a calendar from a duration.", ...),
    stop_incompatible_op(op, x, y, ...)
  )
}

# ------------------------------------------------------------------------------

#' @export
as_year_month_day.clock_calendar <- function(x) {
  as_year_month_day(as_sys_time(x))
}

#' @export
as_year_month_weekday.clock_calendar <- function(x) {
  as_year_month_weekday(as_sys_time(x))
}

#' @export
as_iso_year_week_day.clock_calendar <- function(x) {
  as_iso_year_week_day(as_sys_time(x))
}

#' @export
as_year_day.clock_calendar <- function(x) {
  as_year_day(as_sys_time(x))
}

#' @export
as_year_quarter_day.clock_calendar <- function(x, ..., start = NULL) {
  as_year_quarter_day(as_sys_time(x), ..., start = start)
}

# ------------------------------------------------------------------------------

field_year <- function(x) {
  # The `year` field is the first field of every calendar type, which makes
  # it the field that names are on. When extracting the field, we don't ever
  # want the names to come with it.
  out <- field(x, "year")
  names(out) <- NULL
  out
}
field_quarter <- function(x) {
  field(x, "quarter")
}
field_month <- function(x) {
  field(x, "month")
}
field_week <- function(x) {
  field(x, "week")
}
field_day <- function(x) {
  field(x, "day")
}
field_hour <- function(x) {
  field(x, "hour")
}
field_minute <- function(x) {
  field(x, "minute")
}
field_second <- function(x) {
  field(x, "second")
}
field_subsecond <- function(x) {
  field(x, "subsecond")
}
field_index <- function(x) {
  field(x, "index")
}


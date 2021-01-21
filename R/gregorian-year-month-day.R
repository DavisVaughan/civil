#' Calendar: year-month-day
#'
#' `year_month_day()` constructs the most common calendar type using the
#' Gregorian year, month, day, and time of day components.
#'
#' @details
#' Fields are recycled against each other.
#'
#' Fields are collected in order until the first `NULL` field is located. No
#' fields after the first `NULL` field are used.
#'
#' @param year `[integer]`
#'
#'   The year.
#'
#' @param month `[integer / NULL]`
#'
#'   The month.
#'
#' @param day `[integer / NULL]`
#'
#'   The day.
#'
#' @param hour `[integer / NULL]`
#'
#'   The hour.
#'
#' @param minute `[integer / NULL]`
#'
#'   The minute.
#'
#' @param second `[integer / NULL]`
#'
#'   The second.
#'
#' @param subsecond `[integer / NULL]`
#'
#'   The subsecond. If specified, `subsecond_precision` must also be specified
#'   to determine how to interpret the `subsecond`.
#'
#' @param subsecond_precision `[character(1) / NULL]`
#'
#'   The precision to interpret `subsecond` as. One of: `"millisecond"`,
#'   `"microsecond"`, or `"nanosecond"`.
#'
#' @return A year-month-day calendar object.
#'
#' @export
#' @examples
#' # Just the year
#' x <- year_month_day(2019:2025)
#'
#' # Year-month type
#' year_month_day(2020, 1:12)
#'
#' # The most common use case involves year, month, and day fields
#' x <- year_month_day(2020, 1, 1:5)
#' x
#'
#' # Precision can go all the way out to nanosecond
#' year_month_day(2019, 1, 2, 2, 40, 45, 200, subsecond_precision = "nanosecond")
year_month_day <- function(year,
                           month = NULL,
                           day = NULL,
                           hour = NULL,
                           minute = NULL,
                           second = NULL,
                           subsecond = NULL,
                           ...,
                           subsecond_precision = NULL) {
  check_dots_empty()

  # Stop on the first `NULL` argument
  if (is_null(month)) {
    precision <- PRECISION_YEAR
    fields <- list(year = year)
  } else if (is_null(day)) {
    precision <- PRECISION_MONTH
    fields <- list(year = year, month = month)
  } else if (is_null(hour)) {
    precision <- PRECISION_DAY
    fields <- list(year = year, month = month, day = day)
  } else if (is_null(minute)) {
    precision <- PRECISION_HOUR
    fields <- list(year = year, month = month, day = day, hour = hour)
  } else if (is_null(second)) {
    precision <- PRECISION_MINUTE
    fields <- list(year = year, month = month, day = day, hour = hour, minute = minute)
  } else if (is_null(subsecond)) {
    precision <- PRECISION_SECOND
    fields <- list(year = year, month = month, day = day, hour = hour, minute = minute, second = second)
  } else {
    precision <- calendar_validate_subsecond_precision(subsecond_precision)
    fields <- list(year = year, month = month, day = day, hour = hour, minute = minute, second = second, subsecond = subsecond)
  }

  if (is_last(fields$day)) {
    fields$day <- 1L
    last <- TRUE
  } else {
    last <- FALSE
  }

  fields <- vec_recycle_common(!!!fields)
  fields <- vec_cast_common(!!!fields, .to = integer())

  fields <- collect_year_month_day_fields(fields, precision)

  out <- new_year_month_day_from_fields(fields, precision)

  if (last) {
    out <- set_day(out, "last")
  }

  out
}

# ------------------------------------------------------------------------------

new_year_month_day <- function(year = integer(),
                               month = integer(),
                               day = integer(),
                               hour = integer(),
                               minute = integer(),
                               second = integer(),
                               subsecond = integer(),
                               precision = 0L,
                               ...,
                               names = NULL,
                               class = NULL) {
  if (!is.integer(precision)) {
    abort("`precision` must be an integer.")
  }

  precision_string <- precision_to_string(precision)

  fields <- switch(
    precision_string,
    year = list(year = year),
    month = list(year = year, month = month),
    day = list(year = year, month = month, day = day),
    hour = list(year = year, month = month, day = day, hour = hour),
    minute = list(year = year, month = month, day = day, hour = hour, minute = minute),
    second = list(year = year, month = month, day = day, hour = hour, minute = minute, second = second),
    millisecond = list(year = year, month = month, day = day, hour = hour, minute = minute, second = second, subsecond = subsecond),
    microsecond = list(year = year, month = month, day = day, hour = hour, minute = minute, second = second, subsecond = subsecond),
    nanosecond = list(year = year, month = month, day = day, hour = hour, minute = minute, second = second, subsecond = subsecond)
  )

  field_names <- names(fields)
  for (i in seq_along(fields)) {
    int_assert(fields[[i]], field_names[[i]])
  }

  new_calendar(
    fields = fields,
    precision = precision,
    ...,
    names = names,
    class = c(class, "clock_year_month_day")
  )
}

new_year_month_day_from_fields <- function(fields, precision, names = NULL) {
  new_year_month_day(
    year = fields$year,
    month = fields$month,
    day = fields$day,
    hour = fields$hour,
    minute = fields$minute,
    second = fields$second,
    subsecond = fields$subsecond,
    precision = precision,
    names = names
  )
}

# ------------------------------------------------------------------------------

#' @export
vec_proxy.clock_year_month_day <- function(x, ...) {
  clock_rcrd_proxy(x, names(x))
}

#' @export
vec_restore.clock_year_month_day <- function(x, to, ...) {
  fields <- clock_rcrd_restore_fields(x)
  names <- clock_rcrd_restore_names(x)
  precision <- calendar_precision(to)
  new_year_month_day_from_fields(fields, precision, names)
}

#' @export
vec_proxy_equal.clock_year_month_day <- function(x, ...) {
  clock_rcrd_proxy_equal(x)
}

# ------------------------------------------------------------------------------

#' @export
format.clock_year_month_day <- function(x, ...) {
  out <- format_year_month_day_cpp(x, calendar_precision(x))
  names(out) <- names(x)
  out
}

#' @export
vec_ptype_full.clock_year_month_day <- function(x, ...) {
  calendar_ptype_full(x, "year_month_day")
}

#' @export
vec_ptype_abbr.clock_year_month_day <- function(x, ...) {
  calendar_ptype_abbr(x, "ymd")
}

# ------------------------------------------------------------------------------

#' Is `x` a year-month-day?
#'
#' Check if `x` is a year-month-day.
#'
#' @param x `[object]`
#'
#'   An object.
#'
#' @return Returns `TRUE` if `x` inherits from `"clock_year_month_day"`,
#'   otherwise returns `FALSE`
#'
#' @export
#' @examples
#' is_year_month_day(year_month_day(2019))
is_year_month_day <- function(x) {
  inherits(x, "clock_year_month_day")
}

# ------------------------------------------------------------------------------

#' @export
vec_ptype2.clock_year_month_day.clock_year_month_day <- function(x, y, ...) {
  ptype2_calendar_and_calendar(x, y, ...)
}

#' @export
vec_cast.clock_year_month_day.clock_year_month_day <- function(x, to, ...) {
  cast_calendar_to_calendar(x, to, ...)
}

# ------------------------------------------------------------------------------

#' @export
calendar_is_valid_precision.clock_year_month_day <- function(x, precision) {
  year_month_day_is_valid_precision(precision)
}

year_month_day_is_valid_precision <- function(precision) {
  if (!is_valid_precision(precision)) {
    FALSE
  } else if (precision == PRECISION_YEAR || precision == PRECISION_MONTH) {
    TRUE
  } else if (precision >= PRECISION_DAY && precision <= PRECISION_NANOSECOND) {
    TRUE
  } else {
    FALSE
  }
}

# ------------------------------------------------------------------------------

#' @export
calendar_is_valid_component.clock_year_month_day <- function(x, component) {
  year_month_day_is_valid_component(component)
}
year_month_day_is_valid_component <- function(component) {
  if (!is_string(component)) {
    return(FALSE)
  }
  component %in% c("year", "month", "day", calendar_standard_components())
}

# ------------------------------------------------------------------------------

#' @export
invalid_detect.clock_year_month_day <- function(x) {
  invalid_detect_year_month_day_cpp(x, calendar_precision(x))
}

#' @export
invalid_any.clock_year_month_day <- function(x) {
  invalid_any_year_month_day_cpp(x, calendar_precision(x))
}

#' @export
invalid_count.clock_year_month_day <- function(x) {
  invalid_count_year_month_day_cpp(x, calendar_precision(x))
}

#' @export
invalid_resolve.clock_year_month_day <- function(x, ..., invalid = "error") {
  check_dots_empty()
  precision <- calendar_precision(x)
  fields <- invalid_resolve_year_month_day_cpp(x, precision, invalid)
  new_year_month_day_from_fields(fields, precision, names = names(x))
}

# ------------------------------------------------------------------------------

#' @export
get_year.clock_year_month_day <- function(x) {
  field_year(x)
}

#' @export
get_month.clock_year_month_day <- function(x) {
  calendar_require_minimum_precision(x, PRECISION_MONTH, "get_month")
  field_month(x)
}

#' @export
get_day.clock_year_month_day <- function(x) {
  calendar_require_minimum_precision(x, PRECISION_DAY, "get_day")
  field_day(x)
}

#' @export
get_hour.clock_year_month_day <- function(x) {
  calendar_require_minimum_precision(x, PRECISION_HOUR, "get_hour")
  field_hour(x)
}

#' @export
get_minute.clock_year_month_day <- function(x) {
  calendar_require_minimum_precision(x, PRECISION_MINUTE, "get_minute")
  field_minute(x)
}

#' @export
get_second.clock_year_month_day <- function(x) {
  calendar_require_minimum_precision(x, PRECISION_SECOND, "get_second")
  field_second(x)
}

#' @export
get_millisecond.clock_year_month_day <- function(x) {
  calendar_require_precision(x, PRECISION_MILLISECOND, "get_millisecond")
  field_subsecond(x)
}

#' @export
get_microsecond.clock_year_month_day <- function(x) {
  calendar_require_precision(x, PRECISION_MICROSECOND, "get_microsecond")
  field_subsecond(x)
}

#' @export
get_nanosecond.clock_year_month_day <- function(x) {
  calendar_require_precision(x, PRECISION_NANOSECOND, "get_nanosecond")
  field_subsecond(x)
}

# ------------------------------------------------------------------------------

#' @export
calendar_get_component.clock_year_month_day <- function(x, component) {
  switch(
    component,
    year = get_year(x),
    month = get_month(x),
    day = get_day(x),
    hour = get_hour(x),
    minute = get_minute(x),
    second = get_second(x),
    millisecond = get_millisecond(x),
    microsecond = get_microsecond(x),
    nanosecond = get_nanosecond(x),
    abort("Internal error: Unknown component name.")
  )
}

# ------------------------------------------------------------------------------

#' @export
set_year.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  set_field_year_month_day(x, value, "year")
}

#' @export
set_month.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, PRECISION_YEAR, "set_month")
  set_field_year_month_day(x, value, "month")
}

#' @export
set_day.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, PRECISION_MONTH, "set_day")
  set_field_year_month_day(x, value, "day")
}

#' @export
set_hour.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, PRECISION_DAY, "set_hour")
  set_field_year_month_day(x, value, "hour")
}

#' @export
set_minute.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, PRECISION_HOUR, "set_minute")
  set_field_year_month_day(x, value, "minute")
}

#' @export
set_second.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, PRECISION_MINUTE, "set_second")
  set_field_year_month_day(x, value, "second")
}

#' @export
set_millisecond.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_any_of_precisions(x, c(PRECISION_SECOND, PRECISION_MILLISECOND), "set_millisecond")
  set_field_year_month_day(x, value, "millisecond")
}

#' @export
set_microsecond.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_any_of_precisions(x, c(PRECISION_SECOND, PRECISION_MICROSECOND), "set_microsecond")
  set_field_year_month_day(x, value, "microsecond")
}

#' @export
set_nanosecond.clock_year_month_day <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_any_of_precisions(x, c(PRECISION_SECOND, PRECISION_NANOSECOND), "set_nanosecond")
  set_field_year_month_day(x, value, "nanosecond")
}

set_field_year_month_day <- function(x, value, component) {
  if (is_last(value) && identical(component, "day")) {
    return(set_field_year_month_day_last(x))
  }

  precision_fields <- calendar_precision(x)
  precision_value <- year_month_day_component_to_precision(component)
  precision_out <- precision_common2(precision_fields, precision_value)

  value <- vec_cast(value, integer(), x_arg = "value")
  args <- vec_recycle_common(x = x, value = value)
  x <- args$x
  value <- args$value

  result <- set_field_year_month_day_cpp(x, value, precision_fields, precision_value)
  fields <- result$fields
  field <- year_month_day_component_to_field(component)
  fields[[field]] <- result$value

  new_year_month_day_from_fields(fields, precision_out, names = names(x))
}

set_field_year_month_day_last <- function(x) {
  precision_fields <- calendar_precision(x)
  precision_out <- precision_common2(precision_fields, PRECISION_DAY)

  result <- set_field_year_month_day_last_cpp(x, precision_fields)
  fields <- result$fields
  fields[["day"]] <- result$value

  new_year_month_day_from_fields(fields, precision_out, names = names(x))
}

# ------------------------------------------------------------------------------

#' @export
calendar_set_component.clock_year_month_day <- function(x, value, component, ...) {
  switch(
    component,
    year = set_year(x, value, ...),
    month = set_month(x, value, ...),
    day = set_day(x, value, ...),
    hour = set_hour(x, value, ...),
    minute = set_minute(x, value, ...),
    second = set_second(x, value, ...),
    millisecond = set_millisecond(x, value, ...),
    microsecond = set_microsecond(x, value, ...),
    nanosecond = set_nanosecond(x, value, ...),
    abort("Internal error: Unknown component name.")
  )
}

# ------------------------------------------------------------------------------

#' @export
calendar_check_component_range.clock_year_month_day <- function(x, value, component, value_arg) {
  year_month_day_check_range_cpp(value, component, value_arg)
}

# ------------------------------------------------------------------------------

#' @export
calendar_name.clock_year_month_day <- function(x) {
  "year_month_day"
}

# ------------------------------------------------------------------------------

#' @export
calendar_component_to_precision.clock_year_month_day <- function(x, component) {
  year_month_day_component_to_precision(component)
}
year_month_day_component_to_precision <- function(component) {
  switch(
    component,
    year = PRECISION_YEAR,
    month = PRECISION_MONTH,
    day = PRECISION_DAY,
    hour = PRECISION_HOUR,
    minute = PRECISION_MINUTE,
    second = PRECISION_SECOND,
    millisecond = PRECISION_MILLISECOND,
    microsecond = PRECISION_MICROSECOND,
    nanosecond = PRECISION_NANOSECOND,
    abort("Internal error: Unknown component name.")
  )
}

#' @export
calendar_component_to_field.clock_year_month_day <- function(x, component) {
  year_month_day_component_to_field(component)
}
year_month_day_component_to_field <- function(component) {
  switch (
    component,
    year = component,
    month = component,
    day = component,
    hour = component,
    minute = component,
    second = component,
    millisecond = "subsecond",
    microsecond = "subsecond",
    nanosecond = "subsecond",
    abort("Internal error: Unknown component name.")
  )
}

#' @export
calendar_precision_to_component.clock_year_month_day <- function(x, precision) {
  year_month_day_precision_to_component(precision)
}
year_month_day_precision_to_component <- function(precision) {
  precision <- precision_to_string(precision)

  switch (
    precision,
    year = precision,
    month = precision,
    day = precision,
    hour = precision,
    minute = precision,
    second = precision,
    millisecond = precision,
    microsecond = precision,
    nanosecond = precision,
    abort("Internal error: Unknown precision.")
  )
}

#' @export
calendar_precision_to_field.clock_year_month_day <- function(x, precision) {
  year_month_day_precision_to_field(precision)
}
year_month_day_precision_to_field <- function(precision) {
  precision <- precision_to_string(precision)

  switch (
    precision,
    year = precision,
    month = precision,
    day = precision,
    hour = precision,
    minute = precision,
    second = precision,
    millisecond = "subsecond",
    microsecond = "subsecond",
    nanosecond = "subsecond",
    abort("Internal error: Unknown precision.")
  )
}

# ------------------------------------------------------------------------------

#' Support for vctrs arithmetic
#'
#' @inheritParams vctrs::vec_arith
#' @name clock-arith
#'
#' @return The result of the arithmetic operation.
#' @examples
#' vec_arith("+", year_month_day(2019), 1)
NULL

#' @rdname clock-arith
#' @method vec_arith clock_year_month_day
#' @export
vec_arith.clock_year_month_day <- function(op, x, y, ...) {
  UseMethod("vec_arith.clock_year_month_day", y)
}

#' @method vec_arith.clock_year_month_day MISSING
#' @export
vec_arith.clock_year_month_day.MISSING <- function(op, x, y, ...) {
  arith_calendar_and_missing(op, x, y, ...)
}

#' @method vec_arith.clock_year_month_day clock_year_month_day
#' @export
vec_arith.clock_year_month_day.clock_year_month_day <- function(op, x, y, ...) {
  arith_calendar_and_calendar(op, x, y, ..., calendar_minus_calendar_fn = year_month_day_minus_year_month_day)
}

#' @method vec_arith.clock_year_month_day clock_duration
#' @export
vec_arith.clock_year_month_day.clock_duration <- function(op, x, y, ...) {
  arith_calendar_and_duration(op, x, y, ...)
}

#' @method vec_arith.clock_duration clock_year_month_day
#' @export
vec_arith.clock_duration.clock_year_month_day <- function(op, x, y, ...) {
  arith_duration_and_calendar(op, x, y, ...)
}

#' @method vec_arith.clock_year_month_day numeric
#' @export
vec_arith.clock_year_month_day.numeric <- function(op, x, y, ...) {
  arith_calendar_and_numeric(op, x, y, ...)
}

#' @method vec_arith.numeric clock_year_month_day
#' @export
vec_arith.numeric.clock_year_month_day <- function(op, x, y, ...) {
  arith_numeric_and_calendar(op, x, y, ...)
}

year_month_day_minus_year_month_day <- function(op, x, y, ...) {
  args <- vec_recycle_common(x = x, y = y)
  args <- vec_cast_common(!!!args)
  x <- args$x
  y <- args$y

  names <- names_common(x, y)

  precision <- calendar_precision(x)

  if (precision > PRECISION_MONTH) {
    stop_incompatible_op(op, x, y, ...)
  }

  fields <- year_month_day_minus_year_month_day_cpp(x, y, precision)

  new_duration_from_fields(fields, precision, names = names)
}

# ------------------------------------------------------------------------------

#' @export
add_years.clock_year_month_day <- function(x, n, ...) {
  year_month_day_plus_duration(x, n, PRECISION_YEAR)
}

#' @export
add_quarters.clock_year_month_day <- function(x, n, ...) {
  calendar_require_minimum_precision(x, PRECISION_MONTH, "add_quarters")
  year_month_day_plus_duration(x, n, PRECISION_QUARTER)
}

#' @export
add_months.clock_year_month_day <- function(x, n, ...) {
  calendar_require_minimum_precision(x, PRECISION_MONTH, "add_months")
  year_month_day_plus_duration(x, n, PRECISION_MONTH)
}

year_month_day_plus_duration <- function(x, n, precision_n) {
  precision_fields <- calendar_precision(x)

  n <- duration_collect_n(n, precision_n)
  args <- vec_recycle_common(x = x, n = n)
  x <- args$x
  n <- args$n

  names <- names_common(x, n)

  fields <- year_month_day_plus_duration_cpp(x, n, precision_fields, precision_n)

  new_year_month_day_from_fields(fields, precision_fields, names = names)
}

# ------------------------------------------------------------------------------

#' Convert to year-month-day
#'
#' `as_year_month_day()` converts a vector to the year-month-day calendar.
#' Time points, Dates, POSIXct, and other calendars can all be converted to
#' year-month-day.
#'
#' @param x `[vector]`
#'
#'   A vector to convert to year-month-day.
#'
#' @return A year-month-day vector.
#' @export
#' @examples
#' # From Date
#' as_year_month_day(as.Date("2019-01-01"))
#'
#' # From POSIXct, which assumes that the naive time is what should be converted
#' as_year_month_day(as.POSIXct("2019-01-01 02:30:30", "America/New_York"))
#'
#' # From other calendars
#' as_year_month_day(year_quarter_day(2019, quarter = 2, day = 50))
as_year_month_day <- function(x)  {
  UseMethod("as_year_month_day")
}

#' @export
as_year_month_day.default <- function(x) {
  stop_clock_unsupported_conversion(x, "clock_year_month_day")
}

#' @export
as_year_month_day.clock_year_month_day <- function(x) {
  x
}

# ------------------------------------------------------------------------------

#' @export
as_sys_time.clock_year_month_day <- function(x) {
  calendar_require_all_valid(x, "as_sys_time")
  precision <- calendar_precision(x)
  fields <- as_sys_time_year_month_day_cpp(x, precision)
  duration <- new_duration_from_fields(fields, precision)
  new_sys_time(duration, names = names(x))
}

#' @export
as_naive_time.clock_year_month_day <- function(x) {
  as_naive_time(as_sys_time(x))
}

# ------------------------------------------------------------------------------

#' @export
calendar_leap_year.clock_year_month_day <- function(x) {
  x <- get_year(x)
  gregorian_leap_year_cpp(x)
}

# ------------------------------------------------------------------------------

#' @export
calendar_component_grouper.clock_year_month_day <- function(x, component) {
  switch(
    component,
    year = group_component0,
    month = group_component1,
    day = group_component1,
    hour = group_component0,
    minute = group_component0,
    second = group_component0,
    millisecond = group_component0,
    microsecond = group_component0,
    nanosecond = group_component0
  )
}

# ------------------------------------------------------------------------------

#' @export
calendar_narrow.clock_year_month_day <- function(x, precision) {
  x_precision <- calendar_precision(x)
  precision <- validate_precision(precision)

  if (x_precision == precision) {
    return(x)
  }

  out_fields <- list()
  x_fields <- calendar_fields(x)

  if (precision >= PRECISION_YEAR) {
    out_fields[["year"]] <- x_fields[["year"]]
  }
  if (precision >= PRECISION_MONTH) {
    out_fields[["month"]] <- x_fields[["month"]]
  }
  if (precision >= PRECISION_DAY) {
    out_fields[["day"]] <- x_fields[["day"]]
  }
  if (precision >= PRECISION_HOUR) {
    out_fields <- calendar_narrow_time(out_fields, precision, x_fields, x_precision)
  }

  new_year_month_day_from_fields(out_fields, precision = precision, names = names(x))
}
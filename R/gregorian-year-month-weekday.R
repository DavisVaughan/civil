#' @export
year_month_weekday <- function(year,
                               month = NULL,
                               weekday = NULL,
                               weekday_index = NULL,
                               hour = NULL,
                               minute = NULL,
                               second = NULL,
                               subsecond = NULL,
                               ...,
                               subsecond_precision = NULL) {
  if (xor(is_null(weekday), is_null(weekday_index))) {
    abort("If either `weekday` or `weekday_index` is specified, both must be specified.")
  }

  # Stop on the first `NULL` argument
  if (is_null(month)) {
    precision <- "year"
    fields <- list(year = year)
  } else if (is_null(weekday_index)) {
    precision <- "month"
    fields <- list(year = year, month = month)
  } else if (is_null(hour)) {
    precision <- "day"
    fields <- list(year = year, month = month, weekday = weekday, weekday_index = weekday_index)
  } else if (is_null(minute)) {
    precision <- "hour"
    fields <- list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour)
  } else if (is_null(second)) {
    precision <- "minute"
    fields <- list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour, minute = minute)
  } else if (is_null(subsecond)) {
    precision <- "second"
    fields <- list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour, minute = minute, second = second)
  } else {
    precision <- calendar_validate_subsecond_precision(subsecond_precision)
    fields <- list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour, minute = minute, second = second, subsecond = subsecond)
  }

  if (is_last(fields$weekday_index)) {
    fields$weekday_index <- 1L
    last <- TRUE
  } else {
    last <- FALSE
  }

  fields <- vec_recycle_common(!!!fields)
  fields <- vec_cast_common(!!!fields, .to = integer())

  fields <- collect_year_month_weekday_fields(fields, precision)

  out <- new_year_month_weekday_from_fields(fields, precision)

  if (last) {
    out <- set_weekday_index(out, "last")
  }

  out
}

# ------------------------------------------------------------------------------

#' @export
new_year_month_weekday <- function(year = integer(),
                                   month = integer(),
                                   weekday = integer(),
                                   weekday_index = integer(),
                                   hour = integer(),
                                   minute = integer(),
                                   second = integer(),
                                   subsecond = integer(),
                                   precision = "year",
                                   ...,
                                   names = NULL,
                                   class = NULL) {
  if (!year_month_weekday_is_valid_precision(precision)) {
    abort("`precision` must be a valid precision for 'year_month_weekday'.")
  }

  fields <- switch(
    precision,
    year = list(year = year),
    month = list(year = year, month = month),
    day = list(year = year, month = month, weekday = weekday, weekday_index = weekday_index),
    hour = list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour),
    minute = list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour, minute = minute),
    second = list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour, minute = minute, second = second),
    millisecond = list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour, minute = minute, second = second, subsecond = subsecond),
    microsecond = list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour, minute = minute, second = second, subsecond = subsecond),
    nanosecond = list(year = year, month = month, weekday = weekday, weekday_index = weekday_index, hour = hour, minute = minute, second = second, subsecond = subsecond)
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
    class = c(class, "clock_year_month_weekday")
  )
}

new_year_month_weekday_from_fields <- function(fields, precision, names = NULL) {
  new_year_month_weekday(
    year = fields$year,
    month = fields$month,
    weekday = fields$weekday,
    weekday_index = fields$weekday_index,
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
vec_proxy.clock_year_month_weekday <- function(x, ...) {
  proxy_rcrd(x)
}

#' @export
vec_restore.clock_year_month_weekday <- function(x, to, ...) {
  fields <- restore_rcrd_fields(x)
  names <- restore_rcrd_names(x)
  precision <- calendar_precision(to)
  new_year_month_weekday_from_fields(fields, precision, names)
}

#' @export
vec_proxy_equal.clock_year_month_weekday <- function(x, ...) {
  proxy_equal_rcrd(x)
}

#' @export
vec_proxy_compare.clock_year_month_weekday <- function(x, ...) {
  precision <- calendar_precision(x)

  if (precision_value(precision) >= PRECISION_DAY) {
    # See issue #32
    message <- paste0(
      "'year_month_weekday' types with a precision of >= 'day' cannot be ",
      "trivially compared or ordered. ",
      "Convert to 'year_month_day' to compare using day-of-month values."
    )
    abort(message)
  }

  # Year / month year-month-weekday precision can be compared without ambiguity
  proxy_equal_rcrd(x)
}

# ------------------------------------------------------------------------------

#' @export
format.clock_year_month_weekday <- function(x, ...) {
  out <- format_year_month_weekday_cpp(x, calendar_precision(x))
  names(out) <- names(x)
  out
}

#' @export
vec_ptype_full.clock_year_month_weekday <- function(x, ...) {
  calendar_ptype_full(x, "year_month_weekday")
}

#' @export
vec_ptype_abbr.clock_year_month_weekday <- function(x, ...) {
  calendar_ptype_abbr(x, "ymw")
}

# ------------------------------------------------------------------------------

#' @export
is_year_month_weekday <- function(x) {
  inherits(x, "clock_year_month_weekday")
}

# ------------------------------------------------------------------------------

#' @export
vec_ptype2.clock_year_month_weekday.clock_year_month_weekday <- function(x, y, ...) {
  ptype2_calendar_and_calendar(x, y, ...)
}

#' @export
vec_cast.clock_year_month_weekday.clock_year_month_weekday <- function(x, to, ...) {
  cast_calendar_to_calendar(x, to, ...)
}

# ------------------------------------------------------------------------------

#' @export
calendar_is_valid_precision.clock_year_month_weekday <- function(x, precision) {
  year_month_weekday_is_valid_precision(precision)
}

year_month_weekday_is_valid_precision <- function(precision) {
  if (!is_string(precision)) {
    return(FALSE)
  }

  precision %in% c("year", "month", calendar_standard_precisions())
}

# ------------------------------------------------------------------------------

#' @export
calendar_is_valid_component.clock_year_month_weekday <- function(x, component) {
  year_month_weekday_is_valid_component(component)
}
year_month_weekday_is_valid_component <- function(component) {
  if (!is_string(component)) {
    return(FALSE)
  }
  component %in% c("year", "month", "weekday", "weekday_index", calendar_standard_components())
}

# ------------------------------------------------------------------------------

#' @export
invalid_detect.clock_year_month_weekday <- function(x) {
  invalid_detect_year_month_weekday_cpp(x, calendar_precision(x))
}

#' @export
invalid_any.clock_year_month_weekday <- function(x) {
  invalid_any_year_month_weekday_cpp(x, calendar_precision(x))
}

#' @export
invalid_count.clock_year_month_weekday <- function(x) {
  invalid_count_year_month_weekday_cpp(x, calendar_precision(x))
}

#' @export
invalid_resolve.clock_year_month_weekday <- function(x, ..., invalid = "error") {
  check_dots_empty()
  precision <- calendar_precision(x)
  fields <- invalid_resolve_year_month_weekday_cpp(x, precision, invalid)
  new_year_month_weekday_from_fields(fields, precision, names = names(x))
}

# ------------------------------------------------------------------------------

#' @export
get_year.clock_year_month_weekday <- function(x) {
  field_year(x)
}

#' @export
get_month.clock_year_month_weekday <- function(x) {
  calendar_require_minimum_precision(x, "month", "get_month")
  field_month(x)
}

#' @export
get_weekday.clock_year_month_weekday <- function(x) {
  # [Sunday, Saturday] -> [1, 7]
  calendar_require_minimum_precision(x, "day", "get_weekday")
  field_weekday(x)
}

#' @export
get_weekday_index.clock_year_month_weekday <- function(x) {
  calendar_require_minimum_precision(x, "day", "get_weekday_index")
  field_weekday_index(x)
}

#' @export
get_hour.clock_year_month_weekday <- function(x) {
  calendar_require_minimum_precision(x, "hour", "get_hour")
  field_hour(x)
}

#' @export
get_minute.clock_year_month_weekday <- function(x) {
  calendar_require_minimum_precision(x, "minute", "get_minute")
  field_minute(x)
}

#' @export
get_second.clock_year_month_weekday <- function(x) {
  calendar_require_minimum_precision(x, "second", "get_second")
  field_second(x)
}

#' @export
get_millisecond.clock_year_month_weekday <- function(x) {
  calendar_require_precision(x, "millisecond", "get_millisecond")
  field_subsecond(x)
}

#' @export
get_microsecond.clock_year_month_weekday <- function(x) {
  calendar_require_precision(x, "microsecond", "get_microsecond")
  field_subsecond(x)
}

#' @export
get_nanosecond.clock_year_month_weekday <- function(x) {
  calendar_require_precision(x, "nanosecond", "get_nanosecond")
  field_subsecond(x)
}

# ------------------------------------------------------------------------------

#' @export
calendar_get_component.clock_year_month_weekday <- function(x, component) {
  switch(
    component,
    year = get_year(x),
    month = get_month(x),
    weekday = get_weekday(x),
    weekday_index = get_weekday_index(x),
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
set_year.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  set_field_year_month_weekday(x, value, "year")
}

#' @export
set_month.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, "year", "set_month")
  set_field_year_month_weekday(x, value, "month")
}

#' @export
set_weekday.clock_year_month_weekday <- function(x, value, ..., weekday_index = NULL) {
  check_dots_empty()
  calendar_require_minimum_precision(x, "month", "set_weekday")

  has_weekday_index <- !is_null(weekday_index)
  precision <- calendar_precision(x)

  if (precision_value(precision) == PRECISION_MONTH) {
    if (!has_weekday_index) {
      abort("For 'month' precision 'year_month_weekday', both the weekday and index must be set simultaneously.")
    }

    ones <- ones_along(x, na_propagate = TRUE)

    # Promote up to day precision so we can assign to fields individually
    x <- new_year_month_weekday(
      year = get_year(x),
      month = get_month(x),
      weekday = ones,
      weekday_index = ones,
      precision = "day",
      names = names(x)
    )
  }

  out <- set_field_year_month_weekday(x, value, "weekday")

  if (has_weekday_index) {
    out <- set_field_year_month_weekday(out, weekday_index, "weekday_index")
  }

  out
}

#' @export
set_weekday_index.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, "day", "set_weekday_index")
  set_field_year_month_weekday(x, value, "weekday_index")
}

#' @export
set_hour.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, "day", "set_hour")
  set_field_year_month_weekday(x, value, "hour")
}

#' @export
set_minute.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, "hour", "set_minute")
  set_field_year_month_weekday(x, value, "minute")
}

#' @export
set_second.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_minimum_precision(x, "minute", "set_second")
  set_field_year_month_weekday(x, value, "second")
}

#' @export
set_millisecond.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_any_of_precisions(x, c("second", "millisecond"), "set_millisecond")
  set_field_year_month_weekday(x, value, "millisecond")
}

#' @export
set_microsecond.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_any_of_precisions(x, c("second", "microsecond"), "set_microsecond")
  set_field_year_month_weekday(x, value, "microsecond")
}

#' @export
set_nanosecond.clock_year_month_weekday <- function(x, value, ...) {
  check_dots_empty()
  calendar_require_any_of_precisions(x, c("second", "nanosecond"), "set_nanosecond")
  set_field_year_month_weekday(x, value, "nanosecond")
}

set_field_year_month_weekday <- function(x, value, component) {
  if (is_last(value) && identical(component, "weekday_index")) {
    return(set_field_year_month_weekday_last(x))
  }

  precision_fields <- calendar_precision(x)
  precision_value <- year_month_weekday_component_to_precision(component)
  precision_out <- precision_common2(precision_fields, precision_value)

  value <- vec_cast(value, integer(), x_arg = "value")
  args <- vec_recycle_common(x = x, value = value)
  x <- args$x
  value <- args$value

  result <- set_field_year_month_weekday_cpp(x, value, precision_fields, component)
  fields <- result$fields
  field <- year_month_weekday_component_to_field(component)
  fields[[field]] <- result$value

  new_year_month_weekday_from_fields(fields, precision_out, names = names(x))
}

set_field_year_month_weekday_last <- function(x) {
  # We require 'day' precision to set the `weekday_index` at all, so no
  # need to find a common precision here
  precision_fields <- calendar_precision(x)

  result <- set_field_year_month_weekday_last_cpp(x, precision_fields)
  fields <- result$fields
  fields[["weekday_index"]] <- result$value

  new_year_month_weekday_from_fields(fields, precision_fields, names = names(x))
}

# ------------------------------------------------------------------------------

#' @export
calendar_set_component.clock_year_month_weekday <- function(x, value, component, ...) {
  switch(
    component,
    year = set_year(x, value, ...),
    month = set_month(x, value, ...),
    weekday = set_weekday(x, value, ...),
    weekday_index = set_weekday_index(x, value, ...),
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
calendar_check_component_range.clock_year_month_weekday <- function(x, value, component, value_arg) {
  year_month_weekday_check_range_cpp(value, component, value_arg)
}

# ------------------------------------------------------------------------------

#' @export
calendar_name.clock_year_month_weekday <- function(x) {
  "year_month_weekday"
}

# ------------------------------------------------------------------------------

#' @export
calendar_component_to_precision.clock_year_month_weekday <- function(x, component) {
  year_month_weekday_component_to_precision(component)
}
year_month_weekday_component_to_precision <- function(component) {
  switch (
    component,
    year = component,
    month = component,
    weekday = "day",
    weekday_index = "day",
    hour = component,
    minute = component,
    second = component,
    millisecond = component,
    microsecond = component,
    nanosecond = component,
    abort("Internal error: Unknown component name.")
  )
}

#' @export
calendar_component_to_field.clock_year_month_weekday <- function(x, component) {
  year_month_weekday_component_to_field(component)
}
year_month_weekday_component_to_field <- function(component) {
  switch (
    component,
    year = component,
    month = component,
    weekday = component,
    weekday_index = component,
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
calendar_precision_to_component.clock_year_month_weekday <- function(x, precision) {
  year_month_weekday_precision_to_component(precision)
}
year_month_weekday_precision_to_component <- function(precision) {
  switch (
    precision,
    year = precision,
    month = precision,
    day = abort("Internal error: Ambiguous precision -> component mapping (weekday / weekday_index)."),
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
calendar_precision_to_field.clock_year_month_weekday <- function(x, precision) {
  year_month_weekday_precision_to_field(precision)
}
year_month_weekday_precision_to_field <- function(precision) {
  switch (
    precision,
    year = precision,
    month = precision,
    day = abort("Internal error: Ambiguous precision -> field mapping (weekday / weekday_index)."),
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

#' @method vec_arith clock_year_month_weekday
#' @export
vec_arith.clock_year_month_weekday <- function(op, x, y, ...) {
  UseMethod("vec_arith.clock_year_month_weekday", y)
}

#' @method vec_arith.clock_year_month_weekday MISSING
#' @export
vec_arith.clock_year_month_weekday.MISSING <- function(op, x, y, ...) {
  arith_calendar_and_missing(op, x, y, ...)
}

#' @method vec_arith.clock_year_month_weekday clock_year_month_weekday
#' @export
vec_arith.clock_year_month_weekday.clock_year_month_weekday <- function(op, x, y, ...) {
  arith_calendar_and_calendar(op, x, y, ..., calendar_minus_calendar_fn = year_month_weekday_minus_year_month_weekday)
}

#' @method vec_arith.clock_year_month_weekday clock_duration
#' @export
vec_arith.clock_year_month_weekday.clock_duration <- function(op, x, y, ...) {
  arith_calendar_and_duration(op, x, y, ...)
}

#' @method vec_arith.clock_duration clock_year_month_weekday
#' @export
vec_arith.clock_duration.clock_year_month_weekday <- function(op, x, y, ...) {
  arith_duration_and_calendar(op, x, y, ...)
}

#' @method vec_arith.clock_year_month_weekday numeric
#' @export
vec_arith.clock_year_month_weekday.numeric <- function(op, x, y, ...) {
  arith_calendar_and_numeric(op, x, y, ...)
}

#' @method vec_arith.numeric clock_year_month_weekday
#' @export
vec_arith.numeric.clock_year_month_weekday <- function(op, x, y, ...) {
  arith_numeric_and_calendar(op, x, y, ...)
}

year_month_weekday_minus_year_month_weekday <- function(op, x, y, ...) {
  args <- vec_recycle_common(x = x, y = y)
  args <- vec_cast_common(!!!args)
  x <- args$x
  y <- args$y

  names <- names_common(x, y)

  precision <- calendar_precision(x)

  if (precision_value(precision) > PRECISION_MONTH) {
    stop_incompatible_op(op, x, y, ...)
  }

  fields <- year_month_weekday_minus_year_month_weekday_cpp(x, y, precision)

  new_duration_from_fields(fields, precision, names = names)
}

# ------------------------------------------------------------------------------

#' @export
add_years.clock_year_month_weekday <- function(x, n, ...) {
  year_month_weekday_plus_duration(x, n, "year")
}

#' @export
add_quarters.clock_year_month_weekday <- function(x, n, ...) {
  calendar_require_minimum_precision(x, "month", "add_quarters")
  year_month_weekday_plus_duration(x, n, "quarter")
}

#' @export
add_months.clock_year_month_weekday <- function(x, n, ...) {
  calendar_require_minimum_precision(x, "month", "add_months")
  year_month_weekday_plus_duration(x, n, "month")
}

year_month_weekday_plus_duration <- function(x, n, precision_n) {
  precision_fields <- calendar_precision(x)

  n <- duration_collect_n(n, precision_n)
  args <- vec_recycle_common(x = x, n = n)
  x <- args$x
  n <- args$n

  names <- names_common(x, n)

  fields <- year_month_weekday_plus_duration_cpp(x, n, precision_fields, precision_n)

  new_year_month_weekday_from_fields(fields, precision_fields, names = names)
}

# ------------------------------------------------------------------------------

#' @export
as_year_month_weekday <- function(x)  {
  UseMethod("as_year_month_weekday")
}

#' @export
as_year_month_weekday.default <- function(x) {
  stop_clock_unsupported_conversion(x, "clock_year_month_weekday")
}

#' @export
as_year_month_weekday.clock_year_month_weekday <- function(x) {
  x
}

#' @export
as_year_month_weekday.clock_calendar <- function(x) {
  as_year_month_weekday(as_sys_time(x))
}

# ------------------------------------------------------------------------------

#' @export
as_sys_time.clock_year_month_weekday <- function(x) {
  calendar_require_all_valid(x, "as_sys_time")
  precision <- calendar_precision(x)
  fields <- as_sys_time_year_month_weekday_cpp(x, precision)
  duration <- new_duration_from_fields(fields, precision)
  new_sys_time(duration, names = names(x))
}

#' @export
as_naive_time.clock_year_month_weekday <- function(x) {
  as_naive_time(as_sys_time(x))
}

# ------------------------------------------------------------------------------

#' @export
calendar_group.clock_year_month_weekday <- function(x, precision, ..., n = 1L) {
  if (identical(precision, "day")) {
    message <- paste0(
      "Grouping 'year_month_weekday' by 'day' precision is undefined. ",
      "Convert to 'year_month_day' to group by day of month."
    )
    abort(message)
  }
  NextMethod()
}

#' @export
calendar_component_grouper.clock_year_month_weekday <- function(x, component) {
  switch(
    component,
    year = group_component0,
    month = group_component1,
    weekday = abort("Internal error: Should have errored earlier. Undefined 'day' grouping"),
    weekday_index = abort("Internal error: Should have errored earlier. Undefined 'day' grouping"),
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
calendar_narrow.clock_year_month_weekday <- function(x, precision) {
  x_precision <- calendar_precision(x)

  if (x_precision == precision) {
    return(x)
  }

  x_precision_value <- precision_value(x_precision)
  out_precision_value <- precision_value(precision)

  out_fields <- list()
  x_fields <- calendar_fields(x)

  if (out_precision_value >= PRECISION_YEAR) {
    out_fields[["year"]] <- x_fields[["year"]]
  }
  if (out_precision_value >= PRECISION_MONTH) {
    out_fields[["month"]] <- x_fields[["month"]]
  }
  if (out_precision_value >= PRECISION_DAY) {
    out_fields[["weekday"]] <- x_fields[["weekday"]]
    out_fields[["weekday_index"]] <- x_fields[["weekday_index"]]
  }
  if (out_precision_value >= PRECISION_HOUR) {
    out_fields <- calendar_narrow_time(out_fields, out_precision_value, x_fields, x_precision_value)
  }

  new_year_month_weekday_from_fields(out_fields, precision = precision, names = names(x))
}

# ------------------------------------------------------------------------------

field_weekday <- function(x) {
  field(x, "weekday")
}
field_weekday_index <- function(x) {
  field(x, "weekday_index")
}
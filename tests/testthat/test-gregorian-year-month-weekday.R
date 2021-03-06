# ------------------------------------------------------------------------------
# year_month_weekday()

test_that("helper can create different precisions", {
  x <- year_month_weekday(2019, 1:2)
  expect_identical(get_year(x), c(2019L, 2019L))
  expect_identical(get_month(x), 1:2)

  x <- year_month_weekday(2019, 1:2, clock_weekdays$monday, 2)
  expect_identical(get_day(x), c(clock_weekdays$monday, clock_weekdays$monday))
  expect_identical(get_index(x), c(2L, 2L))
})

test_that("can create subsecond precision calendars", {
  x <- year_month_weekday(2019, 1, 1, 1, 0, 0, 0, 1, subsecond_precision = "millisecond")
  expect_identical(get_millisecond(x), 1L)

  x <- year_month_weekday(2019, 1, 1, 1, 0, 0, 0, 1, subsecond_precision = "microsecond")
  expect_identical(get_microsecond(x), 1L)

  x <- year_month_weekday(2019, 1, 1, 1, 0, 0, 0, 1, subsecond_precision = "nanosecond")
  expect_identical(get_nanosecond(x), 1L)
})

test_that("both day and index must be specified", {
  expect_snapshot_error(year_month_weekday(2020, 1, 1))
})

test_that("validates value ranges", {
  expect_snapshot_error(year_month_weekday(50000))
  expect_snapshot_error(year_month_weekday(2020, 13))
  expect_snapshot_error(year_month_weekday(2020, 1, 32, 1))
  expect_snapshot_error(year_month_weekday(2020, 1, 1, 6))
  expect_snapshot_error(year_month_weekday(2020, 1, 1, 1, 24))
  expect_snapshot_error(year_month_weekday(2020, 1, 1, 1, 1, 60))
  expect_snapshot_error(year_month_weekday(2020, 1, 1, 1, 1, 1, 60))
  expect_snapshot_error(year_month_weekday(2020, 1, 1, 1, 1, 1, 1, 1000, subsecond_precision = "millisecond"))
  expect_snapshot_error(year_month_weekday(2020, 1, 1, 1, 1, 1, 1, 1000000, subsecond_precision = "microsecond"))
  expect_snapshot_error(year_month_weekday(2020, 1, 1, 1, 1, 1, 1, 1000000000, subsecond_precision = "nanosecond"))
})

test_that("can get the last indexed weekday of the month", {
  x <- year_month_weekday(2019, 1:4, clock_weekdays$monday, "last")
  expect_identical(get_index(x), c(4L, 4L, 4L, 5L))
})

test_that("ignores values past first `NULL`", {
  expect_identical(year_month_weekday(2019, minute = 2), year_month_weekday(2019))
})

test_that("NA values propagate", {
  x <- year_month_weekday(2019, 1:3, c(NA, 2, 3), c(3, 4, NA))
  expect_identical(is.na(x), c(TRUE, FALSE, TRUE))
})

# ------------------------------------------------------------------------------
# vec_ptype()

test_that("ptype is correct", {
  base <- year_month_weekday(1)
  ptype <- year_month_weekday(integer())

  for (precision in precision_names()) {
    if (precision == "quarter" || precision == "week") {
      next
    }

    x <- calendar_widen(base, precision)
    expect <- calendar_widen(ptype, precision)

    expect_identical(vec_ptype(x), expect)
  }
})

# ------------------------------------------------------------------------------
# vec_proxy() / vec_restore()

test_that("proxy is a data frame", {
  expect_identical(vec_proxy(year_month_weekday(2019)), data_frame(year = 2019L))
  expect_identical(vec_proxy(year_month_weekday(2019, 1)), data_frame(year = 2019L, month = 1L))
})

test_that("proxy has names on `year`", {
  x <- set_names(year_month_weekday(2019, 1), "nm")
  year <- vec_proxy(x)$year
  expect_named(year, "nm")
})

test_that("restore works", {
  to <- year_month_weekday(2019, 1:5)
  proxy <- vec_slice(vec_proxy(to), 1:2)
  expect_identical(vec_restore(proxy, to), year_month_weekday(2019, 1:2))
})

# ------------------------------------------------------------------------------
# vec_proxy_compare()

test_that("can compare with year / month precision", {
  expect_identical(
    year_month_weekday(2019) > year_month_weekday(2018:2020),
    c(TRUE, FALSE, FALSE)
  )
  expect_identical(
    year_month_weekday(2019, 2) > year_month_weekday(2019, 1:3),
    c(TRUE, FALSE, FALSE)
  )
})

test_that("cannot compare / sort with day precision or finer", {
  x <- year_month_weekday(2019, 1, 1, 1)

  expect_snapshot_error(x > x)
  expect_snapshot_error(vec_order(x))
})

# ------------------------------------------------------------------------------
# vec_ptype_full()

test_that("full ptype is correct", {
  expect_snapshot_output(vec_ptype_full(year_month_weekday(2019)))
  expect_snapshot_output(vec_ptype_full(year_month_weekday(2019, 1, 1, 2)))
  expect_snapshot_output(vec_ptype_full(year_month_weekday(2019, 1, 1, 2, 1, 1, 1, 1, subsecond_precision = "nanosecond")))
  expect_snapshot_output(vec_ptype_full(year_month_weekday(2019, 1, 1, 5)))
})

# ------------------------------------------------------------------------------
# vec_ptype_abbr()

test_that("abbreviated ptype is correct", {
  expect_snapshot_output(vec_ptype_abbr(year_month_weekday(2019)))
  expect_snapshot_output(vec_ptype_abbr(year_month_weekday(2019, 1, 1, 2)))
  expect_snapshot_output(vec_ptype_abbr(year_month_weekday(2019, 1, 1, 2, 1, 1, 1, 1, subsecond_precision = "nanosecond")))
  expect_snapshot_output(vec_ptype_abbr(year_month_weekday(2019, 1, 1, 5)))
})

# ------------------------------------------------------------------------------
# as.character()

test_that("as.character() works", {
  x <- year_month_weekday(2019, 1)
  y <- year_month_weekday(2019, 1, 2, 1)

  expect_identical(as.character(x), format(x))
  expect_identical(as.character(y), format(y))
})

# ------------------------------------------------------------------------------
# calendar_narrow()

test_that("can narrow to month", {
  x_expect <- year_month_weekday(2019, 2)
  x <- set_day(x_expect, 1, index = 2)
  expect_identical(calendar_narrow(x, "month"), x_expect)
  expect_identical(calendar_narrow(x_expect, "month"), x_expect)
})

test_that("can narrow to day", {
  x_expect <- year_month_weekday(2019, 2, 3, 2)
  x <- set_hour(x_expect, 5)
  expect_identical(calendar_narrow(x, "day"), x_expect)
  expect_identical(calendar_narrow(x_expect, "day"), x_expect)
})

# ------------------------------------------------------------------------------
# calendar_widen()

test_that("can widen to month", {
  x <- year_month_weekday(2019)
  expect_identical(calendar_widen(x, "month"), set_month(x, 1))
})

test_that("can widen to day", {
  x <- year_month_weekday(2019)
  y <- year_month_weekday(2019, 02)
  expect_identical(calendar_widen(x, "day"), set_day(set_month(x, 1), 1, index = 1))
  expect_identical(calendar_widen(y, "day"), set_day(y, 1, index = 1))
})

# ------------------------------------------------------------------------------
# calendar_month_factor()

test_that("can get a month factor", {
  expect_identical(
    calendar_month_factor(year_month_weekday(2019, 1:12)),
    factor(month.name, levels = month.name, ordered = TRUE)
  )
})

# ------------------------------------------------------------------------------
# seq()

test_that("only granular precisions are allowed", {
  expect_snapshot_error(seq(year_month_weekday(2019, 1, 1, 1), by = 1, length.out = 2))
})

# NOTE: Most tests are done by `year_month_day()` since they share an implementation
test_that("can generate a sequence", {
  expect_identical(seq(year_month_day(2019, 1), to = year_month_day(2019, 6), by = 2), year_month_day(2019, c(1, 3, 5)))
})

# ------------------------------------------------------------------------------
# invalid_resolve()

test_that("strict mode can be activated", {
  local_options(clock.strict = TRUE)
  expect_snapshot_error(invalid_resolve(year_month_weekday(2019, 1, 1, 1)))
})

# can handle nonexistent times resulting from grouping

    Nonexistent time due to daylight saving time at location 1. Resolve nonexistent time issues by specifying the `nonexistent` argument.

# can't group by finer precisions

    Can't group at a precision (nanosecond) that is more precise than `x` (second).

# can't group by non-year-month-day precisions

    `precision` must be a valid precision for a 'year_month_day'.

# flooring can handle nonexistent times

    Nonexistent time due to daylight saving time at location 2. Resolve nonexistent time issues by specifying the `nonexistent` argument.

# `origin` is floored to the precision of `precision` with a potential warning before rounding

    Code
      date_floor(x, "day", origin = origin)
    Warning <clock_warning_invalid_rounding_origin>
      `origin` has been floored from 'second' precision to 'day' precision to match `precision`. This floor has lost information.
    Output
      [1] "1970-01-01 EST" "1970-01-02 EST"

# `origin` is validated

    `origin` must be a 'POSIXt'.

---

    `origin` must not be `NA` or an infinite date.

---

    `origin` must not be `NA` or an infinite date.

---

    `origin` must have length 1.

---

    `origin` must have the same time zone as `x`.

---

    `origin` must have the same time zone as `x`.

# can format date-times

    C: 20
    y: 18
    Y: 2018
    b: Dec
    h: Dec
    B: December
    m: 12
    d: 31
    a: Mon
    A: Monday
    w: 1
    g: 19
    G: 2019
    V: 01
    u: 1
    U: 52
    W: 53
    j: 365
    D: 12/31/18
    x: 12/31/18
    F: 2018-12-31
    H: 23
    I: 11
    M: 59
    S: 59
    p: PM
    R: 23:59
    T: 23:59:59
    X: 23:59:59
    r: 11:59:59 PM
    z: -0500
    Ez: -05:00
    Z: America/New_York
    c: Mon Dec 31 23:59:59 2018
    %: %

---

    C: 20
    y: 18
    Y: 2018
    b: déc.
    h: déc.
    B: décembre
    m: 12
    d: 31
    a: lun.
    A: lundi
    w: 1
    g: 19
    G: 2019
    V: 01
    u: 1
    U: 52
    W: 53
    j: 365
    D: 12/31/18
    x: 12/31/18
    F: 2018-12-31
    H: 23
    I: 11
    M: 59
    S: 59
    p: PM
    R: 23:59
    T: 23:59:59
    X: 23:59:59
    r: 11:59:59 PM
    z: -0500
    Ez: -05:00
    Z: America/New_York
    c: lun. déc. 31 23:59:59 2018
    %: %

# can resolve ambiguity and nonexistent times

    Nonexistent time due to daylight saving time at location 1. Resolve nonexistent time issues by specifying the `nonexistent` argument.

---

    Ambiguous time due to daylight saving time at location 1. Resolve ambiguous time issues by specifying the `ambiguous` argument.

# failure to parse throws a warning

    Code
      date_time_parse("foo", "America/New_York")
    Warning <clock_warning_parse_failures>
      Failed to parse 1 string at location 1. Returning `NA` at that location.
    Output
      [1] NA

# throws warning on failed parses

    Code
      date_time_parse_complete("foo")
    Warning <clock_warning_parse_failures>
      Failed to parse 1 string at location 1. Returning `NA` at that location.
    Output
      [1] NA

# abbrev - throws warning on failed parses

    Code
      date_time_parse_abbrev("foo", "America/New_York")
    Warning <clock_warning_parse_failures>
      Failed to parse 1 string at location 1. Returning `NA` at that location.
    Output
      [1] NA

# `ambiguous = x` retains the offset of `x` if applicable

    Ambiguous time due to daylight saving time at location 1. Resolve ambiguous time issues by specifying the `ambiguous` argument.

# `zone` is required

    `zone` is a required argument to `date_time_build()`.

# can handle invalid dates

    Invalid date found at location 2. Resolve invalid date issues by specifying the `invalid` argument.

# can handle nonexistent times

    Nonexistent time due to daylight saving time at location 1. Resolve nonexistent time issues by specifying the `nonexistent` argument.

# can handle ambiguous times

    Ambiguous time due to daylight saving time at location 1. Resolve ambiguous time issues by specifying the `ambiguous` argument.

# <posixt> op <duration>

    no applicable method for 'add_milliseconds' applied to an object of class "c('POSIXct', 'POSIXt')"

---

    no applicable method for 'add_milliseconds' applied to an object of class "c('POSIXlt', 'POSIXt')"

---

    <datetime<America/New_York>> * <duration<year>> is not permitted

---

    <POSIXlt<America/New_York>> * <duration<year>> is not permitted

# <duration> op <posixt>

    <duration<year>> - <datetime<America/New_York>> is not permitted
    Can't subtract a POSIXct/POSIXlt from a duration.

---

    <duration<year>> - <POSIXlt<America/New_York>> is not permitted
    Can't subtract a POSIXct/POSIXlt from a duration.

---

    no applicable method for 'add_milliseconds' applied to an object of class "c('POSIXct', 'POSIXt')"

---

    no applicable method for 'add_milliseconds' applied to an object of class "c('POSIXlt', 'POSIXt')"

---

    <duration<year>> * <datetime<America/New_York>> is not permitted

---

    <duration<year>> * <POSIXlt<America/New_York>> is not permitted


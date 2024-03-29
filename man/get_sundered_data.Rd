% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_sundered_data.R
\name{get_sundered_data}
\alias{get_sundered_data}
\title{Sunder the data, splitting it into 'pass' and 'fail' pieces}
\usage{
get_sundered_data(
  agent,
  type = c("pass", "fail", "combined"),
  pass_fail = c("pass", "fail"),
  id_cols = NULL
)
}
\arguments{
\item{agent}{An agent object of class \code{ptblank_agent}. It should have had
\code{\link[=interrogate]{interrogate()}} called on it, such that the validation steps were actually
carried out.}

\item{type}{The desired piece of data resulting from the splitting. Options
for returning a single table are \code{"pass"} (the default) and \code{"fail"}. Each
of these options return a single table with, in the \code{"pass"} case, only the
rows that passed across all validation steps (i.e., had no failing test
units in any part of a row for any validation step), or, the complementary
set of rows in the \code{"fail"} case. Providing \code{NULL} returns both of the
split data tables in a list (with the names of \code{"pass"} and \code{"fail"}). The
option \code{"combined"} applies a categorical (pass/fail) label (settable in
the \code{pass_fail} argument) in a new \code{.pb_combined} flag column. For this
case the ordering of rows is fully retained from the input table.}

\item{pass_fail}{A vector for encoding the flag column with 'pass' and 'fail'
values when \code{type = "combined"}. The default is \code{c("pass", "fail")} but
other options could be \code{c(TRUE, FALSE)}, \code{c(1, 0)}, or \code{c(1L, 0L)}.}

\item{id_cols}{An optional specification of one or more identifying columns.
When taken together, we can count on this single column or grouping of
columns to distinguish rows. If the table undergoing validation is not a
data frame or tibble, then columns need to be specified for \code{id_cols}.}
}
\value{
A list of table objects if \code{type} is \code{NULL}, or, a single table if a
\code{type} is given.
}
\description{
Validation of the data is one thing but, sometimes, you want to use the best
part of the input dataset for something else. The \code{get_sundered_data()}
function works with an agent object that has intel (i.e., post
\code{interrogate()}) and gets either the 'pass' data piece (rows with no failing
test units across all row-based validation functions), or, the 'fail' data
piece (rows with at least one failing test unit across the same series of
validations). As a final option, we can have emit all the data with a new
column (called \code{.pb_combined}) which labels each row as passing or failing
across validation steps. These labels are \code{"pass"} and \code{"fail"} by default
but their values can be easily customized.
}
\details{
There are some caveats to sundering. The validation steps considered for this
splitting has to be of the row-based variety (e.g., the \verb{col_vals_*()}
functions or \code{\link[=conjointly]{conjointly()}}, but not \code{rows_distinct()}). Furthermore,
validation steps that experienced evaluation issues during interrogation are
not considered, and, validation steps where \code{active = FALSE} will be
disregarded. The collection of validation steps that fulfill the above
requirements for sundering are termed in-consideration validation steps.

If using any \code{preconditions} for validation steps, we must ensure that all
in-consideration validation steps use the same specified \code{preconditions}
function. Put another way, we cannot split the target table using a
collection of in-consideration validation steps that use different forms of
the input table.
}
\section{Examples}{


Create a series of two validation steps focused on testing row values for
part of the \code{small_table} object. Then, use \code{\link[=interrogate]{interrogate()}} to put the
validation plan into action.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{agent <-
  create_agent(
    tbl = small_table \%>\%
      dplyr::select(a:f),
    label = "`get_sundered_data()`"
  ) \%>\%
  col_vals_gt(columns = vars(d), value = 1000) \%>\%
  col_vals_between(
    columns = vars(c),
    left = vars(a), right = vars(d),
    na_pass = TRUE
  ) \%>\%
  interrogate()
}\if{html}{\out{</div>}}

Get the sundered data piece that contains only rows that passed both
validation steps (the default piece). This yields 5 of 13 total rows.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{agent \%>\% get_sundered_data()
}\if{html}{\out{</div>}}

\preformatted{## # A tibble: 5 × 6
##       a b             c      d e     f    
##   <int> <chr>     <dbl>  <dbl> <lgl> <chr>
## 1     2 1-bcd-345     3  3423. TRUE  high 
## 2     3 5-egh-163     8 10000. TRUE  low  
## 3     2 5-jdo-903    NA  3892. FALSE mid  
## 4     4 2-dhe-923     4  3291. TRUE  mid  
## 5     1 3-dka-303    NA  2230. TRUE  high}


Get the complementary data piece: all of those rows that failed either of the
two validation steps. This yields 8 of 13 total rows.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{agent \%>\% get_sundered_data(type = "fail")
}\if{html}{\out{</div>}}

\preformatted{## # A tibble: 8 × 6
##       a b             c     d e     f    
##   <int> <chr>     <dbl> <dbl> <lgl> <chr>
## 1     6 8-kdg-938     3 2343. TRUE  high 
## 2     8 3-ldm-038     7  284. TRUE  low  
## 3     7 1-knw-093     3  843. TRUE  high 
## 4     4 5-boe-639     2 1036. FALSE low  
## 5     3 5-bce-642     9  838. FALSE high 
## 6     3 5-bce-642     9  838. FALSE high 
## 7     4 2-dmx-010     7  834. TRUE  low  
## 8     2 7-dmx-010     8  108. FALSE low}


We can get all of the input data returned with a flag column (called
\code{.pb_combined}). This is done by using \code{type = "combined"} and that rightmost
column will contain \code{"pass"} and \code{"fail"} values.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{agent \%>\% get_sundered_data(type = "combined")
}\if{html}{\out{</div>}}

\preformatted{## # A tibble: 13 × 7
##        a b             c      d e     f     .pb_combined
##    <int> <chr>     <dbl>  <dbl> <lgl> <chr> <chr>
##  1     2 1-bcd-345     3  3423. TRUE  high  pass
##  2     3 5-egh-163     8 10000. TRUE  low   pass
##  3     6 8-kdg-938     3  2343. TRUE  high  fail
##  4     2 5-jdo-903    NA  3892. FALSE mid   pass
##  5     8 3-ldm-038     7   284. TRUE  low   fail
##  6     4 2-dhe-923     4  3291. TRUE  mid   pass
##  7     7 1-knw-093     3   843. TRUE  high  fail
##  8     4 5-boe-639     2  1036. FALSE low   fail
##  9     3 5-bce-642     9   838. FALSE high  fail
## 10     3 5-bce-642     9   838. FALSE high  fail
## 11     4 2-dmx-010     7   834. TRUE  low   fail
## 12     2 7-dmx-010     8   108. FALSE low   fail
## 13     1 3-dka-303    NA  2230. TRUE  high  pass}


We can change the \code{"pass"} or \code{"fail"} text values to another type of coding
with the \code{pass_fail} argument. One possibility is \code{TRUE}/\code{FALSE}.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{agent \%>\%
  get_sundered_data(
    type = "combined",
    pass_fail = c(TRUE, FALSE)
  )
}\if{html}{\out{</div>}}

\preformatted{## # A tibble: 13 × 7
##        a b             c      d e     f     .pb_combined
##    <int> <chr>     <dbl>  <dbl> <lgl> <chr> <lgl>
##  1     2 1-bcd-345     3  3423. TRUE  high  TRUE
##  2     3 5-egh-163     8 10000. TRUE  low   TRUE
##  3     6 8-kdg-938     3  2343. TRUE  high  FALSE
##  4     2 5-jdo-903    NA  3892. FALSE mid   TRUE
##  5     8 3-ldm-038     7   284. TRUE  low   FALSE
##  6     4 2-dhe-923     4  3291. TRUE  mid   TRUE
##  7     7 1-knw-093     3   843. TRUE  high  FALSE
##  8     4 5-boe-639     2  1036. FALSE low   FALSE
##  9     3 5-bce-642     9   838. FALSE high  FALSE
## 10     3 5-bce-642     9   838. FALSE high  FALSE
## 11     4 2-dmx-010     7   834. TRUE  low   FALSE
## 12     2 7-dmx-010     8   108. FALSE low   FALSE
## 13     1 3-dka-303    NA  2230. TRUE  high  TRUE}


...and using \code{0} and \code{1} might be worthwhile in some situations.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{agent \%>\%
  get_sundered_data(
    type = "combined",
    pass_fail = 0:1
  )
}\if{html}{\out{</div>}}

\preformatted{## # A tibble: 13 × 7
##        a b             c      d e     f     .pb_combined
##    <int> <chr>     <dbl>  <dbl> <lgl> <chr>        <int>
##  1     2 1-bcd-345     3  3423. TRUE  high             0
##  2     3 5-egh-163     8 10000. TRUE  low              0
##  3     6 8-kdg-938     3  2343. TRUE  high             1
##  4     2 5-jdo-903    NA  3892. FALSE mid              0
##  5     8 3-ldm-038     7   284. TRUE  low              1
##  6     4 2-dhe-923     4  3291. TRUE  mid              0
##  7     7 1-knw-093     3   843. TRUE  high             1
##  8     4 5-boe-639     2  1036. FALSE low              1
##  9     3 5-bce-642     9   838. FALSE high             1
## 10     3 5-bce-642     9   838. FALSE high             1
## 11     4 2-dmx-010     7   834. TRUE  low              1
## 12     2 7-dmx-010     8   108. FALSE low              1
## 13     1 3-dka-303    NA  2230. TRUE  high             0}
}

\section{Function ID}{

8-3
}

\seealso{
Other Post-interrogation: 
\code{\link{all_passed}()},
\code{\link{get_agent_x_list}()},
\code{\link{get_data_extracts}()},
\code{\link{write_testthat_file}()}
}
\concept{Post-interrogation}

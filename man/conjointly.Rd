% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conjointly.R
\name{conjointly}
\alias{conjointly}
\alias{expect_conjointly}
\alias{test_conjointly}
\title{Perform multiple rowwise validations for joint validity}
\usage{
conjointly(
  x,
  ...,
  .list = list2(...),
  preconditions = NULL,
  segments = NULL,
  actions = NULL,
  step_id = NULL,
  label = NULL,
  brief = NULL,
  active = TRUE
)

expect_conjointly(
  object,
  ...,
  .list = list2(...),
  preconditions = NULL,
  threshold = 1
)

test_conjointly(
  object,
  ...,
  .list = list2(...),
  preconditions = NULL,
  threshold = 1
)
}
\arguments{
\item{x}{A data frame, tibble (\code{tbl_df} or \code{tbl_dbi}), Spark DataFrame
(\code{tbl_spark}), or, an \emph{agent} object of class \code{ptblank_agent} that is
created with \code{\link[=create_agent]{create_agent()}}.}

\item{...}{A collection one-sided formulas that consist of validation
functions that validate row units (the \verb{col_vals_*()} series), column
existence (\code{\link[=col_exists]{col_exists()}}), or column type (the \verb{col_is_*()} series). An
example of this is \verb{~ col_vals_gte(., vars(a), 5.5), ~ col_vals_not_null(., vars(b)}).}

\item{.list}{Allows for the use of a list as an input alternative to \code{...}.}

\item{preconditions}{An optional expression for mutating the input table
before proceeding with the validation. This can either be provided as a
one-sided R formula using a leading \code{~} (e.g.,
\code{~ . \%>\% dplyr::mutate(col = col + 10)} or as a function (e.g.,
\code{function(x) dplyr::mutate(x, col = col + 10)}. See the \emph{Preconditions}
section for more information.}

\item{segments}{An optional expression or set of expressions (held in a list)
that serve to segment the target table by column values. Each expression
can be given in one of two ways: (1) as column names, or (2) as a two-sided
formula where the LHS holds a column name and the RHS contains the column
values to segment on. See the \emph{Segments} section for more details on this.}

\item{actions}{A list containing threshold levels so that the validation step
can react accordingly when exceeding the set levels. This is to be created
with the \code{\link[=action_levels]{action_levels()}} helper function.}

\item{step_id}{One or more optional identifiers for the single or multiple
validation steps generated from calling a validation function. The use of
step IDs serves to distinguish validation steps from each other and provide
an opportunity for supplying a more meaningful label compared to the step
index. By default this is \code{NULL}, and \strong{pointblank} will automatically
generate the step ID value (based on the step index) in this case. One or
more values can be provided, and the exact number of ID values should (1)
match the number of validation steps that the validation function call will
produce (influenced by the number of \code{columns} provided), (2) be an ID
string not used in any previous validation step, and (3) be a vector with
unique values.}

\item{label}{An optional label for the validation step. This label appears in
the \emph{agent} report and for the best appearance it should be kept short.}

\item{brief}{An optional, text-based description for the validation step. If
nothing is provided here then an \emph{autobrief} is generated by the \emph{agent},
using the language provided in \code{\link[=create_agent]{create_agent()}}'s \code{lang} argument (which
defaults to \code{"en"} or English). The \emph{autobrief} incorporates details of the
validation step so it's often the preferred option in most cases (where a
\code{label} might be better suited to succinctly describe the validation).}

\item{active}{A logical value indicating whether the validation step should
be active. If the validation function is working with an \emph{agent}, \code{FALSE}
will make the validation step inactive (still reporting its presence and
keeping indexes for the steps unchanged). If the validation function will
be operating directly on data (no \emph{agent} involvement), then any step with
\code{active = FALSE} will simply pass the data through with no validation
whatsoever. Aside from a logical vector, a one-sided R formula using a
leading \code{~} can be used with \code{.} (serving as the input data table) to
evaluate to a single logical value. With this approach, the \strong{pointblank}
function \code{\link[=has_columns]{has_columns()}} can be used to determine whether to make a
validation step active on the basis of one or more columns existing in the
table (e.g., \code{~ . \%>\% has_columns(vars(d, e))}). The default for \code{active}
is \code{TRUE}.}

\item{object}{A data frame, tibble (\code{tbl_df} or \code{tbl_dbi}), or Spark
DataFrame (\code{tbl_spark}) that serves as the target table for the expectation
function or the test function.}

\item{threshold}{A simple failure threshold value for use with the
expectation (\code{expect_}) and the test (\code{test_}) function variants. By
default, this is set to \code{1} meaning that any single unit of failure in data
validation results in an overall test failure. Whole numbers beyond \code{1}
indicate that any failing units up to that absolute threshold value will
result in a succeeding \strong{testthat} test or evaluate to \code{TRUE}. Likewise,
fractional values (between \code{0} and \code{1}) act as a proportional failure
threshold, where \code{0.15} means that 15 percent of failing test units results
in an overall test failure.}
}
\value{
For the validation function, the return value is either a
\code{ptblank_agent} object or a table object (depending on whether an agent
object or a table was passed to \code{x}). The expectation function invisibly
returns its input but, in the context of testing data, the function is
called primarily for its potential side-effects (e.g., signaling failure).
The test function returns a logical value.
}
\description{
The \code{conjointly()} validation function, the \code{expect_conjointly()} expectation
function, and the \code{test_conjointly()} test function all check whether test
units at each index (typically each row) all pass multiple validations. We
can use validation functions that validate row units (the \verb{col_vals_*()}
series), check for column existence (\code{\link[=col_exists]{col_exists()}}), or validate column type
(the \verb{col_is_*()} series). Because of the imposed constraint on the allowed
validation functions, the ensemble of test units are either comprised rows of
the table (after any common \code{preconditions} have been applied) or are single
test units (for those functions that validate columns).

Each of the functions used in a \code{conjointly()} validation step (composed
using multiple validation function calls) ultimately perform a rowwise test
of whether all sub-validations reported a \emph{pass} for the same test units. In
practice, an example of a joint validation is testing whether values for
column \code{a} are greater than a specific value while adjacent values in column
\code{b} lie within a specified range. The validation functions to be part of the
conjoint validation are to be supplied as one-sided \strong{R} formulas (using a
leading \code{~}, and having a \code{.} stand in as the data object). The validation
function can be used directly on a data table or with an \emph{agent} object
(technically, a \code{ptblank_agent} object) whereas the expectation and test
functions can only be used with a data table.
}
\section{Column Names}{

If providing multiple column names in any of the supplied validation steps,
the result will be an expansion of sub-validation steps to that number of
column names. Aside from column names in quotes and in \code{vars()},
\strong{tidyselect} helper functions are available for specifying columns. They
are: \code{starts_with()}, \code{ends_with()}, \code{contains()}, \code{matches()}, and
\code{everything()}.
}

\section{Preconditions}{

Providing expressions as \code{preconditions} means \strong{pointblank} will preprocess
the target table during interrogation as a preparatory step. It might happen
that a particular validation requires a calculated column, some filtering of
rows, or the addition of columns via a join, etc. Especially for an
\emph{agent}-based report this can be advantageous since we can develop a large
validation plan with a single target table and make minor adjustments to it,
as needed, along the way.

The table mutation is totally isolated in scope to the validation step(s)
where \code{preconditions} is used. Using \strong{dplyr} code is suggested here since
the statements can be translated to SQL if necessary (i.e., if the target
table resides in a database). The code is most easily supplied as a one-sided
\strong{R} formula (using a leading \code{~}). In the formula representation, the \code{.}
serves as the input data table to be transformed (e.g., \code{~ . \%>\% dplyr::mutate(col_b = col_a + 10)}). Alternatively, a function could instead
be supplied (e.g., \code{function(x) dplyr::mutate(x, col_b = col_a + 10)}).
}

\section{Segments}{

By using the \code{segments} argument, it's possible to define a particular
validation with segments (or row slices) of the target table. An optional
expression or set of expressions that serve to segment the target table by
column values. Each expression can be given in one of two ways: (1) as column
names, or (2) as a two-sided formula where the LHS holds a column name and
the RHS contains the column values to segment on.

As an example of the first type of expression that can be used,
\code{vars(a_column)} will segment the target table in however many unique values
are present in the column called \code{a_column}. This is great if every unique
value in a particular column (like different locations, or different dates)
requires it's own repeating validation.

With a formula, we can be more selective with which column values should be
used for segmentation. Using \code{a_column ~ c("group_1", "group_2")} will
attempt to obtain two segments where one is a slice of data where the value
\code{"group_1"} exists in the column named \code{"a_column"}, and, the other is a
slice where \code{"group_2"} exists in the same column. Each group of rows
resolved from the formula will result in a separate validation step.

If there are multiple \code{columns} specified then the potential number of
validation steps will be \code{m} columns multiplied by \code{n} segments resolved.

Segmentation will always occur after \code{preconditions} (i.e., statements that
mutate the target table), if any, are applied. With this type of one-two
combo, it's possible to generate labels for segmentation using an expression
for \code{preconditions} and refer to those labels in \code{segments} without having to
generate a separate version of the target table.
}

\section{Actions}{

Often, we will want to specify \code{actions} for the validation. This argument,
present in every validation function, takes a specially-crafted list
object that is best produced by the \code{\link[=action_levels]{action_levels()}} function. Read that
function's documentation for the lowdown on how to create reactions to
above-threshold failure levels in validation. The basic gist is that you'll
want at least a single threshold level (specified as either the fraction of
test units failed, or, an absolute value), often using the \code{warn_at}
argument. This is especially true when \code{x} is a table object because,
otherwise, nothing happens. For the \verb{col_vals_*()}-type functions, using
\code{action_levels(warn_at = 0.25)} or \code{action_levels(stop_at = 0.25)} are good
choices depending on the situation (the first produces a warning when a
quarter of the total test units fails, the other \code{stop()}s at the same
threshold level).
}

\section{Briefs}{

Want to describe this validation step in some detail? Keep in mind that this
is only useful if \code{x} is an \emph{agent}. If that's the case, \code{brief} the agent
with some text that fits. Don't worry if you don't want to do it. The
\emph{autobrief} protocol is kicked in when \code{brief = NULL} and a simple brief will
then be automatically generated.
}

\section{YAML}{

A \strong{pointblank} agent can be written to YAML with \code{\link[=yaml_write]{yaml_write()}} and the
resulting YAML can be used to regenerate an agent (with \code{\link[=yaml_read_agent]{yaml_read_agent()}})
or interrogate the target table (via \code{\link[=yaml_agent_interrogate]{yaml_agent_interrogate()}}). When
\code{conjointly()} is represented in YAML (under the top-level \code{steps} key as a
list member), the syntax closely follows the signature of the validation
function. Here is an example of how a complex call of \code{conjointly()} as a
validation step is expressed in R code and in the corresponding YAML
representation.

R statement:

\if{html}{\out{<div class="sourceCode r">}}\preformatted{agent \%>\% 
  conjointly(
    ~ col_vals_lt(., columns = vars(a), value = 8),
    ~ col_vals_gt(., columns = vars(c), value = vars(a)),
    ~ col_vals_not_null(., columns = vars(b)),
    preconditions = ~ . \%>\% dplyr::filter(a < 10),
    segments = b ~ c("group_1", "group_2"),
    actions = action_levels(warn_at = 0.1, stop_at = 0.2), 
    label = "The `conjointly()` step.",
    active = FALSE
  )
}\if{html}{\out{</div>}}

YAML representation:

\if{html}{\out{<div class="sourceCode yaml">}}\preformatted{steps:
- conjointly:
    fns:
    - ~col_vals_lt(., columns = vars(a), value = 8)
    - ~col_vals_gt(., columns = vars(c), value = vars(a))
    - ~col_vals_not_null(., columns = vars(b))
    preconditions: ~. \%>\% dplyr::filter(a < 10)
    segments: b ~ c("group_1", "group_2")
    actions:
      warn_fraction: 0.1
      stop_fraction: 0.2
    label: The `conjointly()` step.
    active: false
}\if{html}{\out{</div>}}

In practice, both of these will often be shorter as only the expressions for
validation steps are necessary. Arguments with default values won't be
written to YAML when using \code{\link[=yaml_write]{yaml_write()}} (though it is acceptable to include
them with their default when generating the YAML by other means). It is also
possible to preview the transformation of an agent to YAML without any
writing to disk by using the \code{\link[=yaml_agent_string]{yaml_agent_string()}} function.
}

\section{Examples}{


For all examples here, we'll use a simple table with three numeric columns
(\code{a}, \code{b}, and \code{c}). This is a very basic table but it'll be more useful when
explaining things later.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{tbl <-
  dplyr::tibble(
    a = c(5, 2, 6),
    b = c(3, 4, 6),
    c = c(9, 8, 7)
  )
  
tbl
#> # A tibble: 3 x 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     5     3     9
#> 2     2     4     8
#> 3     6     6     7
}\if{html}{\out{</div>}}
\subsection{A: Using an \code{agent} with validation functions and then \code{interrogate()}}{

Validate a number of things on a row-by-row basis using validation functions
of the \verb{col_vals*} type (all have the same number of test units): (1) values
in \code{a} are less than \code{8}, (2) values in \code{c} are greater than the adjacent
values in \code{a}, and (3) there aren't any NA values in \code{b}. We'll determine if
this validation has any failing test units (there are 3 test units, one for
each row).

\if{html}{\out{<div class="sourceCode r">}}\preformatted{agent <-
  create_agent(tbl = tbl) \%>\%
  conjointly(
    ~ col_vals_lt(., columns = vars(a), value = 8),
    ~ col_vals_gt(., columns = vars(c), value = vars(a)),
    ~ col_vals_not_null(., columns = vars(b))
    ) \%>\%
  interrogate()
}\if{html}{\out{</div>}}

Printing the \code{agent} in the console shows the validation report in the
Viewer. Here is an excerpt of validation report, showing the single entry
that corresponds to the validation step demonstrated here.

\if{html}{
\out{
<img src="https://raw.githubusercontent.com/rich-iannone/pointblank/main/images/man_conjointly_1.png" alt="This image was generated from the first code example in the `conjointly()` help file." style="width:100\%;">
}
}

What's going on? Think of there being three parallel validations, each
producing a column of \code{TRUE} or \code{FALSE} values (\code{pass} or \code{fail}) and line
them up side-by-side, any rows with any \code{FALSE} values results in a conjoint
\code{fail} test unit.
}

\subsection{B: Using the validation function directly on the data (no \code{agent})}{

This way of using validation functions acts as a data filter. Data is passed
through but should \code{stop()} if there is a single test unit failing. The
behavior of side effects can be customized with the \code{actions} option.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{tbl \%>\%
  conjointly(
    ~ col_vals_lt(., columns = vars(a), value = 8),
    ~ col_vals_gt(., columns = vars(c), value = vars(a)),
    ~ col_vals_not_null(., columns = vars(b))
  )
#> # A tibble: 3 x 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     5     3     9
#> 2     2     4     8
#> 3     6     6     7
}\if{html}{\out{</div>}}
}

\subsection{C: Using the expectation function}{

With the \verb{expect_*()} form, we would typically perform one validation at a
time. This is primarily used in \strong{testthat} tests.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{expect_conjointly(
  tbl,
  ~ col_vals_lt(., columns = vars(a), value = 8),
  ~ col_vals_gt(., columns = vars(c), value = vars(a)),
  ~ col_vals_not_null(., columns = vars(b))
)
}\if{html}{\out{</div>}}
}

\subsection{D: Using the test function}{

With the \verb{test_*()} form, we should get a single logical value returned to
us.

\if{html}{\out{<div class="sourceCode r">}}\preformatted{tbl \%>\%
  test_conjointly(
    ~ col_vals_lt(., columns = vars(a), value = 8),
    ~ col_vals_gt(., columns = vars(c), value = vars(a)),
    ~ col_vals_not_null(., columns = vars(b))
  )
#> [1] TRUE
}\if{html}{\out{</div>}}
}
}

\section{Function ID}{

2-34
}

\seealso{
Other validation functions: 
\code{\link{col_count_match}()},
\code{\link{col_exists}()},
\code{\link{col_is_character}()},
\code{\link{col_is_date}()},
\code{\link{col_is_factor}()},
\code{\link{col_is_integer}()},
\code{\link{col_is_logical}()},
\code{\link{col_is_numeric}()},
\code{\link{col_is_posix}()},
\code{\link{col_schema_match}()},
\code{\link{col_vals_between}()},
\code{\link{col_vals_decreasing}()},
\code{\link{col_vals_equal}()},
\code{\link{col_vals_expr}()},
\code{\link{col_vals_gte}()},
\code{\link{col_vals_gt}()},
\code{\link{col_vals_in_set}()},
\code{\link{col_vals_increasing}()},
\code{\link{col_vals_lte}()},
\code{\link{col_vals_lt}()},
\code{\link{col_vals_make_set}()},
\code{\link{col_vals_make_subset}()},
\code{\link{col_vals_not_between}()},
\code{\link{col_vals_not_equal}()},
\code{\link{col_vals_not_in_set}()},
\code{\link{col_vals_not_null}()},
\code{\link{col_vals_null}()},
\code{\link{col_vals_regex}()},
\code{\link{col_vals_within_spec}()},
\code{\link{row_count_match}()},
\code{\link{rows_complete}()},
\code{\link{rows_distinct}()},
\code{\link{serially}()},
\code{\link{specially}()},
\code{\link{tbl_match}()}
}
\concept{validation functions}

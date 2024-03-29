% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helper_calculators.R
\name{create_mix_calc_sample_row}
\alias{create_mix_calc_sample_row}
\title{Mixture Response Calculator Wrapper for Manuscript, matched index}
\usage{
create_mix_calc_sample_row(idx, par_list, add_RE = TRUE)
}
\arguments{
\item{idx}{Specifies which clustering to apply to the parameters}

\item{par_list}{a data frame with individual chemical dose response
parameters}

\item{add_RE}{boolean to include or exclude random effect variances}
}
\value{
a function to take a concentration vector as input and response as
output
}
\description{
A slight variation on the standard create_mix_calc, the parameters are still
sampled from the posterior MCMC but they are sampled with a single index so
that the set of parameters is feasible. Sampling all the parameters randomly
could cause an issue when there is non-identifiability, and an extreme value
in one parameter is not offset by a small value in another parameter.
}

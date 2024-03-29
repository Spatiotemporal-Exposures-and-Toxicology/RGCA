% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RE_nimble.R
\name{run_RE_nimble}
\alias{run_RE_nimble}
\title{Nimble MCMC script to fit the manuscript model to the Tox21 data.}
\usage{
run_RE_nimble()
}
\value{
nimble_samples: a list of MCMC chains with an entry for each
parameter of the model.
}
\description{
Fit a random effect dose response model using Nimble for fast MCMC.  Nimble
creates a compiled sampler that can run iterations much faster than the
manually implemented version.
}

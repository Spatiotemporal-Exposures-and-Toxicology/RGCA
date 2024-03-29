% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helper_calculators.R
\name{compute_mixpred_scores}
\alias{compute_mixpred_scores}
\title{Compute Scores for Mixture Predictions}
\usage{
compute_mixpred_scores(mix_df, mix_idx, unplotted_repl, curve_data_list)
}
\arguments{
\item{mix_df}{data frame with the observed mixture responses}

\item{mix_idx}{integer index specifying which observed data should be used}

\item{unplotted_repl}{integer indices specifying additional observed values
to plot}

\item{curve_data_list}{list of vectors where each vector is a predicted
curve.  List length matches the number of methods used to make predictions.}
}
\value{
a vector of scores with scores grouped by method.  If there are two
methods and three scores, the output would have the form (M1S1, M1S2, M1S3,
M2S1, M2S2, M2S3).
}
\description{
Computes the log likelihood, mean square error, and continuous rank
probability score for predictions of the mixture response compared to the
observed mixture response.
}

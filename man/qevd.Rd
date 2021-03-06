% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extremes.R
\name{qevd}
\alias{qevd}
\title{Quantile calculation}
\usage{
qevd(p, location = NULL, scale = NULL, shape = NULL,
  threshold = NULL, model = c("gev", "gpd"), lower.tail = TRUE,
  silent = FALSE)
}
\arguments{
\item{p}{(Numeric) probability vector.}

\item{location}{Of the GEV distribution. Default = NULL.}

\item{scale}{Of the GEV/GP distribution. Default = NULL.}

\item{shape}{Of the GEV/GP distribution. Default = NULL.}

\item{threshold}{Used in the GP distribution. This parameter is
optional but should be provided in order to create a
representation of the fitted data exceedance. Default = NULL.}

\item{model}{String determining whether to calculate the initial
parameters of the GEV ("gev") or GP ("gpd") function. Default =
"gev"}

\item{lower.tail}{Whether to sample the probabilities P[X <= x] or
P[X > x]. Default = TRUE (first case).}

\item{silent}{Whether to display warnings or not. Default = FALSE.}
}
\value{
Numerical vector of the same length as input argument p.
}
\description{
Calculates the quantile of either the GEV or the GP
  distribution
}
\details{
Port from the \pkg{extRemes} package to (again) get rid
  of the \strong{threshold} argument to be able to have an
  separate \code{\link{threshold}} function outside of the fitting
  function.
}
\seealso{
Other extremes: \code{\link{block.list}},
  \code{\link{block.xts}}, \code{\link{block}},
  \code{\link{decluster.list}},
  \code{\link{decluster.xts}}, \code{\link{decluster}},
  \code{\link{extremal.index}}, \code{\link{gev.density}},
  \code{\link{gpd.density}},
  \code{\link{return.level.climex.fit.gev}},
  \code{\link{return.level.climex.fit.gpd}},
  \code{\link{return.level.list}},
  \code{\link{return.level.numeric}},
  \code{\link{return.level}}, \code{\link{revd}},
  \code{\link{rlevd}}, \code{\link{threshold.list}},
  \code{\link{threshold.xts}}, \code{\link{threshold}},
  \code{\link{upper.limit.climex.fit.gev}},
  \code{\link{upper.limit.climex.fit.gpd}},
  \code{\link{upper.limit.list}},
  \code{\link{upper.limit.numeric}},
  \code{\link{upper.limit}}
}
\author{
Philipp Mueller
}
\concept{extremes}

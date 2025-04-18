% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kayaFractions.R
\name{kayaFractions}
\alias{kayaFractions}
\title{kayaFractions}
\usage{
kayaFractions(data, driverNames = NULL, fixTimeSteps = FALSE)
}
\arguments{
\item{data}{MAgPIE object with target variable and variables to calculate drivers. Needs to have the target variable
as first column in the data dimension, and the variables to calculate the drivers in the following columns. I.e.
getItems(data, dim = 3) should return c(t, d1, d2, ..., dn). If decomposition is to be calculated for multiple
scenarios, the data object can have a scenario dimension in 3.2.}

\item{driverNames}{Names of the drivers in the data object. If NULL, names of the drivers are set based on the names
of the variables d1, d2, ..., dn in the data object (i.e. "d2/d1", "d3/d2", ..., "t/dn"). Name of the target variable
is always kept as provided in the data object. Default is NULL.}

\item{fixTimeSteps}{Logical. For a consistent decomposition, the time steps in the data object need to be of equal
length. If fixTimeSteps is TRUE, the function will check if the time steps are of equal length and if not, will
interpolate the data linearly to have equal time steps. If fixTimeSteps is FALSE, the function will only throw a
warning if the time steps are not of equal length. Default is TRUE.}
}
\value{
The function returns a magpie object containing the target variable t and the drivers of the target variable
}
\description{
Calculates the elements t, d1, d2/d1, ..., dn/dn-1, t/dn in a kaya-like identity of the form
t = d1 * d2/d1 * ... * dn/dn-1 * t/dn, based on the variables t, d1, d2, ..., dn.
}
\examples{
\dontrun{
data <- new.magpie(cells_and_regions = c("EUR", "SSA", "USA", "LAM", "IND", "OAS"),
                   years = c(2000, 2005, 2010),
                   names = as.vector(outer(c("Area", "Population", "Supply"),
                                           c("SSP1", "SSP2"), paste, sep = ".")),
                   sets = c("Region", "Year", "Variable", "Scenario"), fill = runif(108))
kayaFractions(data)
}

}
\seealso{
\code{\link{kayaLaspeyres}}
}
\author{
Debbora Leip
}

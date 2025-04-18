#' harvested_area_timber
#'
#' Reads wood harvest area separated by source (primforest,
#' secdforest, forestry, other) and age classes from a gdx.
#' The data is on cluster level and the unit is Mha per year.
#'
#' @param gdx A fulldata.gdx of a magpie run, usually with endogenous forestry enabled
#' @param file a file name the output should be written to using write.magpie
#' @param level Level of regional aggregation; "cell", "reg" (regional), "glo"
#' (global), "regglo" (regional and global) or any secdforest aggregation
#' level defined in superAggregate
#' @param aggregateAgeClasses If TRUE, age classes are aggregated
#' @param annualized If TRUE, Mha per year. If FALSE, Mha per time step
#' @return Area harvested for wood in Mha per year (annualized = TRUE) or
#' Mha per time step (annualized = FALSE) as a magpie object
#'
#' @author Abhijeet Mishra, Pascal Sauer, Florian Humpenoeder
#' @export
harvested_area_timber <- function(gdx, # nolint: object_name_linter.
                                  file = NULL, level = "cell", aggregateAgeClasses = TRUE, annualized = TRUE) {
  x <- NULL
  if (as.numeric(readGDX(gdx, "s32_hvarea")) > 0 && as.numeric(readGDX(gdx, "s35_hvarea")) > 0) {
    forestry <- readGDX(gdx, "ov32_hvarea_forestry", "ov73_hvarea_forestry", "ov_hvarea_forestry",
                        select = list(type = "level"), react = "silent")
    secdforest <- readGDX(gdx, "ov35_hvarea_secdforest", "ov_hvarea_secdforest",
                          select = list(type = "level"), react = "silent")
    primforest <- readGDX(gdx, "ov35_hvarea_primforest", "ov_hvarea_primforest",
                          select = list(type = "level"), react = "silent")
    other <- readGDX(gdx, "ov35_hvarea_other", "ov73_hvarea_other", "ov_hvarea_other",
                     react = "silent", select = list(type = "level"))

    if (getSets(other, fulldim = FALSE)[[3]] == "othertype35.ac") {
      other <- dimSums(other, dim = "othertype35")
    }

    primforest <- add_dimension(primforest, add = "ac", nm = "primary")

    forestry <- add_dimension(forestry, add = "d3", nm = "Forestry")
    primforest <- add_dimension(primforest, add = "d3", nm = "Primary forest")
    secdforest <- add_dimension(secdforest, add = "d3", nm = "Secondary forest")
    other <- add_dimension(other, add = "d3", nm = "Other land")

    x <- mbind(forestry, secdforest, primforest, other)
    total <- dimSums(x, dim = "d3")
    total <- add_dimension(total, add = "d3", nm = "Total")
    x <- mbind(x, total)


    if (aggregateAgeClasses) {
      x <- dimSums(x, "ac")
    }

    if (annualized) {
      # convert from Mha to Mha yr-1
      periods <- timePeriods(gdx)
      if (dim(periods)[2] >= 2) {
        # cannot calculate length of first time step, assume it is equal to the second
        periods[, 1, ] <- as.vector(periods[1, 2, 1])
      } else {
        periods[, 1, ] <- 5
      }
      x <- x / periods
    }

    if (level != "cell") {
      x <- luscale::superAggregate(x, aggr_type = "sum", level = level, na.rm = FALSE)
    }
  } else {
    message("Disabled (no timber) ", appendLF = FALSE)
  }

  return(out(x, file))
}

#!/bin/bash

# Script to build an R package that includes Roxygen2 and Rcpp.

Rscript -e "devtools::create('myRPkg', rstudio = F)"
Rscript -e "devtools::use_gpl3_license(pkg = 'myRPkg')"
Rscript -e "devtools::use_package_doc(pkg = 'myRPkg')"

# Create an R function
echo "#' Add together two numbers.
#'
#' @param x A number.
#' @param y A number.
#' @return The sum of \code{x} and \code{y}.
#' @examples
#' add(1, 1)
#' add(10, 1)
#' @export
add <- function(x, y) {
  x + y
}
" >> myRPkg/R/add.R

Rscript -e "devtools::document(pkg = 'myRPkg')"

# You really should check this,
# but if you want to automate this leave it commented.
#R CMD build myRPkg
#R CMD check --as-cran myRPkg_0.0.0.9000.tar.gz
# Status: 1 NOTE
# New submission

# Add Rcpp
Rscript -e "devtools::use_rcpp(pkg = 'myRPkg')"

# Add lines the directions
perl -pi -e "s/NULL/\#' \@useDynLib myRPkg/g" myRPkg/R/myRPkg-package.r
echo "#' @importFrom Rcpp sourceCpp
NULL" >> myRPkg/R/myRPkg-package.r
Rscript -e "devtools::document(pkg = 'myRPkg')"

# Create an Rcpp function
echo "#include <Rcpp.h>
using namespace Rcpp;
//' Multiply a number by two
//'
//' @param x A single integer.
//' @export
// [[Rcpp::export]]
int timesTwo(int x) {
   return x * 2;
}" >> myRPkg/src/timesTwo.cpp

Rscript -e "devtools::document(pkg = 'myRPkg')"

R CMD build myRPkg
R CMD check --as-cran myRPkg_0.0.0.9000.tar.gz

# Install the package.
# R CMD INSTALL myRPkg_0.0.0.9000.tar.gz

# Uncomment to remove package.
# R CMD REMOVE myRPkg

# install.packages(path_to_file, repos = NULL, type="source")

# EOF

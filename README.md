# myRPkg
Build an R package that includes roxygen2 and Rcpp

I maintain an R package or two.
The R universe includes a lot of nice tools that perform 'magic' to help my job as a developer easier.
Sometimes, this magic breaks, which leaves me at a loss.
My best path forward involves creating a new, minimal, package and attempting to rebuild the package.
Because of the stated dependencies, this minimal package requires:

1. roxygen2
1. Rcpp

This repository describes how I build this minimal package.
I work at the `bash` shell instead of `R` because I'd like to automate this as much as possible.
My hope is that this will help me, and perhaps others, troubleshoot their package issues.
And if this goal is not met, it may help create a minimal reproducible example to post to a discussion group.

## Creating an R package that uses roxygen2

First we'll Create an R package that includes `roxygen2`.
We can use the package `devtools` to accomplish this.

```
Rscript -e "devtools::create('myRPkg', rstudio = F)"
Rscript -e "devtools::use_gpl3_license(pkg = 'myRPkg')"
Rscript -e "devtools::use_package_doc(pkg = 'myRPkg')"
```

Now we can create a simple function for our package.

```
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
```

Once we have added this funciton, we'll want to document it.
This will create the man page from the `roxygen2` comments and, because we've exported the function it should be added to our namespace.

```
Rscript -e "devtools::document(pkg = 'myRPkg')"
```

Now we should have an R package.
We can now build it and test it.

```
R CMD build myRPkg
R CMD check --as-cran myRPkg_0.0.0.9000.tar.gz
```

This should throw one 'NOTE' that raises our attention that this will be a new submission to CRAN.
We don't actually intend to submit this to CRAN, so we can ignore it.


## Adding Rcpp to the package

We can now add Rcpp to the package.

```
Rscript -e "devtools::use_rcpp(pkg = 'myRPkg')"
```

This command instructs us to add a few lines of code to the package.

```
perl -pi -e "s/NULL/\#' \@useDynLib myRPkg/g" myRPkg/R/myRPkg-package.r
echo "#' @importFrom Rcpp sourceCpp
NULL" >> myRPkg/R/myRPkg-package.r
```

And we were also asked to document the package again.

```
Rscript -e "devtools::document(pkg = 'myRPkg')"
```

We'll now want to create an Rcpp function.

```
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
```

We will have to document this new function.

```
Rscript -e "devtools::document(pkg = 'myRPkg')"
```

We should now have a package that uses roxygen2 and Rcpp.
We can build and check it.

```
R CMD build myRPkg
R CMD check --as-cran myRPkg_0.0.0.9000.tar.gz
```

## Install and remove the package

We can install the package from the command line.

```
R CMD INSTALL myRPkg_0.0.0.9000.tar.gz
```

We can also remove the package from the command line when we are done with it.

```
R CMD REMOVE myRPkg
```

A slightly more `R` flavor of this could also be used.

```
Rscript -e "install.packages('myRPkg_0.0.0.9000.tar.gz', repos = NULL, type='source')"
```

And remove.

```
Rscript -e "remove.packages('myRPkg')"
```

## Conclusion

We should now have a funcitonal R package that uses `roxygen2` and `Rcpp`.
The above process has been automated in the script `make_myRPkg.sh`.
However, if you encounter any issues you should step through the above directions.
We can now add functions that we are attempting to troubleshoot or make other modifications that may demonstrate issues.


## Build log

The `R` environment changes through time as packages, and their dependencies, are updated.
Here I'll try to maintain a log of dates when the above directions were successfull for building the package.

1. 2017-09-09 Created the directions, builds with one NOTE: New submission


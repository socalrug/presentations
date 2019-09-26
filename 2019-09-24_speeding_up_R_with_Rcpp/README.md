# Speeding up R with Rcpp

* 2019-09-24
* Speaker: Luke Klein

## Abstract

R is a beautiful and flexible language, and it is improving all the time. However, some processes (e.g. repeated function calls) can add a lot of computational overhead. Rcpp is a package for extending R with C++ functions which is utilized by over 1000 packages on CRAN. Many R data types and objects can be mapped back and forth to C++ equivalents which facilitates both writing new code for people just learning C++, as well as easier integration of third-party libraries. In this talk, I'll demonstrate how easy it is to get started with Rcpp and what kind of performance boosts one can achieve. If you're taking aim at levelling-up your function writing skills then Rcpp is the place to start.

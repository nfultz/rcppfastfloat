library(RcppFastFloat)
require(microbenchmark)
require(readr)
require(data.table)

N <- 1e6
set.seed(42)          # does not matter but ensure sample() shuffle fixed
invec <- sample(sqrt(seq(1:N)))
input <- c("foo", as.character(invec)) # first line is header

f <- tempfile()
writeLines(input, f)

# Below is needed to match signatures up, replace x with from
as.double2f <- as.double2
formals(as.double2f) <- alist(from=)
body(as.double2f)[[2]][[3]] <- quote(from)


setClass("double2")
setAs("character", "double2", as.double2f)

sims <- microbenchmark(
  base      = read.csv(f, header=TRUE, colClasses = "double"),
  base_d2   = read.csv(f, header=TRUE, colClasses = "double2"),
  tidy      = read_csv(f, col_names=TRUE, col_types = cols(col_double()), progress=FALSE),
  dt        = fread(f, header = TRUE, colClasses = "double"),
  dt_d2     = fread(f, header = TRUE, colClasses = "double2"),
  times=30
)

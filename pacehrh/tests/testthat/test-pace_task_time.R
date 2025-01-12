library(pacehrh)

withr::local_dir("..")

test_that("Populations: read sub-ranges", {
  e <- pacehrh:::GPE
  bve <- pacehrh:::BVE

  local_vars("populationLabels", envir = bve)

  testPop <- data.frame(Range = pacehrh:::GPE$ages,
                        Female = seq(1, length(pacehrh:::GPE$ages), 1),
                        Male = seq(1, length(pacehrh:::GPE$ages), 1) + 100)

  # Range = 0,1,2, ... 100
  # Female = 1,2,3, ... 99,100,101
  # Male = 101,102,103, ... 199,200,201

  dt <- data.table::data.table(
    Labels = c("label_1", "label_2", "label_3", "label_4", "-", "all"),
    Male = c(TRUE, TRUE, FALSE, TRUE, FALSE, TRUE),
    Female = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
    Start = c(0, 0, 15, 15, 0, NA),
    End = c(50, 100, 49, 49, 0, NA)
  )

  bve$populationLabels <- dt

  testthat::expect_false(is.null(bve$populationLabels))
  testthat::expect_warning(pacehrh:::.computeApplicablePopulation(testPop, "notalabel"))
  testthat::expect_equal(pacehrh:::.computeApplicablePopulation(testPop, "label_1"), sum(1:51) + sum(101:151))
  testthat::expect_equal(pacehrh:::.computeApplicablePopulation(testPop, "label_2"), sum(1:101) + sum(101:201))
  testthat::expect_equal(pacehrh:::.computeApplicablePopulation(testPop, "label_3"), sum(16:50))
  testthat::expect_equal(pacehrh:::.computeApplicablePopulation(testPop, "label_4"), sum(116:150))
  testthat::expect_equal(pacehrh:::.computeApplicablePopulation(testPop, "-"), 0)
  testthat::expect_equal(pacehrh:::.computeApplicablePopulation(testPop, "all"), sum(1:101) + sum(101:201))

  dt <- data.table::data.table(
    Labels = c("dup", "dup"),
    Male = c(TRUE, TRUE),
    Female = c(TRUE, TRUE),
    Start = c(0, 0),
    End = c(50, 100)
  )

  bve$populationLabels <- dt
  testthat::expect_warning(n <- pacehrh:::.computeApplicablePopulation(testPop, "dup"))
  testthat::expect_equal(n, sum(1:51) + sum(101:151))
})


test_that("Populations: read full ranges", {
  gpe <- pacehrh:::GPE
  bve <- pacehrh:::BVE

  local_vars("inputExcelFile", envir = gpe)
  local_vars("globalConfigLoaded", envir = gpe)
  local_vars("initialPopulation", envir = bve)
  local_vars("populationLabels", envir = bve)
  local_vars("populationRangesTable", envir = bve)

  gpe$inputExcelFile <- "./simple_config/super_simple_inputs.xlsx"
  gpe$globalConfigLoaded <- TRUE

  pacehrh::InitializePopulation()

  # Test for existence of Population Ranges Table
  testthat::expect_true(!is.null(pacehrh:::BVE$populationRangesTable))

  # Test that population range table entries consist entirely of zeroes and ones.)
  for (m in pacehrh:::BVE$populationRangesTable){
    apply(m, 1, function(r){
      testthat::expect_equal(length(setdiff(r, c(0,1))), 0)
    })
  }

  # Test the dimensions of the range tables
  testthat::expect_equal(dim(pacehrh:::BVE$populationRangesTable$Male)[2],
                         length(pacehrh:::GPE$ages))

  testthat::expect_equal(dim(pacehrh:::BVE$populationRangesTable$Female)[2],
                         length(pacehrh:::GPE$ages))


  # Generate fake population projection matrices

  e <- 0.1
  popInit <- 100
  l <- lapply(seq_along(gpe$years), function(i){
    return(rep(round(popInit * ((1 + e) ^ (i - 1)), 0), length(gpe$ages)))
  })

  mf <- do.call(cbind, l)
  rownames(mf) <- gpe$ages
  colnames(mf) <- gpe$years

  mm <- do.call(cbind, l)
  rownames(mf) <- gpe$ages
  colnames(mf) <- gpe$years





  m <- bve$populationRangesTable$Female
  v <- bve$initialPopulation$female@values
  # print(m)
  # print(v)
  # print(m %*% v)
  # print(t(t(m) * v))


  p <- pacehrh:::.computeApplicablePopulationVector()

  testthat::expect_equal(p, 42)

})



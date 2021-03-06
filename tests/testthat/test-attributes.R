context("Attributes functions")
test_session <- test_path("data/RWL_WFFArea_Long/001P00XA1/")
trials <- suppressMessages(Session(test_session))
trial <- trials[[1]]


test_that("Get correct number of items", {
  expect_equal(length(trial %@% "Subject"), 1)
  expect_equal(length(trial %@% "FakeAttribute"), 0)
  expect_equal(length(trials %@% "Subject"), length(trials))
  expect_equal(length(trials %@% "FakeAttribute"), length(trials))
})


test_that("Attributes that don't exist are NULL or a list of NULLs", {
  expect_null(trial %@% "Visited")
  expect_null(unlist(trials %@% "Visited"))
  expect_is((trials %@% "Visited"), "list")
  expect_null((trials %@% "Visited")[[1]])
})

test_that("try-getter handle normal and missing data", {
  expect_equal(length(trial %try@% "Subject"), 1)
  expect_equal(length(trial %try@% "FakeAttribute"), 1)
  expect_equal(length(trials %try@% "Subject"), length(trials))
  expect_equal(length(trials %try@% "FakeAttribute"), length(trials))
})


test_that("Single item assignment", {
  trial %@% "Visited" <- TRUE
  expect_true(trial %@% "Visited")
  trial <- SetAttribute(trial, "Visited", FALSE)
  expect_false(trial %@% "Visited")
})


test_that("Multiple assignment for TrialLists", {
  # Infix form
  trials %@% "Visited" <- TRUE
  expect_true(all(trials %@% "Visited"))
  expect_is(trials, "Session")

  # Function form
  trials <- SetAttribute(trials, "Visited", FALSE)
  expect_false(any(trials %@% "Visited"))
  expect_is(trials, "Session")
})


test_that("Values are recycled in multiple assignment", {
  # No recycling needed
  expect_equivalent(trials %@% "TrialNo", c(1:24, 1:24))
  trials %@% "TrialNo" <- 48:1
  expect_equivalent(trials %@% "TrialNo", 48:1)

  # Even recycling
  trials %@% "TrialNo" <- 1:24
  expect_equivalent(trials %@% "TrialNo", rep(1:24, 2))

  # Uneven recycling warns user
  expect_warning(trials %@% "TrialNo" <- 1:25)
  expect_equivalent(trials %@% "TrialNo", c(1:25, 1:23))
})


test_that("Gathering attributes into dataframes", {
  # An attribute that is only present on some objects
  trials[[1]] %@% "MaybeThere" <- 1
  trials[[2]] %@% "MaybeThere" <- numeric(0)

  # Input with some named attributes
  attrs <- c(Subj = "Subject", "TrialNo", "Fake", Maybe = "MaybeThere")
  results <- gather_attributes(trials, attrs)

  # Values stored correctly
  expect_equal(results$TrialNo, trials %@% "TrialNo")
  expect_equal(results$Subj, trials %@% "Subject")

  # Column names
  expect_equal(names(results), c("Subj", "TrialNo", "Fake", "Maybe"))

  # Input with one unnamed string
  results2 <- gather_attributes(trials, "Fake")
  expect_equal(names(results2), c("Fake"))

  # NA dropping
  results3 <- gather_attributes(trials, c("TrialNo", "Fake"), omit_na = TRUE)
  expect_equal(dim(results3), c(length(trials), 1))
  results4 <- gather_attributes(trials, "Fake", omit_na = TRUE)
  expect_equal(dim(results4), c(length(trials), 0))

})



test_that("Non TrialList getter/setter behaviors", {
  Cat <- function(name, owner) {
    structure(list(Name = name), Owner = owner, class = "cat")
  }

  kiki <- Cat("Kiki", "AML")
  nooper <- Cat("Nooper", "TJM")
  cats <- list(nooper, kiki)

  # Getting is vectorized
  expect_match(kiki %@% "Owner", "AML")
  expect_equivalent(cats %@% "Owner", c("TJM", "AML"))

  # Setting/overwriting an attribute works
  cats[[1]] %@% "Owner" <- NA
  expect_equivalent(cats %@% "Owner", c(NA, "AML"))

  # Assignment is not vectorized for non-TrialLists
  cats %@% "FavoriteOwner" <- "TJM"

  expect_null(cats[[1]] %@% "FavoriteOwner")
  expect_null(unlist(cats %@% "FavoriteOwner"))

  # Instead, the attribute is given to the whole list
  expect_match(attr(cats, "FavoriteOwner"), "TJM")
})

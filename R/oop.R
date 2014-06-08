# This is where we generic methods for LWL objects.


## Combine lists of Trials.
c.Session <- function(session, ...) {
  # Coerce session to a list and then call the c.list method on session and ...
  class(session) <- 'list'
  trials <- c(session, ...)
  
  # If there are multiple subjects, return a "Task".
  if (UniqueTask(trials)) {
    if (UniqueSubject(trials)) as.Session(trials) else as.Task(trials)
  } 
  # WE may need "else trials" if we ever want to combine trials with different
  # tasks.
}

# The checks inside c.Session should work for combining Task objects.
c.Task <- function(task, ...) c.Session(task, ...)

## Coerce a list of Trials into a Session or Task
as.Session <- function(x) {
  if (!is.Session(x)) class(x) <- c("Session", "list")
  x
}

as.Task <- function(x) {
  if (!is.Task(x)) class(x) <- c("Task", "list")
  x
}

#' @export
is.Session <- function(x) inherits(x, "Session")

#' @export
is.Task <- function(x) inherits(x, "Task")

#' @export
print.Trial <- function(trial, ...) str(trial, ...)

#' @export
print.Gazedata <- function(...) str(...)

#' @export
print.Stimdata <- function(...) str(...)


# Check whether trials should be a Task or Session object.
UniqueAttribute <- function(attr_name) { 
  function(trials) n_distinct(trials %@% attr_name) == 1
} 
UniqueTask <- UniqueAttribute("Task")
UniqueSubject <- UniqueAttribute("Subject")

n_distinct <- function(xs) length(unique(xs))
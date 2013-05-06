# The following functions load, reduce, and organize stimulus data from a `.txt`
# Eprime outputted by Eprime.




library(plyr)
library(stringr)
library(lubridate)
library(tools)





#' Open a stimulus log file outputted by Eprime
#' 
#' @param stimdata_path Either the full or relative path to the \code{.txt} file
#'   that is to be parsed.
#' @return the raw contents of the stimdata file. The basename of 
#'   \code{stimdata_path} is attached as an attribute called \code{"Basename"}.
#'   
#' @details 
#' Historically, we have had issues with the encoding of these .txt
#' files, so now we include some exception-handling measures. The procedure is
#' to first try to load the file with UCS-2 Little Endian encoding. If a warning
#' is encountered, the warning is muffled and the file is loaded again, this
#' time without specifying the encoding beforehand. If a warning is encountered
#' on this second attempt, it is printed to the console.
#' @export
LoadStimdataFile <- function(stimdata_path) {
  # A message with the filename is helpful.
  message(paste0("Reading stimdata in ", stimdata_path))
  
  # Initialize an empty warning object.
  warned <- NULL
  
  # Define the procedure to handle warnings: Store them and muffle them.
  HandleWarning <- function(w) { 
    warned <<- w
    invokeRestart("muffleWarning")    
  }
  
  # Read in a file connection using the warning handler. 
  con <- file(stimdata_path, open = 'rt', encoding = 'UCS-2LE')
  withCallingHandlers(stimlog <- readLines(con), warning = HandleWarning)
  close(con)
  
  # If a warning is caught, try connection again with no encoding specified.
  if (0 < length(warned)) {
    con <- file(stimdata_path, open = 'rt')
    stimlog <- readLines(con)
    close(con)
  }
  
  # Attach the original filename to the stimlog as an attribute.
  attr(stimlog, "Basename") <- basename(stimdata_path)
  
  stimlog
}




# Extract values of a given type from a stimdata file
# 
# `.GetValuesOfStimdataType` is a utility function for extracting from a 
# stimlog, the value of a given type of stimdata for each trial. This function 
# is curried so that `.GetValuesOfStimdataType(stimlog)` returns a function
# that can be applied to a vector of the names of the stimdata types.
# 
# @param stimlog A character vector whose elements are the lines of the 
#   stimlog.
# @param stimdataType A character string identifying the type of stimdata whose
#   value for each trial should be found.  E.g., 'Image1' is the stimdata type 
#   of the top left image in the Real Word Listening task.
# @return Either a character vector or numeric vector, each element of which is
#   the value of stimdataType for a trial.
# @examples
# ```
# # Single value extraction
# # onset_times <- .GetValuesOfStimdataType(stimlog)("Image2sec.OnsetTime")
# 
# # Multiple value extraction
# # image_names <- c("ImageL", "ImageR")
# # image_values <- Map(.GetValuesOfStimdataType(stimlog), image_names)
# ```
# @export
.GetValuesOfStimdataType <- function(stimlog) {  
  # Define the function that is returned once a stimlog argument is passed to
  # `.GetValuesOfStimdataType.`
  .LambdaStimdataType <- function(stimdata_type) {
    # The stimdata for each trial is logged using the following pattern:
    # `\t\t{stimdataType}: {value}`. Create a regular expression that can 
    # be used to find the line in each trial where `stimdataType` is logged.
    stim_pattern <- sprintf('\t*%s: ', stimdata_type)
    
    # Extract the lines of the stimlog where `stimdataType` is logged.
    stimlog_lines <- grep(stim_pattern, stimlog, value = TRUE)
    values <- sub(stim_pattern, '', stimlog_lines)
    return(values)
  } 
  return(.LambdaStimdataType)
}

# Wrapper for `.GetValuesOfStimdataType` that returns whether a value is
# present in `stimlog`
# @export
.CheckForStimdataType <- function(stimlog, stimdataType) {
  values <- .GetValuesOfStimdataType(stimlog)(stimdataType)
  found <- length(values) != 0
  return(found)
}






ExtractStim <- function(stim_config, stimlog) {
  # Get the values from the stimdata file
  stim <- stim_config$Stim
  parsed_stimlog <- Map(.GetValuesOfStimdataType(stimlog), stim)
  
  # If a stim field was not found in the stimdata file, it will have a length of
  # zero in the parsed stimlog. We drop those fields that weren't found. This 
  # avoids the error that comes from trying to combine the stim vectors of 
  # differing lengths into a dataframe (which is a collection of vectors of
  # equal length).
  lengths <- sapply(parsed_stimlog, length) 
  drops <- which(lengths == 0)
  
  if (length(drops) != 0) { 
    parsed_stimlog <- parsed_stimlog[-drops]
    # Warn the user
    warn_names <- paste(names(parsed_stimlog)[drops], collapse=", ")
    warn <- paste0("Empty stimdata fields: ", warn_names)
    warning(warn)
  }
  
  # Put the dataframe together
  stimdata <- data.frame(parsed_stimlog, stringsAsFactors = FALSE)
  
  # Add the constants
  for(constant in names(stim_config$Constants)) {
    # Using a for-loop because each iteration updates (side-effects) `stimdata`
    value <- stim_config$Constants[constant]  
    stimdata[, constant] <- value
  }
  
  # Convert number strings to numerics
  num_stim <- stim_config$Numerics
  stimdata[num_stim] <- lapply(stimdata[num_stim], as.numeric)
  
  # Compute derived column values
  skip <- is.null(stim_config$Derived)
  if(!skip) {
    exp <- parse(text = stim_config$Derived)
  }
  
  stimdata <- within(stimdata, {
    # Do nothing if there are no values to derive
    if(!skip) {
      for(ex in exp) eval(ex)
      rm(ex)  
    }
  })
  
  # Add trial numbers
  stimdata$TrialNo <- 1:nrow(stimdata)
  
  # Include the date and time of the block. `unique` because the date and time
  # are recorded twice (at the beginning and end of the experiment).
  date <- unique(.GetValuesOfStimdataType(stimlog)("SessionDate"))
  date <- mdy(date, quiet = TRUE)
  time <- unique(.GetValuesOfStimdataType(stimlog)("SessionTime"))
  time <- hms(time)
  stimdata$DateTime <- date + time  
  
  stimdata
}





#' Parse an LWL stimulus data file outputted by Eprime
#' 
#' \code{Stimdata} is used to read and parse the \code{.txt} file that is output
#' by E-prime during a session of a Looking While Listening experiment.
#' 
#' @param stimdata_path Either the full or relative path to the \code{.txt} file
#'   that is to be parsed.
#' @param output_file Either \code{NULL} or the path---full or relative---for 
#'   the output file. If \code{NULL}, then no output file is created. If a path 
#'   is specified, then the parsed stimdata is written out as a \code{.csv} 
#'   file. Default is \code{NULL}.
#' @return A dataframe containing the parsed stimdata.  Each row of the 
#'   dataframe is the stimdata for a single experimental trial.
#'   
#' @details 
#' A stimdata file in a Looking While Listening task file the naming 
#' convention: \code{[Task]_[BlockNo]_[SubjectID]}. The stimdata file is 
#' assigned a class based on the task in the filename, and then methods for 
#' extracting the stimdata are dispatched based on that class value. Valid task
#' names include "RWL", "MP", "Coartic" and "VisWorld".
#' 
#' @importFrom tools file_path_sans_ext
#' @export
Stimdata <- function(stimdata_path, outputFile = NULL) {  
  # Extract experiment information from the input file name
  file_info <- ParseFilename(stimdata_path)
  task <- file_info$Task
  
  # Load the stimdata file
  stimlog <- LoadStimdataFile(stimdata_path)
  class(stimlog) <- c(task, class(stimlog))
  
  # Determine the appropriate stimdata features and extract them.
  config <- DetermineStim(stimlog)
  stimdata <- ExtractStim(config, stimlog)
  
  # Finalize stimdata
  class(stimdata) <- c(task, "Stimdata", class(stimdata))
  stimdata <- FinalizeStimdata(stimdata)
  
  # Optionally write out stimdata as a tab-delimited table.
  if (!is.null(outputFile)) {
    write.table(stimdata, file = outputFile, sep = ',',
                quote = FALSE, row.names = FALSE)
  }
  
  stimdata
}



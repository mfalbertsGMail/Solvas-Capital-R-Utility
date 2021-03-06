# Style guide:
# 1. Variable names are all lower case use _ to separate words (i.e. day_one)
# 2. Functions names are camel case, verbs i.e. (FiInstrumentGet)
# 3. Functions (methods) associated with S3 classes follow the naming convention ClassName.FunctionName(class_object_instance,...)


#' DataAccess is a required object which always serves as the first parameter 
#' passed to any of the other functions.
#' 
#' @title DataAccess: da_obj to connect and interact with the Capital database
#' @examples
#' \dontrun{
#' connection_string = "Driver={Sql Server};server=(local);trusted_connection=True;database=Internal_Capital_DEV;"
#' sc_da <- DataAccess(connection_string_param=connection_string, fs_id_param=1)
#' DataAccess.FiInstrumentGet(sc_da, NULL, 1)
#' }
#' @param connection_string_param - The SQL Server connection string
#' @param fs_id_param - The scenario id
#' @export
DataAccess <- function(connection_string_param = "", fs_id_param = NULL)
{
  # save da_obj variables
  me <- list(
    connection = connection_string_param,
    fs_id = fs_id_param,
    # locals
    is_init = 0
  )

  # set name for class
  class(me) <- append(class(me), "DataAccess")
  return(me)
}


#' Returns the connection status 
#' 
#' Takes a DataAccess da_obj and returns "success" if the connection is 
#' working otherwise the error message is returned.
#' @param da_obj - Current instance of Solvas|Capital's DataAccess class.
#' @return connection status string "success" if connection is valid otherwise an error message is returned
#' @import RODBC
#' @export
DataAccess.ConnectionStatus <- function(da_obj) {
  return 
    tryCatch(
      {
        cn <- odbcDriverConnect(da_obj$connection)
        odbcClose(cn)
        "success"
      } ,  
      warning = function(cond) paste("ERROR:  ", cond),
      error = function(cond)  paste("ERROR:  ", cond)	  
    )
}

#' Get financial instruments
#' 
#' Takes a DataAccess da_obj and effective_date or effective_period and returns a DataTable
#' with the instruments.  Properties that are schedules are coalesced 
#' to a single value based on the effective_date or effective_period. 
#' NOTE: EITHER effective_date or effective_period must be populated, the other one must be NULL
#' @param da_obj - Current instance of Solvas|Capital's DataAccess class. 
#' @param effective_date - The date to use for schedule data types
#' @param effective_period - The period to use for schedule data types (1=first period)
#' @return Data frame containing the financial instrument data
#' @import RODBC
#' @export
DataAccess.FiInstrumentGet <- function(da_obj, effective_date = NULL, effective_period = NULL) {
 if (da_obj$is_init == 0)
    Solvas.Capital.SqlUtility::SPInstrumentPropertyLoad(da_obj$connection,da_obj$fs_id)
  da_obj$is_init = 1
  return(Solvas.Capital.SqlUtility::SPFIInstrumentGet(da_obj$connection,da_obj$fs_id, effective_date, effective_period))
}

#' Get economic assumptions
#' 
#' @param da_obj - Current instance of Solvas|Capital's DataAccess class.
#' @param tm_desc - description of transformation (i.e. '(apply to all)').  the first
#' transformation by sequence order will be used if NULL, if two or more transformations have the
#' same description an error message is returned
#' @param use_dates - if TRUE then matrix columns will be dates, else periods. default to false 
#' @export
DataAccess.FsAssumptionsGet <- function(da_obj, tm_desc = NULL, use_dates = FALSE) {
  return(Solvas.Capital.SqlUtility::SPFSAssumptionsGet(da_obj$connection, da_obj$fs_id, tm_desc = tm_desc, use_dates))
}
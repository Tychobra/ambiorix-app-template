

### Custom App Endpoints --------------------------------------------------------------------

#' @get /data
#'
#'
function(req, res) {
  
  if (is.null(req$user)) {
    res$status <- 401L
    res$json(list(
      message = "unauthorized"
    ))
    return(NULL)
  }

  out <- NULL
  err_out <- NULL
  tryCatch({
    
    out <- list(message  = "hi")

  }, error = function(err) {

    print("unable to get data")
    if (identical(res$status, 200L)) {
      res$status <- 500L
    }
    print(err)
    err_out <<- conditionMessage(err)

  })


  if (is.null(err_out)) {
    return(out)
  } else {
    return(list(
      message = unbox(err_out)
    ))
  }
}

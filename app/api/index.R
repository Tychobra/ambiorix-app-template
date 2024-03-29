

### Custom App Endpoints --------------------------------------------------------------------

api_router <- Router$new("/api")

api_router$get("/data", \(req, res) {
  
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
    
    out <- list(message  = unbox("hi"))

  }, error = function(err) {

    print("unable to get data")
    if (identical(res$status, 200L)) {
      res$status <- 500L
    }
    print(err)
    err_out <<- conditionMessage(err)

  })


  if (is.null(err_out)) {
    return(res$json(out))
  } else {
    return(res$json(list(
      message = unbox(err_out)
    )))
  }
})

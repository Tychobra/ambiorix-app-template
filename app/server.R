library(ambiorix)
library(dplyr)
library(dbplyr)
library(glue)
library(httr)
library(jsonlite)
library(pool)
library(RPostgres)
library(uuid)

my_serializer <- function(x, na = "null", ...) {
  return(jsonlite::toJSON(x, na = na, ...))
}

options(
  AMBIORIX_SERIALISER = my_serializer
)

parse_cookies <- function(x) {
  parts <- strsplit(x, ";", fixed = TRUE)[[1]]
  
  out <- list()  
  for (ck in parts) {
    hold <- strsplit(ck, "=", fixed = TRUE)[[1]]
    key <- trimws(hold[1])
    val <- trimws(hold[2])
    if (is.null(out[[key]])) {
      out[[key]] <- val
    }  
  }

  return(out)
}





env <- Sys.getenv("R_CONFIG_ACTIVE")

if (env == "production") {
  readRenviron(".env.production")
} else {
  readRenviron(".env.development")
}

db_conn <- dbPool(
  RPostgres::Postgres(),
  dbname = Sys.getenv("DB_NAME"),
  host = Sys.getenv("DB_HOST"),
  password = Sys.getenv("DB_PASSWORD"),
  user = Sys.getenv("DB_USER")
)

app <- Ambiorix$new(
  host = "0.0.0.0", 
  port = 8080L
)

app$get("/favicon.ico", \(req, res) {
  #res$status <- 404
  res$send(NULL)
})

app$use(\(req, res) {
  req$cookies <- parse_cookies(req$HTTP_COOKIE)
  return(NULL)
})

# auth middleware
app$use(\(req, res) {

  err_msg <- NULL
  req$user <- NULL

  # attempt to find session based on cookie
  polished_cookie <- req$cookies$polished
  
  if (is.null(polished_cookie)) {
    # cookie not set, so forward, but without setting user.
    # user will only be able to access public routes
    return(NULL)
  }
  
  tryCatch({

    db_session <- db_conn %>%
      tbl(in_schema("auth", "sessions")) %>%
      filter(cookie == polished_cookie) %>%
      left_join(
      select(tbl(db_conn, in_schema("auth", "users")), uid, email, is_admin, verification_code), 
      by = c("user_uid" = "uid")
    ) %>%
    collect()
    
    if (identical(nrow(db_session), 1L)) {
      req$user <- as.list(db_session)
      
      if (is.na(db_session$verification_code)) {
        req$user$is_verified <- TRUE
      } else {
        req$user$is_verified <- FALSE
      }
    }

    return(NULL)

  }, error = function(err) {

    err_msg <<- conditionMessage(err)
    warning(err_msg)

  })

  if (!is.null(err_msg)) {
    res$status <- 500
    res$send(toJSON(list(error = unbox(err_msg))))
  }
})


app$static("./assets", "assets")

index_page <- source("./pages/index.R", local = TRUE)$value
sign_in_page <- source("./pages/auth/sign_in.R", local = TRUE)$value
sign_in_link_page <- source("./pages/auth/sign_in_link.R", local = TRUE)$value
admin_page <- source("./pages/auth/admin.R", local = TRUE)$value
redirect_page <- source("./pages/redirect.R", local = TRUE)$value

app$get("/sign-in", \(req, res) {
  
  if (!is.null(req$user)) {
    
    if (isTRUE(req$user$is_verified)) {
      return(res$redirect("/", status = 303L))
    } else {
      return(res$redirect("/sign-in-link", status = 303L))
    }
  }
  
  res$send(sign_in_page)
})



app$get("/sign-in-link", \(req, res) {
  if (is.null(req$user)) {
    return(res$redirect("/sign-in", status = 303L))
  }
  
  if (isTRUE(req$user$is_verified)) {
    return(res$redirect("/", status = 303L))
  }
  
  res$send(sign_in_link_page(req$user$email))
})


app$get("/", \(req, res) {
  
  if (is.null(req$user)) {
    return(res$redirect("/sign-in", status = 303L))
  }
  
  if (!isTRUE(req$user$is_verified)) {
    return(res$redirect("/sign-in-link", status = 303L))
  }
  
  res$send(index_page(req$user))
})

app$get("/admin", \(req, res) {
  if (is.null(req$user)) {
    res$redirect("/sign-in", status = 303L)
    return(NULL)
  }
  
  if (!isTRUE(req$user$is_verified)) {
    res$redirect("/sign-in-link", status = 303L)
    return(NULL)
  }

  if (!isTRUE(req$user$is_admin)) {
    res$redirect("/", status = 303L)
    return(NULL)
  }

  res$send(admin_page(req$user))
})

source("auth/index.R", local = TRUE)
app$use(auth_router)

app$start(open = FALSE)

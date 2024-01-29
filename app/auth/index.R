
auth_router <- Router$new("/auth")


auth_router$get("/users", \(req, res) {
  
  if (is.null(req$user)) {
    res$status <- 401L
    res$json(list(
      message = "unauthorized"
    ))
    return(NULL)
  }

  err_out <- NULL
  status_out <- 200L
  tryCatch({   

    user_uid <- req$query$user_uid

    hold <- db_conn %>%
      tbl(in_schema("auth", "users"))

    if (!is.null(user_uid)) {
      hold <- hold %>%
        filter(uid == user_uid)
    }

    out <- hold %>%
      collect()

  }, error = function(err) {

    print(err)
    if (status_out == 200L) {
      status_out <- 500L
    }
    err_out <<- conditionMessage(err)
  })

  if (is.null(err_out)) {
    res$json(as.list(out), auto_unbox = FALSE)
  } else {
    res$status <- status_out
    res$json(list(
      message = unbox(err_out)
    ))
  }
})


auth_router$post("/users", \(req, res) {
  
  if (is.null(req$user) || !req$user$is_admin) {
    res$status <- 401L
    res$json(list(
      message = "unauthorized"
    ))
    return(NULL)
  }

  out <- NULL
  err_out <- NULL
  status_out <- 200L  
  tryCatch({
    
    body <- ambiorix::parse_json(req)
    email <- body$email
    if (is.null(email)) {
      status_out <- 400L
      stop("email not set", call. = FALSE)
    }
    email <- tolower(email)

    is_admin <- body$is_admin
    if (is.null(is_admin)) {
      is_admin <- FALSE
    }
    
    user_uid <- uuid::UUIDgenerate()
    out <- list(
      user_uid = user_uid,
      email = email,
      is_admin = is_admin,
      created_by = req$user$user_uid
    )
    rows_affected <- dbExecute(
      db_conn,
      "INSERT INTO auth.users (uid, email, is_admin, created_by) VALUES ($1, $2, $3, $4)",
      params = unname(out)
    )

    if (!identical(rows_affected, 1L)) {
      status_out <- 400L
      stop("unable to create user - db issue", call. = FALSE)
    }

  }, error = function(err) {

    print(err)
    if (status_out == 200L) {
      status_out <- 500L
    }
    err_out <<- conditionMessage(err)
  })

  if (is.null(err_out)) {
    res$json(out)
  } else {
    res$status <- status_out
    res$json(list(
      message = unbox(err_out)
    ))
  }
})


auth_router$put("/users", \(req, res) {
  
  if (is.null(req$user) || !req$user$is_admin) {
    res$status <- 401L
    res$json(list(
      message = "unauthorized"
    ))
    return(NULL)
  }

  out <- NULL
  err_out <- NULL
  status_out <- 200L
  tryCatch({
    
    body <- ambiorix::parse_json(req)
    user_uid <- body$user_uid
    if (is.null(user_uid)) {
      status_out <- 400L
      stop("user_uid not set", call. = FALSE)
    }

    email <- body$email
    if (is.null(email)) {
      status_out <- 400L
      stop("email not set", call. = FALSE)
    }
    email <- tolower(email)

    is_admin <- body$is_admin
    if (is.null(is_admin)) {
      is_admin <- FALSE
    }
    
    out <- list(
      email = email,
      is_admin = is_admin,
      user_uid = user_uid
    )
    rows_affected <- dbExecute(
      db_conn,
      "UPDATE auth.users SET email=$1, is_admin=$2 WHERE uid=$3",
      params = unname(out)
    )

    if (!identical(rows_affected, 1L)) {
      status_out <- 400L
      stop("unable to update user - db issue", call. = FALSE)
    }

  }, error = function(err) {

    print(err)
    if (status_out == 200L) {
      status_out <- 500L
    }
    err_out <<- conditionMessage(err)
  })

  if (is.null(err_out)) {
    res$json(out)
  } else {
    res$status <- status_out
    res$json(list(
      message = unbox(err_out)
    ))
  }
})


auth_router$delete("/users?user_uid", \(req, res) {
  
  if (is.null(req$user) || !req$user$is_admin) {
    res$status <- 401L
    res$json(list(
      message = "unauthorized"
    ))
    return(NULL)
  }

  err_out <- NULL
  status_out <- 200L
  tryCatch({
    
    user_uid <- req$query$user_uid
    if (is.null(user_uid)) {
      status_out <- 400L
      stop("user uid not set", call. = FALSE)
    }
    
    rows_affected <- dbExecute(
      db_conn,
      "DELETE FROM auth.users WHERE uid=$1",
      params = list(
        user_uid
      )
    )

    if (!identical(rows_affected, 1L)) {
      status_out <- 400L
      stop("unable to delete user - db issue", call. = FALSE)
    }

  }, error = function(err) {

    print(err)
    if (status_out == 200L) {
      status_out <- 500L
    }
    err_out <<- conditionMessage(err)
  })

  if (is.null(err_out)) {
    res$json(list(
      message = "success"
    ))
  } else {
    res$status <- status_out
    res$json(list(
      message = unbox(err_out)
    ))
  }
})

send_sign_in_link <- function(email, verification_code, user_uid) {
  

  httr::POST(
    Sys.getenv("MAILGUN_URL"),
    httr::authenticate(
      "api",
      Sys.getenv("MAILGUN_API_KEY")
    ),
    encode = "form",
    body = list(
      from = "noreply@polished.tech",
      to = email,
      subject = "Sign In Link",
      html = glue::glue(
        "<div style='align-items: center; padding: 20px; background-color: #EEE; text-align: center;'>
          <img src='{Sys.getenv('APP_URL')}/ech/images/logo.png' width='150px' style='display: block; margin: 0 auto;'/>
          <div style='padding: 30px; width: 100%; max-width: 600px; background-color: #FFF; margin: 20px auto;'>
            <a href='{Sys.getenv('APP_URL')}/auth/verify-email?verification_code={verification_code}&user_uid={user_uid}'>Click to Sign In</a>
          </div>
        </div>"
      )
    )
  )
}



auth_router$post("/sign-in", \(req, res) {
  
  status_out <- 200L
  out <- NULL
  err_out <- NULL
  tryCatch({
    
    conn <- poolCheckout(db_conn)
    dbBegin(conn)

    cookies <- req$cookies
    
    if (is.null(cookies) || identical(length(cookies), 0L)) {
      status_out <- 400
      stop("no cookies", call. = FALSE)
    }
    
    polished_cookie <- cookies$polished
    

    if (is.null(polished_cookie) || polished_cookie == "") {
      status_out <- 400
      stop("cookie not set", call. = FALSE)
    }
    
    body <- ambiorix::parse_json(req)
    email <- body$email
    if (is.null(email)) {
      status_out <- 400
      stop("email not set", call. = FALSE)
    }
    email <- tolower(email)

    db_user <- dbGetQuery(
      conn,
      "SELECT * FROM auth.users WHERE email=$1",
      params = list(
        email
      )
    )
    
    if (!identical(nrow(db_user), 1L)) {
      status_out <- 400
      stop("user not found", call. = FALSE)
    }
    

    session_uid <- UUIDgenerate()
    # user has correct password, so sign them in
    
    dbExecute(
      conn,
      "INSERT INTO auth.sessions (uid, user_uid, cookie) VALUES ($1, $2, $3)",
      params = list(
        session_uid,
        db_user$uid,
        polished_cookie
      )
    )
    
    hold_code <- UUIDgenerate()

    dbExecute(
      conn,
      "UPDATE auth.users SET verification_code=$1 WHERE uid=$2",
      params = list(
        hold_code,
        db_user$uid
      )
    )
    
    link_res <- send_sign_in_link(db_user$email, hold_code, db_user$uid)
    
    if (!identical(status_code(link_res), 200L)) {
      status_out <- 400
      stop("unable to send verification email", call. = FALSE)
    }

    dbCommit(conn)
    
    out <- list(
      user_uid = unbox(db_user$uid),
      email = unbox(db_user$email),
      session_uid = unbox(session_uid),
      is_admin = unbox(db_user$is_admin),
      is_verified = unbox(FALSE)
    )
     

    
  }, error = function(err) {
    
    dbRollback(conn)
    if (status_out == 200) {
      status_out <<- 500
    }
    print("unable to sign in")
    err_out <<- conditionMessage(err)
    print(err)

  }, finally = {
    poolReturn(conn)
  })
  
  
  if (is.null(err_out)) {
    res$json(out)
  } else {
    res$status <- status_out
    res$json(list(
      message = unbox(err_out)
    ))
  }
})



auth_router$post("/sign-out", \(req, res) {
  
  if (is.null(req$user)) {
    res$status <- 401L
    res$json(list(
      message = "unauthorized"
    ))
    return(NULL)
  }

  status_out <- 200L
  err_out <- NULL
  tryCatch({
      
    cookies <- req$cookies
    if (is.null(cookies) || identical(length(cookies), 0L)) {
      status_out <- 400
      stop("no cookies", call. = FALSE)
    }

    polished_cookie <- cookies$polished
      
    if (is.null(polished_cookie) || polished_cookie == "") {
      status_out <- 400
      stop("cookie not set", call. = FALSE)
    }
      
    session <- dbGetQuery(
      db_conn,
      "SELECT * FROM auth.sessions WHERE cookie=$1",
      params = list(
        polished_cookie
      )
    )

    if (!identical(nrow(session), 1L)) {
      status_out <- 400
      stop("session not found", call. = FALSE)
    }

    dbExecute(
      db_conn,
      "DELETE FROM auth.sessions WHERE user_uid=$1",
      params = list(
        session$user_uid
      )
    )
      
  }, error = function(err) {
      
    print("unable to sign out")
    print(err)
    if (identical(status_out, 200L)) {
      status_out <<- 500L
    }
    err_out <<- conditionMessage(err)
    
  })
  
  if (is.null(err_out)) {
    res$json(list(
      message = "success"
    ))
  } else {
    res$status <- status_out
    res$json(list(
      message = unbox(err_out)
    ))
  }
})


auth_router$post("/send-verification-email", \(req, res) {
  
  if (is.null(req$user)) {
    res$status <- 401L
    res$json(list(
      message = "unauthorized"
    ))
    return(NULL)
  }

  status_out <- 200L
  err_out <- NULL
  tryCatch({
    
    cookies <- req$cookies
      
    if (is.null(cookies) || identical(length(cookies), 0L)) {
      status_out <- 400
      stop("no cookies", call. = FALSE)
    }
      
    polished_cookie <- cookies$polished
      
    if (is.null(polished_cookie) || polished_cookie == "") {
      status_out <- 400
      stop("cookie not set", call. = FALSE)
    }
      
    session <- dbGetQuery(
      db_conn,
      "SELECT * FROM auth.sessions WHERE cookie=$1",
      params = list(
        polished_cookie
      )
    )

    db_user <- dbGetQuery(
      db_conn,
      "SELECT uid, email, verification_code FROM auth.users WHERE uid=$1",
      params = list(
        session$user_uid
      )
    )
    
    if (!identical(nrow(db_user), 1L)) {
      status_out <- 400L
      stop("user not found", call. = FALSE)
    }

    hold_code <- db_user$verification_code
    
    if (!UUIDvalidate(hold_code)) {
      status_out <- 400L
      stop("invalid verification code", call. = FALSE)
    }

    email <- db_user$email
    user_uid <- db_user$uid

    if (is.null(email)) {
      status_out <- 400L
      stop("email not set", call. = FALSE)
    }
    
    res <- send_sign_in_link(email, hold_code, user_uid)
    
    if (!identical(status_code(res), 200L)) {
      status_out <- 400
      stop("unable to send verification email", call. = FALSE)
    }
    
  }, error = function(err) {
    
    print("unable to send verification email")
    print(err)
    if (identical(status_out, 200L)) {
      status_out <<- 500L
    }
    err_out <<- conditionMessage(err)

  })

  
  if (is.null(err_out)) {
    res$json(list(
      message = unbox("success")
    ))
  } else {
    res$status <- status_out
    res$json(list(
      message = unbox(err_out)
    ))
  }
})


redirect_html <- function(path) {
  glue::glue('<html>
    <head>
      <meta http-equiv="Refresh" content="0; url=.{path}" />
    </head>
    <body>
      <p>Please follow <a href="{Sys.getenv("APP_URL")}">this link</a>.</p>
    </body>
  </html>')
}


auth_router$get("/verify-email?verification_code&user_uid", \(req, res) {
  
  status_out <- 200L
  err_out <- NULL
  tryCatch({
    
    hold_code <- req$query$verification_code

    if (is.null(hold_code)) {
      status_out <- 400L
      stop("verification code not set", call. = FALSE)
    }
    
    user_uid <- req$query$user_uid
    if (is.null(user_uid)) {
      status_out <- 400L
      stop("user uid not set", call. = FALSE)
    }

    db_user <- dbGetQuery(
      db_conn,
      "SELECT uid, verification_code FROM auth.users WHERE uid=$1",
      params = list(
        user_uid
      )
    )

    if (identical(db_user$uid, user_uid)) {
      dbExecute(
        db_conn,
        "UPDATE auth.users SET verification_code=$1 WHERE uid=$2",
        params = list(
          NA,
          user_uid
        )
      )
    }

  }, error = function(err) {
      
    print("unable to verify email")
    print(err)
    if (identical(status_out, 200L)) {
      status_out <<- 500L
    }
    err_out <<- conditionMessage(err)
  })

  if (is.null(err_out)) {
    res$redirect("/", 303L)
  } else {
    res$status <- status_out
    res$send(glue("<h1>{err_out}</h1>"))
  }
})

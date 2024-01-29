function(path) {
  glue::glue('<html>
    <head>
      <meta http-equiv="Refresh" content="0; url=.{path}" />
    </head>
    <body>
      <p>Please follow <a href="{Sys.getenv("APP_URL")}">this link</a>.</p>
    </body>
  </html>')
}

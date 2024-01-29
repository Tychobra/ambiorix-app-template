

header <- source("./pages/partials/header_main.R", local = TRUE)$value



function(user) {
  
  glue('
  <!DOCTYPE html>
  <html>  
  <html>
    <<header()>>
    <body>
      <link rel="stylesheet" href="/assets/build/index.css?version=<<runif(1)>>" />
      <div id="root"></div>
      <script>
        const user = {
          user_uid: "<<user$user_uid>>",
          email: "<<user$email>>",
          is_admin: <<jsonlite::toJSON(user$is_admin, auto_unbox = TRUE)>>
        }

        window.user = user
      </script>
      <script src="/assets/build/index.js?version=<<runif(1)>>" defer type="module" ></script>
    </body>
  </html>', .open = "<<", .close = ">>")
}

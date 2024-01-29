

header <- source("./pages/partials/header.R", local = TRUE)$value



function(user) {
  
  glue('
  <!DOCTYPE html>
  <html>  
    <<header()>>
    <body>
      <link rel="stylesheet" href="/assets/build/auth/admin.css?version=<<runif(1)>>" />
      <div id="root"></div>
      <script>
        const user = {
          user_uid: "<<user$user_uid>>",
          email: "<<user$email>>",
          is_admin: <<jsonlite::toJSON(user$is_admin, auto_unbox = TRUE)>>
        }

        window.user = user
      </script>
      <script src="/assets/build/auth/admin.js?version=<<runif(1)>>" defer type="module" ></script>
    </body>
  </html>', .open = "<<", .close = ">>")
}

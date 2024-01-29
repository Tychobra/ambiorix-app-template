


header <- source("./pages/partials/header.R", local = TRUE)$value
footer <- source("./pages/partials/footer.R", local = TRUE)$value


function(email) {
  glue('
  <!DOCTYPE html>
  <html lang="en">
  <<header()>>
  <body>
    <button id="sign_out" class="btn btn-default" style="background-color: #FFF; position: absolute; top: 5px; right: 15px;"><i class="fa fa-sign-out" style="margin-right: 5px;"></i>Sign Out</button>
    <div style="display: flex; align-items: center; flex-direction: column; margin-top: 50px;">
      <img src="/assets/images/ech_logo.png" style="width: 230px; padding: 0 15px;"/>
      <h1 style="font-size: 40px; margin-bottom: 0;">App Name</h1>
      <br/>
      <div style="width: 100%; max-width: 600px; display: flex; align-items: center; flex-direction: column; background-color: #FFF; border-radius: 20px; padding: 30px;">
        <h2 style="text-align: center; line-height: 1.7;">Sign in link sent to <<email>>.</h2>
        <h3 style="text-align: center; line-height: 1.7; margin-top: 0;">Check your email to sign in.</h3>
        <button id="resend_email_btn" style="max-width: 300px;" class="btn btn-default">Resend Sign In Link Email</button>
      </div>
    </div>
    <<footer>>
    <script defer type="module">
      import { sign_in_link } from "/assets/js/sign_in_link.js"
      import { toast_error } from "/assets/js/utils.js"
      sign_in_link("<<email>>")

      document.getElementById("sign_out").addEventListener("click", async () => {
        try {
          const r = await fetch("/auth/sign-out", {
            method: "POST",
            credentials: "include",
            headers: {
              "Content-Type": "application/json"
            },
          })
          
          if (r.status === 200) {
            window.location.href = "/sign-in"
          } else {          
            throw new Error("Sign out failed")
          }
          
        } catch (err) {
          
          toast_error("Sign out failed") 
           
          console.log(err)
        }
        
      })
    </script>
  </body>
  </html>'
  , .open = "<<", .close = ">>")
}

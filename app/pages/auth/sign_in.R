


header <- source("./pages/partials/header.R", local = TRUE)$value
footer <- source("./pages/partials/footer.R", local = TRUE)$value

glue('
<!DOCTYPE html>
<html lang="en">
{header()}
<body>
  <div style="display: flex; align-items: center; flex-direction: column; margin-top: 75px;">
    <img src="/assets/images/logo.png" style="width: 250px; padding: 0 15px;"/>
    <br/>
    <div style="background-color: #FFF; padding: 30px; border-radius: 15px; margin-top: 40px;">
      <div style="width: 250px;">
        <h1 style="text-align: center; margin: 0;">Sign In</h1>
      </div>
      <form id="sign_in_form" style="width: 250px;">
        <label>Email</label>
        <input id="email" class="npt" type="email" value=""/>
        <br/>
        <br/>
        <button id="sign_in_btn" type="submit" class="btn btn-primary" style="width: 100%;">Sign In</button>
      </form>
    </div>
  </div>
  {footer}
  <script defer type="module" src="/assets/js/sign_in.js?version={runif(1)}"></script>
</body>
</html>'
)
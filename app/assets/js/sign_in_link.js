
import { 
  toast_error,
  toast_success,
} from './utils.js'



export const sign_in_link = (email) => {
  
  const resend_email_btn = document.getElementById("resend_email_btn")

  resend_email_btn.addEventListener("click", async (evt) => {
    
    
    try {
      // resend the verification email
      const r = await fetch("/auth/send-verification-email", {
        method: "post",
        body: JSON.stringify({
          email: email,
        })
      })
      
      if (r.ok === true) {
        toast_success("verification email resent")
      } else {
        throw new Error("unable to resend verification email")
      }
      

    } catch (err) {
      console.log(err)
      toast_error("unable to resend verification email")
    }
    
  })
}


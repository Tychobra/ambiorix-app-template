import { 
  toast_error,
  set_polished_cookie 
} from './utils.js'

const el = document.getElementById('sign_in_form')
      
el.addEventListener('submit', async (evt) => {
  evt.preventDefault()
  
  document.getElementById('sign_in_btn').disabled = true

  let email = document.getElementById('email').value.toLowerCase()
  set_polished_cookie()
  
  let err_out = null
  try {

    const res = await fetch("/auth/sign-in", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        email: email
      }),
      credentials: 'include'
    })
  
    
    if (res.ok === true) {
      
      window.location.href = "/"
      
    } else {
      
      try {
        const err = await res.json()
        console.log(err)
        err_out = err.message
      } catch(err) {
        console.log(err)
        err_out = "sign in error"
      }

      throw new Error(err_out)
    } 
        
    
  } catch(err) {    
    
    console.log(err)
    toast_error(err.message)
  }

  document.getElementById('sign_in_btn').disabled = false
      
})
    
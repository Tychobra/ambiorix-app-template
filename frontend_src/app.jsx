import { render, ErrorBoundary } from "solid-js/web"

import "./index.css"

const App = () => {
  
  const sign_out = async () => {

    try {
      const r = await fetch("/auth/sign-out", { 
        method: "POST", credentials: "include" ,
        headers: {
          "Content-Type": "application/json"
        },
      })

      const rc = await r.json()
      if (r.status === 200) {
        window.location.href = "/"
      } else {
        throw new Error(rc.message)
      } 
    
    } catch (err) {
      console.log("unable to sign out")
      console.log(err)
    }
    
  }

  
  return <ErrorBoundary fallback={err => {
    
    return <div style="display: flex; align-items: center; margin-top: 150px; flex-direction: column;">
      <h2>Client Side Error</h2>
      <code style="width: 100%; text-align: left; background-color: #DDD; padding: 20px; max-width: 600px;">
        Error: {err.message}
      </code>
    </div>
  }}>
    <div>
      <main style="display: flex; flex-direction: column; align-items: center; padding-top: 100px;">
        <h1>Your Solidjs App</h1>
        <div style="border-radius: 10px; width: 450px; background-color: #DDD; padding: 15px;">
          <div style="width: 100%; text-align: center;">
            <h3>Signed In As</h3>
          </div>
          <ul>
          {Object.keys(user).map(k => {
            return <li style="margin-bottom: 10px;">{`${k}: ${user[k]}`}</li>
          })}
          </ul>
        </div>
        <br/>
        <div style="display: flex; justify-content: center; gap: 15px;">
          <button onClick={sign_out} style="width: 200px; padding: 5px 8px;"><i class="fa fa-sign-out" style="margin-right: 8px;"></i>Sign Out</button>
          <button onClick="window.location.href='/admin'" style="width: 200px;  padding: 5px 8px;"><i class="fa fa-users-gear" style="margin-right: 8px;"></i>Go to Admin Panel</button>
        </div>
        <br/>
      </main>
    </div>
  </ErrorBoundary>
};


render(App, document.getElementById("root"))

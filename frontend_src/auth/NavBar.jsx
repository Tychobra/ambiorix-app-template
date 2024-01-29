import { createSignal } from 'solid-js';

import { toast_error } from '../utils';

import styles from "./NavBar.module.css"

function NavBar(props) {
  const [open_profile_menu, set_open_profile_menu] = createSignal(false)
 
  const handle_sign_out = async () => {
    
    
    try {
      
      const res = await fetch("/auth/sign-out", {
        method: "post",
        headers: {
          "Content-Type": "application/json"
        },
        credentials: 'include'
      })
      
      if (res.status === 200) {
        localStorage.removeItem("user")
        window.location.href = "/sign-in"
      } else {
        throw new Error("unable to sign out")
      }
      
    
    } catch(err) {
      toast_error("unable to sign out")
      console.log(err)
    }

  }

  return <div style="
    background-color: #FFF;
    position: fixed; 
    z-index: 500; 
    width: 100%; 
    height: 50px;
    box-shadow: 0 0 5px 5px rgba(0, 0, 0, 0.1); 
    display: flex; 
    justify-content: space-between;"
  > 
    <div style="display: flex; justify-content: start;">
      <div onClick={() => props.set_open_sidebar(c => !c)} id="sidebar_toggle" class={styles.sidebar_toggle_btn}>
        <i className="fa-solid fa-bars" style="font-size: 20px;"></i>
      </div>
      <div style={{width: `100%`, display: `flex`, justifyContent: `center`}}>
        <img alt="ECH Logo" height="50" src="/assets/images/logo_horizontal.png" style="padding: 7.5px; margin-left: 12px;" />
      </div>
      <div style="white-space: nowrap; font-size: 24px; font-weight: 600; margin-top: 8px; margin-left: 60px; color: var(--color_danger)">
        Admin
      </div>
    </div>  
        
        
      
      
    <div style="display: flex;"> 
      <a href="/">
        <div 
          style="padding: 15px 20px; border-left: 1px solid #CCC; cursor: pointer; position: relative;"
        >
        Go to App
        </div>
      </a>
      <div id="nav_user_icon">
        <div 
          onClick={() => set_open_profile_menu(c => !c )}
          style="padding: 15px 20px; border-left: 1px solid #CCC; cursor: pointer; position: relative;"
        >
          <i className="fas fa-user" ></i>
        </div>
        {open_profile_menu() ? <div style="
            position: absolute; 
            top: 40px; 
            right: 5px; 
            background-color: #FFF; 
            box-shadow:0 0 5px 5px rgba(0, 0, 0, 0.1);
          ">
            <ul style="list-style-type: none; white-space: nowrap; padding: 0; margin: 0;">
              <li class={styles.user_menu_item}>
                {window.user.email}
              </li>  
              <li onClick={handle_sign_out} id="nav_sign_out" class={styles.user_menu_item}><i class="fa fa-sign-out" style="margin-right: 8px;"></i>Sign Out</li>
            </ul>
          </div> : null
        }
      </div>
    </div>
  </div>
}

export default NavBar;
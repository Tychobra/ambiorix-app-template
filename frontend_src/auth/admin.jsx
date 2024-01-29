import { createSignal, createEffect, For, Show } from "solid-js"
import { render } from "solid-js/web"
import { createMediaQuery } from "@solid-primitives/media";
import { Router, Routes, Route } from "@solidjs/router"; // 👈 Import the router

import NavBar from "./NavBar"
import Sidebar from "./SideBar"
import { toast_error, toast_success, r_df_to_js, validate_email } from "../utils";
import Card from "../components/Card";

const EditUserModal = (props) => {
  const [email, set_email] = createSignal("")
  const [err_msg, set_err_msg] = createSignal("")
  
  createEffect(() => {
    if (props.user_to_edit()) {
      set_email(props.user_to_edit().email)
    } else {
      set_email("")
    }
  })
  
  createEffect(() => {
    
    let hold_email = email()
    
    let existing_emails = props.users().map(u => u.email)

    if (hold_email.length > 0 && existing_emails.includes(hold_email)) {
      set_err_msg("Email already exists")
    } else {
      set_err_msg("")
    }
  })
  const handle_submit = async (e) => {
    e.preventDefault()
    
    let hold_email = email()
    
    if (err_msg() !== "") {
      return
    }

    if (!validate_email(hold_email)) {
      set_err_msg("Invalid email")
      return
    }

    try {
      
      
      let is_admin = document.getElementById("add_user_is_admin").checked
      
      let body = {
        email: hold_email.toLowerCase(),
        is_admin: is_admin
      }
      
      let resp = null

      if (props.user_to_edit()) {
        // user is being edited
        body.user_uid = props.user_to_edit().uid
        
        resp = await fetch("/auth/users", {
          method: "PUT",
          body: JSON.stringify(body),
          headers: {
            'Content-Type': 'application/json'
          }
        })

        if (resp.ok) {
          toast_success("User edited")
        } else {
          throw new Error("Error editing user")
        }

      } else {
        // user is being added
        resp = await fetch("/auth/users", {
          method: "POST",
          body: JSON.stringify(body),
          headers: {
            'Content-Type': 'application/json'
          }
        })

        if (resp.ok) {
          toast_success("User added")
        } else {
          throw new Error("Error adding user")
        }
      }
      
      props.set_open(false)
      props.set_trigger(Math.random())

    } catch(err) {
      console.log("err: ", err)
      toast_error("Error adding user")
    }
  }
  
  

  return <div class="modal">
    <div class="panel">
      <div class="panel_header">
        <h3 style="margin: 0">{props.user_to_edit() ? "Edit User" : "Add User"}</h3>
        <div 
          style="padding: 10px; cursor: pointer;" 
          onclick={() => props.set_open(false)}>
          <i class="fa fa-times" style="font-size: 20px;"></i>
        </div>
      </div>
      <div class="panel_content">
        <form onsubmit={handle_submit}>
          <div style="position: relative;">
            <label>Email</label>
            <input id="add_user_email" class="npt" type="email" value={email()} oninput={e => set_email(e.currentTarget.value)}/>
            <span class="error_text" >{err_msg}</span>
          </div>
          <br/>
          <br/>
          <div style="width: 100%; text-align: center;">
            <label>
              <input id="add_user_is_admin" type="checkbox" checked={props.user_to_edit() ? props.user_to_edit().is_admin : false}/>
              Is Admin?
            </label>
          </div>
          <br/>
          <div style="width: 100%; display: flex; justify-content: end; gap: 8px;">
            <button 
              type="button"
              onClick={(e) => props.set_open(false)} 
              class="btn btn-default" 
              style="width: 90px"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              class="btn btn-primary" 
              style="width: 90px"
              disabled={err_msg() !== "" || email() === ""}
            >
              Submit
            </button>
          </div> 
        </form>
      </div>
    </div>
  </div>
}

const DeleteUserModal = (props) => {
  
  const handle_submit = async () => {
    
    
    try {
        
      const resp = await fetch(`/auth/users?user_uid=${props.user_to_delete().uid}`, {
        method: "DELETE",
        credentials: "include"
      })

      if (resp.ok) {
        toast_success("User deleted")
      } else {
        let msg = await resp.text()
        console.log("msg: ", msg)
        try {
          let json_msg = JSON.parse(msg)
          msg = json_msg.message
        } finally {
          throw new Error(msg)
        }
        
      }
      
      props.set_open(false)
      props.set_trigger(Math.random())

    } catch(err) {
      console.log("err: ", err)
      toast_error(err.message)
    }
  }

  return <div class="modal">
    <div class="panel_md">
      <div class="panel_header">
        <h3 style="margin: 0">Delete User</h3>
        <div 
          style="padding: 10px; cursor: pointer;" 
          onclick={() => props.set_open(false)}>
          <i class="fa fa-times" style="font-size: 20px;"></i>
        </div>
      </div>
      <div class="panel_content">
        <div style="text-align: center; padding: 30px 50px;">
          <h2 style="line-height: 1.7">{`Are you sure you want to delete ${props.user_to_delete().email}?`}</h2>
        </div>
        <br/>
        <div style="width: 100%; display: flex; justify-content: end; gap: 8px;">
          <button onClick={() => props.set_open(false)} class="btn btn-default" style="width: 110px">
            No, Cancel
          </button>
          <button onClick={handle_submit} class="btn btn-primary" style="width: 110px">
            Yes, Submit
          </button>
        </div> 
      </div>
    </div>
  </div>
}

const App = () => {
  const [open_sidebar, set_open_sidebar] = createSignal(true)
  const [users, set_users] = createSignal([])
  const [trigger, set_trigger] = createSignal(0)
  const [search, set_search] = createSignal("")
  const [table_page, set_table_page] = createSignal(1)

  const [user_to_edit, set_user_to_edit] = createSignal(null)
  const [open_edit_user, set_open_edit_user] = createSignal(false)
  
  const [user_to_delete, set_user_to_delete] = createSignal(null)
  const [open_delete_user, set_open_delete_user] = createSignal(false)
  
  

  const isSmall = createMediaQuery("(max-width: 767px)");

  createEffect(() => {
    if (isSmall()) {
      set_open_sidebar(false)
    } else {
      set_open_sidebar(true)
    }
  })
  
  createEffect(() => {
    trigger()

    let out = []
    try {
      
      fetch("/auth/users").then(r => {
        
        return r.json()
        
      }).then(dat => {
        set_users(r_df_to_js(dat))
      })
      

    } catch (err) {
      console.log("err: ", err)
    }
    
    return out
  })
  
  createEffect(() => {
    if (open_edit_user() === false) {
      set_user_to_edit(null)
    }
  })
  
  const filtered_users = () => {
    const hold_search = search()
    
    let out = users()
    
    if (hold_search.length >= 3) {
      out = users().filter(u => {
        return u.email.toLowerCase().includes(hold_search.toLowerCase())
      })
    }

    return out
  }

  const page_users = () => {
    let out = filtered_users()
    if (out.length > 10) {
      out = out.slice((table_page() - 1) * 10, table_page() * 10)
    }
    return out
  }

  return <Router>
    <div>
    {open_edit_user() ? <EditUserModal 
      user_to_edit={user_to_edit} 
      set_open={set_open_edit_user} 
      set_trigger={set_trigger}
      users={users}
    /> : null}
    {open_delete_user() ? <DeleteUserModal 
      user_to_delete={user_to_delete} 
      set_open={set_open_delete_user} 
      set_trigger={set_trigger}
    /> : null}
    <NavBar set_open_sidebar={set_open_sidebar}/>
    <Sidebar open_sidebar={open_sidebar}/>
    <main class={`main_content ${open_sidebar() ? "" : "main_content_open"}`}>
    <br/>
    <Routes>
      <Route path="/admin" element={
        <div style="padding: 0 15px;">
          <Card title="Users">
            <div style="padding: 15px">
              <div style="display: flex; justify-content: space-between; width: 100%;">
                <button onClick={() => set_open_edit_user(true)} class="btn btn-primary" style="width: 150px;">
                  <i class="fa fa-plus"></i>
                  Add User
                </button>
                <input 
                  type="search" 
                  class="npt" 
                  style="width: 250px;" 
                  value={search()} 
                  oninput={(e) => set_search(e.currentTarget.value)}
                  placeholder="Search..."
                />
              </div>
              <br/>
              <br/>
              <div style="overflow-x: auto;">       
                <table style="width: 100%; white-space: nowrap;">
                  <thead style="border-bottom: 1px solid var(--color_light_2)">
                    <tr>
                      <th></th>
                      <th style="text-align: left; padding: 5px 15px;">Email</th>
                      <th style="text-align: left; padding: 5px 15px;">Admin</th>
                      <th style="text-align: left; padding: 5px 15px;">Invited At</th>
                    </tr>
                  </thead>
                  <tbody id="users_table" style="width: 100%;">
                    <Show 
                      when={users().length > 0}
                      fallback={
                        <tr class="row" id="users_table_loading">
                          <td colspan="4" style="text-align: center; padding: 15px;">
                            <i class="fa fa-spinner fa-spin" style="font-size: 24px;"></i>
                          </td>
                        </tr>
                      }
                    >
                      <For each={page_users()}>
                        {(u) => {
                          
                          

                          return <tr class="row" style="border-bottom: 1px solid #CCC;" >
                            <td class="cell" style="padding-top: 0; padding-bottom: 0; width: 75px; min-width: 75px;"><div>
                              <button 
                                onClick={() => {
                                  set_user_to_edit(u)
                                  set_open_edit_user(true)
                                }} 
                                class="btn btn-sm btn-default" 
                                style="border-top-right-radius: 0; border-bottom-right-radius: 0;" 
                              >
                                <i class="fa fa-edit"></i>
                              </button>
                              <button 
                                onClick={() => {
                                  set_user_to_delete(u)
                                  set_open_delete_user(true)
                                }}
                                class="btn btn-sm btn-default" 
                                style="border-top-left-radius: 0; border-bottom-left-radius: 0;">
                              <i class="fa fa-trash"></i></button>
                            </div></td>
                            <td class="cell">{u.email}</td>
                            <td class="cell">{u.is_admin ? "Yes" : "No"}</td>
                            <td class="cell">{u.created_at.toLocaleString()}</td>
                          </tr>
                        } 
                      }
                      </For>
                    </Show>
                  </tbody>
                </table>
                <Show
                   when={filtered_users().length > 10}
                >
                  <div style="display: flex; width: 100%; justify-content: space-between; align-items: center;">
                    <div style="padding-left: 5px; width: 150px; margin-top: 5px;">
                      {(table_page() - 1) * 10 + 1} - {Math.min(table_page() * 10, filtered_users().length)} of {filtered_users().length} users
                    </div>
                    <div style="width: 100%; display: flex; justify-content: end; margin-top: 5px;">
                      <button 
                        onClick={() => set_table_page(table_page() - 1)}
                        class="btn-sm btn-default" 
                        style="width: 50px;"
                        disabled={table_page() === 1}
                      >
                        <i class="fa fa-chevron-left"></i>
                      </button>
            
                      <div class="btn-sm">{table_page()}</div>
                      <button 
                        onClick={() => set_table_page(table_page() + 1)}
                        class="btn-sm btn-default" 
                        style="width: 50px;"
                        disabled={table_page() * 10 >= filtered_users().length}
                      >
                        <i class="fa fa-chevron-right"></i>
                      </button>
                    </div>
                  </div> 
                </Show>
              </div>
              <br/>
            </div>
          </Card>  
        </div>
      } />
      <Route path="/admin/logs" element={
        <div>
          <h1>Logs</h1>
        </div>
      } />
        
    </Routes>
  </main>
  </div>
  </Router>
};

render(App, document.getElementById("root"))

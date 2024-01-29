import { A, useLocation } from "@solidjs/router";


import styles from "./SideBar.module.css"

const SideBar = (props) => {
  const location = useLocation()


  return <aside 
  class={styles.sidebar}
  classList={{
    [styles.sidebar_closed]: props.open_sidebar() === false
  }}
 >
    <ul style="padding: 0;">
      <A href="/admin">
        <li class={styles.menu_item} classList={{
          [styles.menu_item_active]: location.pathname === "/admin"
        }}>
          <div class={styles.sidebar_icon}>
            <i class="fa-solid fa-users"></i>
          </div>
          <p class={styles.sidebar_text}>User Access</p>
        </li>
      </A>
      <A href="/admin/logs">
        <li class={styles.menu_item} classList={{
          [styles.menu_item_active]: location.pathname === "/admin/logs"
        }}>
          <div class={styles.sidebar_icon}>
            <i class="fa-solid fa-list"></i>
          </div>
          <p class={styles.sidebar_text}>Logs</p>
        </li>
      </A>
    </ul>
  </aside>
}

export default SideBar

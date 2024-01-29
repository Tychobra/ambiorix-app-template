import { createSignal } from 'solid-js'

import styles from "./Card.module.css"

const Card = (props) => {
  const [open, set_open] = createSignal(true)

  return <div class={styles.card} style="width: 100%">
    <div class={styles.card_title}>
      {props.title}
      <div style="padding: 2px 5px 0 5px;" onClick={() => set_open(!open())}>
        {open() ? <i class="fa fa-minus"></i> : <i class="fa fa-plus"></i>}
      </div>
    </div>
    <div class={`${styles.card_content} ${open() === false ? styles.card_content_closed : ""}`}>
      <div style="max-width: 100%; min-width: 0;">
        {props.children}
      </div>
    </div>
  </div>
}

export default Card


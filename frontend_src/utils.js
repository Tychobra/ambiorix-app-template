import Toastify from 'toastify-js'
import 'toastify-js/src/toastify.css'

// utility functions that are used in multiple places
export const toast_success = (msg) => {
  Toastify({
    text: msg,
    style: {
      fontSize: `18px`, 
      width: `300px`,
      minWidth: `250px`,
      textAlign: `center`,
      color: "#000",
      background: "#FFF",
      borderBottom: "5px solid var(--color_success)",
    },
    gravity: "bottom",
    position: "center",
    stopOnFocus: true,
  }).showToast()
}

export const toast_error = (msg) => {
  Toastify({
    text: msg,
    style: {
      fontSize: `18px`, 
      width: `300px`,
      minWidth: `250px`,
      textAlign: `center`,
      color: "var(--color_danger)",
      background: "#FFF",
      borderBottom: "5px solid var(--color_danger)",
    },
    gravity: "bottom",
    position: "center",
    stopOnFocus: true,
  }).showToast()
}

export const set_polished_cookie = () => {
  
  // Build the expiration date string:
  let expiration_date = new Date();
  expiration_date.setFullYear(expiration_date.getFullYear() + 1);

  const polished_cookie = "p" + Math.random()

  let cookie_string = `polished=${polished_cookie}; path=/; expires=${expiration_date.toUTCString()};`
  
  document.cookie = cookie_string

  return cookie_string
}

/*
* convert JSON formatted as an R data frame to JSON formatted as a JS data frame.
*/
export const r_df_to_js = (r_df) => {
  debugger
  const cols = Object.keys(r_df)

  let out = []
  r_df[cols[0]].forEach((d, i) => {
          
    let obj_out = {}
    cols.forEach(col => {
      obj_out[col] = r_df[col][i]
    })
          
    out.push(obj_out)
  })

  return out
}

/*
* convert JSON formatted as an R data frame to JSON formatted as a JS data frame.
*/
export const r_df_to_hot = (r_df, col_ordered = null) => {
  
  let cols = col_ordered
  if (col_ordered === null) {
    cols = Object.keys(r_df)
  }
  

  let out = []
  r_df[cols[0]].forEach((d, i) => {
          
    let row_out = []
    cols.forEach(col => {
      row_out.push(r_df[col][i])
    })
          
    out.push(row_out)
  })

  return out
}

/*
* convert JSON formatted as an R data frame to JSON formatted as a JS data frame.
*/
export const hot_df_to_r = (hot_df, col_names) => {
  
  let t_df = hot_df[0].map((_, colIndex) => hot_df.map(row => row[colIndex]));
  let out = {}
  col_names.forEach((col_names, i) => {
    out[col_names] = t_df[i]
  })

  return out
}


// converts a date from the format mm/dd/YYYY to YYYY-mm-dd
//
// @param date of birth as a string in the format mm/dd/YYYY
export const standardize_date = (date) => {
  let hold_date = date.split("/")
                
  let month = hold_date[0]
                
  if (month.length === 1) {
    month = `0${month}`
  }

  let day = hold_date[1]
  if (day.length === 1) {
    day = `0${day}`
  }

  return `${hold_date[2]}-${month}-${day}`
}

export const validate_email = (email) => {
  return String(email)
    .toLowerCase()
    .match(
      /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    );
};
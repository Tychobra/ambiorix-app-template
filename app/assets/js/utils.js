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
      minWidth: `250px`,
      width: `300px`,
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
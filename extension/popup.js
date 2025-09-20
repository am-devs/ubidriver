document.addEventListener('DOMContentLoaded', function() {
  const $form = document.querySelector("form");

  // Sesión
  chrome.storage.sync.get(['username','sessionId'], (data) => {
    if (data.sessionId) {
      window.location.href = "orders.html";
      return;
    }

    if (data.username) {
      $form.elements.namedItem("username").value = data.username;
    }
  });

  $form.addEventListener("submit", (e) => {
    e.preventDefault();

    chrome.runtime.sendMessage({
      action: "login",
      payload: {
        username: e.currentTarget.elements.namedItem("username").value,
        password: e.currentTarget.elements.namedItem("password").value,
      }
    }, onLoginResponse);
  });
});

function onLoginResponse(response) {
  if (response.status) {
    console.log("Sesión iniciada exitósamente: ", response.result);

    window.location.href = "orders.html";
  } else {
    console.error(response.result);
  }
}
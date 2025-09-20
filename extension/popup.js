document.addEventListener('DOMContentLoaded', function() {
  const $form = document.querySelector("form");
  const $p = document.querySelector("p");

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
    
    e.submitter.disabled = true;
    $p.textContent = "";

    chrome.runtime.sendMessage({
      action: "login",
      payload: {
        username: e.currentTarget.elements.namedItem("username").value,
        password: e.currentTarget.elements.namedItem("password").value,
      }
    }, (response) => {
      if (response.status) {
        console.log("Sesión iniciada exitósamente: ", response.result);

        window.location.href = "orders.html";
      } else {
        console.error(response.result);

        $form.elements.namedItem("password").value = "";

        $p.textContent = "Credenciales inválidas, intente nuevamente";

        e.submitter.disabled = false;
      }
    });
  });
});

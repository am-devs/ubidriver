const ODOO_DATABASE = "portal_mary";
const odooUrl = new URL("https://portalmary.iancarina.com.ve/");
const apiUrl = new URL('wss://chofer.iancarina.com.ve/v1/ws');

// const ODOO_DATABASE = "Test";
// const odooUrl = new URL("http://localhost:8060/");
// const apiUrl = new URL('ws://localhost:8084/v1/ws');

chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    let promise = undefined;
    const { payload: pay } = request;

    switch (request.action) {
      case 'login':
        promise = authenticate(pay.username, pay.password)
          .then((session) => {
            chrome.storage.sync.set({
              sessionId: activeSession = session.id,
              username: session.username
            });

            return session;
          });
          break;
      case "fetch":
        promise = getPendingDocuments(pay.sessionId);
        break;
      case "get":
        promise = getDocumentById(pay.sessionId, pay.orderId);
        break;
      case "approve":
        promise = approveOrder(pay.sessionId, pay.orderId);
        break;
      case "check":
        promise = checkSession(pay.sessionId);
        break;
      case "disapprove":
        promise = disapproveOrder(pay.sessionId, pay.orderId);
    }

    promise
      .then((result) => sendResponse({ status: true, result }))
      .catch((err) => sendResponse({ status: false, result: err.message }));

    return true;
});

async function authenticate(username, password) {
  const response = await fetch(odooUrl + "/web/session/authenticate", {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      method: "call",
      params: {
        db: ODOO_DATABASE,
        login: username,
        password: password
      }
    })
  });
  
  if (!response.ok) {
    throw new Error(`Error de autenticación: ${response.status}`);
  }
  
  const data = await response.json();
  
  if (data.error) {
    throw new Error(data.error.data.message || 'Error de autenticación');
  }
  
  const cookies = await chrome.cookies.getAll({url: odooUrl.toString()});
  const sessionCookie = cookies.find(c => c.name.includes('session_id'));
  
  if (!sessionCookie) {
    throw new Error('No se pudo obtener la sesión');
  }
  
  return {
    id: sessionCookie.value,
    uid: data.result.uid,
    username: data.result.username
  };
}

async function checkSession(sessionId) {
  const response = await fetch(odooUrl + "/web/session/check", {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cookie': `session_id=${sessionId}`
    },
    body: JSON.stringify({})
  });
  
  if (!response.ok) {
    throw new Error(`Error al consultar la sesión: ${response.status}`);
  }
  
  const data = await response.json();
  
  if (data.error) {
    throw new Error(data.error.data.message || 'Error al consultar la sessión');
  }
  
  return true;
}

async function getDocumentById(sessionId, id) {
  const response = await fetch(odooUrl + "/web/dataset/call_kw", {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cookie': `session_id=${sessionId}`
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      method: "call",
      params: {
        model: "ian.sale.return",
        method: "search_and_export_order_to_json",
        args: [id],
        kwargs: {}
      }
    })
  });
  
  if (!response.ok) {
    throw new Error(`Error al obtener documento: ${response.status}`);
  }
  
  const data = await response.json();
  
  if (data.error) {
    throw new Error(data.error.data.message || 'Error al obtener documento');
  }
  
  return data.result;
}

async function getPendingDocuments(sessionId) {
  const response = await fetch(odooUrl + "/web/dataset/call_kw", {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cookie': `session_id=${sessionId}`
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      method: "call",
      params: {
        model: "ian.sale.return",
        method: "search_read",
        args: [],
        kwargs: {
          domain: [["state", "=", "confirm"],["approval_status","=","waiting"]],
          fields: ["id", "name", "create_date"],
          order: "create_date desc"
        }
      }
    })
  });
  
  if (!response.ok) {
    throw new Error(`Error al obtener documentos: ${response.status}`);
  }
  
  const data = await response.json();
  
  if (data.error) {
    throw new Error(data.error.data.message || 'Error al obtener documentos');
  }
  
  return data.result;
}

async function approveOrder(sessionId, orderId) {
    const response = await fetch(odooUrl + "/web/dataset/call_kw", {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cookie': `session_id=${sessionId}`
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      method: "call",
      params: {
        model: "ian.sale.return",
        method: "action_approved",
        args: [[orderId]],
        kwargs: {}
      }
    })
  });
  
  if (!response.ok) {
    throw new Error(`Error al confirmar órden: ${response.status}`);
  }
  
  const data = await response.json();
  
  if (data.error) {
    throw new Error(data.error.data.message || 'Error al confirmar órden');
  }
  
  return data.result;
}

async function disapproveOrder(sessionId, orderId) {
    const response = await fetch(odooUrl + "/web/dataset/call_kw", {
    method: 'POST',
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Cookie': `session_id=${sessionId}`
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      method: "call",
      params: {
        model: "ian.sale.return",
        method: "action_disapproved",
        args: [[orderId]],
        kwargs: {}
      }
    })
  });
  
  if (!response.ok) {
    throw new Error(`Error al rechazar órden: ${response.status}`);
  }
  
  const data = await response.json();
  
  if (data.error) {
    throw new Error(data.error.data.message || 'Error al rechazar órden');
  }
  
  return data.result;
}

// Websocket
let webSocket = null;

function keepAlive() {
  const keepAliveIntervalId = setInterval(
    () => {
      if (webSocket) {
        webSocket.send(JSON.stringify({}));
      } else {
        clearInterval(keepAliveIntervalId);
      }
    },
    20 * 1000 
  );
}

function connect() {
  webSocket = new WebSocket(apiUrl);

  webSocket.onopen = (event) => {
    console.log('websocket open');
    keepAlive();
  };

  webSocket.onmessage = (event) => {
    console.log(`websocket received message: ${event.data}`);

    const { id, name } = JSON.parse(event.data);

    if (name && id) {
      chrome.notifications.create(
        `odoo/ian.sale.return/${id}`,
        {
          iconUrl: "logo.png",
          type: "basic",
          title: 'Nueva aprobación',
          message: `Se ha creado una nueva órden de devolución con la secuencia ${name}`
        }
      );
    }
  };

  webSocket.onclose = (event) => {
    console.log('websocket connection closed');
    webSocket = null;
  };
}

chrome.notifications.onClicked.addListener((id) => {
  chrome.tabs.create({ url: odooUrl + id });
});

connect();
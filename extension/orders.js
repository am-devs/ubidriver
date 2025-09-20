let sessionId = null;

document.addEventListener("DOMContentLoaded", () => {
    // Sesión
    chrome.storage.sync.get(['sessionId'], (data) => {
        if (data.sessionId) {
            console.log("Sesión es: ", sessionId = data.sessionId);
            
              // Fetch orders
            chrome.runtime.sendMessage({
                action: "check",
                payload: {
                    sessionId: data.sessionId
                }
            }, (response) => {
                if (response.status) {
                    // Fetch orders
                    chrome.runtime.sendMessage({
                        action: "fetch",
                        payload: {
                            sessionId: data.sessionId
                        }
                    }, onFetchOrders);
                } else {
                    console.error(response.result);

                    window.location.href = "./popup.html";
                }
            });
        } else {
            window.location.href = "./popup.html";
        }
    });

    document.querySelector("input").addEventListener("search", (e) => {
        document.querySelectorAll(".order").forEach(($e) => {
            $e.hidden = !$e.dataset.order.includes(e.target.value.toLowerCase());
        });
    });
});

const NAME = "products";

function removeOrderAndCheckIfTheresMore(orderId) {
    document.querySelector(`[data-order-id="${orderId}"]`)?.remove();

    if (document.querySelectorAll("[data-order-id]").length === 0) {
        const $section = document.querySelector("section");

        const $h2 = document.createElement("h2");

        $h2.textContent = "No hay nada que mostrar!";

        $section.append($h2);
    }
}

function generateDetail(data) {
    const $template = document.getElementById("detail");
    const $clone = $template.content.cloneNode(true);

    if (data.partner) {
        const $$span = $clone.querySelectorAll(".title");
    
        $$span[0].after(new Text(" " + data.partner.name));
        $$span[1].after(new Text(" " + data.partner.vat));
        $$span[2].after(new Text(" " + data.partner.address));
    } else {
        $clone.querySelector(".partner").remove();
    }
    
    const $root = $clone.querySelector(".order__details");
    const $buttons = $clone.querySelector(".order__details > span");

    data.lines.forEach((line) => {
        const $details = document.createElement("details");

        $details.name = NAME;

        const $summary = document.createElement("summary");

        $summary.appendChild(new Text(line.product));

        $details.append($summary);
        $details.append(new Text(`Motivo: `));

        const $reason = document.createElement("span");

        $reason.textContent = line.reason;

        $details.append($reason);
        $details.append(new Text(", Cantidad: "));

        const $quantity = document.createElement("span");

        $quantity.textContent = line.quantity.toString();

        $details.append($quantity);

        $root.insertBefore($details, $buttons);
    });

    const $error = $clone.querySelector(".error");

    $buttons.addEventListener("click", (e) => {
        if (e.target.tagName !== "BUTTON")
            return;

        e.target.disabled = true;
        $error.textContent = "";

        chrome.runtime.sendMessage({
            action: e.target.value,
            payload: {
                sessionId: sessionId,
                orderId: data.id
            }
        }, (response) => {
            if (response.status) {
                removeOrderAndCheckIfTheresMore(data.id);
            } else {
                e.target.disabled = false;

                console.error(response.result);

                $error.textContent = "Error al procesar la petición";
            }
        });
    });

    return $clone;
}

function onFetchOrders(response) {
    if (!response.status) {
        console.error(response.result);
        return;
    }

    const $section = document.querySelector("section");

    if (response.result.length === 0) {
        const $h2 = document.createElement("h2");

        $h2.textContent = "No hay nada que mostrar!";

        $section.append($h2);

        return;
    }

    const $fragment = document.createDocumentFragment();
    const $template = document.getElementById("order");

    let $clone;

    response.result.forEach((order) => {
        $clone = $template.content.cloneNode(true);
        
        $clone.querySelector("h3").textContent = order.name;
        $clone.querySelector("span").textContent = new Date(order.create_date + "Z").toLocaleString();
        
        const $article = $clone.querySelector("article");

        $article.dataset.order = order.name.toLowerCase();
        $article.dataset.orderId = order.id.toString();

        $article.querySelector("div").addEventListener("click", (e) => {
            if (!e.currentTarget.dataset.opened) {
                // Close all open details
                document.querySelector(".order__details")?.remove();

                chrome.runtime.sendMessage({
                    action: "get",
                    payload: {
                        sessionId: sessionId,
                        orderId: order.id
                    }
                }, (response) => {
                    if (response.status) {
                        const $fragment = generateDetail(response.result);

                        $article.append($fragment);
                    } else {
                        console.error(response.result);
                    }
                });

                e.currentTarget.dataset.opened = "1";
            } else {
                delete e.currentTarget.dataset.opened;

                document.querySelector(".order__details")?.remove();
            }
        });

        $fragment.appendChild($clone);
    });

    $section.append($fragment);
}
let sessionId = null;

document.addEventListener("DOMContentLoaded", () => {
    // Sesión
    chrome.storage.sync.get(['sessionId'], (data) => {
        if (data.sessionId) {
            console.log("Sesión es: ", sessionId = data.sessionId);
            
            // Fetch orders
            chrome.runtime.sendMessage({
                action: "fetch",
                payload: {
                    sessionId: data.sessionId
                }
            }, onFetchOrders);
        }
    });

    document.querySelector("input").addEventListener("search", (e) => {
        document.querySelectorAll(".order").forEach(($e) => {
            $e.hidden = !$e.dataset.order.includes(e.target.value.toLowerCase());
        });
    });
});

function generateDetail(response) {
    const $template = document.getElementById("detail");
    const $clone = $template.content.cloneNode(true);

    // Partner
    const $$dd = $clone.querySelectorAll("dd");

    $$dd[0].textContent = response.partner.name;
    $$dd[1].textContent = response.partner.vat;
    $$dd[2].textContent = response.partner.address;

    // Products
    const $table = $clone.querySelector("table");
    let $row, $cell;

    response.lines.forEach((line, i) => {
        $row = $table.insertRow(i);
        
        // Data
        $cell = $row.insertCell(0);

        $cell.textContent = line.product;

        $cell = $row.insertCell(1);

        $cell.textContent = line.reason;

        $cell = $row.insertCell(2);

        $cell.textContent = line.quantity.toString();
    });

    // Buttons
    $clone.querySelector("button:nth-child(1)").addEventListener("click", (e) => {
        e.currentTarget.disabled = true;

        chrome.runtime.sendMessage({
            action: "approve",
            payload: {
                sessionId: sessionId,
                orderId: response.id
            }
        }, (response) => (response.status)
            ? $clone.parentElement.remove()
            : e.currentTarget.disabled = false
        );
    });

    $clone.querySelector("button:nth-child(2)").addEventListener("click", (e) => {
        e.currentTarget.disabled = true;

        chrome.runtime.sendMessage({
            action: "dissaprove",
            payload: {
                sessionId: sessionId,
                orderId: response.id
            }
        }, (response) => (response.status)
            ? $clone.parentElement.remove()
            : e.currentTarget.disabled = false
        );
    });

    return $clone;
}

let $temp = null;

function onFetchOrders(response) {
    if (!response.status) {
        console.error(response.result);
        return;
    }

    const $section = document.querySelector("section");
    const $fragment = document.createDocumentFragment();
    const $template = document.getElementById("order");
    let $clone;

    response.result.forEach((order) => {
        $clone = $template.content.cloneNode(true);
        
        $clone.querySelector("h3").textContent = order.name;
        $clone.querySelector("span").textContent = order.create_date;
        
        const $article = $clone.querySelector("article");

        $article.dataset.order = order.name.toLowerCase();

        $article.querySelector("div").addEventListener("click", (e) => {
            if (!e.currentTarget.dataset.opened) {
                // Close all open details
                if ($temp) {
                    $temp.remove();
                    $temp = null;
                }

                chrome.runtime.sendMessage({
                    action: "get",
                    payload: {
                        sessionId: sessionId,
                        orderId: order.id
                    }
                }, (response) => {
                    if (response.status) {
                        $temp = generateDetail(response.result);
    
                        console.dir(e);

                        $article.append($temp);
                    } else {
                        console.error(response.result);
                    }
                });

                e.currentTarget.dataset.opened = "1";
            } else {
                delete e.currentTarget.dataset.opened;

                if ($temp) {
                    $temp.remove();
                    $temp = null;
                }
            }
        });

        $fragment.appendChild($clone);
    });

    $section.append($fragment);
}
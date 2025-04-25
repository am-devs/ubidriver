from datetime import datetime
import pathlib
from xml.dom.minidom import parse, Document, parseString

templates = pathlib.Path(__file__).parent.joinpath("templates.xml")
FORMAT = "%Y-%m-%d %H:%M:%S"

def _get_elements():
    with open(templates) as file:
        document = parse(file)
        elements = document.documentElement.getElementsByTagNameNS("http://schemas.xmlsoap.org/soap/envelope/", "Envelope")

        return elements

def get_invoice_confirm_xml(invoice_id: int):
    element = _get_elements()[0]
    doc = Document()

    id_node = element.getElementsByTagName("adin:RecordID")[0]
    id_node.appendChild(doc.createTextNode(str(invoice_id)))

    date_node = element.getElementsByTagName("adin:val")[1]
    date_node.appendChild(doc.createTextNode(datetime.now().strftime(FORMAT)))

    print(element.toxml())

    return element.toxml()

def get_deliveries_templates(ids: list[int]):
    element = _get_elements()[1]
    doc = Document()
    templates = []

    for i in ids:
        clone = element.cloneNode(True)
        id_node = clone.getElementsByTagName("adin:RecordID")[0]
        id_node.appendChild(doc.createTextNode(str(i)))

        date_node = clone.getElementsByTagName("adin:val")[1]
        date_node.appendChild(doc.createTextNode(datetime.now().strftime(FORMAT)))

        print(clone.toxml())

        templates.append(clone.toxml())

    return templates

def get_return_order_template(description: str, bpartner: int):
    element = _get_elements()[2]
    doc = Document()

    vals = element.getElementsByTagName("adin:val")

    vals[0].appendChild(doc.createTextNode(description))
    vals[1].appendChild(doc.createTextNode(str(bpartner)))

    return element.toxml()

def get_return_line_template(order_id: int, lines: list[object]):
    element = _get_elements()[3]
    doc = Document()
    templates = {}

    for line in lines:
        clone = element.cloneNode(True)
        vals = clone.getElementsByTagName("adin:val")

        vals[0].appendChild(doc.createTextNode(str(order_id)))
        vals[1].appendChild(doc.createTextNode(str(line.product_id)))
        vals[2].appendChild(doc.createTextNode(str(line.quantity)))
        vals[3].appendChild(doc.createTextNode(line.reason))

        print(clone.toxml())

        templates[line.product_id] = clone.toxml()

    return templates

def get_record_id_from_response(stream: str):
    doc = parseString(stream)
    record_id = 0

    print(doc.toxml())

    el = doc.getElementsByTagName("StandardResponse")[0]
    
    if not el:
        return record_id

    return int(el.getAttribute("RecordID"))

if __name__ == "__main__":
    get_invoice_confirm_xml(1)
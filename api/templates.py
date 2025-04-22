from datetime import datetime
import pathlib
from xml.dom.minidom import parse, Document

templates = pathlib.Path(__file__).parent.joinpath("templates.xml")
FORMAT = "%Y-%m-%d %H:%M:%S"

def _get_elements():
    with open(templates) as file:
        document = parse(file)
        elements = document.documentElement.getElementsByTagNameNS("http://schemas.xmlsoap.org/soap/envelope/", "Envelope")

        return elements

def _get_template_with_id(i: int, rec_id: int):
    element = _get_elements()[i]
    doc = Document()

    id_node = element.getElementsByTagName("adin:RecordID")[0]
    id_node.appendChild(doc.createTextNode(str(rec_id)))

    date_node = element.getElementsByTagName("adin:val")[1]
    date_node.appendChild(doc.createTextNode(datetime.now().strftime(FORMAT)))

    return element.toxml()

def get_invoice_confirm_xml(invoice_id: int):
    return _get_template_with_id(0, invoice_id)

def get_delivery_confirm_xml(invoice_id: int):
    return _get_template_with_id(1, invoice_id)

def get_record_id_from_response(stream: str):
    doc = parse(stream)
    record_id = 0

    el = doc.getElementsByTagName("StandardResponse")[0]
    
    if not el:
        return record_id

    return int(el.getAttribute("RecordID"))

if __name__ == "__main__":
    get_invoice_confirm_xml(1)
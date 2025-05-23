import datetime
from pydantic import BaseModel
from services import Database, sent_record_and_get_id
from authentication import create_access_token
from passlib.context import CryptContext
import templates

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class Login(BaseModel):
    cedula: str

    def login(self):
        with Database() as db:
            db.execute("""
SELECT 
    fta_driver_id,
    name
FROM fta_driver
WHERE value = %s""", self.cedula)

            result = db.fetchone()

            if result == None:
                raise Exception("Usuario invalido")
            else:
                return create_access_token({
                    "sub": str(result[0]),
                    "name": result[1],
                })

class Product(BaseModel):
    id: int
    name: str

class InvoiceLine(BaseModel):
    line_id: int
    product: Product
    quantity: float
    uom: str

    @staticmethod
    def get_for_multiple_invoices(db: Database, ids: list[int]):
        data = {i: [] for i in ids}

        db.execute("""
SELECT 
    cil.c_invoiceline_id,
	cil.qtyinvoiced,
	mp.m_product_id,
	mp.name,
    cu.name,
    ci.c_invoice_id
FROM c_invoice ci
JOIN c_invoiceLine cil ON ci.c_invoice_id = cil.c_invoice_id
JOIN m_product mp ON cil.m_product_id = mp.m_product_id
JOIN c_uom cu ON cu.c_uom_id = cil.c_uom_id
WHERE ci.c_invoice_id = ANY(%s)""", ids)

        for rec in db.fetchall():
            line = InvoiceLine(
                line_id=rec[0],
                quantity=rec[1],
                product=Product(id=rec[2], name=rec[3]),
                uom=rec[4]
            )
            
            data[rec[5]].append(line)

        return data

class Invoice(BaseModel):
    code: str
    date_invoice: datetime.date
    invoice_id: int
    organization: str 
    customer_name: str 
    customer_id: int
    lines: list[InvoiceLine] = []

    @staticmethod
    def confirm_invoice(invoice_id: int):
        data = templates.get_invoice_confirm_xml(invoice_id)

        return sent_record_and_get_id(data)
    
    @staticmethod
    def confirm_deliveries(invoice_id: int):
        dels = {}

        with Database() as db:
            db.execute("""
SELECT mi.M_InOut_ID
FROM c_invoice as ci
JOIN c_order co ON co.C_Order_ID = ci.C_Order_ID
JOIN M_InOut mi ON mi.C_Order_ID = co.C_Order_ID
WHERE ci.C_Invoice_ID = %s 
AND (mi.is_confirm IS NULL OR mi.is_confirm='N')
AND mi.docstatus='CO'""", invoice_id)
            
            dels.update({r[0]: False for r in db.fetchall()})

        if not dels:
            return {}
        
        data = templates.get_deliveries_templates(list(dels.keys()))

        for temp in data:
            result = sent_record_and_get_id(temp)

            if result in dels:
                dels[result] = True 

        return dels

    @staticmethod
    def get_by_driver_id(driver_id: int):
        with Database() as db:
            db.execute("""
SELECT DISTINCT
	ci.documentno as code,
	ci.dateacct::date as date_invoice,
	ci.c_invoice_id as invoice_id,
	ado.name as organization,
	cb.name as customer_name,
	cb.C_BPartner_ID as customer_id
FROM FTA_EntryTicket as et
JOIN FTA_LoadOrder as lo ON et.FTA_Driver_ID = lo.FTA_Driver_ID AND lo.FTA_EntryTicket_ID = et.FTA_EntryTicket_ID
JOIN FTA_LoadOrderLine as loline ON lo.FTA_LoadOrder_ID = loline.FTA_LoadOrder_ID 
JOIN C_OrderLine as coline ON loline.C_OrderLine_ID = coline.C_OrderLine_ID
JOIN C_Order as co ON coline.C_Order_ID = co.C_Order_ID
JOIN C_Invoice as ci ON co.C_Order_ID = ci.C_Order_ID
JOIN AD_Org ado ON ci.AD_Org_ID = ado.AD_Org_ID
JOIN C_BPartner cb ON ci.C_BPartner_ID = cb.C_BPartner_ID
JOIN C_DocType as ctype on ci.C_DocType_ID = ctype.C_DocType_ID
JOIN C_DocBaseType as baset on ctype.C_DocBaseType_ID = baset.C_DocBaseType_ID
WHERE ci.docstatus = 'CO'
	AND baset.DocBaseType ='ARI'
    AND (ci.is_confirm !='Y' OR ci.is_confirm is NULL)
    AND et.FTA_Driver_ID = %s""", driver_id)
            
            invoices = {}

            for rec in db.fetchall():
                invoices[rec[2]] = Invoice(
                    code=rec[0],
                    date_invoice=rec[1],
                    invoice_id=rec[2],
                    organization=rec[3],
                    customer_name=rec[4],
                    customer_id =rec[5],
                )

            lines = InvoiceLine.get_for_multiple_invoices(db, list(invoices.keys()))

            for i in lines:
                invoices[i].lines = lines[i]

            return list(invoices.values())
        
class Return(BaseModel):
    c_bpartner_id: int

    def create(self, driver_id: int, driver_name: str):
        data = templates.get_return_order_template(
            f"Orden creada por el chofer: {driver_name} ({driver_id})",
            self.c_bpartner_id
        )

        return sent_record_and_get_id(data)
    
class ReturnLine(BaseModel):
    product_id: int
    quantity: int
    reason: str

def create_return_lines(order_id: int, records: list[ReturnLine]):
    data = templates.get_return_line_template(order_id, records)
    results = {r.product_id: 0 for r in records}

    for pid, data in data.items():
        result = sent_record_and_get_id(data)

        if result:
            results[pid] = result

    return results
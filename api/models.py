import datetime
from typing import Optional
from pydantic import BaseModel
from services import Database
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class Product(BaseModel):
    id: int
    name: str

class InvoiceLine(BaseModel):
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
                quantity=rec[1],
                product=Product(id=rec[2], name=rec[3]),
                uom=rec[4]
            )
            
            data[rec[5]].append(line)

        return data

class Customer(BaseModel):
    customer_id: int
    name: str
    address: str
    vat: str

    @staticmethod
    def get_by_locations(db: Database, locations: list[int]):
        db.execute("""
SELECT
    cb.c_bpartner_id,
    cb.value,
    cb.name,
    cl.address1,
    cbl.c_bpartner_location_id
FROM c_bpartner cb
JOIN c_bpartner_location cbl ON cbl.c_bpartner_id = cb.c_bpartner_id AND cbl.c_bpartner_location_id = ANY(%s)
JOIN c_location cl ON cl.c_location_id = cbl.c_location_id""", locations)
        
        data = {}

        for rec in db.fetchall():
            custom = Customer(
                customer_id=rec[0],
                vat=rec[1],
                name=rec[2],
                address=rec[3]
            )
            
            data[rec[4]] = custom

        return data

class Invoice(BaseModel):
    code: str
    date_invoice: datetime.date
    invoice_id: int
    organization: str 
    customer: Optional[Customer] = None
    lines: list[InvoiceLine] = []
    
    @staticmethod
    def confirm_invoice(invoice_id: int):
        ...

    @staticmethod
    def get_by_driver_and_pattern(driver_id: int, pattern: str):
        with Database() as db:
            db.execute("""
SELECT DISTINCT
	ci.documentno as code,
	ci.dateacct::date as date_invoice,
	ci.c_invoice_id as invoice_id,
	ado.name as organization,
	ci.c_bpartner_location_id as customer_location
FROM FTA_EntryTicket as et
JOIN FTA_LoadOrder as lo ON et.FTA_Driver_ID = lo.FTA_Driver_ID AND lo.FTA_EntryTicket_ID = et.FTA_EntryTicket_ID
JOIN FTA_LoadOrderLine as loline ON lo.FTA_LoadOrder_ID = loline.FTA_LoadOrder_ID 
JOIN C_OrderLine as coline ON loline.C_OrderLine_ID = coline.C_OrderLine_ID
JOIN C_Order as co ON coline.C_Order_ID = co.C_Order_ID
JOIN C_Invoice as ci ON co.C_Order_ID = ci.C_Order_ID
JOIN AD_Org ado ON ci.AD_Org_ID = ado.AD_Org_ID
JOIN C_DocType as ctype on ci.C_DocType_ID = ctype.C_DocType_ID
JOIN C_DocBaseType as baset on ctype.C_DocBaseType_ID = baset.C_DocBaseType_ID
WHERE ci.docstatus = 'CO'
	AND baset.DocBaseType ='ARI'
    AND ci.C_Order_ID IS NOT NULL
    AND et.FTA_Driver_ID = %s
    AND ci.documentno ILIKE %s""", driver_id, f"%{pattern}%")
            
            invoices = {}
            locations = {}

            for rec in db.fetchall():
                invoices[rec[2]] = Invoice(
                    code=rec[0],
                    date_invoice=rec[1],
                    invoice_id=rec[2],
                    organization=rec[3],
                )

                locations[rec[2]] = rec[4]

            lines = InvoiceLine.get_for_multiple_invoices(db, list(invoices.keys()))
            customers = Customer.get_by_locations(db, list(locations.values()))

            for i in lines:
                invoices[i].lines = lines[i]
                invoices[i].customer = customers[locations[i]]

            return list(invoices.values())

def check_for_driver(cedula: str):
    with Database() as db:
        db.execute("""
SELECT fta_driver_id
FROM fta_driver
WHERE value = %s""", cedula)

        result = db.fetchone()

        if result == None:
            return 0
        else:
            return result[0]

class DevolutionType(BaseModel):
    name: str
    devolution_type_id: int

    @staticmethod
    def get_all():
        with Database() as db:
            db.execute("SELECT name, M_RMAType_ID FROM M_RMAType")

            return [DevolutionType(name=r[0], devolution_id=r[1]) for r in db.fetchall()]
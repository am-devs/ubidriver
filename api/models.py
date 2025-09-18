import datetime
from typing import Optional
from pydantic import BaseModel
from services import Database, OdooConnection
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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

class Point(BaseModel):
    latitude: float
    longitude: float

    @staticmethod
    def export_from_customer():
        with Database() as db:
            db.execute("""
SELECT
    cb.c_bpartner_id::integer,
    cl.latitude,
    cl.longitude,
    cb.name
FROM c_bpartner cb
JOIN c_bpartner_location cbl ON cbl.c_bpartner_id = cb.c_bpartner_id
JOIN c_location cl ON cl.c_location_id = cbl.c_location_id
WHERE cl.latitude IS NOT NULL AND cl.longitude IS NOT NULL""")

            data = []

            for rec in db.fetchall():
                data.append({
                    "record_identifer_id": rec[0],
                    "latitude": rec[1],
                    "longitude": rec[2],
                    "name": rec[3]
                })

            return data
        
class Customer(BaseModel):
    customer_id: int
    name: str
    address: str
    vat: str
    coordinates: Optional[Point] = None

    @staticmethod
    def get_by_locations(db: Database, locations: list[int]):
        db.execute("""
SELECT
    cb.c_bpartner_id::integer,
    cb.value,
    cb.name,
    COALESCE(cl.address1, cl.address2, cl.city),
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
                address=rec[3],
            )
            
            data[rec[-1]] = custom

        return data

class ReturnStatus(BaseModel):
    id: int
    approval_status: str

    @staticmethod
    def search_for_invoice_id(invoice_id: int):
        order_id = 0

        with Database() as db:
            db.execute("""
SELECT co.c_order_id::integer
FROM C_Order co
JOIN C_Invoice ci ON co.C_Order_ID = ci.C_Order_ID
WHERE ci.c_invoice_id::integer = %s
LIMIT 1""", invoice_id)
            
            result = db.fetchone()

            if result:
                order_id = result[0]

        if not order_id:
            return None

        with OdooConnection() as conn:
            data = conn.execute(
                "ian.sale.return",
                "action_search_by_adempiere_order",
                order_id
            )

            return ReturnStatus(**data)

class ReturnInvoiceLine(BaseModel):
    line_id: int
    quantity: float
    devolution_type_id: int

class ReturnInvoice(BaseModel):
    lines: list[ReturnInvoiceLine]
    coordinates: Optional[Point] = None

    def return_invoice(self, invoice_id: int):
        order_id, partner_id = 0, 0
        line_products = {}

        with Database() as db:
            db.execute("""
SELECT co.c_order_id::integer, co.c_bpartner_id::integer
FROM C_Order co
JOIN C_Invoice ci ON co.C_Order_ID = ci.C_Order_ID
WHERE ci.c_invoice_id::integer = %s
LIMIT 1""", invoice_id)
            
            result = db.fetchone()

            if result:
                order_id = result[0]
                partner_id = result[1]
            else:
                raise Exception("No se encontró una venta por ese ID")

            db.execute("""
SELECT c_invoiceline_id::integer, m_product_id::integer
FROM c_invoiceLine
WHERE c_invoiceline_id = ANY(%s)""", [l.line_id for l in self.lines])
            
            line_products = {r[0]: r[1] for r in db.fetchall()}

        vals = []

        for line in self.lines:
            dump = line.model_dump()

            dump["product_id"] = line_products.get(line.line_id, 0)

            vals.append(dump)

        with OdooConnection() as conn:
            result = conn.execute(
                "ian.sale.return",
                "action_create_from_adempiere_data",
                {
                    "order_id": order_id,
                    "partner_id": partner_id,
                    "lines": vals,
                    "coordinates": self.coordinates and self.coordinates.model_dump()
                }
            )

            return result

class Invoice(BaseModel):
    code: str
    date_invoice: datetime.date
    invoice_id: int
    organization: str 
    customer: Optional[Customer] = None
    lines: list[InvoiceLine] = []
    order_id: int
    return_status: Optional[ReturnStatus] = None
    
    @staticmethod
    def confirm_invoice(invoice_id: int, coordinates: Point = None):
        order_ids = []

        with Database() as db:
            db.execute("""
SELECT co.c_order_id::integer
FROM C_Order co
JOIN C_Invoice ci ON co.C_Order_ID = ci.C_Order_ID
WHERE ci.c_invoice_id = %s""", invoice_id)
            
            order_ids.extend(r[0] for r in db.fetchall())

            db.execute("""
UPDATE C_Invoice 
SET is_confirm = 'Y'
WHERE c_invoice_id = %s""", invoice_id)

        if not order_ids:
            return True

        with OdooConnection() as conn:
            ids = conn.search_ids("sale.order", [("record_identifer_id", "in", order_ids), ("is_direct_dispatch","=",True)])

            if not ids:
                return True

            conn.execute("sale.order", "action_confirm_delivery_by_driver", ids, coordinates and coordinates.model_dump())

        return True

    @staticmethod
    def get_by_driver(driver_id: int):
        with Database() as db:
            db.execute("""
SELECT DISTINCT
	ci.documentno as code,
	ci.dateacct::date as date_invoice,
	ci.c_invoice_id as invoice_id,
	ado.name as organization,
	ci.c_bpartner_location_id as customer_location,
    co.c_order_id as order_id
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
	AND ci.is_confirm IS NULL
ORDER BY ci.dateacct::date DESC""", driver_id)

            invoices = {}
            locations = {}

            for rec in db.fetchall():
                invoices[rec[2]] = Invoice(
                    code=rec[0],
                    date_invoice=rec[1],
                    invoice_id=rec[2],
                    organization=rec[3],
                    order_id=rec[5]
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

            return [DevolutionType(name=r[0], devolution_type_id=r[1]) for r in db.fetchall()]
        
    @staticmethod
    def to_export():
        with Database() as db:
            db.execute("SELECT name, M_RMAType_ID FROM M_RMAType")

            return [{"name": r[0], "record_identifer_id": r[1]} for r in db.fetchall()]
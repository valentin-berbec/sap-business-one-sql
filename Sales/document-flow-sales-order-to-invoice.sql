-- Document Flow: Sales Order → Delivery → A/R Invoice
-- Purpose: Trace how a sales order becomes a delivery and then an invoice
-- This demonstrates how SAP Business One links marketing documents

SELECT
    SO.DocNum AS SalesOrder,
    SO.DocDate AS OrderDate,
    SO.CardCode,
    SO.CardName,

    DL.DocNum AS DeliveryNumber,
    DL.DocDate AS DeliveryDate,

    INV.DocNum AS InvoiceNumber,
    INV.DocDate AS InvoiceDate

FROM ORDR SO

LEFT JOIN RDR1 SOL
    ON SO.DocEntry = SOL.DocEntry

LEFT JOIN DLN1 DL1
    ON DL1.BaseEntry = SOL.DocEntry
    AND DL1.BaseLine = SOL.LineNum
    AND DL1.BaseType = 17

LEFT JOIN ODLN DL
    ON DL.DocEntry = DL1.DocEntry

LEFT JOIN INV1 INV1
    ON INV1.BaseEntry = DL1.DocEntry
    AND INV1.BaseLine = DL1.LineNum
    AND INV1.BaseType = 15

LEFT JOIN OINV INV
    ON INV.DocEntry = INV1.DocEntry

ORDER BY SO.DocNum

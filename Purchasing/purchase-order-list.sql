/*
Query: Purchase Order List
Module: Purchasing

Purpose:
Display purchase orders and their line details within a selected date range,
with the option to filter by document status.

This query is useful for reviewing supplier orders, checking ordered items,
and monitoring open or closed purchase orders in SAP Business One.

Tables Used:
OPOR – Purchase Order Header
POR1 – Purchase Order Rows

Key Fields:
CardCode   – Supplier code
CardName   – Supplier name
DocNum     – Purchase order number
DocDate    – Purchase order date
DocStatus  – Document status (for example: O = Open, C = Closed)
DocCur     – Document currency
ItemCode   – Item code
Dscription – Item description
Quantity   – Ordered quantity
Price      – Unit price
LineTotal  – Line total in local currency
TotalFrgn  – Line total in foreign currency

Parameters:
[%0] – Document status filter
[%1] – Start date
[%2] – End date

Notes:
- If the purchase order is in GBP, the query shows LineTotal.
- If the purchase order is in a foreign currency, the query shows TotalFrgn.
- This keeps the displayed net value aligned to the document currency.
*/

SELECT
    T0.[CardCode] AS 'Supplier A/c',
    T0.[CardName] AS 'Supplier Name',
    T0.[DocNum] AS 'Purchase Order No',
    T0.[DocDate] AS 'Doc Date',
    CONVERT(VARCHAR(10), T0.[DocDate], 103) AS 'Doc Date (Formatted)',
    T0.[DocStatus] AS 'Doc Status',
    T0.[DocCur] AS 'Doc Currency',
    T1.[ItemCode] AS 'Item Code',
    T1.[Dscription] AS 'Item Description',
    T1.[Quantity] AS 'Quantity',
    T1.[Price] AS 'Unit Price',
    ROUND(
        CASE
            WHEN T0.[DocCur] = 'GBP' THEN T1.[LineTotal]
            ELSE T1.[TotalFrgn]
        END,
        2
    ) AS 'Net Value'

FROM OPOR T0

INNER JOIN POR1 T1
    ON T1.[DocEntry] = T0.[DocEntry]

WHERE
    T0.[DocStatus] LIKE '%[%0]%'
    AND T0.[DocDate] BETWEEN '[%1]' AND '[%2]'

ORDER BY
    T0.[DocDate],
    T0.[DocNum]

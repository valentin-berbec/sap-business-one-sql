/*
Query: Daily Returned Items (Credit Notes)
Module: Inventory / Sales Returns

Purpose:
Identify items returned by customers on a specific date using A/R Credit Notes.

This helps inventory and quality teams analyse product returns and identify
patterns such as defective products, incorrect shipments, or customer issues.

Tables Used:
ORIN – A/R Credit Note (Header)
RIN1 – A/R Credit Note Rows (Items returned)

Key Fields:
DocNum   – Credit note number
DocDate  – Credit note posting date
ItemCode – Item returned
Quantity – Quantity returned
U_CRNAnal – Return reason code (custom user-defined field)

Parameter:
[%0] – Date selected by the user when running the query in SAP Query Manager
*/

SELECT
    T1.[U_CRNAnal]  AS 'Return Code',
    T0.[ItemCode]   AS 'Item No',
    T0.[Quantity]   AS 'Quantity',
    T1.[DocNum]     AS 'Credit Note No',
    T1.[DocDate]    AS 'Document Date'

FROM RIN1 T0

INNER JOIN ORIN T1
    ON T0.[DocEntry] = T1.[DocEntry]

WHERE T1.[DocDate] = [%0]

ORDER BY
    T1.[DocNum] DESC

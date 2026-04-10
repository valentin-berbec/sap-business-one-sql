-- Inactive Customers Report
-- Purpose: Identify customers who have not purchased in the last 90 days
-- Useful for sales teams to identify accounts that need re-engagement

SELECT 
    T0.CardCode,
    T0.CardName,
    MAX(T1.DocDate) AS LastInvoiceDate
FROM OCRD T0

LEFT JOIN OINV T1 
    ON T0.CardCode = T1.CardCode

WHERE T0.CardType = 'C'

GROUP BY 
    T0.CardCode,
    T0.CardName

HAVING MAX(T1.DocDate) < DATEADD(DAY,-90,GETDATE())

ORDER BY LastInvoiceDate

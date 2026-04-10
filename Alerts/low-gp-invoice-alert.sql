/*
Query: Low Gross Profit Invoice Alert
Module: Alerts / Sales / Margin Control

Purpose:
Identify sales invoices created yesterday where the overall invoice gross profit
percentage is below 40%.

This query is designed as an alert to highlight potentially low-margin or
unprofitable transactions so they can be reviewed by management or the sales team.

Business Use:
- Detect low-margin invoices
- Review pricing issues or discounting
- Monitor commercial performance
- Exclude free of charge or nominal-value transactions

Source Objects:
vLineSales – Sales line reporting view
OSLP       – Sales employee / sales representative master

Key Fields:
DocNum            – Invoice number
CardCode          – Customer code
CardName          – Customer name
SlpName           – Sales representative
U_CC_Rgn          – Division / region
DocCur            – Document currency
NettLineTotalDC   – Net sales value in document currency
LnGPDC            – Gross profit in document currency

Logic:
1. Pull invoice line data created yesterday
2. Group by invoice and item in the CTE
3. Summarise again at invoice level
4. Calculate GP %
5. Return only invoices where GP % is below 40%
6. Exclude invoices with sales value of 1 or less

Notes:
- This version is invoice-level
- Threshold: GP % < 40
- Date filter: yesterday
- Sales document type filtered as invoice (Doc = 'IV')
*/

WITH [Details] AS
(
    SELECT
        T0.[DocNum],
        T0.[CardCode],
        T0.[CardName],
        T1.[SlpName] AS [ivRep],
        T1.[U_CC_Rgn] AS [Div],
        T0.[ItemCode],
        SUM(T0.[Qty]) AS [Qty],
        T0.[DocCur],
        SUM(T0.[NettLineTotalDC]) AS [Sales],
        SUM(T0.[LnGPDC]) AS [GP],
        CASE
            WHEN SUM(T0.[NettLineTotalDC]) = 0 THEN -100
            ELSE CONVERT(DEC(8,1), SUM(T0.[LnGPDC]) / SUM(T0.[NettLineTotalDC]) * 100)
        END AS [GP-Prcnt]
    FROM [vLineSales] T0
    INNER JOIN [OSLP] T1
        ON T1.[SlpCode] = T0.[SlpCode]
    WHERE
        T0.[CreateDate] = CAST(GETDATE() - 1 AS DATE)
        AND T0.[Doc] = 'IV'
    GROUP BY
        T0.[DocNum],
        T0.[CardCode],
        T0.[CardName],
        T1.[SlpName],
        T1.[U_CC_Rgn],
        T0.[ItemCode],
        T0.[DocCur]
)

SELECT
    T0.[DocNum],
    T0.[CardCode],
    T0.[CardName],
    T0.[ivRep],
    T0.[Div],
    T0.[DocCur],
    CONVERT(DEC(8,2), SUM(T0.[Sales])) AS [Sales],
    CONVERT(DEC(8,2), SUM(T0.[GP])) AS [GP],
    CASE
        WHEN SUM(T0.[Sales]) = 0 THEN -100
        ELSE CONVERT(DEC(8,1), SUM(T0.[GP]) / SUM(T0.[Sales]) * 100)
    END AS [GP-Prcnt]
FROM [Details] T0
GROUP BY
    T0.[DocNum],
    T0.[CardCode],
    T0.[CardName],
    T0.[ivRep],
    T0.[Div],
    T0.[DocCur]
HAVING
    (
        CASE
            WHEN SUM(T0.[Sales]) = 0 THEN -100
            ELSE CONVERT(DEC(8,1), SUM(T0.[GP]) / SUM(T0.[Sales]) * 100)
        END
    ) < 40
    AND SUM(T0.[Sales]) > 1

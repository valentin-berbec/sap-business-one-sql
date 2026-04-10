-- Customer Aging Summary
-- Purpose: Show outstanding customer balances by aging bucket
-- Useful for credit control and accounts receivable review

SELECT
    T0.CardCode,
    T0.CardName,
    SUM(CASE WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) <= 0 THEN T0.DocTotal - T0.PaidToDate ELSE 0 END) AS CurrentBucket,
    SUM(CASE WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) BETWEEN 1 AND 30 THEN T0.DocTotal - T0.PaidToDate ELSE 0 END) AS Bucket_1_30,
    SUM(CASE WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) BETWEEN 31 AND 60 THEN T0.DocTotal - T0.PaidToDate ELSE 0 END) AS Bucket_31_60,
    SUM(CASE WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) BETWEEN 61 AND 90 THEN T0.DocTotal - T0.PaidToDate ELSE 0 END) AS Bucket_61_90,
    SUM(CASE WHEN DATEDIFF(DAY, T0.DocDueDate, GETDATE()) > 90 THEN T0.DocTotal - T0.PaidToDate ELSE 0 END) AS Bucket_90_Plus,
    SUM(T0.DocTotal - T0.PaidToDate) AS TotalOutstanding
FROM OINV T0
WHERE
    T0.DocStatus = 'O'
    AND T0.CANCELED = 'N'
GROUP BY
    T0.CardCode,
    T0.CardName
HAVING
    SUM(T0.DocTotal - T0.PaidToDate) <> 0
ORDER BY
    TotalOutstanding DESC

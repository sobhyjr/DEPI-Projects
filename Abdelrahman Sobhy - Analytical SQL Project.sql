----- Q1 -----

-- 1) WHAT'S THE MOST COUNTRY PURCHASED CUSTOMERS? --
-- View countries ranking in purchasing in descending order --
SELECT  Country,
        COUNT(InvoiceNo) AS [Number of Purchased],
        RANK() OVER (ORDER BY COUNT(InvoiceNo) DESC) AS Rank 
FROM DBO.[Online Retail]
GROUP BY Country
ORDER BY [Number of Purchased] DESC

-- 2) WHAT'S THE MOST PURCHASED ITEM? --
-- View number of items ranking in descending order --
SELECT StockCode,
       Description,
       COUNT(StockCode) AS [Number of Purchased],
	   RANK() OVER (ORDER BY COUNT(StockCode) DESC) AS Rank
FROM DBO.[Online Retail] 
GROUP BY StockCode, Description
ORDER BY [Number of Purchased] DESC

-- 3) WHAT'S THE MOST PURCHASED ITEM IN EACH COUNTRY? --
--  View each country with alphabatic order and number of sold items per country --
SELECT DISTINCT Country,
       COUNT(InvoiceNo) OVER (PARTITION BY COUNTRY) AS [Number of Sold Items] 
FROM DBO.[Online Retail]
ORDER BY COUNTRY

-- 4) WHAT'S TOP 20 DAYS OF YEARS THAT HAVE THE MOST PURCHASED ITEMS? --
-- View top 20 days of highest purchasing and found highest item sold at the middle of every month --
SELECT DISTINCT TOP 20 InvoiceDate,
       COUNT(StockCode) OVER (PARTITION BY INVOICEDATE) AS [Number of Sold Items]
FROM DBO.[Online Retail]
WHERE InvoiceDate IS NOT NULL
ORDER BY [Number of Sold Items] DESC

-- 5- WHAT'S TOP 10 CUSTOMERS (VIP)? --
-- View top 10 customer who made the most invoices ordering by number of invoices descendingly--
SELECT TOP 10 CustomerID,
       COUNT(InvoiceNo) AS [Number of Invoices] 
FROM [Online Retail]
GROUP BY CustomerID
HAVING CustomerID IS NOT NULL
ORDER BY [Number of Invoices] DESC





----- Q2 -----

SELECT *,
        CASE WHEN Y.[Recency Score] = 5 AND Y.[FM Score] = 5 THEN 'Champions'
	         WHEN Y.[Recency Score] = 5 AND Y.[FM Score] = 4 THEN 'Champions'
		     WHEN Y.[Recency Score] = 4 AND Y.[FM Score] = 5 THEN 'Champions'

	         WHEN Y.[Recency Score] = 5 AND Y.[FM Score] = 2 THEN 'Potential Loyalists'
			 WHEN Y.[Recency Score] = 4 AND Y.[FM Score] = 2 THEN 'Potential Loyalists'
			 WHEN Y.[Recency Score] = 3 AND Y.[FM Score] = 3 THEN 'Potential Loyalists'
			 WHEN Y.[Recency Score] = 4 AND Y.[FM Score] = 3 THEN 'Potential Loyalists'

			 WHEN Y.[Recency Score] = 5 AND Y.[FM Score] = 3 THEN 'Loyal Customers'
			 WHEN Y.[Recency Score] = 4 AND Y.[FM Score] = 4 THEN 'Loyal Customers'
			 WHEN Y.[Recency Score] = 3 AND Y.[FM Score] = 5 THEN 'Loyal Customers'
			 WHEN Y.[Recency Score] = 3 AND Y.[FM Score] = 4 THEN 'Loyal Customers'

			 WHEN Y.[Recency Score] = 5 AND Y.[FM Score] = 1 THEN 'Recent Customers'

			 WHEN Y.[Recency Score] = 4 AND Y.[FM Score] = 1 THEN 'Promising'
			 WHEN Y.[Recency Score] = 3 AND Y.[FM Score] = 1 THEN 'Promising'

			 WHEN Y.[Recency Score] = 3 AND Y.[FM Score] = 2 THEN 'Customers Needing Attention'
			 WHEN Y.[Recency Score] = 2 AND Y.[FM Score] = 3 THEN 'Customers Needing Attention'
			 WHEN Y.[Recency Score] = 2 AND Y.[FM Score] = 2 THEN 'Customers Needing Attention'

			 WHEN Y.[Recency Score] = 2 AND Y.[FM Score] = 5 THEN 'At Risk'
			 WHEN Y.[Recency Score] = 2 AND Y.[FM Score] = 4 THEN 'At Risk'
			 WHEN Y.[Recency Score] = 1 AND Y.[FM Score] = 3 THEN 'At Risk'

			 WHEN Y.[Recency Score] = 1 AND Y.[FM Score] = 5 THEN 'Cant Lose Them'
			 WHEN Y.[Recency Score] = 1 AND Y.[FM Score] = 4 THEN 'Cant Lose Them'

			 WHEN Y.[Recency Score] = 1 AND Y.[FM Score] = 2 THEN 'Hibernating'

			 WHEN Y.[Recency Score] = 1 AND Y.[FM Score] = 1 THEN 'Lost'
			 ELSE 'Not Specified'
	    END AS [Customer Segment]
FROM
(
SELECT DISTINCT CustomerID,
       Recency,
	   Frequency,
	   Monetary,
       CASE WHEN Recency <= 30 THEN 5
            WHEN Recency <= 60 THEN 4 
	     	WHEN Recency <= 90 THEN 3
			WHEN Recency <= 120 THEN 2
		    ELSE 1
	   END AS [Recency Score],
       (NTILE(5) OVER (ORDER BY Frequency DESC) +
	    NTILE(5) OVER (ORDER BY Monetary DESC)) / 2 AS [FM Score]
FROM
(
SELECT CustomerID,
       DATEDIFF(DAY,InvoiceDate,MAX(InvoiceDate) OVER()) AS [Recency],
	   COUNT(InvoiceNo) OVER (PARTITION BY CustomerID) AS [Frequency],
	   ROUND(SUM(Quantity * UnitPrice) OVER (PARTITION BY CustomerID),2) AS [Monetary]
	   FROM [Online Retail]
WHERE CustomerID IS NOT NULL AND InvoiceDate IS NOT NULL AND Quantity >= 0
) X
) Y


------- ANOTHER SOLUTION WITH CTE APPROACH -------

--WITH RFM AS 
--(
--SELECT CustomerID,
--       DATEDIFF(DAY,InvoiceDate,MAX(InvoiceDate) OVER()) AS [Recency],
--	   COUNT(InvoiceNo) OVER (PARTITION BY CustomerID) AS [Frequency],
--	   ROUND(SUM(Quantity * UnitPrice) OVER (PARTITION BY CustomerID),2) AS [Monetary]
--	   FROM [Online Retail]
--WHERE CustomerID IS NOT NULL AND InvoiceDate IS NOT NULL AND Quantity >= 0
--)
--SELECT DISTINCT CustomerID,
--       Recency,
--	   Frequency,
--	   Monetary,
--	   CASE WHEN Recency <= 30 THEN 5
--            WHEN Recency <= 60 THEN 4 
--			WHEN Recency <= 90 THEN 3
--			WHEN Recency <= 120 THEN 2
--		    ELSE 1
--	   END AS [Recency Score],
--       (NTILE(5) OVER (ORDER BY Frequency DESC) +
--	    NTILE(5) OVER (ORDER BY Monetary DESC)) / 2 AS [FM Score]
--FROM RFM
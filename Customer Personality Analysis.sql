-- This query divides age into segments and comparing the most spending product category by each age segments
SELECT [Age Segment],
        CASE WHEN [Total Spent On Juice] >= [Total Spent On Fruits] AND
                  [Total Spent On Juice] >= [Total Spent On Meat] AND
				  [Total Spent On Juice] >= [Total Spent On Fish] AND
				  [Total Spent On Juice] >= [Total Spent On Sweet] AND
				  [Total Spent On Juice] >= [Total Spent On Gold] THEN 'Juice Products'

             WHEN [Total Spent On Fruits] >= [Total Spent On Juice] AND
                  [Total Spent On Fruits] >= [Total Spent On Meat] AND
				  [Total Spent On Fruits] >= [Total Spent On Fish] AND
				  [Total Spent On Fruits] >= [Total Spent On Sweet] AND
				  [Total Spent On Fruits] >= [Total Spent On Gold] THEN 'Fruits'

		     WHEN [Total Spent On Meat] >= [Total Spent On Juice] AND
                  [Total Spent On Meat] >= [Total Spent On Fruits] AND
				  [Total Spent On Meat] >= [Total Spent On Fish] AND
				  [Total Spent On Meat] >= [Total Spent On Sweet] AND
				  [Total Spent On Meat] >= [Total Spent On Gold] THEN 'Meat Products'

	         WHEN [Total Spent On Fish] >= [Total Spent On Fruits] AND
                  [Total Spent On Fish] >= [Total Spent On Meat] AND
				  [Total Spent On Fish] >= [Total Spent On Juice] AND
				  [Total Spent On Fish] >= [Total Spent On Sweet] AND
				  [Total Spent On Fish] >= [Total Spent On Gold] THEN 'Fish Products'

		     WHEN [Total Spent On Sweet] >= [Total Spent On Fruits] AND
                  [Total Spent On Sweet] >= [Total Spent On Meat] AND
				  [Total Spent On Sweet] >= [Total Spent On Juice] AND
				  [Total Spent On Sweet] >= [Total Spent On Fish] AND
				  [Total Spent On Sweet] >= [Total Spent On Gold] THEN 'Sweet Products'

	         ELSE 'Gold Products'
	    END AS [Most Category Spent On]
FROM
(
SELECT [Age Segment],
       SUM([Total Spent on Juice]) AS [Total Spent on Juice],
	   SUM([Total Spent on Fruits]) AS [Total Spent on Fruits],
	   SUM([Total Spent on Meat]) AS [Total Spent on Meat],
	   SUM([Total Spent on Fish]) AS [Total Spent on Fish],
	   SUM([Total Spent on Sweet]) AS [Total Spent on Sweet],
       SUM([Total Spent on Gold]) AS [Total Spent on Gold]
FROM
(
SELECT CASE 
           WHEN Age < 20 THEN 'Teenagers'
		   WHEN Age < 30 THEN 'Young Adults'
		   WHEN Age < 40 THEN 'Adults'
		   WHEN Age < 60 THEN 'Middle-aged Adults'
		   WHEN Age >= 60 THEN 'Seniors'
	   END AS [Age Segment],*
FROM
(
SELECT 2014 - YEAR_BIRTH AS [Age],
       SUM(MntJuiceProducts) AS [Total Spent on Juice],
	   SUM(MntFruits) AS [Total Spent on Fruits],
	   SUM(MntMeatProducts) AS [Total Spent on Meat],
	   SUM(MntFishProducts) AS [Total Spent on Fish],
	   SUM(MntSweetProducts) AS [Total Spent on Sweet],
       SUM(MntGoldProds) AS [Total Spent on Gold]
FROM DBO.marketing_campaign
GROUP BY 2014 - YEAR_BIRTH
) X
) Y
GROUP BY [Age Segment]
) Z


--------------------------------------------------------------------------------

-- Also dividing ages into segments and then calculating average spent on Sweet
SELECT [Age Segment],
        ROUND(AVG([Amount Spent on Sweet]),2) AS [Average Spent on Sweet]
FROM
(
SELECT CASE 
           WHEN Age < 20 THEN 'Teenagers'
		   WHEN Age < 30 THEN 'Young Adults'
		   WHEN Age < 40 THEN 'Adults'
		   WHEN Age < 60 THEN 'Middle-aged Adults'
		   WHEN Age >= 60 THEN 'Seniors'
	   END AS [Age Segment],
	   [Amount Spent on Sweet]
FROM
(
SELECT 2014 - YEAR_BIRTH AS [Age],
       (MntSweetProducts) AS [Amount Spent on Sweet]
       
FROM DBO.marketing_campaign
) X
) Y
GROUP BY [Age Segment]
ORDER BY [Average Spent on Sweet] DESC


--------------------------------------------------------------------------------

-- Sum up Kids and Teens into one column and then calculating total spent by each category grouping by number of new column (kids & teens)
SELECT Kidhome + Teenhome AS [Kids & Teens], 
       SUM(MntJuiceProducts) [Total Spent on Juice],
       SUM(MntFruits) [Total Spent on Fruits],
       SUM(MntMeatProducts) [Total Spent on Meat],
       SUM(MntFishProducts) [Total Spent on Fish],
       SUM(MntSweetProducts) [Total Spent on Sweet],
       SUM(MntGoldProds) [Total Spent on Gold]
FROM dbo.marketing_campaign
GROUP BY Kidhome + Teenhome
ORDER BY Kidhome + Teenhome


--------------------------------------------------------------------------------

-- Another approach by calculating total spent of all product categories grouping by new column (kids & teens)
SELECT [Kids & Teens],
       [Total Spent on Juice] +
	   [Total Spent on Fish] +
	   [Total Spent on Fruits] +
	   [Total Spent on Meat] + 
	   [Total Spent on Sweet] +
	   [Total Spent on Gold] AS [Total Spent]
FROM
(
SELECT Kidhome + Teenhome AS [Kids & Teens], 
       SUM(MntJuiceProducts)  [Total Spent on Juice],
       SUM(MntFruits) [Total Spent on Fruits],
       SUM(MntMeatProducts) [Total Spent on Meat],
       SUM(MntFishProducts) [Total Spent on Fish],
       SUM(MntSweetProducts) [Total Spent on Sweet],
       SUM(MntGoldProds) [Total Spent on Gold]
FROM dbo.marketing_campaign
GROUP BY Kidhome + Teenhome
) X
ORDER BY [Kids & Teens]


--------------------------------------------------------------------------------

-- Calculating Recency score from 1 to 5 in which 5 is the best result for recent puchasing customers, using it the subquery
-- to calculate the sum of each campaign and group by recency score, lastly using ranking function to rank each campaign by recency score
SELECT [Recency Score],
       ROW_NUMBER() OVER (ORDER BY [Campaign 1] DESC) AS [Campaign 1 Rank],
	   ROW_NUMBER() OVER (ORDER BY [Campaign 2] DESC) AS [Campaign 2 Rank],
	   ROW_NUMBER() OVER (ORDER BY [Campaign 3] DESC) AS [Campaign 3 Rank],
	   ROW_NUMBER() OVER (ORDER BY [Campaign 4] DESC) AS [Campaign 4 Rank],
	   ROW_NUMBER() OVER (ORDER BY [Campaign 5] DESC) AS [Campaign 5 Rank],
	   ROW_NUMBER() OVER (ORDER BY [Last Campaign] DESC) AS [Last Campaign Rank]

FROM   
(
SELECT [Recency Score],
       SUM(AcceptedCmp1) AS [Campaign 1],
	   SUM(AcceptedCmp2) AS [Campaign 2],
	   SUM(AcceptedCmp3) AS [Campaign 3],
	   SUM(AcceptedCmp4) AS [Campaign 4],
	   SUM(AcceptedCmp5) AS [Campaign 5],
	   SUM(Response) AS [Last Campaign]
FROM 
(
SELECT CASE WHEN Recency < 20 THEN 5
            WHEN Recency < 40 THEN 4
			WHEN Recency < 60 THEN 3
			WHEN Recency < 80 THEN 2
			ELSE 1
			END AS [Recency Score],
			AcceptedCmp1,
			AcceptedCmp2,
			AcceptedCmp3,
			AcceptedCmp4,
			AcceptedCmp5,
			Response
FROM DBO.marketing_campaign
) X
GROUP BY [Recency Score]
) Y
ORDER BY [Recency Score] DESC


--------------------------------------------------------------------------------

-- Calculating Recency score versus total campaign participation
SELECT [Recency Score],
       [Campaign 1] +
	   [Campaign 2] +
	   [Campaign 3] +
	   [Campaign 4] +
	   [Campaign 5] +
	   [Last Campaign] AS [Total Campaign Participation] 
FROM   
(
SELECT [Recency Score],
       SUM(AcceptedCmp1) AS [Campaign 1],
	   SUM(AcceptedCmp2) AS [Campaign 2],
	   SUM(AcceptedCmp3) AS [Campaign 3],
	   SUM(AcceptedCmp4) AS [Campaign 4],
	   SUM(AcceptedCmp5) AS [Campaign 5],
	   SUM(Response) AS [Last Campaign]
FROM 
(
SELECT CASE WHEN Recency < 20 THEN 5
            WHEN Recency < 40 THEN 4
			WHEN Recency < 60 THEN 3
			WHEN Recency < 80 THEN 2
			ELSE 1
			END AS [Recency Score],
			AcceptedCmp1,
			AcceptedCmp2,
			AcceptedCmp3,
			AcceptedCmp4,
			AcceptedCmp5,
			Response
FROM DBO.marketing_campaign
) X
GROUP BY [Recency Score]
) Y
ORDER BY [Recency Score] DESC


--------------------------------------------------------------------------------

-- Comparing between Complaining and Non-complaining customers by Number of Customers, Campaign Responsiveness,
-- Number of Purchases and Total Spending
SELECT [Customer Segment],
       COUNT(Complain) AS [No. of Customers],
       SUM([Campaigns Responsiveness]) AS [Campaigns Responsiveness],
	   SUM([Number of Purchases]) AS [Number of Purchases],
	   SUM([Total Spending]) AS [Total Spending]
FROM
(
SELECT CASE
           WHEN Complain = 0 THEN 'Non-Complaining Customers'
           ELSE 'Complaining Customers'
       END AS [Customer Segment],
	   Complain,
	   AcceptedCmp1 + 
       AcceptedCmp2 + 
	   AcceptedCmp3 + 
	   AcceptedCmp4 + 
	   AcceptedCmp5 + 
	   Response AS [Campaigns Responsiveness],
	   NumDealsPurchases +
	   NumCatalogPurchases +
	   NumStorePurchases +
	   NumWebPurchases AS [Number of Purchases],
       MntJuiceProducts + 
	   MntFruits + 
	   MntMeatProducts + 
	   MntFishProducts + 
	   MntSweetProducts + 
	   MntGoldProds AS [Total Spending]
FROM DBO.marketing_campaign
) X
GROUP BY [Customer Segment]


--------------------------------------------------------------------------------

-- Calculating average spent by Education
SELECT Education,
       ROUND(AVG([Total Spent]),1) AS [Average Spent]
FROM
(
SELECT Education,
	   MntJuiceProducts +
	   MntFruits +
	   MntMeatProducts + 
	   MntFishProducts +
	   MntSweetProducts + 
       MntGoldProds AS [Total Spent]
FROM DBO.marketing_campaign
) X
GROUP BY Education
ORDER BY [Average Spent] DESC


--------------------------------------------------------------------------------

-- Calculating Number of Customers by Education
SELECT DISTINCT Education,
				COUNT(ID) OVER (PARTITION BY Education) AS [Number of Customers]
FROM DBO.marketing_campaign
ORDER BY [Number of Customers] DESC


--------------------------------------------------------------------------------

-- Calculating Total spent of each category and rank up each product category by Education
SELECT Education,
       [Total Spent On Juice],
       ROW_NUMBER() OVER (ORDER BY [Total Spent On Juice] DESC) AS [Juice Total Spent Rank],
	   [Total Spent On Fruits],
       ROW_NUMBER() OVER (ORDER BY [Total Spent On Fruits] DESC) AS [Fruits Total Spent Rank],
	   [Total Spent On Meat],
       ROW_NUMBER() OVER (ORDER BY [Total Spent On Meat] DESC) AS [Meat Total Spent Rank],
	   [Total Spent On Fish],
       ROW_NUMBER() OVER (ORDER BY [Total Spent On Fish] DESC) AS [Fish Total Spent Rank],
	   [Total Spent On Sweet],
       ROW_NUMBER() OVER (ORDER BY [Total Spent On Sweet] DESC) AS [Sweet Total Spent Rank],
	   [Total Spent On Gold],
       ROW_NUMBER() OVER (ORDER BY [Total Spent On Gold] DESC) AS [Gold Total Spent Rank]

FROM
(
SELECT DISTINCT Education,
				SUM(MntJuiceProducts) OVER (PARTITION BY Education) AS [Total Spent On Juice],
				SUM(MntFruits) OVER (PARTITION BY Education) AS [Total Spent On Fruits],
				SUM(MntMeatProducts) OVER (PARTITION BY Education) AS [Total Spent On Meat],
				SUM(MntFishProducts) OVER (PARTITION BY Education) AS [Total Spent On Fish],
				SUM(MntSweetProducts) OVER (PARTITION BY Education) AS [Total Spent On Sweet],
				SUM(MntGoldProds) OVER (PARTITION BY Education) AS [Total Spent On Gold]
FROM DBO.marketing_campaign
) X


--------------------------------------------------------------------------------

-- Calculating Total spent of each category and the most category by Education
SELECT  Education,
        CASE WHEN [Total Spent On Juice] >= [Total Spent On Fruits] AND
                  [Total Spent On Juice] >= [Total Spent On Meat] AND
				  [Total Spent On Juice] >= [Total Spent On Fish] AND
				  [Total Spent On Juice] >= [Total Spent On Sweet] AND
				  [Total Spent On Juice] >= [Total Spent On Gold] THEN 'Juice Products'

             WHEN [Total Spent On Fruits] >= [Total Spent On Juice] AND
                  [Total Spent On Fruits] >= [Total Spent On Meat] AND
				  [Total Spent On Fruits] >= [Total Spent On Fish] AND
				  [Total Spent On Fruits] >= [Total Spent On Sweet] AND
				  [Total Spent On Fruits] >= [Total Spent On Gold] THEN 'Fruits'

		     WHEN [Total Spent On Meat] >= [Total Spent On Juice] AND
                  [Total Spent On Meat] >= [Total Spent On Fruits] AND
				  [Total Spent On Meat] >= [Total Spent On Fish] AND
				  [Total Spent On Meat] >= [Total Spent On Sweet] AND
				  [Total Spent On Meat] >= [Total Spent On Gold] THEN 'Meat Products'

	         WHEN [Total Spent On Fish] >= [Total Spent On Fruits] AND
                  [Total Spent On Fish] >= [Total Spent On Meat] AND
				  [Total Spent On Fish] >= [Total Spent On Juice] AND
				  [Total Spent On Fish] >= [Total Spent On Sweet] AND
				  [Total Spent On Fish] >= [Total Spent On Gold] THEN 'Fish Products'

		     WHEN [Total Spent On Sweet] >= [Total Spent On Fruits] AND
                  [Total Spent On Sweet] >= [Total Spent On Meat] AND
				  [Total Spent On Sweet] >= [Total Spent On Juice] AND
				  [Total Spent On Sweet] >= [Total Spent On Fish] AND
				  [Total Spent On Sweet] >= [Total Spent On Gold] THEN 'Sweet Products'

	         ELSE 'Gold Products'
	    END AS [Most Category Spent On],
		GREATEST([Total Spent On Juice],
		         [Total Spent On Fruits],
				 [Total Spent On Meat],
				 [Total Spent On Fish],
				 [Total Spent On Sweet],
				 [Total Spent On Gold]) AS [Total Spent]
FROM
(
SELECT DISTINCT Education,
				SUM(MntJuiceProducts) OVER (PARTITION BY Education) AS [Total Spent On Juice],
				SUM(MntFruits) OVER (PARTITION BY Education) AS [Total Spent On Fruits],
				SUM(MntMeatProducts) OVER (PARTITION BY Education) AS [Total Spent On Meat],
				SUM(MntFishProducts) OVER (PARTITION BY Education) AS [Total Spent On Fish],
				SUM(MntSweetProducts) OVER (PARTITION BY Education) AS [Total Spent On Sweet],
				SUM(MntGoldProds) OVER (PARTITION BY Education) AS [Total Spent On Gold]	
FROM DBO.marketing_campaign
) X
ORDER BY [Total Spent]


--------------------------------------------------------------------------------

-- Calculating Total spent of Top 3 category by Marital Status but grouped Alone, Divorced, Single, Widow into one group 'Single'
-- and Married, Together into group 'Married' and Absurd, YOLO into 'Others'
SELECT [Marital Status],
       SUM([Total Spent On Juice]) AS [Total Spent On Juice],
	   SUM([Total Spent On Meat]) AS [Total Spent On Meat],
	   SUM([Total Spent On Fish]) AS [Total Spent On Fish]
FROM
(
SELECT DISTINCT CASE
                    WHEN Marital_Status IN ('Alone','Divorced','Single','Widow') THEN 'Single'
		            WHEN Marital_Status IN ('Married','Together') THEN 'Married'
		            ELSE 'Other'
	            END AS [Marital Status],
				SUM(MntJuiceProducts) OVER (PARTITION BY Marital_Status) AS [Total Spent On Juice],
				SUM(MntMeatProducts) OVER (PARTITION BY Marital_Status) AS [Total Spent On Meat],
				SUM(MntFishProducts) OVER (PARTITION BY Marital_Status) AS [Total Spent On Fish]
FROM DBO.marketing_campaign
) X
GROUP BY [Marital Status]
ORDER BY [Total Spent On Juice] DESC


--------------------------------------------------------------------------------

-- Calculating Total spent by Marital Status filtering out 'Other'
SELECT [Marital Status],
       [Total Spent On Juice] +
	   [Total Spent On Fruits] +
	   [Total Spent On Meat] +
	   [Total Spent On Fish] +
	   [Total Spent On Sweet] +
	   [Total Spent On Gold] AS [Total Spent]
FROM
(
SELECT [Marital Status],
       SUM([Total Spent On Juice]) AS [Total Spent On Juice],
       SUM([Total Spent On Fruits]) AS [Total Spent On Fruits],
	   SUM([Total Spent On Meat]) AS [Total Spent On Meat],
	   SUM([Total Spent On Fish]) AS [Total Spent On Fish],
	   SUM([Total Spent On Sweet]) AS [Total Spent On Sweet],
	   SUM([Total Spent On Gold]) AS [Total Spent On Gold]
FROM
(
SELECT DISTINCT CASE
                    WHEN Marital_Status IN ('Alone','Divorced','Single','Widow') THEN 'Single'
		            WHEN Marital_Status IN ('Married','Together') THEN 'Married'
		            ELSE 'Other'
	            END AS [Marital Status],
				SUM(MntJuiceProducts) OVER (PARTITION BY Marital_Status) AS [Total Spent On Juice],
				SUM(MntFruits) OVER (PARTITION BY Marital_Status) AS [Total Spent On Fruits],
				SUM(MntMeatProducts) OVER (PARTITION BY Marital_Status) AS [Total Spent On Meat],
				SUM(MntFishProducts) OVER (PARTITION BY Marital_Status) AS [Total Spent On Fish],
				SUM(MntSweetProducts) OVER (PARTITION BY Marital_Status) AS [Total Spent On Sweet],
				SUM(MntGoldProds) OVER (PARTITION BY Marital_Status) AS [Total Spent On Gold]
FROM DBO.marketing_campaign
) X
GROUP BY [Marital Status]
HAVING [Marital Status] IN ('Married','Single')
) Y
ORDER BY [Total Spent On Juice] DESC


--------------------------------------------------------------------------------

-- Calculating Total spent on Juice by Marital Status
SELECT DISTINCT Marital_Status,
                SUM(MntJuiceProducts) OVER (PARTITION BY Marital_Status) AS [Total Spent on Juice]
FROM DBO.marketing_campaign
ORDER BY [Total Spent on Juice] DESC


--------------------------------------------------------------------------------

-- Calculating Average spent on Gold by Income Segment
SELECT [Income Segment],
        ROUND(AVG([Amount Spent on Gold]),2) AS [Average Spent on Gold]
FROM
(
SELECT CASE 
           WHEN Income < 50000 THEN 'Lower Class'
		   WHEN Income < 100000 THEN 'Middle Class'
		   ELSE 'Upper Class'
	   END AS [Income Segment],
	   [Amount Spent on Gold]
FROM
(
SELECT Income,
       (MntGoldProds) AS [Amount Spent on Gold]
       
FROM DBO.marketing_campaign
) X
) Y
GROUP BY [Income Segment]
ORDER BY [Average Spent on Gold] DESC


--------------------------------------------------------------------------------


------
------------ What are the distinct customer segments based on the frequency of website visits and online purchases? ------------
------ 

 SELECT CustomerSegment , SUM(MntGoldProds)  as Gold , sum(MntMeatProducts) as meat
FROM (
 SELECT 
    CASE 
        WHEN NumWebVisitsMonth > 10 AND NumWebPurchases < 5 THEN 'Frequent Visitors, Low Buyers'
        WHEN NumWebPurchases >= 5 THEN 'High Online Buyers'
        WHEN NumWebVisitsMonth <= 5 AND NumWebPurchases <= 2 THEN 'Low Engagement Customers'
        ELSE 'Balanced Customers'
    END AS CustomerSegment
	,MntGoldProds , MntMeatProducts
     
FROM MCDB
) AS TAP
GROUP BY CustomerSegment



------
--------- Q3 How do enrollment dates correlate with customer loyalty and spending? ------------
------
 
 SELECT loyalty , COUNT (*) 
FROM (
 SELECT  Income  , MntGoldProds,  
    CASE 
        WHEN DATEDIFF(MONTH, Dt_Customer , '2014-06-29') < 6  Then 'New Customer' 
        WHEN  DATEDIFF(MONTH, Dt_Customer , '2014-06-29') >=  12 then 'Loyal Custmer' 
        ELSE 'Moderate'
    END AS loyalty
FROM MCDB
) AS TAP
GROUP BY loyalty



--------------------------
------------------------------------
-------------------------

----Q4 	Are there distinct customer segments based on complaint behavior? 

select avg([Total Purchases]) as AVGTotalPurchases ,avg(recency) as AVGrecency , 'Complained Ppl' as sample
  From (
        SELECT  ID ,  recency , DATEDIFF(DAY, Dt_Customer , '2014-06-29') as days , Income ,  Complain ,
		( NumDealsPurchases + NumWebPurchases + NumStorePurchases + NumCatalogPurchases ) as [Total Purchases] ,
		CAST (AcceptedCmp2 AS INT ) + CAST (AcceptedCmp1 AS INT ) + CAST (AcceptedCmp3 AS INT ) +CAST (AcceptedCmp4 AS INT )
		+CAST (AcceptedCmp5 AS INT ) AS [Totall acceptedcmp]
        FROM MCDB
        WHERE Complain = 1 	
       )as tap
	
union	 

 select  avg(TotalPurchases)  , avg(recency) as AVGrecency ,'satisfied Ppl' 
  from( 
        select  id,  recency, DATEDIFF(DAY, Dt_Customer , '2014-06-29') as days  , 
		(  NumDealsPurchases + NumWebPurchases + NumStorePurchases + NumCatalogPurchases ) as TotalPurchases
        from MCDB
        where Complain = 0
	   ) as tap

	------- the Avg is the Same -------
	------ we find that ppl who complained handeld well and there numbers like  



--------------------------
------------------------------------
-------------------------

--------- What segments of customers show the highest potential for upselling and cross-selling? --------

select loyalty  , COUNT( [Total Purchases]) AS  [Total Purchases]
from (
SELECT  ID, (NumDealsPurchases + NumWebPurchases +
            NumStorePurchases + NumCatalogPurchases)
			as [Total Purchases] ,
    CASE 
        WHEN DATEDIFF(month, Dt_Customer, '2014-06-29') < 6 THEN 'New Customer'
        WHEN DATEDIFF(month, Dt_Customer, '2014-06-29') > 12 THEN 'Long Term Customer'
        ELSE 'Moderate'
    END AS loyalty
FROM MCDB
) as tap 

group by loyalty
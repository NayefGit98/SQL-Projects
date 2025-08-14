/* Group customers into three groups based on their spending behaviour:
-	VIP: Customers with atleast 12 months of history and spending more than $5,000.
-	Regular: Customers with atleast 12 months of history but spending $5,000 or less.
-	New: Customers with a lifespan less than 12 months.
Find the total numbers of customers by each group*/

WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF (month, MIN(order_date), MAX(order_date)) AS lifespan
FROM [gold.fact_sales] f
LEFT JOIN [gold.dim_customers] c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
	SELECT 
	customer_key,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END customer_segment
	FROM customer_spending ) t
	GROUP BY customer_segment
	ORDER BY total_customers DESC
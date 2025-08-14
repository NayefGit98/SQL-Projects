/* 
Product Report
===============
Purpose:

- This report consolidates key product metrics and behaviour
Highlights:
1. Gather essential fields such as product_names, category, subcategory and cost.
2. Segments product by revenue to identify High-performers, Midrange and Low-performers.
3. Aggregate product-level metrics:
	- total orders
	- total sales
	- total quantity sold
	- total customers (unique)
	- lifespan (in months)
4. Calculate valuable KPIs:
	- Recency (months since last sales)
	- Average order revenue
	- Average monthly revenue

=======================================*/
CREATE VIEW dbo.report_products AS 
WITH base_query AS (
	SELECT
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost,
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity
	FROM [gold.fact_sales] f
	LEFT JOIN [gold.dim_products] p
	ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL 
),

product_aggregations AS (
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF (month, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
SELECT 
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
CASE
	WHEN total_sales > 50000 THEN 'High-Performer'
	WHEN total_sales >= 10000 THEN 'Mig-Range'
	ELSE 'Low-Performer'
END AS product_segment,
lifespan,
total_orders,
total_customers,
total_sales,
total_quantity,
avg_selling_price,
DATEDIFF (month, last_sale_date, GETDATE()) AS recency_in_months,
--Average order revenue
CASE 
	WHEN total_orders = 0 THEN 0
	ELSE total_sales/total_orders 
END AS avg_order_revenue,
--Average monthly revenue
CASE 
	WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan
END AS avg_montly_revenue
FROM product_aggregations

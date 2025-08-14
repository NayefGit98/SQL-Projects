-- Calculate the total sales per month
-- the running total of sales over time

SELECT
order_date,
total_sales,
SUM (total_sales) OVER (ORDER BY order_date) AS running_total_sales

FROM
(
SELECT
DATETRUNC (month,order_date) AS order_date,
SUM(sales_amount) AS total_sales
FROM [gold.fact_sales]
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC (month,order_date)
) t
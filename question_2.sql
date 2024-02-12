-- Which month in 2022 has had the highest revenue?

SELECT 
    dim_date.year, 
    dim_date.month_name, 
    ROUND(SUM(orders.product_quantity * dim_product.sale_price)::Decimal, 2) AS revenue
FROM orders
LEFT JOIN
    dim_product ON orders.product_code = dim_product.product_code
LEFT JOIN
    dim_date ON orders.order_date = dim_date.date
WHERE
    dim_date.year = '2022'
GROUP BY
    dim_date.year, dim_date.month_name
ORDER BY
    revenue DESC
LIMIT 
    3;




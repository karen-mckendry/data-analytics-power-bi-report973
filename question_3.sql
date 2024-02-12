-- Which German store type had the highest revenue for 2022?

SELECT 
    dim_store.store_type,
    dim_store.country_code,
    dim_date.year, 
    ROUND(SUM(orders.product_quantity * dim_product.sale_price)::Decimal, 2) AS revenue
FROM orders
LEFT JOIN
    dim_product ON orders.product_code = dim_product.product_code
LEFT JOIN
    dim_date ON orders.order_date = dim_date.date
LEFT JOIN
    dim_store ON orders.store_code = dim_store.store_code
WHERE
    (dim_date.year = '2022') AND (dim_store.country_code = 'DE')
GROUP BY
    dim_store.store_type, dim_store.country_code, dim_date.year
ORDER BY
    revenue DESC
LIMIT 
    1;

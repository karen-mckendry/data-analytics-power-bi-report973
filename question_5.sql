-- Which product category generated the most profit for the "Wiltshire, UK" region in 2021?

SELECT 
    dim_date.year,
    dim_store.full_region,
    dim_product.category,
    round(SUM((dim_product.sale_price - dim_product.cost_price) * orders.product_quantity)::Decimal,2) AS profit
FROM orders
LEFT JOIN
    dim_product ON orders.product_code = dim_product.product_code
LEFT JOIN
    dim_date ON orders.order_date = dim_date.date
LEFT JOIN
    dim_store ON orders.store_code = dim_store.store_code
WHERE
    (dim_date.year = '2021') AND (dim_store.full_region = 'Wiltshire, UK')
GROUP BY
    dim_product.category, dim_store.full_region, dim_date.year
ORDER BY
    profit DESC
LIMIT 
    1;
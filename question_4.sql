-- Create a view where the rows are the store types and the columns are the total sales, 
-- percentage of total sales and the count of orders

SELECT 
    dim_store.store_type,
    ROUND(SUM(orders.product_quantity * dim_product.sale_price)::Decimal, 2) AS total_sales,
    ROUND(SUM(orders.product_quantity * dim_product.sale_price)::Decimal / 
        (SELECT SUM(orders.product_quantity * dim_product.sale_price)
        FROM orders
        JOIN dim_product ON orders.product_code = dim_product.product_code
        )::Decimal * 100, 2) || '%' AS sales_percentage,
    COUNT (orders.order_date_uuid) AS total_orders
FROM orders
JOIN
    dim_product ON orders.product_code = dim_product.product_code
JOIN
    dim_store ON orders.store_code = dim_store.store_code
GROUP BY
    dim_store.store_type
;
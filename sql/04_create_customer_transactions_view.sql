-- =====================================================================
-- Customer Transactions View
-- Project: revops-customer-segmentation
-- Purpose: Single source-of-truth fact table for all downstream RFM,
--          CLV, and segmentation analysis
-- Author:  Sivakumar Reddy Yenna
--
-- Design decisions (derived from sql/03_data_quality_checks.sql):
--   - Join on customer_unique_id (NOT customer_id) for real-person view
--   - Filter to order_status = 'delivered' only (97% of orders)
--   - Require order_delivered_customer_date IS NOT NULL
--   - Aggregate payment_value per order (some orders have multiple
--     payment rows due to installments / split payments)
--   - Count line items per order for an additional feature
-- =====================================================================


-- Drop view if it already exists (safe re-runs during development)
DROP MATERIALIZED VIEW IF EXISTS customer_transactions;


-- ---------------------------------------------------------------------
-- Build the unified, analysis-ready transactions table
-- ---------------------------------------------------------------------
CREATE MATERIALIZED VIEW customer_transactions AS
SELECT
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_status,
    p.total_payment      AS payment_value,
    i.num_items,
    c.customer_state,
    c.customer_city
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN (
    -- Aggregate payments per order: handles installment / split payments
    SELECT
        order_id,
        SUM(payment_value) AS total_payment
    FROM order_payments
    GROUP BY order_id
) p ON o.order_id = p.order_id
LEFT JOIN (
    -- Count line items per order
    SELECT
        order_id,
        COUNT(*) AS num_items
    FROM order_items
    GROUP BY order_id
) i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND p.total_payment IS NOT NULL;


-- ---------------------------------------------------------------------
-- Add indexes for downstream query performance
-- ---------------------------------------------------------------------
CREATE INDEX idx_ct_customer_unique_id
    ON customer_transactions (customer_unique_id);

CREATE INDEX idx_ct_purchase_timestamp
    ON customer_transactions (order_purchase_timestamp);


-- ---------------------------------------------------------------------
-- Sanity-check the view
-- ---------------------------------------------------------------------
SELECT
    COUNT(*)                              AS total_transactions,
    COUNT(DISTINCT customer_unique_id)    AS unique_customers,
    ROUND(SUM(payment_value)::numeric, 2) AS total_revenue,
    MIN(order_purchase_timestamp)         AS earliest_purchase,
    MAX(order_purchase_timestamp)         AS latest_purchase
FROM customer_transactions;
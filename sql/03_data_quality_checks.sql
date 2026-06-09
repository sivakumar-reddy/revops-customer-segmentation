-- =====================================================================
-- Olist Data Quality Checks
-- Project: revops-customer-segmentation
-- Purpose: Validate data integrity, understand distributions, and
--          surface decisions that shape downstream RFM/CLV analysis
-- Author:  Sivakumar Reddy Yenna
-- =====================================================================


-- ---------------------------------------------------------------------
-- Q1. Date range of the order data
-- Why: defines the analysis window and the "snapshot date" for Recency
-- ---------------------------------------------------------------------
SELECT
    MIN(order_purchase_timestamp) AS earliest_order,
    MAX(order_purchase_timestamp) AS latest_order,
    MAX(order_purchase_timestamp) - MIN(order_purchase_timestamp) AS time_span
FROM orders;


-- ---------------------------------------------------------------------
-- Q2. Distribution of order statuses
-- Why: tells us which orders to include in RFM (only "delivered" likely)
-- ---------------------------------------------------------------------
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- ---------------------------------------------------------------------
-- Q3. customer_id vs customer_unique_id — the BIG ONE
-- Why: Olist has two customer keys. customer_id is per-order.
--      customer_unique_id is the actual person. We need to know which
--      to use for RFM (spoiler: customer_unique_id)
-- ---------------------------------------------------------------------
SELECT
    COUNT(DISTINCT customer_id)        AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_people,
    COUNT(*)                           AS total_customer_rows
FROM customers;


-- ---------------------------------------------------------------------
-- Q4. How many orders does each unique customer place?
-- Why: baseline for Frequency scoring in RFM
-- ---------------------------------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    order_count,
    COUNT(*) AS num_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM customer_orders
GROUP BY order_count
ORDER BY order_count;


-- ---------------------------------------------------------------------
-- Q5. Null rate on key timestamp fields in orders
-- Why: which orders are "complete enough" for RFM? Some orders may
--      never have been delivered, paid, or approved
-- ---------------------------------------------------------------------
SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE order_approved_at IS NULL)             AS missing_approved,
    COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL)  AS missing_carrier_date,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS missing_customer_delivery
FROM orders;


-- ---------------------------------------------------------------------
-- Q6. Payment value distribution — find outliers
-- Why: monetary scoring needs to know if there are extreme values
--      that will skew the M score
-- ---------------------------------------------------------------------
SELECT
    COUNT(*) AS num_payments,
    ROUND(MIN(payment_value)::numeric, 2)  AS min_payment,
    ROUND(AVG(payment_value)::numeric, 2)  AS avg_payment,
    ROUND(MAX(payment_value)::numeric, 2)  AS max_payment,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY payment_value)::numeric, 2) AS median_payment,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY payment_value)::numeric, 2) AS p95_payment,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY payment_value)::numeric, 2) AS p99_payment
FROM order_payments;


-- ---------------------------------------------------------------------
-- Q7. Top-level revenue snapshot
-- Why: what's the total business volume we're looking at?
-- ---------------------------------------------------------------------
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2)   AS total_revenue,
    ROUND(AVG(p.payment_value)::numeric, 2)   AS avg_order_value
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered';
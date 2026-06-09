-- =====================================================================
-- Olist Brazilian E-Commerce Database Schema
-- Project: revops-customer-segmentation
-- Purpose: Create 9 tables for RFM segmentation + CLV modeling analysis
-- Author:  Sivakumar Reddy Yenna
-- =====================================================================

-- Drop tables if they already exist (safe re-runs during development)
DROP TABLE IF EXISTS order_reviews CASCADE;
DROP TABLE IF EXISTS order_payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS geolocation CASCADE;
DROP TABLE IF EXISTS product_category_name_translation CASCADE;


-- ---------------------------------------------------------------------
-- 1. CUSTOMERS — unique customers and their location info
-- ---------------------------------------------------------------------
CREATE TABLE customers (
    customer_id              VARCHAR(50) PRIMARY KEY,
    customer_unique_id       VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city            VARCHAR(100),
    customer_state           VARCHAR(5)
);

-- ---------------------------------------------------------------------
-- 2. GEOLOCATION — Brazilian zip codes mapped to lat/lon
-- ---------------------------------------------------------------------
CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat             NUMERIC,
    geolocation_lng             NUMERIC,
    geolocation_city            VARCHAR(100),
    geolocation_state           VARCHAR(5)
);

-- ---------------------------------------------------------------------
-- 3. SELLERS — marketplace sellers and their locations
-- ---------------------------------------------------------------------
CREATE TABLE sellers (
    seller_id              VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city            VARCHAR(100),
    seller_state           VARCHAR(5)
);

-- ---------------------------------------------------------------------
-- 4. PRODUCTS — product catalog
-- ---------------------------------------------------------------------
CREATE TABLE products (
    product_id                 VARCHAR(50) PRIMARY KEY,
    product_category_name      VARCHAR(100),
    product_name_lenght        INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty         INTEGER,
    product_weight_g           INTEGER,
    product_length_cm          INTEGER,
    product_height_cm          INTEGER,
    product_width_cm           INTEGER
);

-- ---------------------------------------------------------------------
-- 5. ORDERS — the core fact table: orders and their lifecycle timestamps
-- ---------------------------------------------------------------------
CREATE TABLE orders (
    order_id                      VARCHAR(50) PRIMARY KEY,
    customer_id                   VARCHAR(50) REFERENCES customers(customer_id),
    order_status                  VARCHAR(20),
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 6. ORDER_ITEMS — line items inside each order (one row per item)
-- ---------------------------------------------------------------------
CREATE TABLE order_items (
    order_id            VARCHAR(50) REFERENCES orders(order_id),
    order_item_id       INTEGER,
    product_id          VARCHAR(50) REFERENCES products(product_id),
    seller_id           VARCHAR(50) REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10, 2),
    freight_value       NUMERIC(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

-- ---------------------------------------------------------------------
-- 7. ORDER_PAYMENTS — how each order was paid for
-- ---------------------------------------------------------------------
CREATE TABLE order_payments (
    order_id             VARCHAR(50) REFERENCES orders(order_id),
    payment_sequential   INTEGER,
    payment_type         VARCHAR(20),
    payment_installments INTEGER,
    payment_value        NUMERIC(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- ---------------------------------------------------------------------
-- 8. ORDER_REVIEWS — customer reviews and ratings per order
-- ---------------------------------------------------------------------
CREATE TABLE order_reviews (
    review_id               VARCHAR(50),
    order_id                VARCHAR(50) REFERENCES orders(order_id),
    review_score            INTEGER,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 9. PRODUCT_CATEGORY_NAME_TRANSLATION — Portuguese to English mapping
-- ---------------------------------------------------------------------
CREATE TABLE product_category_name_translation (
    product_category_name         VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);
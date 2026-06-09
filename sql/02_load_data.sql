-- =====================================================================
-- Olist Data Loading Script
-- Project: revops-customer-segmentation
-- Purpose: Load all 9 CSV files into the olist database tables
-- Author:  Sivakumar Reddy Yenna
-- Note:    Load order respects foreign key dependencies
-- =====================================================================

-- ---------------------------------------------------------------------
-- Layer 1: Independent tables (no foreign keys to other Olist tables)
-- ---------------------------------------------------------------------

\copy customers FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true);

\copy sellers FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true);

\copy products FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true);

\copy geolocation FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true);

\copy product_category_name_translation FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true);


-- ---------------------------------------------------------------------
-- Layer 2: Orders table (depends on customers)
-- ---------------------------------------------------------------------

\copy orders FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true);


-- ---------------------------------------------------------------------
-- Layer 3: Order-dependent tables
-- ---------------------------------------------------------------------

\copy order_items FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true);

\copy order_payments FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true);

\copy order_reviews FROM 'C:/Users/reddy/projects/revops-customer-segmentation/data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'LATIN1');
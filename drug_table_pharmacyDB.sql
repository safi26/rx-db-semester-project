USE Pharmacydb;

-- increasing size of DrugName -- 
ALTER TABLE Drug
MODIFY COLUMN DrugName VARCHAR(255) NOT NULL;

-- building Drug table from raw_sales and raw_prescription_items -- 
INSERT INTO Drug (DrugID, DrugName)
SELECT DISTINCT product_id, product_name
FROM raw_sales
UNION
SELECT DISTINCT product_id, product_name
FROM raw_prescription_items;
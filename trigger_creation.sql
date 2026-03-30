USE Pharmacydb;
-- creating view for prescription, order, and inventory --
-- Safi Modifying the view and triggers

DROP VIEW IF EXISTS prescription_view;
CREATE VIEW prescription_view AS
SELECT
    p.prescription_id,
    p.issue_date,
    c.first_name,
    d.name,
    prescribed_quantity
FROM Prescription p
JOIN Customer c ON p.customer_id = c.customer_id
JOIN Prescription_Drug pd ON p.prescription_id = pd.prescription_id
JOIN Drug d ON pd.drug_id = d.drug_id;

DROP VIEW IF EXISTS order_view;
CREATE VIEW order_view AS
SELECT
    o.order_id,
    o.order_date,
    -- o.OrderType,
    c.first_name,
    d.name,
    od.Quantity,
    od.SalePrice,
    (od.Quantity * od.SalePrice) AS LineTotal
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
JOIN Order_Drug od ON o.order_id = od.order_id
JOIN Drug d ON od.drug_id = d.drug_id;

DROP VIEW IF EXISTS inventory_view;
CREATE VIEW inventory_view AS
SELECT
    i.InventoryID,
    d.name,
    i.QuantityInStock
FROM Inventory i
JOIN Drug d ON i.drug_id = d.drug_id;

-- Testing --
SELECT * FROM Prescription view  LIMIT 10;

-- creating function that calculates the total cost of one order --
-- Safi commenting because its not working
DELIMITER $$

DROP FUNCTION IF EXISTS order_total;
CREATE FUNCTION order_total(p_order_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_amount DECIMAL(10,2);

    SELECT IFNULL(SUM(Quantity * SalePrice), 0)
    INTO total_amount
    FROM Order_Drug
    WHERE order_id = p_order_id;

    RETURN total_amount;
END $$

DELIMITER ;

-- Testing --
SELECT order_total(3) AS total_amount;

-- testing to get order details --
SELECT
    o.order_id,
    -- o.OrderType,
    c.first_name,
    order_total(o.order_id) AS Total_amount
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
WHERE o.order_id = 1;

-- creating procedure: creates a sale summary for an order --
DELIMITER $$

DROP PROCEDURE IF EXISTS sale_from_order;
CREATE PROCEDURE sale_from_order (
    IN p_order_id INT,
    IN p_EmployeeID INT
)
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_OrderDate DATE;
    DECLARE v_TotalAmount DECIMAL(10,2);

    SELECT customer_id, order_date
    INTO v_customer_id, v_OrderDate
    FROM Orders
    WHERE order_id = p_order_id;

    SELECT IFNULL(SUM(Quantity * SalePrice), 0)
    INTO v_TotalAmount
    FROM Order_Drug
    WHERE order_id = p_order_id;

    INSERT INTO Sales (order_id, customer_id, sale_date, line_total, employee_id)
    VALUES (p_order_id, v_customer_id, v_OrderDate, v_TotalAmount, p_EmployeeID);
END $$

DELIMITER ;

-- testing --
-- CALL sale_from_order(1, 1);

SELECT *
FROM Sales
ORDER BY sale_id DESC
LIMIT 10;

-- Trigger: when a new drug item is added to an order, the inventory reduces --
DROP TRIGGER IF EXISTS trigger_reduce_;

DELIMITER $$
CREATE TRIGGER trigger_reduce_
AFTER INSERT ON Order_Drug
FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET QuantityInStock = QuantityInStock - NEW.Quantity
    WHERE drug_id = NEW.drug_id;
END $$

-- testing trigger --
-- current stock --
SELECT *
FROM Inventory
WHERE drug_id = 1;

-- inserting a new order first --
-- INSERT INTO Orders (order_id, customer_id, OrderType, OrderDate)
INSERT INTO Orders (order_id, customer_id, OrderDate)
VALUES (9999, 1, 'Walk-in', CURDATE());

-- inserting into order_drug --
INSERT INTO Order_Drug (order_id, drug_id, Quantity, SalePrice)
VALUES (9999, 1, 5, 10.00);

-- rechecking inventory --



-- Trigger: inventory increases after a new purchase --
DROP TRIGGER IF EXISTS trigger_increase;

DELIMITER $$
CREATE TRIGGER trigger_increase
AFTER INSERT ON Purchases
FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET QuantityInStock = QuantityInStock + NEW.Quantity
    WHERE drug_id = NEW.drug_id;
END $$

DELIMITER ;


-- Create readonly user

CREATE USER 'readonly_user'@'%' IDENTIFIED BY 'example';
GRANT SELECT ON Pharmacydb.* TO 'readonly_user'@'%';
FLUSH PRIVILEGES;


-- Create masked view

CREATE VIEW customers_masked AS
SELECT
    id,
    name,
    CONCAT('XXX-XXX-', RIGHT(phone, 4)) AS phone
FROM Customer;

SELECT * FROM Pharmacydb.customers_masked;
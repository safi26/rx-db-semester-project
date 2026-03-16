USE Pharmacydb;
-- creating view for prescription, order, and inventory -- 

CREATE VIEW prescription_view AS
SELECT 
    p.PrescriptionID,
    p.PrescriptionDate,
    c.CustomerName,
    d.DrugName,
    pd.Quantity
FROM Prescription p
JOIN Customer c ON p.CustomerID = c.CustomerID
JOIN Prescription_Drug pd ON p.PrescriptionID = pd.PrescriptionID
JOIN Drug d ON pd.DrugID = d.DrugID;

CREATE VIEW order_view AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.OrderType,
    c.CustomerName,
    d.DrugName,
    od.Quantity,
    od.SalePrice,
    (od.Quantity * od.SalePrice) AS LineTotal
FROM Orders o
JOIN Customer c ON o.CustomerID = c.CustomerID
JOIN Order_Drug od ON o.OrderID = od.OrderID
JOIN Drug d ON od.DrugID = d.DrugID;

CREATE VIEW inventory_view AS
SELECT
    i.InventoryID,
    d.DrugName,
    i.QuantityInStock
FROM Inventory i
JOIN Drug d ON i.DrugID = d.DrugID;

-- Testing -- 
SELECT * FROM prescription view  LIMIT 10;

-- creating function that calculates the total cost of one order -- 
DELIMITER $$

CREATE FUNCTION order_total(p_OrderID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_amount DECIMAL(10,2);

    SELECT IFNULL(SUM(Quantity * SalePrice), 0)
    INTO total_amount
    FROM Order_Drug
    WHERE OrderID = p_OrderID;

    RETURN total_amount;
END $$

DELIMITER ;

-- Testing -- 
SELECT order_total(3) AS total_amount;

-- testing to get order details --
SELECT 
    o.OrderID,
    o.OrderType,
    c.CustomerName,
    order_total(o.OrderID) AS Total_amount
FROM Orders o
JOIN Customer c ON o.CustomerID = c.CustomerID
WHERE o.OrderID = 1;

-- creating procedure: creates a sale summary for an order -- 
DELIMITER $$

CREATE PROCEDURE sale_from_order (
    IN p_OrderID INT,
    IN p_EmployeeID INT
)
BEGIN
    DECLARE v_CustomerID INT;
    DECLARE v_OrderDate DATE;
    DECLARE v_TotalAmount DECIMAL(10,2);

    SELECT CustomerID, OrderDate
    INTO v_CustomerID, v_OrderDate
    FROM Orders
    WHERE OrderID = p_OrderID;

    SELECT IFNULL(SUM(Quantity * SalePrice), 0)
    INTO v_TotalAmount
    FROM Order_Drug
    WHERE OrderID = p_OrderID;

    INSERT INTO Sales (CustomerID, SaleDate, Amount, EmployeeID)
    VALUES (v_CustomerID, v_OrderDate, v_TotalAmount, p_EmployeeID);
END $$

DELIMITER ;

-- testing -- 
CALL sale_from_order(1, 1);

SELECT * 
FROM Sales
ORDER BY SaleID DESC
LIMIT 10;

-- Trigger: when a new drug item is added to an order, the inventory reduces -- 
DELIMITER $$
CREATE TRIGGER trigger_reduce_
AFTER INSERT ON Order_Drug
FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET QuantityInStock = QuantityInStock - NEW.Quantity
    WHERE DrugID = NEW.DrugID;
END $$

-- testing trigger -- 
-- current stock -- 
SELECT * 
FROM Inventory
WHERE DrugID = 1;

-- inserting a new order first --
INSERT INTO Orders (OrderID, CustomerID, OrderType, OrderDate)
VALUES (9999, 1, 'Walk-in', CURDATE());

-- inserting into order_drug -- 
INSERT INTO Order_Drug (OrderID, DrugID, Quantity, SalePrice)
VALUES (9999, 1, 5, 10.00);

-- rechecking inventory -- 



-- Trigger: inventory increases after a new purchase -- 
CREATE TRIGGER trigger_increase
AFTER INSERT ON Purchases
FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET QuantityInStock = QuantityInStock + NEW.Quantity
    WHERE DrugID = NEW.DrugID;
END $$

DELIMITER ;

-- testing -- 
-- checking current stock -- 
SELECT * FROM Inventory WHERE DrugID = 1;

-- inserting a purchase -- 
INSERT INTO Purchases (PurchaseID, DrugID, Quantity, ExpirationDate, PurchaseCost, PurchaseDate)
VALUES (9999, 1, 20, '2027-12-31', 15.00, CURDATE());

-- re checking inventory -- 
SELECT * FROM Inventory WHERE DrugID = 1;





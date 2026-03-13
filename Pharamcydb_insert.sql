USE Pharmacydb;
-- popluate the final tables -- 

-- inserting customer table -- 
INSERT INTO Customer (CustomerID, CustomerName)
SELECT customer_id, CONCAT(first_name, ' ', last_name)
FROM raw_customer;

-- checking -- 
SELECT * FROM Customer LIMIT 10;

-- inserting employee table -- 
INSERT INTO Employee (EmployeeID, EmployeeName, Role)
SELECT employee_id, CONCAT(first_name, ' ', last_name), role
FROM raw_employee;

-- checking --
SELECT * FROM Employee LIMIT 10;

-- inserting prescription table -- 
INSERT INTO Prescription (PrescriptionID, CustomerID, PrescriptionDate)
SELECT prescription_id, customer_id, issue_date
FROM raw_prescription;

-- checking --
SELECT * FROM Prescription LIMIT 10;

-- inserting orders table -- 
INSERT INTO Orders (OrderID, CustomerID, OrderType, OrderDate)
SELECT DISTINCT order_id, customer_id, 'Walk-in', sale_date
FROM raw_sales;

-- checking -- 
SELECT * FROM Orders LIMIT 10;

-- inserting prescription_drug table -- 
INSERT INTO Prescription_Drug (PrescriptionID, DrugID, Quantity)
SELECT prescription_id, product_id, prescribed_quantity
FROM raw_prescription_items;

-- checking-- 
SELECT * FROM Prescription_Drug LIMIT 10;

-- inserting order_drug_ table -- 
INSERT INTO Order_Drug (OrderID, DrugID, Quantity, SalePrice)
SELECT order_id, product_id, quantity, unit_price
FROM raw_sales;

-- checking --
SELECT * FROM Order_Drug LIMIT 10;

-- inserting sales table -- 
INSERT INTO Sales (CustomerID, SaleDate, Amount, EmployeeID)
SELECT
    customer_id,
    sale_date,
    SUM(line_total) AS Amount,
    1 AS EmployeeID
FROM raw_sales
GROUP BY order_id, customer_id, sale_date;

-- checking --
SELECT * FROM Sales LIMIT 10;

-- manually inserting inventory -- 
INSERT INTO Purchases (PurchaseID, DrugID, Quantity, ExpirationDate, PurchaseCost, PurchaseDate)
VALUES
(1, 1, 100, '2027-12-31', 12.50, '2026-01-10'),
(2, 2, 200, '2027-11-30', 8.75, '2026-01-12'),
(3, 3, 150, '2028-03-15', 5.25, '2026-01-15');


-- manually inserting purchases -- 
INSERT INTO Inventory (InventoryID, DrugID, QuantityInStock)
VALUES
(1, 1, 100),
(2, 2, 200),
(3, 3, 150);



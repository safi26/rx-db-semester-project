USE PharmacyDB;

CREATE TABLE raw_customer (
    customer_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(50),
    street VARCHAR(150),
    city VARCHAR(100),
    state VARCHAR(100),
    zip VARCHAR(20),
    birthdate DATE
);

CREATE TABLE raw_employee (
    employee_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(50),
    email VARCHAR(150),
    phone VARCHAR(50),
    hire_date DATE
);

CREATE TABLE raw_prescription (
    prescription_id INT,
    customer_id INT,
    doctor_name VARCHAR(150),
    issue_date DATE,
    valid_until DATE,
    notes TEXT
);

CREATE TABLE raw_prescription_items (
    prescription_item_id INT,
    prescription_id INT,
    product_id INT,
    product_name VARCHAR(255),
    packaging VARCHAR(100),
    prescribed_quantity INT
);

CREATE TABLE raw_sales (
    sale_id INT,
    order_id INT,
    customer_id INT,
    product_id INT,
    product_name VARCHAR(255),
    quantity INT,
    unit_price DECIMAL(10,2),
    line_total DECIMAL(10,2),
    sale_date DATE
);


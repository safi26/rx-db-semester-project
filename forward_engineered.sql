-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema Pharmacydb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `Pharmacydb` ;

-- -----------------------------------------------------
-- Schema Pharmacydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `Pharmacydb` DEFAULT CHARACTER SET utf8mb4 ;
USE `Pharmacydb` ;

-- -----------------------------------------------------
-- Table `Pharmacydb`.`Customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Customer` (
  `customer_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL,
  `phone` VARCHAR(50) NOT NULL,
  `street` VARCHAR(150) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `state` VARCHAR(100) NOT NULL,
  `zip` VARCHAR(20) NOT NULL,
  `birthdate` DATE NOT NULL,
  PRIMARY KEY (`customer_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Prescription`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Prescription` (
  `prescription_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `issue_date` DATE NOT NULL,
  `doctor_name` VARCHAR(100) NOT NULL,
  `valid_until` DATE NOT NULL,
  `notes` VARCHAR(1000) NOT NULL,
  PRIMARY KEY (`prescription_id`),
  INDEX `Prescription.customer_id_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `Prescription.customer_id`
    FOREIGN KEY (`customer_id`)
    REFERENCES `Pharmacydb`.`Customer` (`customer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `Pharmacydb`.`Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Drug` (
  `drug_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(1000) NOT NULL,
  `packaging` VARCHAR(100) NOT NULL,
  `price` VARCHAR(100) NOT NULL,
  `discounted_price` VARCHAR(100) NOT NULL,
  `discount_percentage` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`drug_id`))
ENGINE = InnoDB;

-- name,packaging,price,discounted_price,discount_percentage


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Prescription_Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Prescription_Drug` (
  `prescription_item_id` INT NOT NULL,
  `prescription_id` INT NOT NULL,
  `drug_id` INT NOT NULL,
  `prescribed_quantity` INT NOT NULL,
  PRIMARY KEY (`prescription_item_id`, `drug_id`),
  INDEX `Prescription_Drug.drug_id_idx` (`drug_id` ASC) VISIBLE,
  CONSTRAINT `Prescription_Drug.prescription_id`
    FOREIGN KEY (`prescription_id`)
    REFERENCES `Pharmacydb`.`Prescription` (`prescription_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Prescription_Drug.drug_id`
    FOREIGN KEY (`drug_id`)
    REFERENCES `Pharmacydb`.`Drug` (`drug_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- prescription_item_id,prescription_id,drug_id,prescribed_quantity



-- -----------------------------------------------------
-- Table `Pharmacydb`.`Employee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Employee` (
  `employee_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `role` VARCHAR(50) NOT NULL,
  `email` VARCHAR(500) NOT NULL,
  `phone` VARCHAR(10) NOT NULL,
  `hire_date` DATE NOT NULL,
  PRIMARY KEY (`employee_id`))
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `Pharmacydb`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Orders` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `employee_id` INT NOT NULL,
  `prescription_id` INT NOT NULL,
  -- `OrderType` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `payment_method` VARCHAR(50) NOT NULL,
  `items_count` INT NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  `tax_amount` DECIMAL(10,2) NOT NULL,
  `shipping_fee` DECIMAL(10,2) NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `order_date` DATE NOT NULL,
  PRIMARY KEY (`order_id`),
  INDEX `Orders.customer_id_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `Orders.customer_id`
    FOREIGN KEY (`customer_id`)
    REFERENCES `Pharmacydb`.`Customer` (`customer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Orders.employee_id`
    FOREIGN KEY (`employee_id`)
    REFERENCES `Pharmacydb`.`Employee` (`employee_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Orders.prescription_id`
    FOREIGN KEY (`prescription_id`)
    REFERENCES `Pharmacydb`.`Prescription` (`prescription_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- order_id,customer_id,employee_id,employee_name,prescription_id,order_date,status,payment_method,items_count,subtotal,tax_amount,shipping_fee,total_amount
-- -----------------------------------------------------
-- Table `Pharmacydb`.`Order_Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Order_Drug` (
  `order_id` INT NOT NULL,
  `drug_id` INT NOT NULL,
  `Quantity` INT NOT NULL,
  `SalePrice` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`order_id`, `drug_id`),
  INDEX `Order_Drug.drug_id_idx` (`drug_id` ASC) VISIBLE,
  CONSTRAINT `Order_Drug.order_id`
    FOREIGN KEY (`order_id`)
    REFERENCES `Pharmacydb`.`Orders` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Order_Drug.drug_id`
    FOREIGN KEY (`drug_id`)
    REFERENCES `Pharmacydb`.`Drug` (`drug_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Inventory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Inventory` (
  `InventoryID` INT NOT NULL AUTO_INCREMENT,
  `drug_id` INT NOT NULL,
  `QuantityInStock` INT NOT NULL,
  PRIMARY KEY (`InventoryID`),
  UNIQUE INDEX `Inventory.drug_id_UNIQUE` (`drug_id` ASC) VISIBLE,
  CONSTRAINT `Inventory.drug_id`
    FOREIGN KEY (`drug_id`)
    REFERENCES `Pharmacydb`.`Drug` (`drug_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Purchases`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Purchases` (
  `PurchaseID` INT NOT NULL AUTO_INCREMENT,
  `drug_id` INT NOT NULL,
  `Quantity` INT NOT NULL,
  `ExpirationDate` DATE NOT NULL,
  `PurchaseCost` DECIMAL(10,2) NOT NULL,
  `PurchaseDate` DATE NOT NULL,
  PRIMARY KEY (`PurchaseID`),
  INDEX `Purchases.drug_id_idx` (`drug_id` ASC) VISIBLE,
  CONSTRAINT `Purchases.drug_id`
    FOREIGN KEY (`drug_id`)
    REFERENCES `Pharmacydb`.`Drug` (`drug_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Sales`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Sales` (
  `sale_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `order_id` INT NOT NULL,
  `drug_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `line_total` DECIMAL(10,2) NOT NULL,
  `sale_date` DATE NOT NULL,
  -- `Amount` DECIMAL(10,2) NOT NULL,
  `employee_id` INT NOT NULL,
  PRIMARY KEY (`sale_id`),
  INDEX `Sales.customer_id_idx` (`customer_id` ASC) VISIBLE,
  -- INDEX `Sales.employee_id_idx` (`employee_id` ASC) VISIBLE,
  CONSTRAINT `Sales.customer_id`
    FOREIGN KEY (`customer_id`)
    REFERENCES `Pharmacydb`.`Customer` (`customer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Sales.order_id`
    FOREIGN KEY (`order_id`)
    REFERENCES `Pharmacydb`.`Orders` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Sales.drug_id`
    FOREIGN KEY (`drug_id`)
    REFERENCES `Pharmacydb`.`Drug` (`drug_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Sales.employee_id`
    FOREIGN KEY (`employee_id`)
    REFERENCES `Pharmacydb`.`Employee` (`employee_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- sale_id,order_id,customer_id,drug_id,quantity,unit_price,line_total,sale_date


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;



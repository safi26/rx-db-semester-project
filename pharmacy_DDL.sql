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
  `CustomerID` INT NOT NULL AUTO_INCREMENT,
  `CustomerName` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`CustomerID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Prescription`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Prescription` (
  `PrescriptionID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `PrescriptionDate` DATE NOT NULL,
  PRIMARY KEY (`PrescriptionID`),
  INDEX `Prescription.CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  CONSTRAINT `Prescription.CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `Pharmacydb`.`Customer` (`CustomerID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Drug` (
  `DrugID` INT NOT NULL AUTO_INCREMENT,
  `DrugName` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`DrugID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Prescription_Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Prescription_Drug` (
  `PrescriptionID` INT NOT NULL,
  `DrugID` INT NOT NULL,
  `Quantity` INT NOT NULL,
  PRIMARY KEY (`PrescriptionID`, `DrugID`),
  INDEX `Prescription_Drug.DrugID_idx` (`DrugID` ASC) VISIBLE,
  CONSTRAINT `Prescription_Drug.PrescriptionID`
    FOREIGN KEY (`PrescriptionID`)
    REFERENCES `Pharmacydb`.`Prescription` (`PrescriptionID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Prescription_Drug.DrugID`
    FOREIGN KEY (`DrugID`)
    REFERENCES `Pharmacydb`.`Drug` (`DrugID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Employee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Employee` (
  `EmployeeID` INT NOT NULL AUTO_INCREMENT,
  `EmployeeName` VARCHAR(100) NOT NULL,
  `Role` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`EmployeeID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Orders` (
  `OrderID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `OrderType` VARCHAR(50) NOT NULL,
  `OrderDate` DATE NOT NULL,
  PRIMARY KEY (`OrderID`),
  INDEX `Orders.CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  CONSTRAINT `Orders.CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `Pharmacydb`.`Customer` (`CustomerID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Order_Drug`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Order_Drug` (
  `OrderID` INT NOT NULL,
  `DrugID` INT NOT NULL,
  `Quantity` INT NOT NULL,
  `SalePrice` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`OrderID`, `DrugID`),
  INDEX `Order_Drug.DrugID_idx` (`DrugID` ASC) VISIBLE,
  CONSTRAINT `Order_Drug.OrderID`
    FOREIGN KEY (`OrderID`)
    REFERENCES `Pharmacydb`.`Orders` (`OrderID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Order_Drug.DrugID`
    FOREIGN KEY (`DrugID`)
    REFERENCES `Pharmacydb`.`Drug` (`DrugID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Inventory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Inventory` (
  `InventoryID` INT NOT NULL AUTO_INCREMENT,
  `DrugID` INT NOT NULL,
  `QuantityInStock` INT NOT NULL,
  PRIMARY KEY (`InventoryID`),
  UNIQUE INDEX `Inventory.DrugID_UNIQUE` (`DrugID` ASC) VISIBLE,
  CONSTRAINT `Inventory.DrugID`
    FOREIGN KEY (`DrugID`)
    REFERENCES `Pharmacydb`.`Drug` (`DrugID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Purchases`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Purchases` (
  `PurchaseID` INT NOT NULL AUTO_INCREMENT,
  `DrugID` INT NOT NULL,
  `Quantity` INT NOT NULL,
  `ExpirationDate` DATE NOT NULL,
  `PurchaseCost` DECIMAL(10,2) NOT NULL,
  `PurchaseDate` DATE NOT NULL,
  PRIMARY KEY (`PurchaseID`),
  INDEX `Purchases.DrugID_idx` (`DrugID` ASC) VISIBLE,
  CONSTRAINT `Purchases.DrugID`
    FOREIGN KEY (`DrugID`)
    REFERENCES `Pharmacydb`.`Drug` (`DrugID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Pharmacydb`.`Sales`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Pharmacydb`.`Sales` (
  `SaleID` INT NOT NULL AUTO_INCREMENT,
  `CustomerID` INT NOT NULL,
  `SaleDate` DATE NOT NULL,
  `Amount` DECIMAL(10,2) NOT NULL,
  `EmployeeID` INT NOT NULL,
  PRIMARY KEY (`SaleID`),
  INDEX `Sales.CustomerID_idx` (`CustomerID` ASC) VISIBLE,
  INDEX `Sales.EmployeeID_idx` (`EmployeeID` ASC) VISIBLE,
  CONSTRAINT `Sales.CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `Pharmacydb`.`Customer` (`CustomerID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Sales.EmployeeID`
    FOREIGN KEY (`EmployeeID`)
    REFERENCES `Pharmacydb`.`Employee` (`EmployeeID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

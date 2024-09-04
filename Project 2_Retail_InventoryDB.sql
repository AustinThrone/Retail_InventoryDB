
--RetailInventtoryDB

CREATE DATABASE RetailInventoryDB
--USE RetailInventoryDB
CREATE TABLE ProductTB (ProductID NVARCHAR (10) PRIMARY KEY, ProductName nvarchar(100) not null,
CategoryID NVARCHAR not null, Price int not null, Quantity int not null, SupplierID NVARCHAR(10))
INSERT INTO ProductTB(ProductID, ProductName, CategoryID,Price, Quantity, SupplierID)
VALUES('P01','Laptop', '1', 1200, 50, '101'),
('P02','Smartphone', '1', 800, 100, '102'),
('P03','TV', '2', 1500, 30, '103'),
('P04','Refrigerator', '2', 900, 25, '104'),
('P05','Microwave', '3', 200, 60, '105'),
('P06','Washing Machine', '2', 1100, 20, '106'),
('P07','Headphone', '4', 100, 200, '107'),
('P08','Camera', '1', 700, 15, '108'),
('P09','Air Conditioner', '2', 1300, 10, '109'),
('P10','Blender', '3', 150, 80, '110');

SELECT * FROM ProductTB


CREATE TABLE Category(CategoryID NVARCHAR(5) PRIMARY KEY, CategoryName nvarchar(100) not null)
INSERT INTO Category(CategoryID, CategoryName)
VALUES ('1', 'Electronics'),
('2', 'Appliances'),
('3', 'Kitchenware'),
('4', 'Accessories');
select * from Category


CREATE TABLE Supplier(SupplierID NVARCHAR(10) PRIMARY KEY, SupplierName nvarchar(50) not null, 
ContactNumber nvarchar(20) NOT NULL)
INSERT INTO Supplier(SupplierID, SupplierName, ContactNumber)
VALUES('101', 'SupplierA', '123-456-7890'),
('102', 'SupplierB', '234-567-8901'),
('103', 'SupplierC', '345-678-9012'),
('104', 'SupplierD', '456-789-0123'),
('105', 'SupplierE', '567-890-1234'),
('106', 'SupplierF', '678-901-2345'),
('107', 'SupplierG', '789-012-3456'),
('108', 'SupplierH', '890-123-4567'),
('109', 'SupplierI', '901-234-5678'),
('110', 'SupplierJ', '012-345-6789');
SELECT * FROM Supplier



CREATE TABLE Warehouse(WarehouseID NVARCHAR(5) PRIMARY KEY, WarehouseName nvarchar(100) NOT NULL,
Location nvarchar(100) not null)
INSERT INTO Warehouse(WarehouseID, WarehouseName, Location)
VALUES ('W01', 'MainWarehouse', 'New York'),
('W02', 'EastWarehouse', 'Boston'),
('W03', 'WestWarehouse', 'San Diego'),
('W04', 'NorthWarehouse', 'Chicago'),
('W05', 'SouthWarehouse', 'Miami'),
('W06', 'CentralWarehouse', 'Dallas'),
('W07', 'PacificWarehouse', 'San Francisco'),
('W08', 'MountainWarehouse', 'Denver'),
('W09', 'SouthernWarehouse', 'Atlanta'),
('W10', 'GulfWarehouse', 'Houston');
SELECT * FROM Warehouse


-- SQL TASK RetailInventoryDB
--TASK 1
--FETCH PRODUCTS WITH THE  SAME PRICE?
--SOLUTION

SELECT *
FROM ProductTB
WHERE Price IN (
    SELECT Price
	FROM ProductTB
	GROUP BY Price
	HAVING COUNT(Price) > 1
	);

--TASK 2
--Find the second highest priced product and its category?
--SOLUTION

SELECT ProductID, ProductName, CategoryName
	FROM ProductTB P
	INNER JOIN Category C ON P.CategoryID = P.CategoryID
	ORDER BY Price DESC
	OFFSET 1 ROW
	FETCH NEXT 1 ROW ONLY;

	--TASK 3
--GET THE MAXIMUM PRICE PER CATEGORY AND THE PRODUCT NAME?
--SOLUTION


  WITH RankedproductTB AS ( SELECT CategoryID, ProductName, Price,
  ROW_NUMBER() OVER (PARTITION BY categoryID order by price desc) as rowNum
  from ProductTB
  )
  select CategoryID, productName, price maxperice
  from RankedproductTB
  where rowNum = 1;

  --TASK 4
--SUPPLIER-WISE COUNT OF PRODUCTS SORTED BY COUNT IN DESCENDING ORDER?
--SOLUTION

SELECT COUNT(DISTINCT Supplier.SupplierName) COUNT_OF_products, Supplier.SupplierID
FROM Supplier, ProductTB
WHERE Supplier.SupplierID = ProductTB.SupplierID
group by ProductTB.SupplierID, Supplier.SupplierID
ORDER BY COUNT_OF_products DESC;

--TASK 5
--FETCH ONLY THE FIRST WORD FROM THE PRODUCTNAME AND APPEND THE PRICE?
--SOLUTION

SELECT CONCAT(LEFT(ProductName,
  CHARINDEX(' ', ProductName) -1), '_', Price) firstName_price
  FROM ProductTB
  SELECT ProductName, Price 
  FROM ProductTB;


  --TASK 6
--Fetch products with odd prices?
--SOLUTION

SELECT ProductName
from ProductTB
where Price % 2 = 1


--TASK 7
--CREATE A VIEW TO FETCH PRODUCTS WITH A PRICE GREATER THAN $500?
--SOLUTION

CREATE VIEW VW_PRODUCT_PRICE_$500
AS 
SELECT
ProductTB.Price,
ProductTB.ProductName,
ProductTB.ProductID,
ProductTB.SupplierID
FROM
ProductTB
INNER JOIN Category C ON ProductTB.CategoryID = C.CategoryID
INNER JOIN Supplier S on ProductTB.SupplierID = S.supplierID
WHERE ProductTB.Price > 500


--TASK 8
--CReate a procedure to update product prices by 15% where the category is ELECTRONICS 
--and the supplier is not SupplierA?
--SOLUTION

 CREATE PROCEDURE SP_UpdateProductPrice
  AS
  BEGIN
      UPDATE ProductTB 
	  SET ProductTB.Price = P.Price * 1.15
	  from ProductTB P
	  INNER JOIN Category C ON P.CategoryID = C.CategoryID
      INNER JOIN Supplier S on P.SupplierID = S.supplierID
	  WHERE C.CategoryName = 'ELECTRONICS' 
	  AND S.SupplierName NOT IN ('SupplierA')
	  END
	  GO
	  EXEC SP_UpdateProductPrice;


	  --TASK 9
--CReate a stored procedure to fetch product details along with their category, supplier,
--and warehouse location including error handling?
--SOLUTION



CREATE PROCEDURE SP_GetProductDetails
AS
BEGIN
  BEGIN TRY
    SELECT 
      P.ProductID, 
      P.ProductName, 
      C.CategoryName, 
      S.SupplierName, 
      W.WarehouseName, 
      W.Location
    FROM 
      ProductTB P
    INNER JOIN 
      Category C ON P.CategoryID = C.CategoryID
    INNER JOIN 
      Supplier S ON P.SupplierID = S.SupplierID
    INNER JOIN 
      Warehouse W ON S.SupplierID = W.WarehouseID
  END TRY
  BEGIN CATCH
    DECLARE @ErrorMessage nvarchar(4000)
    SET @ErrorMessage = ERROR_MESSAGE()
    RAISERROR (@ErrorMessage, 16, 1)
  END CATCH
END
GO
EXEC SP_GetProductDetails






  

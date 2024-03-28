--DATA MIGRATION FROM OLTP TO STAGING ENVIRONMENT SCRIPT--

USE [GROUP_STAGING]
GO

CREATE SCHEMA STAGING
GO
--denormalizing the Locations Tables --
-- CREATING A LOCATION LOOKUP TABLE --
USE [GROUP_OLTP]
SELECT 
LF.[LocationFact_ID_PK],
LF.[Location_ID_FK], 
LD.[Name],
CD.County,
TZ.[Time Zone],
TD.[Type],
SC.[State Code],
SD.[State],
LF.[Area Code],
LF.[Households],
LF.[Land Area],
LF.[Latitude],
LF.[Longitude],
LF.[Median Income],
LF.[Population],
LF.[Water Area]

FROM [OLTP].[Location_Fact] LF
LEFT JOIN
[OLTP].[Location_Dim] LD ON LF.Location_ID_FK = LD.Location_ID_PK
LEFT JOIN 
[OLTP].[County_Dim] CD ON LD.County_ID_FK = CD.County_ID_PK
LEFT JOIN
[OLTP].[StateCode_Dim] SC ON CD.StateCode_ID_FK = SC.StateCode_ID_PK
LEFT JOIN
[OLTP].[State_Dim] SD ON SC.State_ID_FK = SD.State_ID_PK
LEFT JOIN
[OLTP].[TimeZone_Dim] TZ ON LD.TimeZone_ID_FK = TZ.TimeZone_ID_PK
LEFT JOIN
[OLTP].[Type_Dim] TD ON LD.Type_ID_FK = TD.Type_ID_PK
GO

-- create a view for the locations lookup table --
USE [GROUP_OLTP]
GO

CREATE VIEW VW_LocationLookUp 
WITH SCHEMABINDING
AS
SELECT 
LF.[LocationFact_ID_PK],
LF.[Location_ID_FK], 
LD.County_ID_FK,
CD.StateCode_ID_FK,
SC.State_ID_FK,
LD.[Type_ID_FK],
LD.[TimeZone_ID_FK],
LD.[Name],
CD.County,
TZ.[Time Zone],
TD.[Type],
SC.[State Code],
SD.[State],
LF.[Area Code],
LF.[Households],
LF.[Land Area],
LF.[Latitude],
LF.[Longitude],
LF.[Median Income],
LF.[Population],
LF.[Water Area]

FROM [OLTP].[Location_Fact] LF
LEFT JOIN
[OLTP].[Location_Dim] LD ON LF.Location_ID_FK = LD.Location_ID_PK
LEFT JOIN 
[OLTP].[County_Dim] CD ON LD.County_ID_FK = CD.County_ID_PK
LEFT JOIN
[OLTP].[StateCode_Dim] SC ON CD.StateCode_ID_FK = SC.StateCode_ID_PK
LEFT JOIN
[OLTP].[State_Dim] SD ON SC.State_ID_FK = SD.State_ID_PK
LEFT JOIN
[OLTP].[TimeZone_Dim] TZ ON LD.TimeZone_ID_FK = TZ.TimeZone_ID_PK
LEFT JOIN
[OLTP].[Type_Dim] TD ON LD.Type_ID_FK = TD.Type_ID_PK
GO

SELECT * FROM VW_LocationLookUp
GO
-- creating the Location Lookup table --

USE [GROUP_STAGING]
DROP TABLE IF EXISTS STAGING.LocationLookUp
CREATE TABLE STAGING.LocationLookUp(
    [LocationFact_ID_PK] bigint,
    [Location_ID_FK] nvarchar(255),
    [Name] nvarchar(255),
    [County] nvarchar(255),
    [Time Zone] nvarchar(255),
    [Type] nvarchar(255),
    [State Code] nvarchar(255),
    [State] nvarchar(255),
    [Area Code] bigint,
    [Households] bigint,
    [Land Area] float,
    [Latitude] float,
    [Longitude] float,
    [Median Income] float,
    [Population] bigint,
    [Water Area] float
)
GO
-- creating the Product Lookup Table by denormalizing related tables in the snowflake schema model --
USE [GROUP_OLTP]
SELECT  
PF.[ProductFact_ID_PK],
PF.[Product_ID_FK],
PD.[Product_Name],
PF.[Cost],
PF.[Original Sale Price],
PF.[Current Price],
PF.[Discount],
PF.[Taxes]

FROM [OLTP].[Product_Fact] PF 
LEFT JOIN [OLTP].[Product_Dim] PD ON PF.Product_ID_FK = PD.Product_ID_PK
GO
--product look up table --
USE [GROUP_STAGING]
DROP TABLE IF EXISTS STAGING.ProductLookUp
CREATE TABLE STAGING.ProductLookUp (
    [ProductFact_ID_PK] bigint,
    [Product_ID_FK] nvarchar(255),
    [Product_Name] nvarchar(255),
    [Cost] float,
    [Original Sale Price] float,
    [Current Price] float,
    [Discount] float,
    [Taxes] float
)
GO

--creating the Sales Fact table --
USE [GROUP_OLTP]
SELECT 
SF.[Order_ID_PK],
SF.[Product_ID_FK],
SF.[Customer_ID_FK],
SF.[SalesPerson_ID_FK],
SF.Location_ID_FK,
SF.[Price],
SF.[Quantity],
SF.[Purchase_Date],
SF.[Upload_Date]
FROM [OLTP].[Sales_Fact] SF 
GO

-- creating the Sales Fact Table --

USE [GROUP_STAGING]
DROP TABLE IF EXISTS STAGING.SalesFact
CREATE TABLE STAGING.SalesFact (
    [Order_ID_PK] nvarchar(255),
    [Product_ID_FK] nvarchar(255),
    [Customer_ID_FK] nvarchar(255),
    [SalesPerson_ID_FK] nvarchar(255),
    [Location_ID_FK] nvarchar(255),
    [Price] float,
    [Quantity] float,
    [Purchase_Date] datetime,
    [Upload_Date] nvarchar(255)
)
GO

--creating the Customers Look Up table
USE [GROUP_STAGING]
DROP TABLE IF EXISTS STAGING.CustomerLookUp
CREATE TABLE STAGING.CustomerLookUp (
    [Customer_ID_PK] nvarchar(255),
    [Customer_Name] nvarchar(255)
CONSTRAINT PK_Staging_CustomerLookUp_CustomerID PRIMARY KEY (Customer_ID_PK)
)

-- creating the Salesperson Look Up table

USE [GROUP_STAGING]
DROP TABLE IF EXISTS STAGING.SalespersonLookUp
CREATE TABLE STAGING.SalespersonLookUp (
    [Salesperson_ID_PK] nvarchar(255),
    [Salesperson_Name] nvarchar(255)
CONSTRAINT PK_Staging_SalespersonLookUp_SalespersonID PRIMARY KEY (Salesperson_ID_PK)
)
GO

select * from [GROUP_STAGING].STAGING.SalesFact
 ----
 
 IF (SELECT COUNT(*) FROM [GROUP_STAGING].STAGING.SalesFact) = 0
BEGIN
SELECT * FROM [GROUP_OLTP].[OLTP].[Sales_Fact]
WHERE [upload_date] = (select min([upload_date]) from [GROUP_OLTP].[OLTP].[Sales_fact])
END
ELSE
IF (select max([upload_date]) from [GROUP_STAGING].STAGING.SalesFact) = (select min([upload_date]) 
from [GROUP_OLTP].[OLTP].[Sales_fact])
BEGIN
SELECT * FROM [GROUP_OLTP].[OLTP].[Sales_fact]
WHERE [upload_date] > (select min([upload_date]) from [GROUP_OLTP].[OLTP].[Sales_fact]) AND
[upload_date] < (select max([upload_date]) from [GROUP_OLTP].[OLTP].[Sales_fact])
END
ELSE
BEGIN
SELECT * FROM [GROUP_OLTP].[OLTP].[Sales_fact]
WHERE [upload_date] = (select max([upload_date]) from [GROUP_OLTP].[OLTP].[Sales_fact])
END

use [GROUP_DW]
select * from warehouse.SalesFact


SELECT SF.Order_ID_PK, 
LL.Location_ID_SK, 
CL.Customer_ID_SK,
SPL.Salesperson_ID_SK, 
PL.Product_ID_SK,
SF.Price, 
SF.Purchase_Date, 
SF.Quantity, 
SF.Upload_Date

FROM [GROUP_STAGING].STAGING.SalesFact SF
LEFT JOIN [GROUP_DW].WAREHOUSE.LocationLookUp LL ON SF.Location_ID_FK = LL.Location_ID_FK
LEFT JOIN [GROUP_DW].WAREHOUSE.CustomerLookup CL ON SF.Customer_ID_FK = CL.Customer_ID_PK
LEFT JOIN [GROUP_DW].WAREHOUSE.SalespersonLookUp SPL ON SF.SalesPerson_ID_FK = SPL.Salesperson_ID_PK
LEFT JOIN [GROUP_DW].WAREHOUSE.ProductLookUp PL ON SF.Product_ID_FK = PL.Product_ID_FK

select Order_ID_PK, Location_ID_SK, Customer_ID_SK, Salesperson_ID_SK, Product_ID_SK,
Price, Purchase_Date, Quantity, Upload_date, Start_date, End_date, max(quantity) from WAREHOUSE.SalesFact

use GROUP_OLTP
select * from oltp.Sales_Fact
go

with cte as (select product_id_fk, max(Quantity) as maximum_quantity_product from oltp.Sales_Fact
group by Order_ID_PK)
select * from oltp.Sales_Fact sf join cte c on sf.Product_ID_FK = cte.product_id_fk;

go

WITH OrderedProducts AS (
    SELECT
		Order_ID_PK,
        Product_id_fk,
		Salesperson_ID_FK,
		Customer_ID_FK,
		Price,
	    Quantity,
        ROW_NUMBER() OVER (PARTITION BY ORDER_ID_PK ORDER BY Quantity DESC) AS RowNum
    FROM
        OLTP.Sales_Fact 
)

SELECT
	Order_ID_PK,
    Product_id_fk,
		Salesperson_ID_FK,
		Customer_ID_FK,
		Price,
	    Quantity
FROM
    OrderedProducts
WHERE
    RowNum = 1 AND Product_ID_FK = 'ENX2008'
ORDER BY Salesperson_ID_FK;


use [GROUP_OLTP]
select 
Customer_ID_PK,
Customer_Name,
UPPER(parsename(replace(Customer_Name,' ', '.'), 2)) as Customer_FirstName,
LOWER(parsename(replace(Customer_Name, ' ', '.'),1)) as Customer_LastName 
from [OLTP].[Customer_Dim]


USE [GROUP_OLTP]
SELECT
Salesperson_ID_PK,
Salesperson_Name,
UPPER(PARSENAME(REPLACE(Salesperson_Name, ' ', '.'), 2)) AS [Salesperson_FirstName],
LOWER(PARSENAME(REPLACE(Salesperson_Name, ' ', '.'), 1)) AS [Salesperson_LastName]
FROM [OLTP].[Salesperson_Dim]
GO

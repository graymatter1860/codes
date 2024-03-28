--DATA MIGRATION FROM STAGING TO WAREHOUSE --

USE [PROJECT_DW]
GO

CREATE SCHEMA WAREHOUSE
GO

--creating the Location Lookup table --

DROP TABLE IF EXISTS WAREHOUSE.LocationLookUp
CREATE TABLE WAREHOUSE.LocationLookUp(
	LOCATION_ID_SK int IDENTITY(1,1),
    [CityID_FK] nvarchar(100),
    [CountyID_FK] bigint,
    [StateCodeID_FK] bigint,
    [StateID_FK] bigint,
    [LocationTypeID_FK] bigint,
    [TimeZoneID_FK] bigint,
    [Area Code] bigint,
    [Households] bigint,
    [Land Area] float,
    [Latitude] float,
    [Longitude] float,
    [Median Income] float,
    [Population] bigint,
    [Water Area] float,
    [Name] nvarchar(100),
    [County] nvarchar(100),
    [State Code] nvarchar(5),
    [State] nvarchar(100),
	[Start_date] datetime,
	[End_date] datetime
CONSTRAINT PK_LocationLookUp_Location_ID_SK PRIMARY KEY (LOCATION_ID_SK)
)
GO

-- creating the Product Lookup table --
DROP TABLE IF EXISTS WAREHOUSE.ProductLookUp
CREATE TABLE WAREHOUSE.ProductLookUp(
    [PriceID_PK] bigint,
    [ProductID_FK] nvarchar(255),
    [Product Name] nvarchar(255),
    [Cost] float,
    [Original Sale Price] float,
    [Current Price] float,
    [Discount] float,
    [Taxes] float,
	[Start_date] datetime,
	[End_date] datetime
)
GO

-- creating the Sales Fact table --

DROP TABLE IF EXISTS WAREHOUSE.SalesFact
CREATE TABLE WAREHOUSE.SalesFact (
	[Sales_ID] int IDENTITY(1,1),
    [OrderID_PK] nvarchar(255),
    [ProductID_FK] nvarchar(255),
    [CustomerID_FK] nvarchar(255),
    [CityID_FK] nvarchar(255),
	[PriceID_FK] int,
    [SalesPersonID_FK] nvarchar(255),
    [Price] bigint,
    [Quantity] bigint,
    [Purchase Date] datetime,
    [Upload Date] nvarchar(255),
	[Start_date] datetime,
	[End_date] datetime

CONSTRAINT SK_SalesFact_Sales_ID PRIMARY KEY (Sales_ID]
)GO

 USE [PROJECT_STAGING]
SELECT 
    sf.[OrderID_PK],
    sf.[ProductID_FK],
    sf.[CustomerID_FK],
    sf.[CityID_FK],
	p.[PriceID_PK],
    sf.[SalesPersonID_FK],
    sf.[Price],
    sf.[Quantity],
    sf.[Purchase Date],
    sf.[Upload Date]
FROM [PROJECT_STAGING].[STAGING].[SalesFact] sf
LEFT JOIN [PROJECT_STAGING].[STAGING].[ProductLookUp] p
ON sf.ProductID_FK = p.ProductID_FK
GO

USE [PROJECT_DW]
DROP TABLE IF EXISTS WAREHOUSE.SalesFact
CREATE TABLE WAREHOUSE.SalesFact (
	Sales_ID int IDENTITY(1,1),
    [OrderID_PK] nvarchar(255),
    [ProductID_FK] nvarchar(255),
    [CustomerID_FK] nvarchar(255),
    [CityID_FK] nvarchar(255),
    [SalesPersonID_FK] nvarchar(255),
    [Price] bigint,
    [Quantity] bigint,
    [Purchase Date] datetime,
    [Upload Date] nvarchar(255),
    [PriceID_PK] bigint,
	[Start_date] datetime,
	[End_date] datetime
CONSTRAINT SK_SalesFact_SalesID PRIMARY KEY (Sales_ID)
CONSTRAINT FK_SalesFact_CustomerID_FK (CustomerID_FK) REFERENCES WAREHOUSE.CustomerDim (CustomerID_PK),
CONSTRAINT FK_SalesFact_SalespersonDim (SalespersonID_FK) REFERENCES WAREHOUSE.SalespersonDim (SalespersonID_PK),
CONSTRAINT fk
)
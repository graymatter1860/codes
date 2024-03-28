--SCRIPT FILES TO CREATE DATABASES AT THE OLTP PRIOR TO MIGRATING EXCEL FILES

--CREATING TABLES FOR AT THE OLTP --

USE [GROUP_OLTP]
GO

CREATE SCHEMA OLTP
GO

--creating the State Dim table --
DROP TABLE IF EXISTS OLTP.State_Dim
CREATE TABLE OLTP.State_Dim (
    [State_ID_PK] bigint,
    [State] nvarchar(255)
CONSTRAINT PK_OLTP_State_Dim_StateID PRIMARY KEY (State_ID_PK)
)
GO

-- creating the State Code Dim table --
DROP TABLE IF EXISTS OLTP.StateCode_Dim
CREATE TABLE OLTP.StateCode_Dim (
    [StateCode_ID_PK] bigint,
    [State_ID_FK] bigint,
    [State Code] nvarchar(255)
CONSTRAINT PK_OLTP_StateCode_Dim_StateCodeID PRIMARY KEY (StateCode_ID_PK),
CONSTRAINT FK_OLTP_StateCode_Dim_State_ID FOREIGN KEY (State_ID_FK) 
REFERENCES OLTP.State_Dim (State_ID_PK)
)
GO

-- creating County Dim --
DROP TABLE IF EXISTS OLTP.County_Dim
CREATE TABLE OLTP.County_Dim (
    [County_ID_PK] bigint,
    [StateCode_ID_FK] bigint,
    [County] nvarchar(255)
CONSTRAINT PK_OLTP_County_Dim_CountyID PRIMARY KEY (County_ID_PK),
CONSTRAINT FK_OLTP_County_Dim_StateCodeID FOREIGN KEY (StateCode_ID_FK) 
REFERENCES OLTP.StateCode_Dim (StateCode_ID_PK)
)
GO

-- creating the TimeZone Dimension table --
DROP TABLE IF EXISTS OLTP.TimeZone_Dim
CREATE TABLE OLTP.TimeZone_Dim (
    [TimeZone_ID_PK] bigint,
    [Time Zone] nvarchar(255)
CONSTRAINT PK_OLTP_TimeZone_Dim_TimeZoneID PRIMARY KEY (TimeZone_ID_PK),
)
GO
-- creating the Type Dim table --
DROP TABLE IF EXISTS OLTP.Type_Dim
CREATE TABLE OLTP.Type_Dim (
    [Type_ID_PK] bigint,
    [Type] nvarchar(255)
CONSTRAINT PK_OLTP_Type_Dim_TypeID PRIMARY KEY (Type_ID_PK)
)
GO
-- creating the Location Dim table --
DROP TABLE IF EXISTS OLTP.Location_Dim
CREATE TABLE OLTP.Location_Dim (
    [Location_ID_PK] nvarchar(255),
    [County_ID_FK] bigint,
    [TimeZone_ID_FK] bigint,
    [Type_ID_FK] bigint,
    [Name] nvarchar(255)
CONSTRAINT PK_OLTP_Location_Dim_LocationID PRIMARY KEY (Location_ID_PK),
CONSTRAINT FK_OLTP_Location_Dim_CountyID FOREIGN KEY (County_ID_FK)
REFERENCES OLTP.County_Dim (County_ID_PK),
CONSTRAINT FK_OLTP_Location_Dim_TimeZoneID FOREIGN KEY (TimeZone_ID_FK) 
REFERENCES OLTP.TimeZone_Dim (TimeZone_ID_PK),
CONSTRAINT FK_OLTP_Location_Dim_TypeID FOREIGN KEY (Type_ID_FK) 
REFERENCES OLTP.Type_Dim (Type_ID_PK)
)
GO
--creation of Location Fact table --
DROP TABLE IF EXISTS OLTP.Location_Fact
CREATE TABLE OLTP.Location_Fact (
    [LocationFact_ID_PK] bigint,
    [Location_ID_FK] nvarchar(255),
    [Area Code] bigint,
    [Households] bigint,
    [Land Area] float,
    [Latitude] float,
    [Longitude] float,
    [Median Income] float,
    [Population] bigint,
    [Water Area] float
CONSTRAINT PK_Location_Fact_LocationFactID PRIMARY KEY (LocationFact_ID_PK),
CONSTRAINT FK_Location_Fact_LocationID FOREIGN KEY (Location_ID_FK) 
REFERENCES OLTP.Location_Dim (Location_ID_PK)
)
GO

-- creating the Salesperson Dim table --
DROP TABLE IF EXISTS OLTP.Salesperson_Dim
CREATE TABLE OLTP.Salesperson_Dim (
    [Salesperson_ID_PK] nvarchar(255),
    [Salesperson_Name] nvarchar(255)
CONSTRAINT PK_OLTP_Salesperson_Dim_SalespersonID PRIMARY KEY (Salesperson_ID_PK)
)
GO

-- creating the  Customer Dim table --
DROP TABLE IF EXISTS OLTP.Customer_Dim
CREATE TABLE OLTP.Customer_Dim (
    [Customer_ID_PK] nvarchar(255),
    [Customer_Name] nvarchar(255)
CONSTRAINT PK_OLTP_Customer_Dim_CustomerID PRIMARY KEY (Customer_ID_PK)
)
GO
-- creating the Product Dim table --
DROP TABLE IF EXISTS OLTP.Product_Dim
CREATE TABLE OLTP.Product_Dim (
    [Product_ID_PK] nvarchar(255),
    [Product_Name] nvarchar(255)
CONSTRAINT PK_OLTP_Product_Dim_Product_ID PRIMARY KEY (Product_ID_PK)
)
GO
-- creating the Product Fact table --
DROP TABLE IF EXISTS OLTP.Product_Fact
CREATE TABLE OLTP.Product_Fact (
    [ProductFact_ID_PK] bigint,
    [Product_ID_FK] nvarchar(255),
    [Cost] float,
    [Current Price] float,
    [Discount] float,
    [Original Sale Price] float,
    [Taxes] float
CONSTRAINT PK_OLTP_Product_Fact_ProductFactID PRIMARY KEY (ProductFact_ID_PK),
CONSTRAINT FK_OLTP_Product_Fact_ProductID FOREIGN KEY (Product_ID_FK)
REFERENCES OLTP.Product_Dim (Product_ID_PK)
)
GO

-- creating the Sales Fact table --
DROP TABLE IF EXISTS OLTP.Sales_Fact
CREATE TABLE OLTP.Sales_Fact (
    [Order_ID_PK] nvarchar(255),
    [Location_ID_FK] nvarchar(255),
    [Product_ID_FK] nvarchar(255),
    [Salesperson_ID_FK] nvarchar(255),
    [Customer_ID_FK] nvarchar(255),
    [Price] float,
    [Quantity] float,
    [Purchase_Date] datetime,
    [Upload_Date] nvarchar(255)
CONSTRAINT PK_OLTP_Sales_Fact_OrderID PRIMARY KEY (Order_ID_PK),
CONSTRAINT FK_OLTP_Sales_Fact_LocationID FOREIGN KEY (Location_ID_FK) 
REFERENCES OLTP.Location_Dim (Location_ID_PK),

CONSTRAINT FK_OLTP_Sales_Fact_ProductID FOREIGN KEY (Product_ID_FK) 
REFERENCES OLTP.Product_Dim (Product_ID_PK),

CONSTRAINT FK_OLTP_Sales_Fact_SalespersonID FOREIGN KEY (Salesperson_ID_FK) 
REFERENCES OLTP.Salesperson_Dim (Salesperson_ID_PK),

CONSTRAINT FK_OLTP_Sales_Fact_CustomerID FOREIGN KEY (Customer_ID_FK) 
REFERENCES OLTP.Customer_Dim (Customer_ID_PK)
)
GO

--end of code--


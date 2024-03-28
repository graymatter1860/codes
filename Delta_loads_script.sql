-- code for capturing incremental changes in the sales fact table while migrating from oltp to staging--

/*The Logic:
line 1: If there is no data in the warehouse table
line 2: begin the operation that follows
line 3: select all columns from the OLTP sales table
line 4: filter data for where the upload date is equal to the minimum upload date (2018 data)
		and this is captured using the subquery - (select min(upload_date) from OLTP sales table)
line 5: end the operation.
line 6: Else, if the first condition is not fulfilled - that is if there is already data in the staging table...
line 7: If the maximum upload date in the staging table is equal to the minimum upload date in the oltp table
		(essentially, you are saying if the data in the staging is only that of 2018 (min in the oltp)
line 8: begin a new operation
line 9/10: select data from oltp where upload date is greater than the minimum date but smaller than the maximum date
		(in other words, you are extracting only the 2019 data)
line 11: end the operation
line 12: else - that is if the maximum date in the staging is not equal to the minimum in the oltp (which means we already
		have the 2019 data)
line 13: begin the operation
line 14: select all columns from oltp, where upload date is the maximum upload date (2020 data)*/

IF (SELECT COUNT(*) FROM [GROUP_DW].WAREHOUSE.SalesFact) = 0
BEGIN
SELECT * FROM [GROUP_OLTP].[OLTP].[Sales_fact_testing]
WHERE [upload date] = (select min([upload date]) from [GROUP_OLTP].[OLTP].[Sales_fact_testing])
END
ELSE
IF (select max([upload date]) from [GROUP_STAGING].STAGING.Sales_fact_testing) = (select min([upload date]) 
from [GROUP_OLTP].[OLTP].[Sales_fact_testing])
BEGIN
SELECT * FROM [GROUP_OLTP].[OLTP].[Sales_fact_testing]
WHERE [upload date] > (select min([upload date]) from [GROUP_OLTP].[OLTP].[Sales_fact_testing]) AND
[upload date] < (select max([upload date]) from [GROUP_OLTP].[OLTP].[Sales_fact_testing])
END
ELSE
BEGIN
SELECT * FROM [GROUP_OLTP].[OLTP].[Sales_fact_testing]
WHERE [upload date] = (select max([upload date]) from [GROUP_OLTP].[OLTP].[Sales_fact_testing])
END


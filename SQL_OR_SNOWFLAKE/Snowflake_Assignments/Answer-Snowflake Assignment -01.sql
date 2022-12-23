
-- ASSIGNMENT_ANSWERS;

USE WAREHOUSE INEURON_ASSIGNMENTS;
USE DATABASE ASSIGNMENT_DB;

/* __________________________________ ANSWER 1 __________________________________ */

-- 1. Load the given dataset into snowflake with a primary key to Order Date column;

-- DROP TABLE IF EXISTS VJ_SALES_DATA;
CREATE OR REPLACE TABLE VJ_SALES_DATA
							 (order_id VARCHAR(40),
							  order_date VARCHAR(15) NOT NULL PRIMARY KEY,
							  ship_date VARCHAR(15),
							  ship_mode VARCHAR(20),
							  customer_name VARCHAR(40),
							  segment VARCHAR(40),
							  state VARCHAR(40),
							  country VARCHAR(40),
							  market VARCHAR(40),
							  region VARCHAR(40),
							  product_id VARCHAR(50),
							  category VARCHAR(40),
							  sub_category VARCHAR(40),
							  product_name VARCHAR2(200),
							  sales NUMBER(20,4),
							  quantity NUMBER(10,4),
							  discount NUMBER(10,4),
							  profit NUMBER(10,4),
							  shipping_cost NUMBER(10,4),
							  order_priority CHAR(20),
							  year INTEGER
							  );
                              
SELECT GET_DDL('Table', 'VJ_SALES_DATA');

SELECT *
FROM VJ_SALES_DATA;

-- DROP TABLE IF EXISTS VJ_SALES_COPY;

CREATE OR REPLACE TABLE VJ_SALES_COPY LIKE VJ_SALES_DATA; -- Copy architecture of the database;

SELECT GET_DDL('Table', 'VJ_SALES_COPY');

CREATE OR REPLACE TABLE VJ_SALES_COPY AS SELECT * FROM VJ_SALES_DATA; -- Copy of original dataset;

SELECT *
FROM VJ_SALES_COPY;

DESCRIBE TABLE VJ_SALES_COPY; -- Verify Order_Date is PRIMARY KEY of the table;
-- OR 
SHOW PRIMARY KEYS IN VJ_SALES_COPY; -- It shows only primary key of the database i.e., ORDER_DATE;

-- #NOTE: We create a copy of original data and now work on copy dataset.

/* __________________________________ ANSWER 2 __________________________________ */

-- 2. Change the Primary key to Order Id Column.


ALTER TABLE VJ_SALES_COPY
DROP PRIMARY KEY;          -- Only one primary key possible on the table, so we need to drop it first and then add accordingly.

ALTER TABLE VJ_SALES_COPY 
ADD PRIMARY KEY (ORDER_ID); -- Now, make a primary key to order_ID beacuse it does not accept the any duplicate and NULL values.

SHOW PRIMARY KEYS IN VJ_SALES_COPY; -- Primary key is set for ORDER_ID;
-- OR
DESCRIBE TABLE VJ_SALES_COPY; -- Full description of the dataset;

SELECT GET_DDL('Table', 'VJ_SALES_COPY'); -- Scroll down, you can see primary key is set for order_id

/* __________________________________ ANSWER 3 __________________________________ */

-- 3. Check the data type for Order date and Ship date and mention in what data type it should be?

DESCRIBE TABLE VJ_SALES_COPY;
-- OR
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'PUBLIC' AND TABLE_NAME = 'VJ_SALES_COPY' AND (COLUMN_NAME = 'ORDER_DATE' OR COLUMN_NAME = 'SHIP_DATE');

-- The above code check and indiactes that the column ORDER_DATE and SHIP_DATE is TEXT i.e., VARCHAR.

-- Thus, the ORDER_DATE and SHIP_DATE should be in DATE FORMAT but it is in VARCHAR.
-- Therefore, we need to change it from VARCHAR TO DATE.

CREATE OR REPLACE TABLE VJ_SALES_COPY AS SELECT *, TO_DATE(ORDER_DATE, 'YYYY-MM-DD') AS ORDER_DATE_NEW,
                                                   TO_DATE(SHIP_DATE, 'YYYY-MM-DD') AS SHIP_DATE_NEW
                                         FROM VJ_SALES_DATA;


SELECT *
FROM VJ_SALES_COPY;

ALTER TABLE VJ_SALES_COPY 
ADD PRIMARY KEY (ORDER_ID);

DESCRIBE TABLE VJ_SALES_COPY; -- ORDER_DATE and SHIP_DATE is in DATE FORMAT.
-- OR
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'PUBLIC' AND TABLE_NAME = 'VJ_SALES_COPY' AND (COLUMN_NAME = 'ORDER_DATE_NEW' OR COLUMN_NAME = 'SHIP_DATE_NEW');

ALTER TABLE VJ_SALES_COPY
DROP COLUMN ORDER_DATE, SHIP_DATE; -- We can drop irrelevant column from the table.

DESCRIBE TABLE VJ_SALES_COPY;


-- Now, ORDER_DATE and SHIP_DATE is in "DATE" FORMAT.

/* ROUGH (IGNORE)
CREATE OR REPLACE TABLE VJ_SALES_ROUGH_COPY AS
SELECT *, TO_CHAR(TO_DATE(ORDER_DATE, 'YYYY-MM-DD'), 'DD-MM-YYYY') AS ORDER_DATE_NEW,
          TO_CHAR(TO_DATE(SHIP_DATE, 'YYYY-MM-DD'), 'DD-MM-YYYY') AS SHIP_DATE_NEW 
FROM VJ_SALES_DATA;
DROP TABLE VJ_SALES_ROUGH_COPY;
*/


/* __________________________________ ANSWER 4__________________________________ */

-- 4. Create a new column called order_extract and extract the number after the last ‘–‘from Order ID column.

ALTER TABLE VJ_SALES_COPY
ADD COLUMN ORDER_EXTRACT INT;

-- Extractin the last number using SPLIT_PART () or SUBSTR () function both work in same way.

SELECT SPLIT_PART(ORDER_ID,'-',3) AS SPLIT_ID,
       SUBSTR(ORDER_ID, 9) AS SUBSTR_ID
FROM VJ_SALES_COPY;

-- NOW, updating a new column ORDER_EXTRACT.

UPDATE VJ_SALES_COPY
SET ORDER_EXTRACT = SPLIT_PART(ORDER_ID,'-',3);

SELECT ORDER_ID, ORDER_EXTRACT
FROM VJ_SALES_COPY;

/* __________________________________ ANSWER 5 __________________________________ */;

/* 5. Create a new column called Discount Flag and categorize it based on discount.
Use ‘Yes’ if the discount is greater than zero else ‘No’ */



ALTER TABLE VJ_SALES_COPY
ADD COLUMN DISCOUNT_FLAG VARCHAR(5);

UPDATE VJ_SALES_COPY
SET DISCOUNT_FLAG = (CASE
                         WHEN DISCOUNT > 0 THEN 'YES'
                         ELSE 'NO'
                     END);
                     
SELECT *
FROM VJ_SALES_COPY;

/* __________________________________ ANSWER 6 __________________________________ */;

/* 6. Create a new column called process days and
      calculate how many days it takes for each order id to process from the order to its shipment */
      

ALTER TABLE VJ_SALES_COPY
ADD COLUMN PROCESS_DAY INT;


UPDATE VJ_SALES_COPY
SET PROCESS_DAY = (DATEDIFF(DAYS, ORDER_DATE_NEW, SHIP_DATE_NEW)); -- FROM Order_Date to SHIP_DATE;

SELECT ORDER_DATE_NEW, SHIP_DATE_NEW, PROCESS_DAY
FROM VJ_SALES_COPY;


/* __________________________________ ANSWER 7 __________________________________ */;

/* 7. Create a new column called Rating and then based on the Process dates give rating like given below.
        a. If process days less than or equal to 3days then rating should be 5
        b. If process days are greater than 3 and less than or equal to 6 then rating should be 4
        c. If process days are greater than 6 and less than or equal to 10 then rating should be 3
        d. If process days are greater than 10 then the rating should be 2. */;
        













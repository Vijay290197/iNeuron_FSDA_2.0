USE WAREHOUSE INEURON_ASSIGNMENTS;
USE DATABASE ASSIGNMENT_DB;


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TASK 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */;

DROP TABLE IF EXISTS SHOPPING_HISTORY;

CREATE OR REPLACE TABLE SHOPPING_HISTORY (PRODUCT VARCHAR NOT NULL,
                                          QUANTITY INT NOT NULL,
                                          UNIT_PRICE INT NOT NULL
                                         );
                                         
INSERT INTO SHOPPING_HISTORY (PRODUCT, QUANTITY, UNIT_PRICE) VALUES ('milk', 3, 10),
                                                                    ('bread', 7, 3),
                                                                    ('bread', 5, 2);
                                                                    

ALTER TABLE SHOPPING_HISTORY
ADD COLUMN TOTAL_PRICE FLOAT;

UPDATE SHOPPING_HISTORY
SET TOTAL_PRICE = (QUANTITY*UNIT_PRICE);

SELECT *
FROM SHOPPING_HISTORY;

SELECT PRODUCT, SUM(TOTAL_PRICE)
FROM SHOPPING_HISTORY
GROUP BY PRODUCT;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TASK 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */;

-- TASK 2.1;

CREATE OR REPLACE TABLE PHONES (NAME VARCHAR (20) NOT NULL UNIQUE,
                                PHONE_NUMBER INT NOT NULL UNIQUE
                                );
                                
CREATE OR REPLACE TABLE CALLS (ID INT NOT NULL UNIQUE,
                               CALLER INT NOT NULL,
                               CALLEE INT NOT NULL,
                               DURATION INT NOT NULL
                               );
                               
    
INSERT INTO PHONES (NAME, PHONE_NUMBER) VALUES ('Jack', 1234),
                                               ('Lena', 3333),
                                               ('Mark', 9999),
                                               ('Anna', 7582);
                                               
                                               
SELECT *
FROM PHONES;

SELECT GET_DDL('TABLE', 'PHONES');

INSERT INTO CALLS (ID, CALLER,CALLEE, DURATION)
VALUES (25, 1234, 7582, 8),
       (7, 9999, 7582, 1),
       (18, 9999, 3333, 4),
       (2, 7582, 3333, 3),
       (3, 3333, 1234, 1),
       (21, 3333, 1234, 1);
       
                                               
SELECT *
FROM CALLS;

SELECT caller AS phone_number, SUM(duration) AS duration
                       FROM calls
                       GROUP BY caller
                       UNION ALL
                       SELECT callee AS phone_number, SUM(duration) AS duration
                       FROM calls
                       GROUP BY callee;

SELECT GET_DDL('TABLE', 'CALLS');

WITH call_duration AS (SELECT caller AS phone_number, SUM(duration) AS duration
                       FROM calls
                       GROUP BY caller
                       UNION ALL
                       SELECT callee AS phone_number, SUM(duration) AS duration
                       FROM calls
                       GROUP BY callee
                      )
SELECT name
FROM phones phn
JOIN call_duration cd ON cd.phone_number = phn.phone_number
GROUP BY name
HAVING SUM(duration) >= 10 -- ATLEAST 10 MINUTES;
ORDER BY name ASC;


-- TASK 2.2

CREATE OR REPLACE TABLE phones1(name VARCHAR (12) NOT NULL UNIQUE,
                                phone_number INT NOT NULL UNIQUE);


INSERT INTO phones1 (name, phone_number) VALUES ('John',6356),
                                                ('Addison',4315),
                                                ('Kate',8003),
                                                ('Ginny',9831);
                                                
SELECT *
FROM phones1;

CREATE OR REPLACE TABLE calls1(id INT NOT NULL UNIQUE,
                               caller INT NOT NULL,
                               callee INT NOT NULL,
                               duration INT NOT NULL);

INSERT INTO calls1 (id, caller, callee, duration) VALUES (65,8003,9831,7),
                                                         (100,9831,8003,3),
                                                         (145,4315,9831,18);
                               

SELECT *
FROM calls1;

WITH call_details1 AS(SELECT caller AS phone_no, SUM(duration) AS call_duration
                      FROM calls1 GROUP BY caller
                      UNION
                      SELECT callee AS phone_no, SUM(duration) AS call_duration FROM calls1
                      GROUP BY callee
                     )
SELECT p1.name FROM phones1 p1
JOIN call_details1 cd1 ON p1.phone_number = cd1.phone_no 
GROUP BY name 
HAVING SUM(call_duration)>=10 
ORDER BY name ASC;
                                
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ TASK 3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */;

-- TASK 3.1

CREATE OR REPLACE TABLE transactions(Amount INTEGER NOT NULL,
						             Date DATE NOT NULL
						            );

INSERT INTO transactions(Amount,Date) VALUES (1000,'2020-01-06'),
											 (-10,'2020-01-14'),
                                             (-75,'2020-01-20'),
                                             (-5,'2020-01-25'),
                                             (-4,'2020-01-29'),
                                             (2000,'2020-03-10'),
                                             (-75,'2020-03-12'),
                                             (-20,'2020-03-15'),
                                             (40,'2020-03-15'),
                                             (-50,'2020-03-17'),
                                             (200,'2020-10-10'),
                                             (-200,'2020-10-10');
					
					
-- TRUNCATE TABLE IF EXISTS TRANSACTIONS;

-- DROP TABLE IF EXISTS TRANSACTIONS;

SELECT *
FROM TRANSACTIONS;

DESCRIBE TABLE TRANSACTIONS;
                                     
SELECT SUM(amount) AS balance
FROM TRANSACTIONS;

SELECT SUM(t1.balance) - SUM(t2.balance) AS total_balance 
FROM (SELECT 1 AS id, SUM(amount) AS balance
      FROM transactions) AS t1
JOIN (SELECT 1 AS id, COUNT(date)*11 AS balance
      FROM transactions WHERE month (date) = 03) AS t2 ON t1.id = t2.id;


-- TASK 3.2

CREATE OR REPLACE TABLE transactions1(Amount INTEGER NOT NULL,
						             Date DATE NOT NULL
						             );
                                    
INSERT INTO transactions1 (Amount,Date) VALUES (1, '2020-06-29'),
                                               (35, '2020-02-20'),
                                               (-50, '2020-02-03'),
                                               (-1, '2020-02-26'),
                                               (-200, '2020-08-01'),
                                               (-44, '2020-02-07'),
                                               (-5, '2020-02-25'),
                                               (1, '2020-06-29'),
                                               (1, '2020-06-29'),
                                               (-100, '2020-12-29'),
                                               (-100, '2020-12-30'),
                                               (-100, '2020-12-31');


SELECT *
FROM TRANSACTIONS1;

DESCRIBE TABLE TRANSACTIONS1;
                                     
SELECT SUM(amount) AS balance
FROM TRANSACTIONS1;

WITH credit_card AS (SELECT SUM(amount) AS total_balance, COUNT(amount) AS transaction_no
                     FROM transactions1
                     WHERE amount < 0
                     GROUP BY year(date), month(date)
                     HAVING total_balance <=-100 and transaction_no >=3)
SELECT SUM(amount)-(5*(12-(SELECT COUNT(*) FROM credit_card))) AS balance
FROM transactions1;

-- TASK 3.3;

CREATE OR REPLACE TABLE transactions2(amount INTEGER NOT NULL,
						              date DATE NOT NULL
						             );

INSERT INTO transactions2 (amount, date) VALUES (6000, '2020-04-03'),
                                                (5000, '2020-04-02'),
                                                (4000, '2020-04-01'),
                                                (3000, '2020-03-01'),
                                                (2000, '2020-02-01'),
                                                (1000, '2020-01-01');

SELECT *
FROM transactions2;

WITH card_payments AS (SELECT SUM(amount) AS total_balance, COUNT(amount) AS transaction_no
FROM transactions2
WHERE amount<0
GROUP BY year(date), month(date)
HAVING total_balance <=-100 AND transaction_no >=3)
SELECT SUM(amount)-(5*(12-(SELECT COUNT(*) FROM card_payments))) AS balance
FROM transactions2;

/* .................................... THANK YOU .................................... */; 
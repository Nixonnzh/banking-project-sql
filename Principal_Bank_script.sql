-- *****************************************************************************
-- Principal Bank SQL Script
-- Author: Nixon Ng
-- Purpose: This script queries and analyzes data from the Principal Bank dataset.
-- The dataset includes information about customers, accounts, transactions, loans,
-- and geographical details related to bank branches and economic conditions.
-- *****************************************************************************

-- *****************************************************************************
-- SECTION 1: Database Selection
-- Ensure the script is run on the correct database before executing queries.
-- *****************************************************************************
USE DE32_Battersea_Power_Station;

-- *****************************************************************************
-- SECTION 2: Preview of All Tables
-- Provides an overview of the dataset by selecting all records from each table.
-- This helps understand the structure and contents of the data.
-- *****************************************************************************
SELECT * FROM [account];  -- Account details
SELECT * FROM [client];   -- Customer information
SELECT * FROM [disp];     -- Disposition linking clients and accounts
SELECT * FROM [order];    -- Orders related to accounts
SELECT * FROM [trans];    -- Transactions
SELECT * FROM [loan];     -- Loan details
SELECT * FROM [card];     -- Issued bank cards
SELECT * FROM [district]; -- District-level economic data

-- *****************************************************************************
-- SECTION 3: District Analysis
-- Analyzes economic and demographic data for each district.
-- *****************************************************************************
SELECT 
    A1 AS District_code,
    A2 AS District_name,
    A3 AS Region,
    A4 AS 'Number of Inhabitants',
    A5 AS 'Municipalities with <499 inhabitants',
    A6 AS 'Municipalities with 500-1999 inhabitants',
    A7 AS 'Municipalities with 2000-9999 inhabitants',
    A8 AS 'Municipalities with >10000 inhabitants',
    A9 AS 'Number of Cities',
    A10 AS 'Urban Inhabitants Ratio',
    A11 AS 'Average Salary',
    A12 AS 'Unemployment Rate (1995)',
    A13 AS 'Unemployment Rate (1996)',
    A14 AS 'Number of Entrepreneurs',
    A15 AS 'Crime Count (1995)',
    A16 AS 'Crime Count (1996)'
FROM district;

-- *****************************************************************************
-- SECTION 4: Account and Client Relationship Analysis
-- Identifies how accounts are linked to clients and their details.
-- *****************************************************************************
SELECT 
    a.account_id, 
    c.client_id, 
    c.birth_number, 
    d.type AS disposition_type
FROM account a
JOIN disp d ON a.account_id = d.account_id
JOIN client c ON d.client_id = c.client_id;

-- Connecting account, client, disp, card & district tables to card info. (Filter by card)
SELECT DISTINCT a.account_id, c.client_id, c.birth_number, d.disp_id, a.district_id, dist.A2 dist_name, dist.A3 region, cd.[type], a.[date] AS bank_start, 
CAST(cd.issued AS date) AS card_issued,
COUNT(order_id) OVER (PARTITION BY c.client_id) num_orders
FROM account a
JOIN disp d
ON a.account_id = d.account_id
JOIN client c
ON c.client_id = d.client_id
JOIN [card] cd
ON d.disp_id = cd.disp_id
JOIN district dist
ON a.district_id = dist.A1
JOIN [order] o
ON a.account_id = o.account_id
ORDER BY account_id, client_id
-- 892 different card holders, but there are duplicates 

-- Connecting account, client, disp, card & district tables to card info. (Filter by card)
SELECT DISTINCT a.account_id, c.client_id, c.birth_number, d.disp_id, a.district_id, dist.A2 dist_name, dist.A3 region, cd.[type], a.[date] AS bank_start, 
CAST(cd.issued AS date) AS card_issued
FROM account a
JOIN disp d
ON a.account_id = d.account_id
JOIN client c
ON c.client_id = d.client_id
JOIN [card] cd
ON d.disp_id = cd.disp_id
JOIN district dist
ON a.district_id = dist.A1
ORDER BY account_id, client_id
-- 892 distinct card holders

-- Connecting account, client, disp, card & district tables to card info for all regions. (Filter by card)
SELECT DISTINCT a.account_id, c.client_id, c.birth_number, d.disp_id, a.district_id, dist.A2 dist_name, dist.A3 region, cd.[type], a.[date] AS bank_start, 
CAST(cd.issued AS date) AS card_issued,
COUNT(order_id) OVER (PARTITION BY c.client_id) num_orders
FROM account a
JOIN disp d
ON a.account_id = d.account_id
JOIN client c
ON c.client_id = d.client_id
JOIN [card] cd
ON d.disp_id = cd.disp_id
JOIN district dist
ON a.district_id = dist.A1
JOIN [order] o
ON a.account_id = o.account_id
ORDER BY account_id, client_id
-- 702 distinct card holders that have made permanents, but there are duplicates whereby one card holder has made multiple permanent orders (1255 orders in total)


-- There are 4,500 unique account IDs
-- There are 5,369 unique client IDs
-- There are also 5,369 unique disposition IDs
-- There are also 682 unique loans
-- Max number of disposition per account_ID is 2, min of 1
-- Max number of clients per account_ID is 2, min of 1
-- Max number of account per disp_ID is 1
-- There are 892 distinct credit card holders
-- There are 702 distinct credit card holders that have made orders. (With 1255 total orders for card holders)
-- 77 distinct district name, with 8 regions in total
-- *****************************************************************************
-- Grouping by region
-- *****************************************************************************
SELECT * FROM district

SELECT A1 dist_code, A2 dist_name, A3 region, A4 num_inhab, A5 num_mun_499, A6 num_mun_500_1999, A7 num_mun_2000_9999, A8 num_mun_10000, A9 num_cities, A10 ratio_urban, A11 avg_salary, A12 unemp_95, A13 unemp_96, A14 num_entre, A15 num_crimes_95, A16 num_crimes_96
FROM district

-- Dataset has 77 distinct district names, with 8 regions in total

SELECT A3 region, COUNT(A3) num_districts
FROM district
GROUP BY A3
-- *****************************************************************************
-- 702 DISTINCT credit card holders with orders, specific 
-- *****************************************************************************
SELECT DISTINCT a.account_id, c.client_id, c.birth_number, d.disp_id, a.district_id, dist.A2 dist_name, dist.A3 region, cd.[type], a.[date] AS bank_start, 
CAST(cd.issued AS date) AS card_issued,
COUNT(order_id) OVER (PARTITION BY c.client_id) num_orders
FROM account a
FULL OUTER JOIN disp d
ON a.account_id = d.account_id
FULL OUTER JOIN client c
ON c.client_id = d.client_id
FULL OUTER JOIN [card] cd
ON d.disp_id = cd.disp_id
FULL OUTER JOIN district dist
ON a.district_id = dist.A1
FULL OUTER JOIN [order] o
ON a.account_id = o.account_id
FULL OUTER JOIN [newclient] nc
ON a.account_id = nc.account_id
-- WHERE dist.A3 = '(Region_Name)' -- OR change this to district to get info for district credit cardholders
ORDER BY account_id, client_id
-- Can change JOINs to tabulate rows with all credit card users (892 users)

-- *****************************************************************************
-- Aggregate table for Credit Card Holders
-- *****************************************************************************
SELECT DISTINCT a.account_id, c.client_id, nc.age, nc.gender, d.disp_id, a.district_id, dist.A2 dist_name, dist.A3 region, cd.[type], a.[date] AS bank_start, 
nc.type_of_disposition,
CAST(cd.issued AS date) AS card_issued,
COUNT(order_id) OVER (PARTITION BY c.client_id) num_orders
FROM account a
FULL OUTER JOIN disp d
ON a.account_id = d.account_id
FULL OUTER JOIN client c
ON c.client_id = d.client_id
FULL OUTER JOIN [card] cd
ON d.disp_id = cd.disp_id
FULL OUTER JOIN district dist
ON a.district_id = dist.A1
FULL OUTER JOIN [order] o
ON a.account_id = o.account_id
FULL OUTER JOIN [newclient] nc
ON c.client_id = nc.client_id
-- WHERE dist.A3 = '(Region_Name)' -- OR change this to district to get info for district credit cardholders
-- WHERE nc.type_of_disposition = 'OWNER' -- Add this to get only OWNERs/DISPONENTs
-- WHERE cd.[type] IS NOT NULL -- Add this to get only number of cred card owners
ORDER BY client_id

SELECT * FROM newclient

-- *****************************************************************************
-- Aggregate table for loan owners
-- *****************************************************************************
SELECT * FROM loan

SELECT DISTINCT a.account_id, c.client_id, nc.age, nc.gender, d.disp_id, a.district_id, dist.A2 dist_name, dist.A3 region, a.[date] AS bank_start, 
nc.type_of_disposition,
l.[date] loan_start_date,
l.duration loan_duration,
l.amount loan_amount,
l.payments loan_payments,
l.[status] loan_status,
COUNT(order_id) OVER (PARTITION BY c.client_id) num_orders
FROM account a
FULL OUTER JOIN disp d
ON a.account_id = d.account_id
FULL OUTER JOIN client c
ON c.client_id = d.client_id
FULL OUTER JOIN [card] cd
ON d.disp_id = cd.disp_id
FULL OUTER JOIN district dist
ON a.district_id = dist.A1
FULL OUTER JOIN [order] o
ON a.account_id = o.account_id
FULL OUTER JOIN [newclient] nc
ON c.client_id = nc.client_id
FULL OUTER JOIN loan l
ON a.account_id = l.account_id
-- 1.)WHERE dist.A3 = '(Region_Name)' -- OR change this to district to get info for regional loan owners
-- 2.)WHERE nc.type_of_disposition = 'OWNER' -- Add this to get only OWNERs/DISPONENTs
-- 3.)WHERE l.[status] IS NOT NULL -- Add this to get only number of loans connected to client_id/disp_id
--    AND nc.type_of_disposition = 'OWNER'
ORDER BY client_id

-- Only account & dispo with correlated data
SELECT DISTINCT a.account_id, nc.age, nc.gender,d.disp_id, a.district_id, dist.A2 dist_name, dist.A3 region, a.[date] AS bank_start, 
nc.type_of_disposition
FROM account a
JOIN disp d
ON a.account_id = d.account_id
JOIN district dist
ON a.district_id = dist.A1
JOIN [order] o
ON a.account_id = o.account_id
JOIN [newclient] nc
ON a.account_id = nc.account_id
ORDER BY account_id

-- Max dispositionID per account_ID is 2
SELECT a.account_id, COUNT(d.disp_id) num_of_disp
FROM account a
JOIN disp d
ON a.account_id = d.account_id
GROUP BY a.account_id
ORDER BY num_of_disp DESC

-- Max number of accounts per disposition ID is 1
SELECT d.disp_id, COUNT(a.account_id) num_of_acc
FROM account a
JOIN disp d
ON a.account_id = d.account_id
GROUP BY d.disp_id
ORDER BY num_of_acc DESC

-- Max number of accounts per loan_ID is 1
SELECT l.loan_id, COUNT(a.account_id) num_of_acc
FROM account a
JOIN loan l
ON a.account_id = l.account_id
GROUP BY l.loan_id
ORDER BY num_of_acc DESC

-- Max number of loans per account_ID is 1
SELECT a.account_id, COUNT(l.loan_id) num_of_loans
FROM account a
JOIN loan l
ON a.account_id = l.account_id
GROUP BY a.account_id
ORDER BY num_of_loans DESC

SELECT * FROM loan


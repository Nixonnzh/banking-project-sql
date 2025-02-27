# Principle Bank Project (Data Ingestion & Analysis in MSSQL)

## Project Overview

This project analyzes customer and banking transaction data to uncover insights that can help a retail bank improve its services. The focus is on identifying key customer segments, understanding spending patterns, and distinguishing between profitable and risky customers. The goal is to provide data-driven recommendations to enhance decision-making for customer retention, risk assessment, and financial planning.

## Data Description

The dataset consists of multiple files containing information about customers, their accounts, transactions, loans, credit cards, and demographic details. The key tables include:

- **account.asc**: Static characteristics of bank accounts.
- **client.asc**: Customer details, including demographic information.
- **disp.asc**: Relationships between customers and accounts.
- **order.asc**: Permanent payment orders.
- **trans.asc**: Account transaction details.
- **loan.asc**: Information on loans granted to customers.
- **card.asc**: Issued credit cards and their types.
- **district.asc**: Demographic data about the districts where customers reside.

## Database Setup in MS SQL Server

To analyze the data, we first need to ingest it into **Microsoft SQL Server**. Below is the step-by-step process:

### 1. Create Database

```sql
CREATE DATABASE PrincipleBank;
GO
```

### 2. Create Tables

Run the provided SQL script (`Principal_Bank_script.sql`) to create the required tables.

```sql
USE PrincipleBank;
-- Ensure the tables exist before inserting data
```

### 3. Data Ingestion

Since the data is in `.asc` format (which is a text format similar to CSV), we use **Bulk Insert** to load data into SQL Server.

Example of importing the `account.asc` file:

```sql
BULK INSERT account
FROM 'C:\\path\\to\\your\\file\\account.asc'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\\n',
    FIRSTROW = 2 -- Skip header if present
);
```

Repeat this for all tables (`client`, `disp`, `trans`, `loan`, etc.).

## Data Analysis

Once the data is ingested, we can perform various analyses.

### 1. Customer Segmentation

```sql
SELECT c.client_id, d.type AS account_type, COUNT(t.trans_id) AS num_transactions,
       SUM(CASE WHEN t.amount > 0 THEN t.amount ELSE 0 END) AS total_credit,
       SUM(CASE WHEN t.amount < 0 THEN -t.amount ELSE 0 END) AS total_debit
FROM client c
JOIN disp d ON c.client_id = d.client_id
JOIN trans t ON d.account_id = t.account_id
GROUP BY c.client_id, d.type;
```

### 2. Risk Assessment for Loan Customers

```sql
SELECT l.account_id, l.amount, l.duration, l.status,
       COUNT(t.trans_id) AS num_transactions,
       SUM(t.amount) AS total_transaction_value
FROM loan l
JOIN trans t ON l.account_id = t.account_id
GROUP BY l.account_id, l.amount, l.duration, l.status;
```

### 3. Identifying Profitable Customers

```sql
SELECT c.client_id, SUM(t.amount) AS total_transactions, 
       COUNT(DISTINCT cr.card_id) AS num_cards, 
       COUNT(DISTINCT l.loan_id) AS num_loans
FROM client c
JOIN disp d ON c.client_id = d.client_id
LEFT JOIN trans t ON d.account_id = t.account_id
LEFT JOIN card cr ON d.disp_id = cr.disp_id
LEFT JOIN loan l ON d.account_id = l.account_id
GROUP BY c.client_id
ORDER BY total_transactions DESC;
```

## Key Insights

- **High-value customers** exhibit frequent transactions and hold multiple credit cards.
- **Risky customers** show high loan amounts with irregular transaction patterns.
- **Customer segmentation** helps in targeted financial product offerings.

## Conclusion

This project provides a data-driven approach to understanding banking customer behavior, aiding in **customer retention strategies, risk assessment, and financial planning** for a retail bank.

---

**Author:** Nixon Ng  
**GitHub Repository:** [[GitHub-Nixon]](https://github.com/Nixonnzh)

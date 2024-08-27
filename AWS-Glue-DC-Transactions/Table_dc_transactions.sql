/* 
Create dc_transactions table and schema.
Data will be populated by AWS-Glue Job DC-Transactions-Pipeline. 
*/

CREATE TABLE IF NOT EXISTS dc_transactions(
objectid INTEGER PRIMARY KEY,
agency VARCHAR(60),
vendor_name VARCHAR(60),
vendor_state_province CHAR(2),
mcc_description VARCHAR(60),
transaction_date DATE,
transaction_amount INTEGER);
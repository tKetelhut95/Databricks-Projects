-- Run this line to Refresh Concurrently 
REFRESH MATERIALIZED VIEW CONCURRENTLY agency_transactions_monthly_rank;

-- Creates a Unique Index to allow for Refresh Concurrently
CREATE UNIQUE INDEX unique_index_agency_transactions_monthly_rank ON agency_transactions_monthly_rank(agency, year, month, total_transaction_amount, agency_monthly_rank);

-- Materialized View to show agency rank by total_transaction_amount per month from dc_transactions data
CREATE MATERIALIZED VIEW agency_transactions_monthly_rank AS 

	SELECT 
		agency, 
		date_part('year', transaction_date) as year,
		date_part('month', transaction_date) as month, 
		SUM(transaction_amount) as total_transaction_amount,
		RANK () OVER (PARTITION BY date_part('year', transaction_date), date_part('month', transaction_date) ORDER BY SUM(transaction_amount) DESC) as agency_monthly_rank
	FROM 
		dc_transactions
	GROUP BY 
		agency, date_part('year', transaction_date), date_part('month', transaction_date)
	ORDER BY 
		year, month, agency_monthly_rank ASC;

-- Quick Select statement to see output of agency_transactions_monthly_rank materialized view
SELECT * FROM agency_transactions_monthly_rank;
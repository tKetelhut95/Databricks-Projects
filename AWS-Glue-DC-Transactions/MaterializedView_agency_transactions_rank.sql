-- Run this line to Refresh Concurrently 
REFRESH MATERIALIZED VIEW CONCURRENTLY agency_transactions_rank;

-- Creates a Unique Index to allow for Refresh Concurrently
CREATE UNIQUE INDEX unique_index_agency_transactions_rank ON agency_transactions_rank(agency, total_transaction_amount, agency_rank);

-- Materialized View to show agency rank by total_transaction_amount from dc_transactions data
CREATE MATERIALIZED VIEW agency_transactions_rank AS 

	SELECT 
		agency, 
		SUM(transaction_amount) AS total_transaction_amount, 
		RANK () OVER(ORDER BY SUM(transaction_amount) DESC) as agency_rank
	FROM 
		dc_transactions
	GROUP BY 
		agency
	ORDER BY 
		agency_rank;

-- Quick Select statement to see output of agency_transactions_rank materialized view
SELECT * FROM agency_transactions_rank
ORDER BY agency_rank ASC;
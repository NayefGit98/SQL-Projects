INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_material_status,
	cst_gndr,
	cst_create_date)


SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,--For removing spaces inbetween
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single' --Replacing S/M with Single and Married(Normalization)
	 WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
	 ELSE 'Unknown'
END cst_marital_status,

CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' --Replacing F/M with Female and Male(Normalization)
	 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	 ELSE 'Unknown'
END cst_gndr,
cst_create_date
FROM (
	SELECT 
	*,
	ROW_NUMBER () OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last --Removed Duplicates
	FROM bronze.crm_cust_info
	WHERE cst_id  IS NOT NULL
) t WHERE flag_last = 1
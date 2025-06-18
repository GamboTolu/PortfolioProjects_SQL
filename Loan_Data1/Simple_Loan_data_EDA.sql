-- DROP TABLE IF EXISTS loan_data;

-- CREATE TABLE loan_data
 					(
 						Column1 INT,
 					 	Loan_ID VARCHAR,
 						Gender VARCHAR,
 						Married VARCHAR,
 						Dependents VARCHAR,
 						Education VARCHAR,
 						Self_Employed VARCHAR,
 						ApplicantIncome INT,
 						CoapplicantIncome INT,
 						LoanAmount INT,
 						Loan_Amount_Term INT,
 						Credit_History INT,
 						Property_Area VARCHAR,
 						Loan_Status VARCHAR
 					);


------------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM loan_data
;

SELECT COUNT(*)
FROM loan_data
;

------------------------------------------------------------------------------------------------------------------------------------

-- VIEW NULL VALUES

SELECT *
FROM loan_data
WHERE 
	Gender = ''
	OR Education = ''
	OR Self_Employed = ''
	OR ApplicantIncome = ''
	OR CoapplicantIncome = ''
	OR LoanAmount = ''
	OR Loan_Amount_Term = ''
	OR Credit_History = ''
;
	

-- DROP ROWS WITH EMPTY APPLICANTINCOME = '' OR 0

DELETE FROM loan_data 
WHERE ApplicantIncome = ''
;

DELETE FROM loan_data 
WHERE ApplicantIncome = 0
;

SELECT *
FROM loan_data
WHERE 
	ApplicantIncome = 0
	OR ApplicantIncome = ''
	
------------------------------------------------------------------------------------------------------------------------------------

-- View ApplicantIncome < $1000
	
SELECT *
FROM loan_data 
WHERE 
	ApplicantIncome < 1000 
;

-- View Applicants with >1 Dependants and at least 1 Credit History

SELECT *
FROM loan_data
WHERE 
	Dependents > 1
	AND Credit_History >= 1
;

-- View ApplicantIncome and CoapplicantIncome >= 2000

SELECT *
FROM loan_data
WHERE
	ApplicantIncome >= 2000
	AND CoapplicantIncome >= 2000
;

-- COUNT Loan_Status 

SELECT 
	Loan_Status,
	COUNT(Loan_Status) AS Loan_Count
FROM loan_data
GROUP BY Loan_Status 
;

-- Loan_Amount_Term < 360

SELECT *
FROM loan_data
WHERE 
	Loan_Amount_Term < 360
;

-- Loan_Amount_Term > 360

SELECT *
FROM loan_data
WHERE 
	Loan_Amount_Term > 360
;



	
































































-- Data Cleaning and EDA (SQLite)


SELECT *
FROM NashvilleHousing
;


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

SELECT *
FROM NashvilleHousing
-- WHERE PropertyAddress = '' 
ORDER BY ParcelID
;

-- Find rows where PropertyAddress is blank
-- Identify if there's another row with the same ParcelID but with a valid address

SELECT 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = ''
;

-- Creates MergedAddress column to demonstrate what would be populated

SELECT 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress, 
	IFNULL(NULLIF(a.PropertyAddress, ''), b.PropertyAddress) AS MergedAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress = ''
;

-- Replaces the blank address with a non-blank address from another row with the same ParcelID
-- (LIMIT 1 prevents multiple-match errors)

UPDATE NashvilleHousing
SET PropertyAddress = (
    SELECT b.PropertyAddress
    FROM NashvilleHousing b
    WHERE b.ParcelID = NashvilleHousing.ParcelID
      AND b.UniqueID <> NashvilleHousing.UniqueID
      AND b.PropertyAddress != ''
    LIMIT 1
)
WHERE PropertyAddress = ''
;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- PROPERTY ADDRESS

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress = ''
--ORDER BY ParcelID
;

SELECT
    PropertyAddress,
    TRIM(SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1)) AS StreetAddress,
    TRIM(SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1)) AS City
FROM NashvilleHousing
WHERE PropertyAddress LIKE '%,%'
;

ALTER TABLE NashvilleHousing ADD COLUMN StreetAddress TEXT;
ALTER TABLE NashvilleHousing ADD COLUMN City TEXT;
;

UPDATE NashvilleHousing
SET 
    StreetAddress = TRIM(SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1)),
    City = TRIM(SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1))
WHERE PropertyAddress LIKE '%,%'
;

SELECT 
    PropertyAddress,
    StreetAddress,
    City
FROM NashvilleHousing
;


-- OWNER ADDRESS

SELECT OwnerAddress 
FROM NashvilleHousing
;

SELECT OwnerAddress
FROM NashvilleHousing
WHERE OwnerAddress LIKE '%,%,%'
;


ALTER TABLE NashvilleHousing ADD COLUMN OwnerStreetAddress TEXT;
ALTER TABLE NashvilleHousing ADD COLUMN OwnerCity TEXT;
ALTER TABLE NashvilleHousing ADD COLUMN OwnerState TEXT;

UPDATE NashvilleHousing
SET OwnerStreetAddress = TRIM(SUBSTR(OwnerAddress, 1, INSTR(OwnerAddress, ',') - 1))
WHERE OwnerAddress LIKE '%,%,%'
;

UPDATE NashvilleHousing
SET OwnerCity = TRIM(SUBSTR(
    SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1),
    1,
    INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') - 1
))
WHERE OwnerAddress LIKE '%,%,%'
;

UPDATE NashvilleHousing
SET OwnerState = TRIM(SUBSTR(
    SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), 
    INSTR(SUBSTR(OwnerAddress, INSTR(OwnerAddress, ',') + 1), ',') + 1
))
WHERE OwnerAddress LIKE '%,%,%'
;

SELECT OwnerAddress, OwnerStreetAddress, OwnerCity, OwnerState
FROM NashvilleHousing
WHERE OwnerStreetAddress IS NOT NULL
;


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Standardize SoldAsVacant column
-- Change Y and N to Yes and No

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
Group by SoldAsVacant
ORDER BY Count(SoldAsVacant)
;

SELECT SoldAsVacant,
       CASE 
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
       END AS SoldAsVacant_Formatted
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       ELSE SoldAsVacant
                   END;


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Handle Duplicates

-- View Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 propertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 	UniqueID
				 	) row_num
FROM NashvilleHousing 
--ORDER BY ParcelID 
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
;

-- Delete Duplicates
-- Create a temporary table with only the duplicate UniqueIDs
CREATE TEMP TABLE DuplicateIDs AS
WITH RowNumCTE AS (
    SELECT UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM NashvilleHousing
)
SELECT UniqueID
FROM RowNumCTE
WHERE row_num > 1;

-- Delete rows from the original table using the temporary table
DELETE FROM NashvilleHousing
WHERE UniqueID IN (SELECT UniqueID FROM DuplicateIDs);

-- Drop the temp table after cleanup
-- DROP TABLE DuplicateIDs;


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Drop Unused Columns 

SELECT *
FROM NashvilleHousing;

-- Create a temp table WITHOUT the columns to drop
CREATE TEMP TABLE NashvilleHousing_temp AS
SELECT 
    -- Include only the columns you want to KEEP
    UniqueID,
    ParcelID,
    SaleDate,
    SalePrice,
    LegalReference,
    StreetAddress,
    City,
    OwnerStreetAddress,
    OwnerCity,
    OwnerState
FROM NashvilleHousing;

-- Drop the original table
DROP TABLE NashvilleHousing;

-- Recreate the original table from the temp one
CREATE TABLE NashvilleHousing AS
SELECT * FROM NashvilleHousing_temp;

-- Drop the temp table
-- DROP TABLE NashvilleHousing_temp;


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Standardize Date 

SELECT saleDate
FROM NashvilleHousing
;

SELECT COUNT(SaleDate)
FROM NashvilleHousing
WHERE SaleDate LIKE 'April%'
;

-- Convert m d,yyyy to dd-m-yy
-- Using Python
-- Code in Housing_Data_change_date_format(.ipynb)



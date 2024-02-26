/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------
--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate);

-- Add a new column named SaleDateConverted to store the converted dates
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

-- Update the SaleDateConverted column with the converted dates
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);



----------------------------------------------------------------------------------
--Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT table1.ParcelID, table1.PropertyAddress, table2.ParcelID, table2.PropertyAddress, ISNULL(table1.PropertyAddress,table2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS table1
JOIN PortfolioProject.dbo.NashvilleHousing AS table2 
ON table1.ParcelID = table2.ParcelID
AND table1.[UniqueID ] <> table2.[UniqueID ]
WHERE table1.PropertyAddress IS NULL

UPDATE table1
SET PropertyAddress = ISNULL(table1.PropertyAddress,table2.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing AS table1
JOIN PortfolioProject.dbo.NashvilleHousing AS table2 
ON table1.ParcelID = table2.ParcelID
AND table1.[UniqueID ] <> table2.[UniqueID ]
WHERE table1.PropertyAddress IS NULL

--------------------------------------------------------------------------------------

--Breaking out address into individual columns

----(Address,City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null


SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
    
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


---Owner Address(NB METHOD FOR SEPERATING)
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


----------------------------------------------------------------------------------------
--Change Y AND N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant  -- If neither 'Y' nor 'N', keep the original value
    END AS SoldAsVacantModified
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SoldAsVacantModified Nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacantModified = CASE 
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant  -- Keep the original value for other cases
                    END;

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------

---Removing duplicates
--Act like uniqueID doesn't exist

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num_duplicate
    FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT *
--(1)DELETE 
FROM RowNumCTE
WHERE row_num_duplicate > 1
---ORDER BY PropertyAddress;



----------------------------------------------------------------------------------------------
--DELETE UNUSED COLUMNS
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


















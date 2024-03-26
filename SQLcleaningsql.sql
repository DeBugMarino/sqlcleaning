
---Cleaning Data in SQL Queries:



Select *
From Project.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDate AS saleDateConverted, 

CONVERT(Date, SaleDate) AS convertedSaleDate

FROM Project.dbo.NashvilleHousing;


-- If it doesn't Update properly

UPDATE Project.dbo.NashvilleHousing

SET SaleDate = CONVERT(Date, SaleDate);

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Project.dbo.NashvilleHousing

--Where PropertyAddress is null

order by ParcelID

SELECT 
    a.ParcelID, 
    a.PropertyAddress AS PropertyAddress_a, 
    b.ParcelID, 
    b.PropertyAddress AS PropertyAddress_b, 
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS NonNullPropertyAddress
FROM 
    Project.dbo.NashvilleHousing a
JOIN 
    Project.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID
WHERE 
    a.PropertyAddress IS NULL
    AND a.ParcelID <> b.ParcelID; 
	
	-- Updated join condition

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project.dbo.NashvilleHousing a
JOIN Project.dbo.NashvilleHousing b ON a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL
AND a.ParcelID <> b.ParcelID;





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT *
FROM Project.dbo.NashvilleHousing
--where PropertyAddress is null
--ORDER BY ParcelID;


SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM
    Project.dbo.NashvilleHousing;


ALTER TABLE Project.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);


UPDATE Project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);


ALTER TABLE Project.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);


UPDATE Project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));




Select *
From Project.dbo.NashvilleHousing



Select OwnerAddress
From Project.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Project.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Project.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Project.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID 
        ) AS row_num
    FROM Project.dbo.NashvilleHousing
)
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY ParcelID) AS parcel_row_num
    FROM RowNumCTE
) AS OrderedRowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

SELECT *
FROM Project.dbo.NashvilleHousing;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Project.dbo.NashvilleHousing


ALTER TABLE Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE Project.dbo.NashvilleHousing
DROP COLUMN SaleDate







-----------------------------------------------------------------------------------------------
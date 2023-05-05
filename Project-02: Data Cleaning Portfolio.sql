/*

Cleaning Data in SQL Queries

*/

SELECT * 
From [Portfolio Project].dbo.NashvilleHousing
----------------------------------------------------------------------------------------------------
--Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate) 
From [Portfolio Project].dbo.NashvilleHousing



----Option 1 Update Query didn't work as expected

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Option 2

-- Add the new column
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

--Update the values in the new column
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--for confirmation
SELECT SaleDateConverted 
From [Portfolio Project].dbo.NashvilleHousing

--drop the old column and rename the new column
ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate;

----------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT * 
From [Portfolio Project].dbo.NashvilleHousing
--Where PropertyAddress is NUll
Order By ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
	Where a.PropertyAddress is NUll


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
	Where a.PropertyAddress is NUll

----------------------------------------------------------------------------------------------------

--Breaking Down Address into Individual Columns (Address, City State)
--Property Address
SELECT PropertyAddress
From [Portfolio Project].dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as Address2

From [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress NvarChar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NvarChar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))


SELECT *
From [Portfolio Project].dbo.NashvilleHousing

--OwnerAddress

SELECT OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing

SELECT  
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From [Portfolio Project].dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NvarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NvarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState NvarChar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


----------------------------------------------------------------------------------------------------

--Change Y and N to Yes or No in "Sold and Vacant" field

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From [Portfolio Project].dbo.NashvilleHousing
	

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From [Portfolio Project].dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project].dbo.NashvilleHousing
--Order by ParcelID
)
Select * --/DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

----------------------------------------------------------------------------------------------------

--Delete Unusable Columns

SELECT *
From [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is NULL;

----------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing


SELECT 
  LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress)-1) AS Address,
  LTRIM(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, LEN(OwnerAddress)-CHARINDEX(',', OwnerAddress)-CHARINDEX(',',REVERSE(OwnerAddress )))) AS City,
  LTRIM(RIGHT(OwnerAddress, CHARINDEX(',', REVERSE(OwnerAddress))-1)) AS State
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = LTRIM(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, LEN(OwnerAddress)-CHARINDEX(',', OwnerAddress)-CHARINDEX(',',REVERSE(OwnerAddress ))))

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = LTRIM(RIGHT(OwnerAddress, CHARINDEX(',', REVERSE(OwnerAddress))-1))


--SELECT
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SOldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


---------------------------------------------------------------------------------------------------------------------------------------------

-- Remove duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 

ALTER TABLE PortfolioProject..NashvilleHousing
DROP Column OwnerAddress,TaxDistrict, PropertyAddress, SaleDate


SELECT *
FROM PortfolioProject..NashvilleHousing
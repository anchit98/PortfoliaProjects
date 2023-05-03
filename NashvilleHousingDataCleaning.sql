SELECT *
FROM NashvilleHousingData

--Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousingData
ADD SaleDateConverted Date;

UPDATE NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
	 ON a.ParcelID = b.ParcelID
	 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
FROM NashvilleHousingData a
JOIN NashvilleHousingData b
	 ON a.ParcelID = b.ParcelID
	 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
From NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 



SELECT OwnerAddress
FROM NashvilleHousingData

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS SaleCount
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY SaleCount

SELECT CAST(SoldAsVacant AS varchar(50))
FROM NashvilleHousingData

SELECT CAST(SoldAsVacant AS varchar(50))
, CASE WHEN SoldAsVacant = 1 THEN 'Yes'
	   WHEN SoldAsVacant = 0 THEN 3
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 1 THEN 'Yes'
	   WHEN SoldAsVacant = 0 THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num

FROM NashvilleHousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Delete Unused Columns
SELECT *
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousingData
DROP COLUMN SaleDate

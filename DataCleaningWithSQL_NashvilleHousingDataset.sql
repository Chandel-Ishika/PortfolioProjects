/*
Cleaning Data in SQL
*/

Select *
FROM [PortfolioProject1].[dbo].[NashvilleHousing]
--where PropertyAddress is null;

-----------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
FROM [PortfolioProject1].[dbo].[NashvilleHousing];

--Add New SaleDate Column
Alter Table NashvilleHousing
Add SaleDateConverted Date;

--Add Converted Date to the new column
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

--------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data
/* 
From the data, I gather for same Parcel ID the property address will be same. So if the property address is null,
I will populate it with property address of the matching parcel id.
*/

--Finding null property address and using isnull() 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject1].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject1].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;

--Update property address where it is null
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject1].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject1].[dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;

------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

--Split PropertyAddress
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as City
FROM [PortfolioProject1].[dbo].[NashvilleHousing];

--Add Columns and Update the Values

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress));

--Split OwnerAddress

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerState
FROM [PortfolioProject1].[dbo].[NashvilleHousing];

--Add new columns
Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

--Update values
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

-----------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in  SoldAsVacant Field to have same data flowing throughout

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PortfolioProject1].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant;

--Using CASE Statement

Select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [PortfolioProject1].[dbo].[NashvilleHousing];

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

/*
we create a row_num by using partition by identifying the fields that should be unique. The row_num with value 2, is a duplicate
record and we will delete it. We sort this in a CTE and then delete records row_num > 1
*/

WITH RowNumCTE AS (
Select *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID) row_num
FROM [PortfolioProject1].[dbo].[NashvilleHousing]
)
DELETE
--Select *
FROM RowNumCTE
where row_num > 1;

---------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

ALTER TABLE [PortfolioProject1].[dbo].[NashvilleHousing]
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict;
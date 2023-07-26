/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- PropertyAddress

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select PropertySplitAddress, PropertySplitCity
From PortfolioProject.dbo.NashvilleHousing

--OwnerAddress
select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


select 
PARSENAME(replace(OwnerAddress,',','.'),3)as address,
PARSENAME(replace(OwnerAddress,',','.'),2)as city,
PARSENAME(replace(OwnerAddress,',','.'),1)as state
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
select *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order BY UniqueID) Row_num
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
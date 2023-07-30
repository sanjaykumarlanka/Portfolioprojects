use portfolioproject

--Data cleaning in sql quieries
select * from nashvillehousing


-- Standardize Date Format
select SaleDateConverted, convert(Date,SaleDate)
from nashvillehousing

alter table nashvillehousing 
add SaleDateConverted Date;

update nashvillehousing
set SaleDateConverted=convert(Date,SaleDate)



--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
select * from nashvillehousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress from nashvillehousing 
--where PropertyAddress is null
--order by ParcelID

select 
substring(PropertyAddress,1,charindex(',',PropertyAddress) -1) as Address,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from nashvillehousing

alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update nashvillehousing
set PropertySplitAddress=substring(PropertyAddress,1,charindex(',',PropertyAddress) -1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update nashvillehousing
set PropertySplitCity=substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

select OwnerAddress from nashvillehousing

select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from nashvillehousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255)

update nashvillehousing
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255)

update nashvillehousing
set OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255)

update nashvillehousing
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)

select * from nashvillehousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case  when SoldAsVacant='Y' then 'yes'
       when  SoldAsVacant='N' then 'No'
	   else  SoldAsVacant
	   end
	   from nashvillehousing

update  nashvillehousing
set  SoldAsVacant=case  when SoldAsVacant='Y' then 'yes'
       when  SoldAsVacant='N' then 'No'
	   else  SoldAsVacant
	   end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From nashvillehousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select * from nashvillehousing


ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
--cleaning data in sql queries

select *
from NashvilleHousing ;

-----------
--standardize data format

select 
saledate,
convert(date,SaleDate) as SaleDate
from NashvilleHousing ;

update NashvilleHousing
SET saledate = convert(date,SaleDate) ; --its not updated 

alter table NashvilleHousing
add SaleDateConverted date ;

update NashvilleHousing
SET SaleDateConverted = convert(date,SaleDate) ;

select 
SaleDateConverted,
convert(date,SaleDate) as SaleDate
from NashvilleHousing ;  --to see the result
------

-- populate property address data

select
*
from NashvilleHousing 
-- where propertyaddress is null
order by ParcelID ;

select
a.[UniqueID ],
b.[UniqueID ],
a.ParcelID,
a.PropertyAddress,
b.ParcelID,
b.PropertyAddress,
isnull(a.PropertyAddress , b.PropertyAddress )
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null ; --to know all the null values

update a
set PropertyAddress = b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null ; --to replace all the null with values
----------
--breaking address into individual columns (address , city , state )

select PropertyAddress
from NashvilleHousing ;

select
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress) - 1 ) address ,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress) + 1 , len(PropertyAddress)) address

from NashvilleHousing ;

alter table NashvilleHousing
add streetadress nvarchar(255) ;

update NashvilleHousing
SET streetadress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress) - 1 ) ;

alter table NashvilleHousing
add city nvarchar(255) ;

update NashvilleHousing
SET city = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress) + 1 , len(PropertyAddress)) ;

select OwnerAddress
from NashvilleHousing ;

select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from NashvilleHousing;

alter table NashvilleHousing
add ownerstreetaddress nvarchar(255) ;

update NashvilleHousing
SET ownerstreetaddress = parsename(replace(OwnerAddress,',','.'),3) ;

alter table NashvilleHousing
add ownercity nvarchar(255) ;

update NashvilleHousing
SET ownercity = parsename(replace(OwnerAddress,',','.'),2) ;

alter table NashvilleHousing
add ownerstate nvarchar(255) ;

update NashvilleHousing
SET ownerstate = parsename(replace(OwnerAddress,',','.'),1) ;
--------
--change Y to Yes & N to No in "SoldASVacant" field
select
distinct(soldasvacant),
count(soldasvacant) 
from NashvilleHousing 
group by SoldAsVacant
order by count(soldasvacant)  ;

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end ;
---------
--remove duplicates

with rownumCTE as (
select *,
ROW_NUMBER() over( partition by 
								parcelid,
								propertyaddress,
								saledate,
								saleprice,
								legalreference	
								order by uniqueid ) as row_num
from NashvilleHousing
--order by parcelid 
)
delete
from rownumCTE 
where row_num > 1 
--order by ParcelID (in select stat. to make sure i queried it right before delete )
;

--------------
-- delete unused columns  make sure that's you are having the row data in a diff place (don't delete your row data !!!!)

select *
from NashvilleHousing;

alter table NashvilleHousing
drop column propertyaddress , owneraddress , taxdistrict ,saledate ;
---------
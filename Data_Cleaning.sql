select * from Data

-- Seperate time from SaleDate

select SaleDate, CONVERT(date,SaleDate)
from Data

update Data
set SaleDate = CONVERT(date,SaleDate)



alter table Data
Add SaleDateConverted date;

update Data
set SaleDateConverted = CONVERT(date,SaleDate)

-- Update property address

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
case 
when a.PropertyAddress is null then b.PropertyAddress
end as nullfilled
from Data as a
join Data as b on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = case 
when a.PropertyAddress is null then b.PropertyAddress
end
from Data as a
join Data as b on a.ParcelID = b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select * from Data
where PropertyAddress is null

-- Breaking property address into individual columns (Address, City, Sate)

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as city
from Data


alter table Data
Add SplitPropAddress nvarchar(255);

update Data
set SplitPropAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table Data
Add SplitCity nvarchar(255);

update Data
set SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select PropertyAddress,SplitPropAddress,SplitCity  from Data


-- Breaking Owner address into individual columns (Address, City, Sate)

select PARSENAME(replace(OwnerAddress,',','.'),3) as Owner_address
, PARSENAME(replace(OwnerAddress,',','.'),2) as Owner_city
, PARSENAME(replace(OwnerAddress,',','.'),1) as Owner_state
from Data

alter table Data
Add Owner_address nvarchar(255);

update Data
set Owner_address = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table Data
Add Owner_city nvarchar(255);

update Data
set Owner_city = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table Data
Add Owner_state nvarchar(255);

update Data
set Owner_state = PARSENAME(replace(OwnerAddress,',','.'),1)

select * from Data


-- Change Y and N to Yes and No in SoldAsVacant

select distinct(SoldAsVacant) from Data

update Data
set SoldAsVacant = 'No'
where SoldAsVacant = 'N'

update Data
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'


-- Delete duplicates

with Row_num_cte AS
(
select *,ROW_NUMBER() over (partition by ParcelID,
PropertyAddress, 
SaleDate, 
SalePrice, 
LegalReference
order by ParcelID) as rownum
from Data
)
Delete from Row_num_cte
where rownum > 1

select * from Data

-- Delete unused columns

alter table Data
drop column PropertyAddress, OwnerAddress, LandUse

alter table Data
drop column SaleDate

select * from Data


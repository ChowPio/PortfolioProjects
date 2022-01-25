
/*Cleaning Data in SQL Queries*/



--Standardize Date Format

/*The below conversion doen not always work, try adding a new column instead! */
Update [dbo].[NashvilleHousing]
SET SaleDate = CONVERT(date, SaleDate)


Alter Table [dbo].[NashvilleHousing]
Add SaleDate2 Date;

Update [dbo].[NashvilleHousing]
SET SaleDate2 = CONVERT(date, SaleDate);

Select SaleDate, SaleDate2
From [dbo].[NashvilleHousing]




-- Populate Property Address data

Select *  --, PropertyAddress
From [dbo].[NashvilleHousing]
--where PropertyAddress is null
order by ParcelID

--For some pairs of Properties with the same ParcellID and different UniqueID one of them has an empty PropertyAddress attribute.
--Perform a self join operation to identify these pairs.
Select a.[UniqueID ], b.[UniqueID ], ISNULL(a.PropertyAddress, b.PropertyAddress),
a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress 
from [dbo].[NashvilleHousing] as a
join [dbo].[NashvilleHousing] as b
on a.ParcelID  = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Now replace the NULL in PropertyAddress with the use of a PropertyAddress from a second side of a connection. UPDATE based on JOIN.

begin tran;

Update a
set a.PropertyAddress = b.PropertyAddress  -- or use the following:  set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [dbo].[NashvilleHousing] as a
join [dbo].[NashvilleHousing] as b
on a.ParcelID  = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Check if it was successfull?
Select *  --, PropertyAddress
From [dbo].[NashvilleHousing]
where PropertyAddress is null




--Breaking out Address into Individual Columns (Address, City, State)


--Function CHARINDEX: Search for "t" in string "Customer", and return position


--SUBSTRING(string, start, length)
--string:  Required. The string to extract from
--start:   Required. The start position. The first position in string is 1
--lenght:  Required. The number of characters to extract. Must be a positive number

Select PropertyAddress, 
CHARINDEX(',', PropertyAddress), 
--Extracting an Address part of the string
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Adddress, 
--Extracting a City part of the string
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) ) as City 

From [dbo].[NashvilleHousing]



--Now add columns and update them by using previously developed queries
Alter Table [dbo].[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255);

Update [dbo].[NashvilleHousing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


Alter Table [dbo].[NashvilleHousing]
Add PropertySplitCity Nvarchar(255);

Update [dbo].[NashvilleHousing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) );

--Query the newly updated table 
Select * from [dbo].[NashvilleHousing];


-- An easier way to extract string, this time form OwnerAddress atribute - use a PARSENAME function
-- PARSENAME ('object_name' , object_piece )
-- Returns the specified part of an object name. The parts of an object that can be retrieved are the object name, schema name, database name, and server name.
--EXAMPLES:
--SELECT PARSENAME('AdventureWorksPDW2012.dbo.DimCustomer', 1) AS 'Object Name';  
--SELECT PARSENAME('AdventureWorksPDW2012.dbo.DimCustomer', 2) AS 'Schema Name';  
--SELECT PARSENAME('AdventureWorksPDW2012.dbo.DimCustomer', 3) AS 'Database Name';  
--SELECT PARSENAME('AdventureWorksPDW2012.dbo.DimCustomer', 4) AS 'Server Name';  
--GO 

select 
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState
from NashvilleHousing


--Again, add new columns and update them based on PARSERNAME function queries

Alter Table [dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo].[NashvilleHousing]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


Alter Table [dbo].[NashvilleHousing]
Add OwnerSplitCity Nvarchar(255);

Update [dbo].[NashvilleHousing]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


Alter Table [dbo].[NashvilleHousing]
Add OwnerSplitState Nvarchar(255);

Update [dbo].[NashvilleHousing]
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--Query the newly updated table 
Select * from [dbo].[NashvilleHousing];




--Change Y and N to Yes and No in 'Sold as Vacant' attribute

select distinct SoldAsVacant, count(SoldAsVacant)
from [dbo].[NashvilleHousing]
group by SoldAsVacant
order by SoldAsVacant


Update NashvilleHousing
set SoldAsVacant = 
CASE when SoldAsVacant like 'N' then 'No'
when SoldAsVacant like 'Y' then 'Yes'
else SoldAsVacant
END




--Remove duplicates

With RowNumCTE
AS
(
Select *, 
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) as row_numb
from [dbo].[NashvilleHousing]
)
Select * From RowNumCTE
where row_numb > 1
Order by PropertyAddress



--Delete unused columns

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

select *
from [Portfolio Projects].dbo.Housing_Nashvile

--1.Standardize date format
select saledate, Convert(date,saledate)
from [Portfolio Projects].dbo.Housing_Nashvile

alter table [Portfolio Projects].dbo.Housing_Nashvile
alter column saledate date

--2.populate property address. some rows are null but other rows with same parcelID are not.
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
from [Portfolio Projects].dbo.Housing_Nashvile a
join [Portfolio Projects].dbo.Housing_Nashvile b
on a.ParcelID=b.parcelid
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress= isnull(a.propertyaddress, b.PropertyAddress)
from [Portfolio Projects].dbo.Housing_Nashvile a
join [Portfolio Projects].dbo.Housing_Nashvile b
on a.ParcelID=b.parcelid
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--3.Breaking out address into individual columns (address,city,state)
--first option
select parcelid,OwnerAddress, SUBSTRING(owneraddress,1,(len(OwnerAddress)-15)) as Address, substring(owneraddress,(len(OwnerAddress)-12), 9) as City,
substring(owneraddress,(len(OwnerAddress)-1), 2) as State
from [Portfolio Projects].dbo.Housing_Nashvile 
where owneraddress is not null

--Second Option
select
substring(OwnerAddress, 1, (charindex(',', OwnerAddress)-1)) as Address, 
substring(OwnerAddress, (charindex(',', OwnerAddress)+1), len(OwnerAddress)) As City
from [Portfolio Projects].dbo.Housing_Nashvile 
where owneraddress is not null

--Third Option and the best one
select Parsename(replace(owneraddress,',','.'),3) as OwnerAddress_Edit ,Parsename(replace(owneraddress,',','.'),2) as City,Parsename(replace(owneraddress,',','.'),1) as State
from [Portfolio Projects].dbo.Housing_Nashvile 
where OwnerAddress is not null

Alter Table [Portfolio Projects].dbo.Housing_Nashvile
add Ownersplitaddress nvarchar(255)

update [Portfolio Projects].dbo.Housing_Nashvile
set Ownersplitaddress= Parsename(replace(owneraddress,',','.'),3)

Alter Table [Portfolio Projects].dbo.Housing_Nashvile
add Ownersplitcity nvarchar(255)

update [Portfolio Projects].dbo.Housing_Nashvile
set Ownersplitcity= Parsename(replace(owneraddress,',','.'),2)

Alter Table [Portfolio Projects].dbo.Housing_Nashvile
add OwnersplitState nvarchar(255)

update [Portfolio Projects].dbo.Housing_Nashvile
set OwnersplitState= Parsename(replace(owneraddress,',','.'),1)

Alter table [Portfolio Projects].dbo.Housing_Nashvile
drop column owneraddress

--4.change Y and N to Yes and No in soldasvacant

select soldasvacant,
case
when soldasvacant='N' then 'No'
when soldasvacant='Y' then 'Yes'
else soldasvacant
end
from [Portfolio Projects].dbo.Housing_Nashvile

update  [Portfolio Projects].dbo.Housing_Nashvile
set soldasvacant= case
when soldasvacant='N' then 'No'
when soldasvacant='Y' then 'Yes'
else soldasvacant
end

--for checking 
select distinct(soldasvacant), count(soldasvacant)
from [Portfolio Projects].dbo.Housing_Nashvile
group by soldasvacant

--5.Removing Duplicates

with Rownum_CTE as 
(select *, row_number() over (partition by soldasvacant,parcelid,saledate,saleprice,legalreference order by soldasvacant) as 'Rownumber'
from [Portfolio Projects].dbo.Housing_Nashvile
)
delete
from Rownum_CTE
where Rownumber>1


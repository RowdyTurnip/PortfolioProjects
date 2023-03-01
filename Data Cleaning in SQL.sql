--We are cleaning data in the following queries
Select *
from PortfolioProject2.dbo.Nashville_Housing



-- Standardizing the Date Format
Select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject2.dbo.Nashville_Housing

Update PortfolioProject2.dbo.Nashville_Housing
SET SaleDate = Convert(Date,SaleDate)

Alter Table PortfolioProject2.dbo.Nashville_Housing
Add SaleDate_Converted Date;

Update PortfolioProject2.dbo.Nashville_Housing
Set SaleDate_Converted = Convert(Date,SaleDate)

Select SaleDate_Converted,Convert(Date,SaleDate)
From PortfolioProject2.dbo.Nashville_Housing

-- Seperate Property Address Dtaa columns into Address, City, and State
Select *
From PortfolioProject2.dbo.Nashville_Housing
Where PropertyAddress is null
Order by ParcelID

--Looking at NUll a.PropertAddress to identify Nulls that correlate with b.PropertyAddress and then using b to fill in a
Select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyAddress,b.PropertyAddress)
From PortfolioProject2.dbo.Nashville_Housing a
JOIN PortfolioProject2.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
From PortfolioProject2.dbo.Nashville_Housing a
JOIN PortfolioProject2.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null

--Breaking Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject2.dbo.Nashville_Housing

--Removing Comma
Select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
From PortfolioProject2.dbo.Nashville_Housing

Alter Table PortfolioProject2.dbo.Nashville_Housing
Add Property_Separated_Address NVARCHAR(255);

Update PortfolioProject2.dbo.Nashville_Housing
SET Property_Separated_Address = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

Alter Table PortfolioProject2.dbo.Nashville_Housing
Add Property_Separated_City NVARCHAR(255);

Update PortfolioProject2.dbo.Nashville_Housing
SET Property_Separated_City = substring(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT *
FROM PortfolioProject2.dbo.Nashville_Housing

--Now proceeding with owner Address
Select OwnerAddress
from PortfolioProject2.dbo.Nashville_Housing

--Replacing comma with period since parsname only recognizes periods
Select
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
from PortfolioProject2.dbo.Nashville_Housing



Alter Table PortfolioProject2.dbo.Nashville_Housing
Add Owner_Split_Address NVARCHAR(255);
Update PortfolioProject2.dbo.Nashville_Housing
SET Owner_Split_Address = Parsename(Replace(OwnerAddress,',','.'),3)



Alter Table PortfolioProject2.dbo.Nashville_Housing
Add Owner_Split_City NVARCHAR(255);

Update PortfolioProject2.dbo.Nashville_Housing
SET Owner_Split_City = Parsename(Replace(OwnerAddress,',','.'),2)




Alter Table PortfolioProject2.dbo.Nashville_Housing
Add Owner_Split_State NVARCHAR(255);
Update PortfolioProject2.dbo.Nashville_Housing
SET Owner_Split_State = Parsename(Replace(OwnerAddress,',','.'),1)

Select *
From PortfolioProject2.dbo.Nashville_Housing



-- Changing 'Y'/'N' to Yes or No in "Sold as Vacant" field
Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From PortfolioProject2.dbo.Nashville_Housing
Order by 2

Select SoldAsVacant,
Case WHEN SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject2.dbo.Nashville_Housing

Alter Table PortfolioProject2.dbo.Nashville_Housing
Add Sold_As_Vacant NVARCHAR(255);
Update PortfolioProject2.dbo.Nashville_Housing
SET Sold_As_Vacant = Case WHEN SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END

Select *
From PortfolioProject2.dbo.Nashville_Housing

Select Distinct(Sold_As_Vacant),COUNT(Sold_As_Vacant)
From PortfolioProject2.dbo.Nashville_Housing
Group by Sold_As_Vacant


--Remove Duplicates
With RowNumCTE AS(
Select *,
	Row_Number() Over(
	Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by UniqueID
		) row_num
From PortfolioProject2.dbo.Nashville_Housing
)
DELETE
From RowNumCTE
where row_num >1

With RowNumCTE AS(
Select *,
	Row_Number() Over(
	Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by UniqueID
		) row_num
From PortfolioProject2.dbo.Nashville_Housing
)
Select *
From RowNumCTE
where row_num >1


-- Deleting Unused Columns
Select *
From PortfolioProject2.dbo.Nashville_Housing

Alter Table PortfolioProject2.dbo.Nashville_Housing
Drop Column SaleDate

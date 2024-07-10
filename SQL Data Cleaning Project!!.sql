SELECT TOP (1000) [UniqueID ]
,[ParcelID]
,[LandUse]
,[PropertyAddress]
,[SaleDate]
,[SalePrice]
,[LegalReference]
,[SoldAsVacant]
,[OwnerName]
,[OwnerAddress]
,[Acreage]
,[TaxDistrict]
,[LandValue]
,[BuildingValue]
,[TotalValue]
,[YearBuilt]
,[Bedrooms]
,[FullBath]
,[HalfBath]
FROM [SQL starter]..NashvilleHousing

-- Step 1: Standardizing/Changing Sale Date Format
Select SaleDate, CONVERT (Date,SaleDate)
From [SQL starter]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT (Date,SaleDate)
-- This command came from a comment on the yt video, shout out @t.d.2016
 ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE


 -- Step 2: Populate Property Address Data
 Select PropertyAddress
 From [SQL starter]..NashvilleHousing
 Where PropertyAddress is NULL

 Select *
 From [SQL starter]..NashvilleHousing
 Where PropertyAddress is NULL

 Select *
 From [SQL starter]..NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID

-- Some ParcelID's are duplicates, but some addresses are missing. Knowing they should have the same address, we can populate the missing addresses using the duplicates!!!

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
From [SQL starter]..NashvilleHousing a
JOIN [SQL starter]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null

-- The ISNULL tells the database that wherever a.PropertyAddress is Null to replace it with b.PropertyAddress because as I’ve said before, they have the same ParcelID meaning they also have the same address

Update a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
From [SQL starter]..NashvilleHousing a
JOIN [SQL starter]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Just to check to see if it actually worked!!
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
From [SQL starter]..NashvilleHousing a
JOIN [SQL starter]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	-- Where a.PropertyAddress is null

-- Step 3: Breaking up Address into Individual Columns (Address, City, State)
Select PropertyAddress
From [SQL starter]..NashvilleHousing

-- The comma acts as a delimiter (something that separates different columns or values) for the address and the city. We want to break these up
-- To break these up we're using a substring and a character index. The charactewr index searches for a specific value

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address

FROM [SQL starter]..NashvilleHousing
-- The CHARINDEX looks for position, it's the value of WHERE the comma is. The -1 helps get rid of the comma that was previously there (bcs CHARINDEX is the NUMBER of the POSITION of whatever it was looking for)

-- This next substring's a bit more complex 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM [SQL starter]..NashvilleHousing


-- We're now updating the table to include the split up values
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Now lets see if it worked!!
Select *
From [SQL starter]..NashvilleHousing
-- It did !! it added the columns at the end!!

-- Now time to do this for Owner Address :(, but.. with a new method ;) This time we're using PARSENAME

Select OwnerAddress
From [SQL starter]..NashvilleHousing

Select
PARSENAME(OwnerAddress,1)
From [SQL starter]..NashvilleHousing
-- Did nothing :(, but that's bcs PARSENAME only works with periods, so we need to replace all the commas were periods!!, also oddly enough it splits things backwards, so to have the right order it'd be a countdown

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1) 
From [SQL starter]..NashvilleHousing

-- YAYAYAY it split it up for us!!!, time to add them to the table

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

-- Let's see if it worked!!
Select *
From [SQL starter]..NashvilleHousing
-- It did!!! It added them at the end of our previous change!!!!!
-- However, for effiencies sake, next time, put all the alters first, THEN do the updates that way you don't have to do them individually


-- Step 4: Change Y and N in the "Sold as Vacant" field to Yes and No
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [SQL starter]..NashvilleHousing
Group by SoldAsVacant
Order by 2
-- This was to see how many Y and N there are so we can use a case statement to change them to Yes or No. It's basically, in the case that Y, then make it Yes
-- It can now be used to see if the update worked, IT DID!!!!
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [SQL starter]..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Step 5: Remove Duplicates

-- Usually, a temp table is used to remove duplicates as it's not really standard procedure to just delete data, but this is for practice soooo...
-- There's a few ways to do this, but we're creating a CTE and using some Windows functions to find the duplicates (remember the CTE from last time.....)

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID
				 ,PropertyAddress
				 ,SaleDate
				 ,SalePrice
				 ,LegalReference
				 ORDER BY
					UniqueID
					) row_num
From [SQL starter]..NashvilleHousing)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
-- We need to partition it, so a few ways can be rank, etc. but we're using row # (maybe research the other types? -\_(`~`)_/- )
-- Time to delete stuff!!!
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID
				 ,PropertyAddress
				 ,SaleDate
				 ,SalePrice
				 ,LegalReference
				 ORDER BY
					UniqueID
					) row_num
From [SQL starter]..NashvilleHousing)

DELETE
From RowNumCTE
Where row_num > 1
-- It's empty because it worked!! All the duplicates are gone!

-- Step 6: Delete Unused Columns
-- Again, this isn't common, this is more for views, but for the sake of learning, we're gonna delete some columns!!!
-- You can delete any, but for our purposes, we have a better Owner and Property Address, so those will be deleted!

ALTER TABLE [SQL starter]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select *
From [SQL starter]..NashvilleHousing
-- As you can see, the columns are gone!!
-- Because of the command we got in that YT comment, the sale date got changed, so there's no need to delete the column!! YAYAYAYAYAYAYY!
-- This wasn’t a comprehensive list, but it sure was a great start. To be honest, considering I’m just a student, this kind of experience is great for college and possibly employers too!! This is just the start!!!!!
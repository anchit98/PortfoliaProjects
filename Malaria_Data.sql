--Checking imported dataset
Select *
From..MalariaDeaths
Where code is not null
Order by 1,3


--Total Deaths per year
Select Year, sum(Deaths) as DeathsPerYear
From..MalariaDeaths
Group by Year
Order by Year


--Total Deaths and rolling count
Select Entity, Year, sum(Deaths) over (partition by Entity order by Entity,Year) as RollingDeathsCount
From..MalariaDeaths
Where code is not null
Order by 1,2


--Total Deaths within the last decade in India
Select Year, Entity, sum(Deaths) as TotalDeaths
From..MalariaDeaths
Where Year >= 2009 and Year <= 2019 and Entity like '%India%'
Group by Year, Entity
Order by 1,2


--Maximum deaths in each country for a particular year
Select Year, Entity, max(Deaths) as MaxDeathCount
From..MalariaDeaths
Group by Year, Entity
Order by 1,2

--Death Percentage in India per year compared to World Total
Select Year, (Select sum(Deaths)
From..MalariaDeaths
Where Entity like '%India%')/sum(Deaths)*100 as DeathPercent
From..MalariaDeaths
Group by Year
Order by Year

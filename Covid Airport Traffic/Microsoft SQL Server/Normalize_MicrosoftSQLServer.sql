USE [Covid Airport Traffic]
GO

--Looking at the RAW imported data 
SELECT * FROM [RAW_covid_impact_on_airport_traffic]

--Converting RAW table to WRK table
CREATE TABLE Covid_impact_Airport_Traffic(
	[RowNumber] int identity(1,1),
	[AggregationMethod] VARCHAR(10) DEFAULT 'Daily',
	[Date] DATE,
	[Version] INTEGER DEFAULT 1,
	[AirportName] VARCHAR(100),
	[PercentOfBaseline] INTEGER,
	[Centroid] VARCHAR(100),
	[City] VARCHAR(100),
	[State] VARCHAR(100),
	[ISO_3166_2] VARCHAR(20),
	[Country] VARCHAR(100),
	[Geography] VARCHAR(2000)
)

--Dropping Table RAW
DROP TABLE Covid_impact_Airport_Traffic

--Importing Value to WRK table
INSERT INTO [Covid_impact_Airport_Traffic](
	[Date] ,
	[AirportName] ,
	[PercentOfBaseline] ,
	[Centroid] ,
	[City] ,
	[State] ,
	[ISO_3166_2],
	[Country],
	[Geography] 
) 
SELECT 
	[Date] ,
	[AirportName] ,
	[PercentOfBaseline] ,
	[Centroid] ,
	[City] ,
	[State] ,
	[ISO_3166_2],
	[Country],
	[Geography] 

FROM [RAW_covid_impact_on_airport_traffic]
--7247 rows affected

--Data in the WRK Table
SELECT * FROM [Covid_impact_Airport_Traffic]

--1NF Investigation
--Checking Duplicates in the Table
SELECT COUNT(*) FROM [Covid_impact_Airport_Traffic]		--7247 entries

SELECT COUNT(*) FROM (
	SELECT DISTINCT * FROM [Covid_impact_Airport_Traffic]
) AS tmp_Covid												--7247 entries

--1NF Justified

--2NF Investigation
--Checking Candidate Keys: 1. Row Number & 2. Combination of (Date and Airport Name)
--Investigating the candidate key for (Date and Airport Name)
/*
SELECT COUNT(*) FROM (
SELECT AVG([PercentOfBaseline]) AS Average FROM [Covid_impact_Airport_Traffic]
GROUP BY [Date],[AirportName]
) AS tmp_cand
--7247 entries again
*/

--Since, Centroid, City, State, ISO_3166_2, Country,Geography are all dependent on a partial candidate key (i.e Airport) and not on date, hence mving them to a separate table
SELECT [AirportName],
		[Centroid], 
		[City], 
		[State], 
		[ISO_3166_2], 
		[Country],
		[Geography]
INTO Tmp_Airports
FROM [Covid_impact_Airport_Traffic]

--Checking Tmp_Airports Table with respect to 1NF and 2NF
SELECT COUNT(*) FROM Tmp_Airports		--7247 entries
SELECT COUNT(*) FROM (
	SELECT DISTINCT * FROM Tmp_Airports
) AS temp								--28 distinct rows

--Creating new table from the distint values
SELECT DISTINCT * 
INTO Airports
FROM Tmp_Airports
--28 rows affected

SELECT * FROM Airports

--Dropping the temporary table
DROP TABLE Tmp_Airports

--Dropping the columns from the main table
ALTER TABLE [Covid_impact_Airport_Traffic]
DROP COLUMN [Centroid], 
		[City], 
		[State], 
		[ISO_3166_2], 
		[Country],
		[Geography]

SELECT * FROM [Covid_impact_Airport_Traffic]

--2NF Justified

--3NF Investigation
SELECT [City],
		[State],
		[ISO_3166_2],
		[Country]
INTO tmp_City
FROM Airports

--Checking the normalised forms for Tmp_City
SELECT * FROM tmp_City
SELECT COUNT(*) FROM tmp_City		--28 entries
SELECT COUNT(*) FROM (
	SELECT DISTINCT * FROM tmp_City
) AS tmp							--27 entries

--Transferring Distinct data into City
SELECT DISTINCT * 
INTO Cities
FROM tmp_City
--27 rows affected

--Dropping tmp_City and columns from Airports
DROP TABLE tmp_City
ALTER TABLE Airports
DROP COLUMN [State],
			[ISO_3166_2],
			[Country]

--Now checking the two new tables created for their normalised forms
SELECT * FROM Airports
SELECT * FROM Cities

--In the table Cities, columns, 1SO_3166_2 and Country are dependent on State, whcih is a non-prime attribute, So converting this into 3NF
SELECT [State],	
		[ISO_3166_2],
		[Country]
INTO tmp_State
FROM Cities

--Checking duplicates in tmp_State
SELECT COUNT(*) FROM tmp_State			--27 rows
SELECT COUNT(*) FROM (
	SELECT DISTINCT * FROM tmp_State
) AS tmp								--23 rows

SELECT DISTINCT * 
INTO States
FROM tmp_State
--23 rows affected

--Dropping tmp_State and columns from the table Cities
DROP TABLE tmp_State
ALTER TABLE Cities
DROP COLUMN [ISO_3166_2],
		[Country]

--Nw, checking the new tables to be nomalised
SELECT * FROM Cities
SELECT * FROM States

--3NF Justified

--So the tables created are
/*
Table Name: [Covid_impact_Airport_Traffic]
Primary Key: RowNumber
Foreign Key: AirportName
*/
SELECT * FROM [Covid_impact_Airport_Traffic]

/*
Table Name: [Airports]
Primary Key: AirportName
Foreign Key: City
*/
SELECT * FROM [Airports]

/*
Table Name: [Cities]
Primary Key/ Candidate Key: City + State
Foreign Key: State
*/
SELECT * FROM [Cities]

/*
Table Name: [States]
Primary Key: State + Country
*/
SELECT * FROM [States]

-- Step 1: Create the aircraft_crashes table
-- Description: Defines the structure for importing and storing aircraft crash data.
-- This table will later be used for cleaning, exploratory analysis, and reporting.

CREATE TABLE aircraft_crashes (
    date DATE,
    time TIME,
    aircraft VARCHAR,
    operator VARCHAR,
    flight_phase VARCHAR,
    flight_type VARCHAR,
    survivors VARCHAR,
    crash_site VARCHAR,
    yom VARCHAR,
    crash_location VARCHAR,
    country VARCHAR,
    region VARCHAR,
    crew_on_board INT,
    crew_fatalities INT,
    pax_on_board INT,
    pax_fatalities INT,
    other_fatalities INT,
    total_fatalities INT,
    crash_cause VARCHAR
);


-- Data successfully imported into 'aircraft_crashes' using pgAdmin.
-- Ready for data cleaning and analysis.




-- Step 2: Null Value Summary
-- Purpose: Check for NULL values across all columns to assess data completeness before cleaning


SELECT *
FROM aircraft_crashes
WHERE 
    aircraft IS NULL OR
    operator IS NULL OR
	flight_phase IS NULL OR
	flight_type IS NULL OR
	survivors IS NULL OR
	crash_site IS NULL OR
	yom IS NULL OR
	crash_location IS NULL OR
	country IS NULL OR
	region IS NULL OR
	crew_on_board Is NULL OR
	crew_fatalities Is NULL OR
	pax_on_board Is NULL OR
	pax_fatalities Is NULL OR 
	other_fatalities Is NULL OR
	total_fatalities Is NULL;


Update aircraft_crashes
Set Flight_phase = 'Unknown'
Where Flight_phase is null;


-- 377 rows had NULL in 'flight_phase'.
-- Updated to 'Unknown' as no reliable source was available to fill the missing values.
 



Update aircraft_crashes
Set Flight_type = 'Unknown'
Where Flight_type is null;


-- 377 rows had NULL in 'Flight_type'.
-- Updated to 'Unknown' as no reliable source was available to fill the missing values.



Update aircraft_crashes
Set survivors = 'Unknown'
Where survivors is null;


-- 578 NULLs in 'survivors' column updated to 'Unknown' due to missing data.



Update aircraft_crashes
Set yom = '0'
Where yom is null;


Alter table aircraft_crashes
alter column yom type integer
using yom:: integer;



-- Found 1,757 NULL values in the 'yom' (Year of Manufacture) column.
-- Updated them to 0 since no manufacturer data was available to estimate the actual year.




Update Aircraft_crashes
Set crash_location = country
where crash_location IS NULL;


-- Found 4 NULL values in the 'crash_location' column.
-- Replaced them with the corresponding country name as the exact location was not publicly available.



Update aircraft_crashes
Set crash_site = 'Unknown'
Where crash_site is null;

-- Replaced NULLs in 'crash_site' with 'Unknown'


Update Aircraft_crashes
Set crew_on_board = crew_fatalities
where crew_on_board is null;


-- Updated 9 NULLs in 'crew_on_board' using 'crew_fatalities' as fallback



Update Aircraft_crashes
Set crew_fatalities = 0
where crew_fatalities is null;

Update Aircraft_crashes
Set pax_on_board = pax_fatalities
where pax_on_board is null;


-- Replaced NULLs in 'pax_on_board' using 'pax_fatalities'
-- Assumption: If only fatalities are recorded, total passengers is at least equal to fatalities


Update Aircraft_crashes
Set other_fatalities = 0
where other_fatalities is null;




-- Checking for duplicate records to ensure data integrity before analysis



With Crashes_cte AS
( 	Select *, Row_number() Over( Partition by date, time, aircraft, operator, flight_phase, flight_type, survivors, crash_site, yom, crash_location, country,
	region, crew_on_board, crew_fatalities, pax_on_board, pax_fatalities, other_fatalities, total_fatalities, crash_cause Order By ctid) AS ROWNUM 
 	From Aircraft_crashes
)
Select *
FROM Crashes_cte
Where Rownum > 1;


With Crashes_cte AS
( 	Select *, Ctid, Row_number() Over( Partition by date, time, aircraft, operator, flight_phase, flight_type, survivors, crash_site, yom, crash_location, country,
	region, crew_on_board, crew_fatalities, pax_on_board, pax_fatalities, other_fatalities, total_fatalities, crash_cause Order By ctid) AS ROWNUM 
 	From Aircraft_crashes
)
Delete
FROM Aircraft_crashes
Where ctid in
( Select ctid
FROM Crashes_cte
Where Rownum > 1);


-- Identified and removed 50 duplicate records.
-- Backup of the original table was created prior to deletion to ensure data safety.



date, time, aircraft, operator, flight_phase, flight_type, survivors, crash_site, yom, crash_location, country,
region, crew_on_board, crew_fatalities, pax_on_board, pax_fatalities, other_fatalities, total_fatalities, crash_cause



-- Removing unwanted leading and trailing spaces from text columns to ensure data consistency


SELECT 
    TRIM(aircraft) AS aircraft,
    TRIM(operator) AS operator,
    TRIM(flight_phase) AS flight_phase,
    TRIM(flight_type) AS flight_type,
    TRIM(survivors) AS survivors,
    TRIM(crash_site) AS crash_site,
    TRIM(crash_location) AS crash_location,
    TRIM(country) AS country,
    TRIM(region) AS region,
    TRIM(crash_cause) AS crash_cause
FROM aircraft_crashes;



Update aircraft_crashes
Set aircraft = Trim(aircraft),
	operator = Trim(operator),
	flight_phase = TRIM(flight_phase),
	flight_type = TRIM(flight_type),
	survivors = TRIM(survivors),
    crash_site = TRIM(crash_site),
	crash_location = TRIM(crash_location),
	country = TRIM(country),
	region = TRIM(region),
	crash_cause = TRIM(crash_cause);



-- The 'operator' column contains inconsistent or incorrect entries.
-- Applying UPDATE statements to fix known errors and standardize values.



UPDATE aircraft_crashes
SET operator = CASE operator
    WHEN 'Private Isreali' THEN 'Private Israeli'
    WHEN 'Private Venezeula' THEN 'Private Venezuelan'
    WHEN 'Private Costarican' THEN 'Private Costa Rican'
    WHEN 'Private thai' THEN 'Private Thai'
    WHEN 'Private Germany' THEN 'Private German'
    WHEN 'Private Mexico' THEN 'Private Mexican'
    WHEN 'Private Paraguay' THEN 'Private Paraguayan'
    WHEN 'Private Russia' THEN 'Private Russian'
    WHEN 'Private South Africa' THEN 'Private South African'
    WHEN 'Private United States of America' THEN 'Private American'
    WHEN 'Private Sao Tome %26 Principe' THEN 'Private São Tomé and Príncipe'
    ELSE operator
END
WHERE operator IN (
    'Private Isreali',
    'Private Venezeula',
    'Private Costarican',
    'Private thai',
    'Private Germany',
    'Private Mexico',
    'Private Paraguay',
    'Private Russia',
    'Private South Africa',
    'Private United States of America',
    'Private Sao Tome %26 Principe'
);


-- 'Yom' Column contains inconsistent values 

UPDATE aircraft_crashes
SET yom = 0
WHERE yom < 1800;

UPDATE aircraft_crashes
SET yom = 0
WHERE yom > 2025;


-- The 'flight_type' column contains duplicate values with inconsistent casing (e.g., 'Military' vs 'military').
-- We'll standardize the casing and remove redundant variations to clean the data.



UPDATE aircraft_crashes
SET flight_type = CASE flight_type
    WHEN 'Aerial photography' THEN 'Aerial Photography'
    WHEN 'Fire fighting' THEN 'Firefighting'
    WHEN 'Fire Fighter' THEN 'Firefighting'
    WHEN 'Postal (mail)' THEN 'Postal / Mail'
    WHEN 'Charter/Taxi (Non Scheduled Revenue Flight)' THEN 'Charter / Taxi'
    WHEN 'Executive/Corporate/Business' THEN 'Executive / Corporate'
    WHEN 'Illegal (smuggling)' THEN 'Illegal (Smuggling)'
    WHEN 'Skydiving / Paratroopers' THEN 'Skydiving / Parachute Ops'
    WHEN 'Geographical / Geophysical / Scientific' THEN 'Scientific / Geophysical Survey'
	ELSE flight_type

END
WHERE flight_type IN (
    'Aerial photography',
    'Fire fighting',
    'Fire Fighter',
    'Postal (mail)',
    'Charter/Taxi (Non Scheduled Revenue Flight)',
    'Executive/Corporate/Business',
    'Illegal (smuggling)',
    'Skydiving / Paratroopers',
    'Geographical / Geophysical / Scientific'
);



-- The 'country' column contains inconsistencies and misspellings that prevent accurate grouping.
-- Applying update queries to standardize country names and fix errors.




UPDATE aircraft_crashes
SET country = CASE country
    WHEN 'Salvador' THEN 'El Salvador'
    WHEN 'Comoros Islands' THEN 'Comoros'
    WHEN 'Maldivian Islands' THEN 'Maldives'
    WHEN 'French Guyana' THEN 'French Guiana'
    WHEN 'Samoa Islands (Western Samoa)' THEN 'Samoa'
    WHEN 'Antigua' THEN 'Antigua and Barbuda'
    WHEN 'Saint Vincent and Grenadines' THEN 'Saint Vincent and the Grenadines'
    WHEN 'La Reunion' THEN 'Réunion'
    WHEN 'Mayotte' THEN 'France'
    WHEN 'Saint-Barthélemy' THEN 'France'
    WHEN 'New Caledonia' THEN 'France'
    WHEN 'Saint Pierre and Miquelon' THEN 'France'
    WHEN 'French Guyana' THEN 'France'
	WHEN 'British Virgin Islands' THEN 'United Kingdom'
    WHEN 'Anguilla' THEN 'United Kingdom'
    WHEN 'Falkland Islands' THEN 'United Kingdom'
    WHEN 'Turks and Caicos Islands' THEN 'United Kingdom'
    WHEN 'Chagos Archipelago' THEN 'United Kingdom'
    WHEN 'Dutch Antilles' THEN 'Netherlands'
    WHEN 'Guam Island' THEN 'United States'
    WHEN 'Northern Mariana Islands' THEN 'United States'
	WHEN 'Faroe Islands' THEN 'Denmark'
    WHEN 'Greenland' THEN 'Denmark'
	
    ELSE country
END;


Update aircraft_crashes
Set country = Case country
	WHEN 'United States of America' THEN 'United States'
	WHEN 'US Virgin Islands' THEN 'United States'
	WHEN 'Puerto Rico' THEN 'United States'
	WHEN 'French Guiana' THEN 'France'
	WHEN 'Guadeloupe' THEN 'France'
	WHEN 'Martinique' THEN 'France'
	WHEN 'French Polynesia' THEN 'France'
	WHEN 'American Samoa' THEN 'United States'
	WHEN 'Réunion'  THEN 'France'
	WHEN 'Cayman Islands' THEN 'United Kingdom'
	WHEN 'Bermuda' THEN 'United Kingdom'
	WHEN 'Montserrat' THEN 'United Kingdom'
 	ELSE country 
	
End;



-- Cleaned the 'country' column: reduced 216 unique values down to 193 standardized country names.
-- This ensures accurate grouping and reliable geographic analysis.





-- Found 18 records where crew_fatalities > crew_on_board
-- This is a logical inconsistency (more deaths than people onboard)


Select *
From aircraft_crashes
where crew_fatalities > crew_on_board


UPDATE aircraft_crashes
SET crew_on_board = crew_fatalities
WHERE crew_fatalities > crew_on_board;


-- Updated crew_on_board to match crew_fatalities in those 18 rows
-- Assumption: crew_fatalities field is more reliable, and full crew count was missing






-- Adding new calculated columns to enhance analysis:
-- 'yoc', 'aircraft_age', 'fatality_rate', 'pax_survivors', 'crew_survivors', 'total_survivors', and 'manufacturer'
-- These fields will help with age-based insights, survival rates, and manufacturer-level breakdowns.


Alter table aircraft_crashes
Add column yoc integer;


Update aircraft_crashes
Set yoc = Extract(Year From Date);


Alter table aircraft_crashes
Add column Aircraft_Age int;


Update aircraft_crashes
Set Aircraft_Age = Greatest(yoc - yom, 0)
Where Yoc > yom
and Yom > 1800;


Alter table aircraft_crashes
Add column fatality_rate Numeric(5,2);


UPDATE aircraft_crashes
SET fatality_rate = ROUND(
	(crew_fatalities + pax_fatalities)::NUMERIC
	/ NULLIF(crew_on_board + pax_on_board, 0), 2
);


Alter table aircraft_crashes
Add column PAX_Survivors int;


UPDATE aircraft_crashes
SET pax_survivors = GREATEST(pax_on_board - pax_fatalities, 0)
WHERE pax_survivors < 0;


Alter table aircraft_crashes
Add column Crew_Survivors int;


Update aircraft_crashes
Set Crew_Survivors = (Crew_on_board - crew_fatalities)
where Crew_on_board >= crew_fatalities;


Alter table aircraft_crashes
Add column total_Survivors int;


Update aircraft_crashes
Set total_Survivors = (PAX_Survivors + Crew_Survivors);


ALTER TABLE aircraft_crashes
ADD COLUMN severity_level TEXT;

UPDATE aircraft_crashes
SET severity_level = CASE
    WHEN total_fatalities > 100 THEN 'Major'
    WHEN total_fatalities BETWEEN 1 AND 100 THEN 'Moderate'
    WHEN total_fatalities = 0 THEN 'Non-Fatal'
    ELSE 'Unclassified'
END;


Alter table aircraft_crashes
Add Column manufacturer varchar;


UPDATE aircraft_crashes
SET manufacturer = CASE
    WHEN aircraft ILIKE '%Lockheed%' THEN 'Lockheed'
    WHEN aircraft ILIKE '%De Havilland%' THEN 'De Havilland'
    WHEN aircraft ILIKE '%Fokker%' THEN 'Fokker'
    WHEN aircraft ILIKE '%Ilyushin%' THEN 'Ilyushin'
    WHEN aircraft ILIKE '%Piper%' THEN 'Piper'
    WHEN aircraft ILIKE '%Antonov%' THEN 'Antonov'
    WHEN aircraft ILIKE '%Boeing%' THEN 'Boeing'
    WHEN aircraft ILIKE '%Airbus%' THEN 'Airbus'
    WHEN aircraft ILIKE '%Douglas%' THEN 'Douglas'
    WHEN aircraft ILIKE '%Cessna%' THEN 'Cessna'
    WHEN aircraft ILIKE '%Beechcraft%' THEN 'Beechcraft'
    WHEN aircraft ILIKE '%PZL-Mielec%' THEN 'PZL-Mielec'
    WHEN aircraft ILIKE '%Let%' THEN 'Let'
    WHEN aircraft ILIKE '%Embraer%' THEN 'Embraer'
    WHEN aircraft ILIKE '%Rockwell%' THEN 'Rockwell'
    WHEN aircraft ILIKE '%Pilatus%' THEN 'Pilatus'
    WHEN aircraft ILIKE '%Socata%' THEN 'Socata'
    WHEN aircraft ILIKE '%Learjet%' THEN 'Learjet'
    WHEN aircraft ILIKE '%Canadair%' THEN 'Canadair'
    WHEN aircraft ILIKE '%Britten-Norman%' THEN 'Britten-Norman'
    WHEN aircraft ILIKE '%Swearingen%' THEN 'Swearingen'
    WHEN aircraft ILIKE '%BAe%' OR aircraft ILIKE '%Bae%' THEN 'BAe'
    WHEN aircraft ILIKE '%Dassault%' THEN 'Dassault'
    WHEN aircraft ILIKE '%Quest%' THEN 'Quest'
    WHEN aircraft ILIKE '%Gulfstream%' THEN 'Gulfstream'
    WHEN aircraft ILIKE '%Hawker%' THEN 'Hawker'
    WHEN aircraft ILIKE '%Mitsubishi%' THEN 'Mitsubishi'
    WHEN aircraft ILIKE '%Partenavia%' THEN 'Partenavia'
    WHEN aircraft ILIKE '%Raytheon%' THEN 'Raytheon'
    WHEN aircraft ILIKE '%Honda%' THEN 'Honda'
    WHEN aircraft ILIKE '%Casa%' THEN 'CASA'
    WHEN aircraft ILIKE '%Grumman%' THEN 'Grumman'
    WHEN aircraft ILIKE '%Tupolev%' THEN 'Tupolev'
    WHEN aircraft ILIKE '%Saab%' THEN 'Saab'
    WHEN aircraft ILIKE '%ATR%' THEN 'ATR'
    WHEN aircraft ILIKE '%Short%' THEN 'Short Brothers'
    WHEN aircraft ILIKE '%Epic%' THEN 'Epic Aircraft'
    WHEN aircraft ILIKE '%IAI%' THEN 'IAI'
    WHEN aircraft ILIKE '%Basler%' THEN 'Basler Turbo Conversions'
    WHEN aircraft ILIKE '%Comp Air%' THEN 'Comp Air'
    WHEN aircraft ILIKE '%Fletcher%' THEN 'Fletcher'
    WHEN aircraft ILIKE '%Convair%' THEN 'Convair'
    WHEN aircraft ILIKE '%Beriev%' THEN 'Beriev'
    WHEN aircraft ILIKE '%Xian%' THEN 'Xian Aircraft Industrial Corporation'
    WHEN aircraft ILIKE '%Avro%' THEN 'Avro'
    WHEN aircraft ILIKE '%North American%' THEN 'North American Aviation'
    WHEN aircraft ILIKE '%Shijiazhuang%' THEN 'Shijiazhuang Aircraft'
    WHEN aircraft ILIKE '%PAC%' THEN 'Pacific Aerospace'
    WHEN aircraft ILIKE '%Stinson%' THEN 'Stinson Aircraft'
    WHEN aircraft ILIKE '%Curtiss%' THEN 'Curtiss-Wright'
    WHEN aircraft ILIKE '%Yakovlev%' THEN 'Yakovlev'
    WHEN aircraft ILIKE '%Eclipse%' THEN 'Eclipse Aviation'
    WHEN aircraft ILIKE '%GippsAero%' THEN 'GippsAero'
    WHEN aircraft ILIKE '%Angel%' THEN 'Angel Aircraft Corporation'
    WHEN aircraft ILIKE '%Technoavia%' THEN 'Technoavia'
    WHEN aircraft ILIKE '%HESA%' THEN 'HESA'
    WHEN aircraft ILIKE '%NAMC%' THEN 'NAMC'
    WHEN aircraft ILIKE '%Aeritalia%' THEN 'Aeritalia'
    WHEN aircraft ILIKE '%GAF%' THEN 'GAF'
    WHEN aircraft ILIKE '%NAL%' THEN 'NAL'
    WHEN aircraft ILIKE '%Piaggio%' THEN 'Piaggio Aerospace'
    WHEN aircraft ILIKE '%AAC%' THEN 'AAC'
    WHEN aircraft ILIKE '%ACAZ%' THEN 'ACAZ'
    WHEN aircraft ILIKE '%Aérospatiale-BAC%' THEN 'Aérospatiale-BAC'
    WHEN aircraft ILIKE '%Aérospatiale%' THEN 'Aérospatiale'
    WHEN aircraft ILIKE '%Airspeed%' THEN 'Airspeed'
    WHEN aircraft ILIKE '%Alekseev%' THEN 'Alekseev'
    WHEN aircraft ILIKE '%Amiot%' THEN 'Amiot'
    WHEN aircraft ILIKE '%Armstrong Whitworth%' THEN 'Armstrong Whitworth'
    WHEN aircraft ILIKE '%Avia%' THEN 'Avia'
    WHEN aircraft ILIKE '%Aviation Traders%' THEN 'Aviation Traders'
    WHEN aircraft ILIKE '%Aviméta%' THEN 'Aviméta'
    WHEN aircraft ILIKE '%BAc%' THEN 'BAc'
    WHEN aircraft ILIKE '%Bach%' THEN 'Bach'
    WHEN aircraft ILIKE '%Bellanca%' THEN 'Bellanca'
    WHEN aircraft ILIKE '%Bernard%' THEN 'Bernard'
    WHEN aircraft ILIKE '%Blackburn%' THEN 'Blackburn'
    WHEN aircraft ILIKE '%Blériot%' THEN 'Blériot'
    WHEN aircraft ILIKE '%Bolkhovitinov%' THEN 'Bolkhovitinov'
    WHEN aircraft ILIKE '%Boulton & Paul%' THEN 'Boulton & Paul'
    WHEN aircraft ILIKE '%Breguet%' THEN 'Breguet'
    WHEN aircraft ILIKE '%Bristol%' THEN 'Bristol'
    WHEN aircraft ILIKE '%Budd%' THEN 'Budd'
    WHEN aircraft ILIKE '%Buhl%' THEN 'Buhl'
    WHEN aircraft ILIKE '%CAMS%' THEN 'CAMS'
    WHEN aircraft ILIKE '%Canadian Vickers%' THEN 'Canadian Vickers'
    WHEN aircraft ILIKE '%Caproni%' THEN 'Caproni'
    WHEN aircraft ILIKE '%Caudron%' THEN 'Caudron'
    WHEN aircraft ILIKE '%Chase%' THEN 'Chase'
    WHEN aircraft ILIKE '%CMASA%' THEN 'CMASA'
    WHEN aircraft ILIKE '%Consolidated%' THEN 'Consolidated'
    WHEN aircraft ILIKE '%Couzinet%' THEN 'Couzinet'
    WHEN aircraft ILIKE '%CRDA%' THEN 'CRDA'
    WHEN aircraft ILIKE '%Desoutter%' THEN 'Desoutter'
    WHEN aircraft ILIKE '%Dinfia%' THEN 'Dinfia'
    WHEN aircraft ILIKE '%Dornier%' THEN 'Dornier'
    WHEN aircraft ILIKE '%Excel Jet%' THEN 'Excel Jet'
    WHEN aircraft ILIKE '%Fairchild-Hiller%' THEN 'Fairchild-Hiller'
    WHEN aircraft ILIKE '%Fairchild%' THEN 'Fairchild'
    WHEN aircraft ILIKE '%Felixstowe%' THEN 'Felixstowe'
    WHEN aircraft ILIKE '%Ford%' THEN 'Ford'
    WHEN aircraft ILIKE '%Focke-Wulf%' THEN 'Focke-Wulf'
    WHEN aircraft ILIKE '%General Aircraft%' THEN 'General Aircraft'
    WHEN aircraft ILIKE '%GVF%' THEN 'GVF'
    WHEN aircraft ILIKE '%Hanriot%' THEN 'Hanriot'
    WHEN aircraft ILIKE '%Handley Page%' THEN 'Handley Page'
    WHEN aircraft ILIKE '%Hansa Brandenburg%' THEN 'Hansa Brandenburg'
    WHEN aircraft ILIKE '%Harbin%' THEN 'Harbin'
    WHEN aircraft ILIKE '%Heinkel%' THEN 'Heinkel'
    WHEN aircraft ILIKE '%Hindustan Aeronautics%' THEN 'Hindustan Aeronautics'
    WHEN aircraft ILIKE '%Howard%' THEN 'Howard'
    WHEN aircraft ILIKE '%Junkers%' THEN 'Junkers'
    WHEN aircraft ILIKE '%Kalinin%' THEN 'Kalinin'
    WHEN aircraft ILIKE '%Keystone%' THEN 'Keystone'
    WHEN aircraft ILIKE '%Koolhoven%' THEN 'Koolhoven'
    WHEN aircraft ILIKE '%Laird%' THEN 'Laird'
    WHEN aircraft ILIKE '%Latécoère%' THEN 'Latécoère'
    WHEN aircraft ILIKE '%Levasseur%' THEN 'Levasseur'
    WHEN aircraft ILIKE '%Lisunov%' THEN 'Lisunov'
    WHEN aircraft ILIKE '%Lioré-et-Olivier%' THEN 'Lioré-et-Olivier'
    WHEN aircraft ILIKE '%Loening%' THEN 'Loening'
    WHEN aircraft ILIKE '%LWS%' THEN 'LWS'
    WHEN aircraft ILIKE '%Macchi%' THEN 'Macchi'
    WHEN aircraft ILIKE '%Martinsyde%' THEN 'Martinsyde'
    WHEN aircraft ILIKE '%Martin%' THEN 'Martin'
    WHEN aircraft ILIKE '%Max Holste%' THEN 'Max Holste'
    WHEN aircraft ILIKE '%MBB%' THEN 'MBB'
    WHEN aircraft ILIKE '%Messerschmitt%' THEN 'Messerschmitt'
    WHEN aircraft ILIKE '%Metal%' THEN 'Metal'
    WHEN aircraft ILIKE '%Miles%' THEN 'Miles'
    WHEN aircraft ILIKE '%Morane-Saulnier%' THEN 'Morane-Saulnier'
    WHEN aircraft ILIKE '%Nakajima%' THEN 'Nakajima'
    WHEN aircraft ILIKE '%New Standard%' THEN 'New Standard'
    WHEN aircraft ILIKE '%Nieuport-Delage%' THEN 'Nieuport-Delage'
    WHEN aircraft ILIKE '%Noorduyn%' THEN 'Noorduyn'
    WHEN aircraft ILIKE '%Nord%' THEN 'Nord'
    WHEN aircraft ILIKE '%Pander%' THEN 'Pander'
    WHEN aircraft ILIKE '%Percival%' THEN 'Percival'
    WHEN aircraft ILIKE '%Pitcairn%' THEN 'Pitcairn'
    WHEN aircraft ILIKE '%Polikarpov%' THEN 'Polikarpov'
    WHEN aircraft ILIKE '%Potez%' THEN 'Potez'
    WHEN aircraft ILIKE '%Rohrbach%' THEN 'Rohrbach'
    WHEN aircraft ILIKE '%Ryan%' THEN 'Ryan'
    WHEN aircraft ILIKE '%Sabca%' THEN 'Sabca'
    WHEN aircraft ILIKE '%Salmson%' THEN 'Salmson'
    WHEN aircraft ILIKE '%Savoia-Marchetti%' THEN 'Savoia-Marchetti'
    WHEN aircraft ILIKE '%Savoia%' THEN 'Savoia'
    WHEN aircraft ILIKE '%SCAN%' THEN 'SCAN'
    WHEN aircraft ILIKE '%Scottish Aviation%' THEN 'Scottish Aviation'
    WHEN aircraft ILIKE '%Shaanxi%' THEN 'Shaanxi'
    WHEN aircraft ILIKE '%Sikorsky%' THEN 'Sikorsky'
    WHEN aircraft ILIKE '%Simmonds%' THEN 'Simmonds'
    WHEN aircraft ILIKE '%SNCASE%' THEN 'SNCASE'
    WHEN aircraft ILIKE '%SNCASO%' THEN 'SNCASO'
    WHEN aircraft ILIKE '%SPCA%' THEN 'SPCA'
    WHEN aircraft ILIKE '%Spartan%' THEN 'Spartan'
    WHEN aircraft ILIKE '%Spectrum%' THEN 'Spectrum'
    WHEN aircraft ILIKE '%Stearman%' THEN 'Stearman'
    WHEN aircraft ILIKE '%Sud-Aviation%' THEN 'Sud-Aviation'
    WHEN aircraft ILIKE '%Supermarine%' THEN 'Supermarine'
    WHEN aircraft ILIKE '%Transall%' THEN 'Transall'
    WHEN aircraft ILIKE '%Travel Air%' THEN 'Travel Air'
    WHEN aircraft ILIKE '%Udet%' THEN 'Udet'
    WHEN aircraft ILIKE '%Vickers%' THEN 'Vickers'
    WHEN aircraft ILIKE '%Volpar%' THEN 'Volpar'
    WHEN aircraft ILIKE '%Vultee%' THEN 'Vultee'
    WHEN aircraft ILIKE '%Waco%' THEN 'Waco'
    WHEN aircraft ILIKE '%Westland%' THEN 'Westland'
    WHEN aircraft = 'Unnamed aircraft' THEN 'Unknown'
    WHEN aircraft = 'Fairey III' THEN 'Fairey Aviation'
    WHEN aircraft = 'CANT 10' THEN 'CANT'
    WHEN aircraft = 'Farman F.190' THEN 'Farman'
    WHEN aircraft = 'Northrop Alpha 3' THEN 'Northrop'
    WHEN aircraft = 'Farman F.60 Goliath' THEN 'Farman'
    WHEN aircraft = 'Farman F.303' THEN 'Farman'
    WHEN aircraft = 'Sablatnig P.III' THEN 'Sablatnig'
    WHEN aircraft = 'Dewoitine D.33' THEN 'Dewoitine'
    WHEN aircraft = 'Aero A.10' THEN 'Aero Vodochody'
    WHEN aircraft = 'Lascurain Aura' THEN 'Lascurain'
    WHEN aircraft = 'FVM S.18' THEN 'FVM'
    ELSE manufacturer
END
WHERE aircraft IS NOT NULL;


UPDATE aircraft_crashes
SET manufacturer = CASE
    WHEN aircraft = 'Myasishchev 3M' THEN 'Myasishchev'
    WHEN aircraft = 'Aero C-3A' THEN 'Aero Vodochody'
    WHEN aircraft = 'Shin Meiwa PS-1' THEN 'Shin Meiwa'
    WHEN aircraft = 'Shin Meiwa US-2' THEN 'Shin Meiwa'
    WHEN aircraft = 'Northrop N-23 Pioneer' THEN 'Northrop'
    WHEN aircraft = 'Northrop Alpha 3' THEN 'Northrop'
    WHEN aircraft = 'Northrop Alpha 4' THEN 'Northrop'
    WHEN aircraft = 'Carstedt Jet Liner 600' THEN 'Carstedt'
    WHEN aircraft = 'Rausch Super 18 Hudstar' THEN 'Rausch'
    WHEN aircraft = 'Saunders ST-27' THEN 'Saunders-Roe'
    WHEN aircraft = 'Helio H-550A Stallion' THEN 'Helio Aircraft'
    WHEN aircraft = 'Fiat G.212' THEN 'Fiat'
    WHEN aircraft = 'Bushmaster 2000' THEN 'Stol Aircraft'
    WHEN aircraft = 'Bombardier Global Express/XRS' THEN 'Bombardier'
    WHEN aircraft = 'Bombardier Global 5000' THEN 'Bombardier'
    WHEN aircraft = 'Bombardier Challenger 300' THEN 'Bombardier'
    WHEN aircraft = 'Sukhoi Superjet 100-95' THEN 'Sukhoi'
    WHEN aircraft = 'Extra EA-400' THEN 'Extra Aircraft'
    WHEN aircraft = 'Cirrus Vision SF50' THEN 'Cirrus Aircraft'
    WHEN aircraft = 'Hurel-Dubois HD.321' THEN 'Hurel-Dubois'
    WHEN aircraft = 'Baade 152' THEN 'VEB Flugzeugwerke Dresden'
    WHEN aircraft = 'Breda-Zappata B.Z.308' THEN 'Breda-Zappata'
    WHEN aircraft = 'Kawasaki C-1' THEN 'Kawasaki'
    WHEN aircraft = 'Faucett F.19' THEN 'Faucett'
    WHEN aircraft = 'Grob G180 SPn' THEN 'Grob Aircraft'
    WHEN aircraft = 'Türk Hava Kurumu THK-5A' THEN 'THK'
    WHEN aircraft = 'Gavilán 358' THEN 'Gavilán Aircraft'
    ELSE manufacturer
END
WHERE aircraft IN (
    'Myasishchev 3M',
    'Aero C-3A',
    'Shin Meiwa PS-1',
    'Shin Meiwa US-2',
    'Northrop N-23 Pioneer',
    'Northrop Alpha 3',
    'Northrop Alpha 4',
    'Carstedt Jet Liner 600',
    'Rausch Super 18 Hudstar',
    'Saunders ST-27',
    'Helio H-550A Stallion',
    'Fiat G.212',
    'Bushmaster 2000',
    'Bombardier Global Express/XRS',
    'Bombardier Global 5000',
    'Bombardier Challenger 300',
    'Sukhoi Superjet 100-95',
    'Extra EA-400',
    'Cirrus Vision SF50',
    'Hurel-Dubois HD.321',
    'Baade 152',
    'Breda-Zappata B.Z.308',
    'Kawasaki C-1',
    'Faucett F.19',
    'Grob G180 SPn',
    'Türk Hava Kurumu THK-5A',
    'Gavilán 358'
);



UPDATE aircraft_crashes
SET manufacturer = 
    CASE manufacturer
        WHEN 'Aac' THEN 'AAC'
        WHEN 'Aérospatiale-Bac' THEN 'Aérospatiale'
        WHEN 'Bac' THEN 'BAC'
        WHEN 'Bae' THEN 'BAe'
        WHEN 'Iai' THEN 'IAI'
        WHEN 'Mbb' THEN 'MBB'
        WHEN 'Casa' THEN 'CASA'
        WHEN 'Pzl-Mielec' THEN 'PZL-Mielec'
        WHEN 'Sncaso' THEN 'SNCASO'
        WHEN 'Sncase' THEN 'SNCASE'
        WHEN 'Crda' THEN 'CRDA'
        WHEN 'Nal' THEN 'NAL'
        WHEN 'Thk' THEN 'THK'
        WHEN 'Let' THEN 'LET'
        ELSE manufacturer
    END
WHERE manufacturer IN (
    'Aac', 'Aérospatiale-Bac', 'Bac', 'Bae', 'Iai', 'Mbb', 'Casa',
    'Pzl-Mielec', 'Sncaso', 'Sncase', 'Crda', 'Nal', 'Thk', 'Let'
);


Update aircraft_crashes
Set manufacturer = INITCAP(manufacturer)
Where manufacturer is not null;


-- Added and populated new columns for analysis:
-- yoc, aircraft_age, fatality_rate, pax_survivors, crew_survivors, total_survivors, manufacturer

-- Data Preparation Completed
-- The dataset has been cleaned, standardized, and enriched:
-- Nulls handled and replaced based on logical assumptions
-- Duplicate records identified and removed
-- Inconsistent country and text values normalized
-- Data types adjusted for accuracy
-- The dataset is now ready for exploration, reporting, and dashboard visualization.


Select *
From aircraft_crashes












































































































































































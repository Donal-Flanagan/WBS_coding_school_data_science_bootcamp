CREATE DATABASE if not exists gans; 

USE gans;

drop table if exists cities;
CREATE TABLE IF NOT EXISTS cities (
    city_id INT,
    city_name VARCHAR(200),
--     latitude_deg float, 
--     longitude_deg float, 
--     iso_country varchar(200),
--     iso_region varchar(200),
--     municipality varchar(200),
--     gps_code varchar(200),
--     iata_code varchar(200),
    PRIMARY KEY(city_id)
); 

select * from cities;
INSERT INTO cities (city_id, city_name) VALUES (1, 'hasjdhs');

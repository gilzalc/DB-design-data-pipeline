CREATE TYPE region_group AS ENUM (
    'South Asia',
    'Europe and Central Asia',
    'Middle East and North Africa',
    'Sub-Saharan Africa',
    'Latin America and Caribbean',
    'East Asia and Pacific',
    'North America'
    );
CREATE TYPE income_group AS ENUM (
    'Low income',
    'Lower middle income',
    'Upper middle income',
    'High income'
    );
create table Country
(
    country     VARCHAR(50) UNIQUE,
    countrycode CHAR(3) primary key,
    region      region_group ,
    incomegroup income_group
);

CREATE TABLE University
(
    countrycode  CHAR(3) check (countrycode ~ '^[A-Z]{3}$'), --the CHECK ensures that the value inserted into the countrycode column is a string of exactly three uppercase letters.
    iau_id1      VARCHAR(20) PRIMARY KEY,
    eng_name     VARCHAR NOT NULL ,
    orig_name    VARCHAR NOT NULL ,
    foundedyr    SMALLINT NOT NULL CHECK (foundedyr <= 2020),
    yrclosed     INTEGER CHECK (yrclosed <= 2020),
    private01    BOOL     NOT NULL,
    latitude     DOUBLE PRECISION CHECK (ABS(latitude) <= 90.0),
    longitude    DOUBLE PRECISION CHECK (ABS(longitude) <= 180.0),
    phd_granting BOOL     NOT NULL,
    divisions    INTEGER CHECK (divisions >= 0),
    specialized  BOOL     NOT NULL,
    FOREIGN KEY (countrycode) REFERENCES Country (countrycode)
);


CREATE TABLE YearData
(
    iau_id1             VARCHAR  NOT NULL,
    year                SMALLINT NOT NULL,
    students5_estimated INTEGER CHECK (students5_estimated >= 0),
    PRIMARY KEY (year, iau_id1),
    FOREIGN KEY (iau_id1) REFERENCES University (iau_id1) ON DELETE CASCADE,
    CHECK (year BETWEEN 1950 AND 2020)
);

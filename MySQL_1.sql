
-- DATA CLEANING : LAYOFFS PROJECT --
-- 1. Remove duplicates
-- 2. Standarize the data 
-- 3. Null values  or blank values 
-- 4. Remove unneccessary columns 

USE world_layoffs;
SELECT * FROM layoffs;  

-- make a copy 
CREATE TABLE layoffs_staging
LIKE layoffs; 

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT *
FROM layoffs_staging;

-- subquery FROM(...) wajib ada nama panggilan -Alias
-- so here we check if theres duplicate by creating new column 
-- Code 1: Guna subquery untuk create column row_num dan tengok semua data
-- Tujuan: Nak verify nombor yang ROW_NUMBER() hasilkan sebelum tapis duplicates
-- remember date is unique word so need to use backtick
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, percentage_laid_off, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
) AS t;

-- Code 2: Guna CTE untuk create row_num dan terus tapis duplicates (row_num > 1)
-- Tujuan: Terus ambil rows yang duplicate sahaja tanpa tunjuk semua
WITH duplicate_cte  AS
(
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, percentage_laid_off, funds_raised_millions
               ) AS row_num
    FROM layoffs_staging
)
DELETE 
FROM duplicate_cte 
WHERE row_num >  1;

-- after double checking 'oda' takde pun duplicate 
SELECT * FROM layoffs_staging;
WHERE company = 'Cazoo';

-- -----------------------------------------------------------------------------------
-- lets make a copy of the dataset to delete the duplicated row but not  both row 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2
WHERE row_num >1;

INSERT INTO layoffs_staging2
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, `date`, stage, country, percentage_laid_off, funds_raised_millions
               ) AS row_num
    FROM layoffs_staging;
    
DELETE 
FROM layoffs_staging2
WHERE row_num >1;

SELECT * FROM layoffs_staging2;
-- duplicate rows successfully deleted

-- 2. standaridizing the data
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- we can see here theres tons of industry so we need to reduce this
-- theres even a blank and NULL
SELECT DISTINCT industry
FROM layoffs_staging2 
ORDER BY 1;

-- merge crypto and crypto currency
SELECT * FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
ORDER BY industry;
 
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
 
-- look at the country column in ascnding order
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%'

-- convert date and perc to int
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT * FROM layoffs_staging2;

-- eventho its updated, the column type is still text so we need to convert that too
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- check NULL in total_laid_off
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND  percentage_laid_off IS NULL;

-- check NULL in industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry ='';

-- cross check with company to populate the NULL row in industry using company airbnb 
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Find rows where the industry is missing, but the same company has another row with industry filled in  
-- So we can “borrow” that industry info to fill the missing one
-- but first we change blank space into NULL 
UPDATE layoffs_staging2
SET industry = null 
WHERE industry = '';

SELECT * 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL 
-- we can see that theres two table joined tgt one with missing column info in industry
-- and another one with industry that has info
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL; 

-- populate the missing industry info
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- now we check the airbnb industry is filled 
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- check the remaining NULL indurstry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry ='';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- for columns like total_laid_off perc_laid_off and fund_raied_mill which have NULL
-- cant be populated due to not enough info like total laid off
SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- -----------------------------------------------------------------------------------------

-- Exploratry Data Analysis 
SELECT *
FROM layoffs_staging2;

-- 1 in percentage laid off means 100% from the company got laid off 
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- so we will see which company that has all the stuffs laid off by 
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY total_laid_off DESC;

-- company that get invested the most but the stuff got laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

-- NO of people who got laid off by company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- date range when company started laying off people and th last date
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- no of people who  laid off by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- US has the most laid off 
-- maybe we can see how many people got laid off by year/ month etc
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 1 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;
 
 -- rolling total layoff
 -- create column total_off and rolling_total as the sum from prev month total 
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;




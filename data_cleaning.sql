-- Data cleaning--
-- in order to identify duplicates, introduce row number--
 
select *, 
row_number()over(
partition by company,location,industry,total_laid_off,percentage_laid_off, "date",stage,country,funds_raised_millions) as row_num 
from layoff_staging;

CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoff_staging2
select *, 
row_number()over(
partition by company,location,industry,total_laid_off,percentage_laid_off, "date",stage,country,funds_raised_millions) as row_num 
from layoff_staging;

select * from layoff_staging2;

-- delete the duplicates where rownumber is more than 1 --
delete from layoff_staging2 where row_num>1;

SET SQL_SAFE_UPDATES = 0;

-- standardizing data 
select * from layoff_staging2;

select count(*) from layoff_staging2;

-- Trim take off the white space both begining and ending
select company,trim(company)
from layoff_staging2; 

update layoff_staging2 set company=trim(company);

select distinct industry  
from layoff_staging2;

update layoff_staging2 set industry ="Crypto"
where industry like "Crypto%";

select distinct industry  
from layoff_staging2;

select distinct country, trim(trailing '.' from country) 
from layoff_staging2 order by 1;

update layoff_staging2
set country =trim(trailing '.' from country)
where country like 'United%';

select * from layoff_staging2;

select `date` from layoff_staging2; 

select `date`,str_to_date(`date`, '%m/%d/%Y')
from layoff_staging2; 

-- this is to update the date formate in a way that SQL can recognize 
update layoff_staging2 
set `date`=str_to_date(`date`, '%m/%d/%Y');

SET SQL_SAFE_UPDATES = 0; 

-- change the text formate to date at column 
Alter table layoff_staging2 
modify column `date` date;

-- Checking null 
select * 
from layoff_staging2 
where total_laid_off is null
and percentage_laid_off is null;

select distinct industry 
from layoff_staging2
where industry is null 
or industry='';

select *
from layoff_staging2
where industry is null 
or industry='';

select t1.industry,t2.industry 
from layoff_staging2 t1
join layoff_staging2 t2 
     on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t2.industry is not null;

SET SQL_SAFE_UPDATES = 0;

-- undating the blank value with null --

update layoff_staging2 
set industry=null
where industry='';

update layoff_staging2 t1
join layoff_staging2 t2 
     on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null
and t2.industry is not null;

select * 
from layoff_staging2;

select * 
from layoff_staging2 
where total_laid_off is null
and percentage_laid_off is null;

-- deleting the unwanted rows as it is not necessary for analysis

delete 
from layoff_staging2 
where total_laid_off is null
and percentage_laid_off is null; 

Alter table layoff_staging2
drop column row_num;

select * 
from layoff_staging2;

--
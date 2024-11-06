-- Exploring the data set
describe layoff_staging2; -- to get all the column name

select * from layoff_staging2;

-- identifying maximum laid_off

select max(total_laid_off) 
from layoff_staging2;

select max(total_laid_off),max(percentage_laid_off)
from layoff_staging2;

select company, sum(total_laid_off)
from layoff_staging2
group by company
order by 2 desc;

-- identifying total laid_off by each industry
select industry, sum(total_laid_off)
from layoff_staging2
group by industry
order by 2 desc;

select country, sum(total_laid_off)
from layoff_staging2
group by country
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoff_staging2
group by Year(`date`)
order by 2 desc;

select stage, sum(total_laid_off)
from layoff_staging2
group by stage
order by 2 desc;

-- getting the sum of laid off for months (1 to 12)
select substring(`date`,6,2) as 'month', sum(total_laid_off) 
from layoff_staging2
group by 1;

-- getting the sum of laid off for the year and month like (2022-02)
select substring(`date`,1,7) as 'month', sum(total_laid_off) 
from layoff_staging2
where substring(`date`,1,7) is not null
group by 1
order by 1 asc;

-- identifying the rolling total
with rolling_total_cte as 
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total
from layoff_staging2
where substring(`date`,1,7) is not null
group by 1
order by 1 asc
)
select `month`,total,sum(total) over (order by `month`) as rolling_total
from rolling_total_cte;

-- identifying total laid_off by company and year 
select company,year(`date`) as `year` ,sum(total_laid_off) as total
from layoff_staging2
group by 1,2
order by 3 desc;

with company_year_cte as
(
select company,year(`date`) as `year` ,sum(total_laid_off) as total
from layoff_staging2
group by company, `year`
)
select *,
dense_rank () over (partition by `year` order by total desc) as ranking 
from company_year_cte
where `year` is not null
order by ranking asc;

-- Identifying top 5 companies for all the years
with company_year_cte as
(
select company,year(`date`) as `year` ,sum(total_laid_off) as total
from layoff_staging2
group by company, `year`
), company_top_cte as 
(select *,
dense_rank () over (partition by `year` order by total desc) as ranking 
from company_year_cte
where `year` is not null)
select * from company_top_cte 
where ranking <=5;
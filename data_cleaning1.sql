select *
from layoffs_staging;

-- Creating staging table for cleaning

create table layoffs_staging
like layoffs;

insert layoffs_staging
select *
from layoffs;

-- remove duplicates
with dup as(
select *,
row_number() over(
partition by company, location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions)
 as row_num
from layoffs_staging)
select *
from dup
where row_num>1;

create table layoff2
like dup;

CREATE TABLE `layoffs2` (
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

insert into layoffs2
select *,
row_number() over(
partition by company, location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions)
 as row_num
from layoffs_staging;

delete  from layoffs2 where row_num>1

-- Standardize rows

update layoffs2
set company=trim(company);

select *
from layoffs2
where industry='Crypto currency';

update layoffs2
set industry='Crypto'
where industry like 'Crypto%';

update layoffs2
set country='United States'
where country like 'United States%';

update layoffs2
set `date`=str_to_date(`date`, '%m/%d/%Y');

alter table layoffs2
modify column `date` DATE;

select distinct industry
from layoffs2
order by 1;

-- Remove nulls
update layoffs2
set industry=null
where industry='';

update layoffs2 t1 join layoffs2 t2
on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null
and t2.industry is not null;

select *
from layoffs2
where total_laid_off is null 
and percentage_laid_off is null;

-- Remove unwanted columns
alter table layoffs2
drop column row_num;

select *
from layoffs2
order by 1;




 







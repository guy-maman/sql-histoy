select *
from file_process limit 100;

select * from file_process where file_name = 'MSC2020082427928.dat';
select date_trunc('day',current_date);

select  distinct status from file_process
where created_date < date_trunc('day',current_date);

select distinct file_checksum from file_process
where created_date < date_trunc('day',current_date);


select file_name, max(process_start)  as process_start, count(*) from file_process
where status = 'BROKEN_IN_PROCESSING' and created_date >  current_date - 1
group by file_name
having count(*) > 2
order by process_start;
;

select * from file_process where file_name = 'chsLog.1849_20200824171509';
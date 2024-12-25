/*
create table default.dictionary_x(date datetime,Operator int,trafficId int,x1 Float64,x2 Float64,x3 Float64)           --int,MSISDN String)
ENGINE = MergeTree() order by date;
*/
-- test tariff
-- select  toStartOfMonth(date) date,if(d.operator = 'ORANGE',1,2) operator,t.operatorId,type,sum(volume) v
-- from    default.daily_traffic_liberia d
--     join mediation.traffic_types t on d.type = t.value
-- where   toStartOfMonth(d.date) between '2024-01-01' and '2024-06-01'
-- group by date,operator,t.operatorId,type
-- order by date,operator,t.operatorId;
--
-- select * from dictionary_x
-- truncate table dictionary_x
-- select * from mediation.monthly_revenue_report_manual
-- truncate table mediation_shard.monthly_revenue_report_manual_shared  ON CLUSTER liberia;
-- insert into mediation.monthly_revenue_report_manual values (3,	'Pre-Paid Sales Revenue',	'2024-01-01',	7327340.32,	93402,	'ORANGE')


-- air time
select  toStartOfMonth(date) date,if(d.operator = 'ORANGE',1,2) operator,t.operatorId,type,sum(volume) v,--x1,x2
        round(multiIf(t.operatorId = 2,sum(volume/x1/x2),operator = 1 and t.operatorId = 6,0,operator = 2 and t.operatorId = 5,0,
                      sum(volume*x1*x2))/sum(volume),4) traiff
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on d.type = t.value
    join default.dictionary_x dx on operator = dx.Operator and toStartOfMonth(d.date) = dx.date and t.operatorId = toUInt64(dx.trafficId)
where   toYYYYMM(d.date) = (:yyyymm)
--     and operator = (:op)
group by date,operator,t.operatorId,type,x1,x2
order by date,operator,t.operatorId;

-- monthly revenue
select operator,date,type,revenue,exempt
from mediation.monthly_revenue_report_manual
where toYYYYMM(date) = (:yyyymm)
order by operator desc,type_id,type desc



/*
select  operator,'Prepaid sales' x,sum(tariff) tar
from (
         select toStartOfMonth(date)                             date,
                if(d.operator = 'ORANGE', 1, 2)                  operator,
                round(multiIf(t.operatorId = 2, sum(volume / x1 / x2), operator = 1 and t.operatorId = 6, 0,
                              operator = 2 and t.operatorId = 5, 0,
                              sum(volume * x1 * x2)) * x3, 2) tariff
         from default.daily_traffic_liberia d
                  join mediation.traffic_types t on d.type = t.value
                  join default.dictionary_x dx on operator = dx.Operator and toStartOfMonth(d.date) = dx.date and
                                                  t.operatorId = toUInt64(dx.trafficId)
         where toYYYYMM(d.date) = 202401
            and operator = (:op)
         group by date, operator, t.operatorId, type, x1, x2,x3
         ) group by operator
union all
select  operator,'Postpaid sales' x,sum(tariff) tar
from (
         select toStartOfMonth(date)                             date,
                if(d.operator = 'ORANGE', 1, 2)                  operator,
                round(multiIf(t.operatorId = 2, sum(volume / x1 / x2), operator = 1 and t.operatorId = 6, 0,
                              operator = 2 and t.operatorId = 5, 0,
                              sum(volume * x1 * x2)) * (1-x3), 2) tariff
         from default.daily_traffic_liberia d
                  join mediation.traffic_types t on d.type = t.value
                  join default.dictionary_x dx on operator = dx.Operator and toStartOfMonth(d.date) = dx.date and
                                                  t.operatorId = toUInt64(dx.trafficId)
         where toYYYYMM(d.date) = 202401
            and operator = (:op)
         group by date, operator, t.operatorId, type, x1, x2,x3
         ) group by operator;


--orange

-- select ts,operator,if(trafficType in (1,3,4,5,6),'Voice','DATA') trafficType
--      ,sum(revenue) total
-- from (
--          select operator,
--                 trafficType,
--                 toStartOfMonth(eventTimeStamp) ts,
--                 multiIf(
--                         trafficType = 1, toFloat64(sum(duration)/60)*0.33 * 0.0156,
--                         trafficType = 2, toFloat64(sum(duration)/1024)/1.3,
--                         trafficType = 3, toFloat64(sum(duration)/60) * 0,
--                         trafficType = 4, toFloat64(sum(duration)/60) * 0.12,
--                         trafficType = 5, toFloat64(sum(duration)/60) * if(operator = 1, 0.05, 0),
--                         trafficType = 6, toFloat64(sum(duration)/60) * if(operator = 2, 0.05, 0),
--                         null
--                 )                              revenue
--          from mediation.hourly_traffic
--          where toYYYYMM(eventTimeStamp) = 202401
--          group by operator, trafficType, ts
--          order by ts,operator, trafficType
--          )
-- group by ts,trafficType,operator
-- order by operator, trafficType,ts;
--
--
-- select ts,operator,if(trafficType in (1,3,4,5,6),'Voice','DATA') trafficType
--      ,sum(revenue) total
-- from (
--          select operator,
--                 trafficType,
--                 toStartOfMonth(eventTimeStamp) ts,
--                 multiIf(
--                         trafficType = 1, toFloat64(sum(duration)/60),
--                         trafficType = 2, toFloat64(sum(duration)/1024),
--                         trafficType = 3, toFloat64(sum(duration)/60) * 0,
--                         trafficType = 4, toFloat64(sum(duration)/60),
--                         trafficType = 5, toFloat64(sum(duration)/60) * if(operator = 1, 1, 0),
--                         trafficType = 6, toFloat64(sum(duration)/60) * if(operator = 2, 1, 0),
--                         null
--                 )                              revenue
--          from mediation.hourly_traffic
--          where toYYYYMM(eventTimeStamp) = 202401
--          group by operator, trafficType, ts
--          order by ts,operator, trafficType
--          )
-- group by ts,trafficType,operator
-- order by operator, trafficType,ts;
--
--
-- select  toStartOfMonth(date) date,if(d.operator = 'ORANGE',1,2) operator,t.operatorId,type,sum(volume) v
-- from    default.daily_traffic_liberia d
--     join mediation.traffic_types t on d.type = t.value
-- where   toYYYYMM(date) =202401
-- --     and operator = 'ORANGE'
-- group by date,t.operatorId,operator,type
-- order by date,operator,t.operatorId


-- sum(if(t.operatorId = 2,(volume)/dx.x1/dx.x2,(volume)*dx.x1*dx.x2)) v

-- insert into default.dictionary_x values ('2024-01-01',1,1,0.3300,0.0156,0.997);
-- insert into default.dictionary_x values ('2024-01-01',1,2,1024.0,1.3000,0.997);
-- insert into default.dictionary_x values ('2024-01-01',1,3,0.0000,0.0000,0.997);
-- insert into default.dictionary_x values ('2024-01-01',1,4,0.1200,1.0000,0.997);
-- insert into default.dictionary_x values ('2024-01-01',1,5,0.0500,1.0000,0.997);
-- insert into default.dictionary_x values ('2024-01-01',1,6,0.0500,1.0000,0.997);
-- insert into default.dictionary_x values ('2024-01-01',2,1,0.3300,0.0156,0.986);
-- insert into default.dictionary_x values ('2024-01-01',2,2,1024.0,1.3000,0.986);
-- insert into default.dictionary_x values ('2024-01-01',2,3,0.0000,0.0000,0.986);
-- insert into default.dictionary_x values ('2024-01-01',2,4,0.1200,1.0000,0.986);
-- insert into default.dictionary_x values ('2024-01-01',2,5,0.0500,1.0000,0.986);
-- insert into default.dictionary_x values ('2024-01-01',2,6,0.0500,1.0000,0.986);






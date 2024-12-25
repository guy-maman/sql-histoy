
/*
alter table mediation_shard.daily_traffic_liberia_shard on cluster liberia delete where toStartOfMonth(date) = '2024-05-01';
select *
from    default.daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
*/
--Liberia traffic
select  type,orange,mtn,orange+mtn Total
from (
select  toStartOfMonth(date) date,type,
        sum(volume) orange
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
    and operator = 'ORANGE'
group by operator,type, date,t.operatorId
order by operator desc, date,t.operatorId
)as a
left any join
(
select  toStartOfMonth(date) date,type,
        sum(volume) mtn
from    default.daily_traffic_liberia d
    join mediation.traffic_types t on t.value = type
where   toYYYYMM(date) = (:yyyymm)
    and operator = 'MTN'
group by operator,type, date,t.operatorId
order by operator desc, date,t.operatorId
)as b on a.type = b.type;

--Daily traffic table
select  Operator,Date,sum(On_Net) On_Net,sum(DATA) DATA,sum(International_Incoming) International_Incoming
        ,sum(International_Outgoing) International_Outgoing,sum(Orange_To_MTN) Orange_To_MTN
        ,sum(MTN_To_Orange) MTN_To_Orange
from    default.report_daily_table
where   toYYYYMM(Date) = (:yyyymm)
group by Operator,Date
order by Operator desc,Date;

--Traffic trends
select  case
            when type = 'On Net'            then 1
            when type= 'DATA MB'            then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,
        type,
        sum(case when operator = 'ORANGE' then crnt/mom-1 else 0 end) as ORANGE_MoM,
        sum(case when operator = 'ORANGE' then crnt/yoy-1 else 0 end) as ORANGE_YoY,
        sum(case when operator = 'MTN' then crnt/mom-1 else 0 end) as MTN_MoM,
        sum(case when operator = 'MTN' then crnt/yoy-1 else 0 end) as MTN_YoY,
        sum(crnt/mom-1) MoM,
        sum(crnt/yoy-1) YoY
from (
select  operator,type,crnt,mom,yoy
from (
         select operator,type,crnt,mom
         from (
                  select operator, toStartOfMonth(date) month, type, round(sum(volume) / count()) crnt
                  from default.daily_traffic_liberia
                  where toYYYYMM(date) = toYYYYMM(toDate(:date))
                  group by operator, month, type
                  ) as a
                  join
              (
                  select operator, toStartOfMonth(date) month, type, round(sum(volume) / count()) mom
                  from default.daily_traffic_liberia
                  where toYYYYMM(date) = toYYYYMM(date_add(MONTH, -1, toDate((:date))))
                  group by operator, month, type
                  ) as b on a.operator = b.operator and a.type = b.type
         )as c
    join
     (
         select operator, toStartOfMonth(date) month, type, round(sum(volume) / count()) yoy
         from default.daily_traffic_liberia
         where toYYYYMM(date) = toYYYYMM(date_add(YEAR, -1, toDate((:date))))
         group by operator, month, type
         )as d on c.operator = d.operator and c.type = d.type
order by 1,3
)group by type
order by ind
;

--Traffic Market share
select type,orange,mtn,orange+mtn liberia,orange/(total) AccORANGE,mtn/(total) AccMTN
from (
select type,sum(orange) orange,sum(mtn) mtn,orange+mtn total
from (
select multiIf(type = 'INTL Incoming', 'INTL', type = 'INTL Outgoing', 'INTL', type = 'Orange to MTN', 'Off net',
               type = 'MTN to Orange', 'Off net', type)  type,
       sum(multiIf(ind = 6, 0, ind = 5, (Total) / 2, orange)) orange,
       sum(multiIf(ind = 5, 0, ind = 6, (Total) / 2, mtn))    mtn,
        case
            when type = 'On Net'   then 1
            when type = 'DATA MB'  then 4
            when type = 'INTL'     then 3
            when type = 'Off net'  then 2
        end ind1
from (
select  type,ind,orange,mtn,(orange+mtn) Total
from (
select  toStartOfMonth(date) date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,type,
        sum(volume) orange
from    default.daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and operator = 'ORANGE'
group by operator,type, date
order by operator, date,ind
)as a
left any join
(
select  toStartOfMonth(date) date,
        case
            when type = 'On Net'            then 1
            when type = 'DATA MB'           then 2
            when type = 'INTL Incoming'     then 3
            when type = 'INTL Outgoing'     then 4
            when type = 'Orange to MTN'     then 5
            when type = 'MTN to Orange'     then 6
        end ind,type,
        sum(volume) mtn
from    default.daily_traffic_liberia
where   toYYYYMM(date) = (:yyyymm)
    and operator = 'MTN'
group by operator,type, date
order by operator, date,ind
)as b on a.type = b.type
)group by type,/*orange,mtn,*/Total,ind
)group by type,ind1
order by ind1
)
;

--International Traffic
select Operator,Direction,CountryName,callDuration
from (
      select Top 10 1 ind, Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from default.INTL
      where toYYYYMM(Date) = (:yyyymm)
        and CountryName not in ('Liberia')
        and Operator = 'ORANGE'
        and Direction = '3'
      group by Operator, Direction, CountryName
      order by callDuration desc
union all
      select Top 10 2 ind, Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from (
      select Operator, Direction, CountryName,callReference,Date,sum(callDuration) callDuration
      from default.INTL
      where toYYYYMM(Date) = (:yyyymm)
        and CountryName not in ('Liberia')
        and Operator = 'MTN'
        and Direction = '3'
      group by Operator, Direction, CountryName,Date,callReference
      )
      group by Operator, Direction, CountryName
      order by callDuration desc
union all
      select Top 10 3 ind, 'Merged' Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from default.INTL
      where toYYYYMM(Date) = (:yyyymm)
        and CountryName not in ('Liberia')
        and Direction = '3'
      group by Operator, Direction, CountryName
      order by callDuration desc
union all
      select Top 10 4 ind, Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from default.INTL
      where toYYYYMM(Date) = (:yyyymm)
        and CountryName not in ('Liberia')
        and Operator = 'ORANGE'
        and Direction = '4'
      group by Operator, Direction, CountryName
      order by callDuration desc
union all
      select Top 10 5 ind, Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from default.INTL
      where toYYYYMM(Date) = (:yyyymm)
        and CountryName not in ('Liberia')
        and Operator = 'MTN'
        and Direction = '4'
      group by Operator, Direction, CountryName
      order by callDuration desc
union all
      select Top 10 6 ind, 'Merged' Operator, Direction, CountryName, round(sum(callDuration)/60,2) callDuration
      from default.INTL
      where toYYYYMM(Date) = (:yyyymm)
        and CountryName not in ('Liberia')
        and Direction = '4'
      group by Operator, Direction, CountryName
      order by callDuration desc
union all
        select  8 ind, 'Merged' Operator,'Merged' Direction,
                if(CountryName = 'USA\ Canada', 'usa', CountryName) CountryName,
                round(sum(callDuration)/60,2) callDuration
        from    default.INTL
        where   toYYYYMM(Date) = (:yyyymm)
        group by Operator, Direction, CountryName
        order by callDuration desc
         )
order by ind,callDuration desc;

-- Active subs
select  Activity,ORANGE,MTN
from
(
select 1 ind, 'Active Subs' Activity, sum(subscount) ORANGE
 from default.Active_Subs
 where toYYYYMM(date) = (:yyyymm)
   and Operator = 'ORANGE'
 group by Operator
 union all
 select case
            when Activity = 'Voice&DATA' then 2
            when Activity = 'DATA' then 3
            when Activity = 'Voice' then 4
            end   ind,
        Activity,
        subscount ORANGE
 from default.Active_Subs
 where toYYYYMM(date) = (:yyyymm)
   and Operator = 'ORANGE'
 order by ind
) a
join
(
select  1 ind,'Active Subs' Activity,sum(subscount) MTN
from    default.Active_Subs
where   toYYYYMM(date) = (:yyyymm)
    and Operator = 'MTN'
group by Operator
union all
select  case
            when Activity = 'Voice&DATA' then 2
            when Activity = 'DATA' then 3
            when Activity = 'Voice' then 4
        end ind,
        Activity,subscount MTN
from    default.Active_Subs
where   toYYYYMM(date) = (:yyyymm)
    and Operator = 'MTN'
order by ind
) b on a.ind = b.ind
order by ind;

-- Management yearly
select  Date,sum(avg)/(count()/4) avg,count()/4 days
from (
         select toYear(date) Date, if(t.operatorId = 3, volume * 0.14, volume * 0.05) avg
         from default.daily_traffic_liberia d
                  join mediation.traffic_types t on t.value = type
         where t.operatorId in (3, 4)
--                 and date < toStartOfMonth(now())
         )
group by Date
order by Date;



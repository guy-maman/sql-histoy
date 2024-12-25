
-- select top 10 CountryName,sum(Incoming) Incoming
select top 10 CountryName,sum(Outgoing) Outgoing
from Top10
where DateMonth = (:yyyymm)
    and CountryName not in ('Liberia')
--     and Operator = 'ORANGE'
--     and Operator = 'MTN'
group by CountryName
-- order by Incoming desc
order by Outgoing desc

---------------------------------------------------

-- select top 10 CountryName,Incoming
select top 10 CountryName,Outgoing
from Top10
where DateMonth = (:yyyymm)
    and CountryName not in ('Liberia')
    and Operator = 'ORANGE'
--     and Operator = 'MTN'
-- order by Incoming desc
order by Outgoing desc
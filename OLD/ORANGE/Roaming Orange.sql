-----------------------Orange---------------------------------

type
MO_CALL_RECORD
MT_CALL_RECORD
COMMON_EQUIP_RECORD
HLR_INT_RECORD
INC_GATEWAY_RECORD
OUT_GATEWAY_RECORD
USSD_RECORD
MO_LCS_RECORD
MO_SMS_RECORD
MT_SMS_RECORD
MCF_CALL_RECORD
ROAM_RECORD
SS_ACTION_RECORD
TERM_CAMEL_INT_RECORD

create table CountryOperatorsCode (Country String,NetworkCode String,CountryCode String, OperatorName String) ENGINE = Memory;
-- drop table CountryOperatorsCode;
insert into CountryOperatorsCode
values
('Benin ','61601','229','Benin Telecoms Mobile'),
('Benin ','61602','229','Telecel Benin'),
('Benin ','61603','229','Spacetel Benin'),
('Benin ','61604','229','Bell Benin Communications'),
('Benin ','61605','229','Glo Communication Benin'),
('Burkina Faso','61301','226','Onatel'),
('Burkina Faso','61302','226','Orange Burkina Faso'),
('Burkina Faso','61303','226','Telecel Faso SA'),
('Guinea ','61101','224','Orange S.A.'),
('Guinea ','61102','224','Sotelgui Lagui'),
('Guinea ','61103','224','INTERCEL Guinée'),
('Guinea ','61104','224','Areeba Guinea'),
('Guinea ','61105','224','Cellcom'),
('Ivory Coast','61201','225','Cora de Comstar'),
('Ivory Coast','61202','225','Atlantique Cellulaire'),
('Ivory Coast','61203','225','Orange'),
('Ivory Coast','61204','225','Comium Ivory Coast Inc'),
('Ivory Coast','61205','225','Loteny Telecom'),
('Ivory Coast','61206','225','Oricel'),
('Ivory Coast','61207','225','Aircomm'),
('Ivory Coast','61218','225','YooMee'),
('Mali ','61001','223','Malitel SA'),
('Mali ','61002','223','Orange Mali SA'),
('Mali ','61003','223','Alpha Telecommunication Mali S.A.'),
('Senegal ','60801','221','Sonatel'),
('Senegal ','60802','221','Millicom International Cellular S.A.'),
('Senegal ','60803','221','Sudatel'),
('Senegal ','60804','221','CSU-SA'),
('Sierra Leone','61901','232','Orange SL Limited'),
('Sierra Leone','61902','232','Lintel Sierra Leone Limited'),
('Sierra Leone','61903','232','Lintel Sierra Leone Limited'),
('Sierra Leone','61904','232','Comium (Sierra Leone) Ltd.'),
('Sierra Leone','61905','232','Lintel Sierra Leone Limited'),
('Sierra Leone','61906','232','Sierra Leone Telephony'),
('Sierra Leone','61907','232','Qcell Sierra Leone'),
('Sierra Leone','61909','232','InterGroup Telecom SL'),
('Sierra Leone','61925','232','Mobitel'),
('Sierra Leone','61940','232','Datatel (SL) Ltd.'),
('Sierra Leone','61950','232','Datatel (SL) Ltd.'),
('Togo ','61501','228','Togo Telecom'),
('Togo ','61503','228','Moov Togo')
;
------------------------------------------------Inbound-----------------------------

create table Inbound_2019 (Month String,Country String,CountryCode String,NetworkCode String, OperatorName String,Inbound_MOC int,Inbound_MTC int) ENGINE = Memory;
--drop table Inbound_2019
insert into Inbound_2019

select Month,
       Country,
       CountryCode,
       NetworkCode,
       OperatorName,
       Inbound_MOC,
       Inbound_MTC
from (

         select Month, NetworkCode, sum(Inbound_MOC) Inbound_MOC, sum(Inbound_MTC) Inbound_MTC
         from (
               select toMonth(eventTimeStamp)     Month,
                      substring(servedIMSI, 1, 5) NetworkCode,
                      case
                          when type = ('MO_CALL_RECORD') then sum(callDuration)
                          else 0 end as           Inbound_MOC,
                      case
                          when type = ('MT_CALL_RECORD') then sum(callDuration)
                          else 0 end as           Inbound_MTC
               from zte
               where type in ('MT_CALL_RECORD', 'MO_CALL_RECORD')
                 and servedIMSI not like ('61807%')
                 and toYear(eventTimeStamp) = (:year)
--                  and toMonth(eventTimeStamp) = (:month)
               group by Month, NetworkCode, type
                  )
         group by Month, NetworkCode

         ) any
         left join
     (

        select Country, NetworkCode, CountryCode, OperatorName from CountryOperatorsCode

         ) using NetworkCode
where Country <> ''
order by Month, Country
;

-- select Country,OperatorName from Inbound_2019 group by Country,OperatorName

------------------------------------------Outbound----------------------------

create table Outbound_2019 (Month String,Country String,CountryCode String, Outbound_MOC int,Outbound_MTC int) ENGINE = Memory;

insert into Outbound_2019

select Month,
       Country,
       CountryCode,
       Outbound_MOC,
       Outbound_MTC
from (
         select Month, CountryCode, sum(Outbound_MOC) Outbound_MOC, sum(Outbound_MTC) Outbound_MTC
         from (
               select toMonth(eventTimeStamp)        Month,
                      substring(roamingNumber, 5, 3) CountryCode,
                      case
                          when callingNumber like ('%777777077') then sum(callDuration)
                          else 0 end as              Outbound_MOC,
                      case
                          when callingNumber not like ('%777777077') then sum(callDuration)
                          else 0 end as              Outbound_MTC
               from zte
               where type in ('ROAM_RECORD')
                 and toYear(eventTimeStamp) = (:year)
--                  and toMonth(eventTimeStamp) = (:month)
               group by Month, CountryCode, callingNumber
                  )group by  CountryCode,Month --order by Month, CountryCode
         ) any
         left join
     (
         select Country, /*NetworkCode,*/ CountryCode from CountryOperatorsCode group by Country, /*NetworkCode,*/ CountryCode

         )using CountryCode
where Country <> ''
group by Country, CountryCode,Month,Outbound_MOC,Outbound_MTC
order by Month, Country

-- select * from Outbound_2019

;

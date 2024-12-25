
-------------- Orange Number testing

select  callReference
        ,answerTime
        ,substring(servedMSISDN,3) calling_Number
        ,case   when substring(calledNumber,3,1) = '0' and substring(calledNumber,3,2) <> '00'
                then '231' || '' || substring(calledNumber,4)
                when substring(calledNumber,3,2) = '00'
                then substring(calledNumber,5)
                when substring(calledNumber,1,2) in ('18') and substring(calledNumber,3,2) in ('77','88','55')
                then '231' || '' || substring(calledNumber,3)
                else substring(calledNumber,3)
                end as called_Number
--         ,roamingNumber
        ,callDuration
        ,incomingTKGPName
        ,outgoingTKGPName
from    zte
where   type = 'MO_CALL_RECORD'
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
        and calling_Number not like '23177%'
limit 500
;

select  callReference
        ,answerTime
        ,case   when substring(callingNumber,1,2) = '12' and substring(callingNumber,3,1) = '0'
                then '231' || '' || substring(callingNumber,6)
                when substring(callingNumber,1,2) = '12' and substring(callingNumber,3,1) <> '0'
                then '231' || '' || substring(callingNumber,5)
                when substring(callingNumber,1,2) in ('10','11') and substring(callingNumber,5,2) = '00'
                then substring(callingNumber,7)
                else substring(callingNumber,5)
                end as calling_Number
        ,substring(servedMSISDN,3) called_Number
--         ,roamingNumber
        ,callDuration
        ,incomingTKGPName
        ,outgoingTKGPName
from    zte
where   type = 'MT_CALL_RECORD'
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
limit 500

----------- -----------------------------------------------------------------------------------

select callReference,ref1,ref2
from(
        select distinct callReference,count() ref1 from zte
        where   type in --('MT_CALL_RECORD')
                ('MO_CALL_RECORD',
                'MT_CALL_RECORD',
                'INC_GATEWAY_RECORD',
                'OUT_GATEWAY_RECORD',
                'MCF_CALL_RECORD',
                'ROAM_RECORD')
            and eventTimeStamp >= toDateTime(:from_v)
            and eventTimeStamp < toDateTime(:to_v)
        group by callReference
    ) any left join
    (
        select distinct callReference,count() ref2
        from zte
        where type in ('MO_CALL_RECORD')
          and eventTimeStamp >= toDateTime(:from_v)
          and eventTimeStamp < toDateTime(:to_v)
        group by callReference
        )using callReference
limit 500;


select   substring(servedMSISDN,3,3) prefix
        ,substring(callingNumber,5,3) prefix1
        ,/*substring(calling_Number,5,3) prefix2
        ,*/type,callReference,answerTime
--         ,case   when    (case when type in ('MO_CALL_RECORD') then servedMSISDN else callingNumber end) like '19231%' then 'Nat'
--                 when    (case when type in ('MO_CALL_RECORD') then servedMSISDN else callingNumber end) like '1900231%' then 'Nat'
--                 when    (case when type in ('MO_CALL_RECORD') then servedMSISDN else callingNumber end) like '19231%' then 'Nat'
--
--
--             as calling_Number
--         ,case when type in ('MT_CALL_RECORD','ROAM_RECORD') then servedMSISDN else calledNumber end as called_Number
        ,servedMSISDN
        ,callingNumber
        ,calledNumber
        ,roamingNumber
        ,callDuration
        ,incomingTKGPName
        ,outgoingTKGPName
from    zte
where   type in ('ROAM_RECORD')
--         ('MO_CALL_RECORD',
--         'MT_CALL_RECORD',
--         'INC_GATEWAY_RECORD',
--         'OUT_GATEWAY_RECORD',
--         'MCF_CALL_RECORD',
--         'ROAM_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
--         and outgoingTKGPName in
--                 ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
--         and incomingTKGPName not in ('RBT_SERV1','RBT_SERV2')
--         and outgoingTKGPName not in ('RBT_SERV1','RBT_SERV2')
        and callDuration > 0
--         and prefix not in ('231')
--         and length(calledNumber) > 6
--         and calling_Number not like '1A70000040'
--         and substring(prefix,1,2) in ('19')
--         and prefix1  in ('231')--,'08','05','06','81')
--         and incomingTKGPName <> ''
--         and prefix2 not in ('231')--,'199','0A','08')
order by answerTime,callReference
limit 500;



select  substring(servedMSISDN,1,2) prefix
        ,substring(servedMSISDN,3,3) prefix1
--         ,substring(connectedNumber,5,3) prefix2
        ,count()
from    zte
where   type in ('MO_CALL_RECORD',
        'MT_CALL_RECORD'/*,
        'INC_GATEWAY_RECORD',
        'OUT_GATEWAY_RECORD',
        'MCF_CALL_RECORD',
        'ROAM_RECORD'*/)
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and prefix1 not like '231'
--         and incomingTKGPName not in ('RBT_SERV1','RBT_SERV2')
--         and outgoingTKGPName not in ('RBT_SERV1','RBT_SERV2')
        and callDuration > 0
--         and substring(prefix,1,2) in ('19')
group by prefix,prefix1--,prefix2
order by prefix1
;

----------------------------------------------------------------------------------------------------------

select   substring(calling_Number,1,2) prefix
        ,substring(calling_Number,3,2) prefix1
        ,substring(calling_Number,5,3) prefix2
        ,type--,callReference,answerTime
        ,case   when type in ('MO_CALL_RECORD') then substring(servedMSISDN,3)
                when substring(callingNumber,1,2) = '12' and substring(callingNumber,3,1) = '0'
                then '231' || '' || substring(callingNumber,6)
                when substring(callingNumber,1,2) = '12' and substring(callingNumber,3,1) <> '0'
                then '231' || '' || substring(callingNumber,5)
                when substring(callingNumber,1,2) in ('10','11') and substring(callingNumber,5,2) = '00'
                then substring(callingNumber,7)
                when substring(callingNumber,1,2) in ('10','11') and substring(callingNumber,5,1) in ('0','D')
                then substring(callingNumber,5)
                when substring(callingNumber,1,2) in ('18','19') and substring(callingNumber,5,2) = '00'
                then substring(callingNumber,7)
                when substring(callingNumber,1,2) in ('18','19') and substring(callingNumber,5,1) in ('0','D')
                then substring(callingNumber,5)
                else
                    (case   when substring(callingNumber,1,2) in ('10','11','12')
                            then substring(callingNumber,5)
                            else substring(callingNumber,3)
                                end)
                end as calling_Number
        ,case when type in ('MT_CALL_RECORD','ROAM_RECORD') then servedMSISDN else calledNumber end as called_Number
        ,servedMSISDN
        ,callingNumber
        ,calledNumber
        ,roamingNumber
        ,callDuration
        ,incomingTKGPName
        ,outgoingTKGPName
from    zte
where   type in ('MO_CALL_RECORD',
        'MT_CALL_RECORD',
        'INC_GATEWAY_RECORD',
        'OUT_GATEWAY_RECORD',
        'MCF_CALL_RECORD',
        'ROAM_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and incomingTKGPName not in ('RBT_SERV1','RBT_SERV2')
        and outgoingTKGPName not in ('RBT_SERV1','RBT_SERV2')
        and callDuration > 0
--         and length(calledNumber) > 6
--         and calling_Number not like '1A70000040'
        and substring(prefix,1,2) in ('12')
--         and prefix1  in ('07','08','05','06')--,'81')
--         and incomingTKGPName <> ''
--         and prefix2 not in ('231')--,'199','0A','08')
-- order by answerTime,callReference
limit 500;



select  substring(callingNumber,1,4) prefix
--         ,substring(callingNumber,3,2) prefix1
--         ,substring(connectedNumber,5,3) prefix2
        ,count()
from    zte
where   type in (/*'MO_CALL_RECORD',*/
        'MT_CALL_RECORD',
        'INC_GATEWAY_RECORD',
        'OUT_GATEWAY_RECORD',
        'MCF_CALL_RECORD',
        'ROAM_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and incomingTKGPName not in ('RBT_SERV1','RBT_SERV2')
        and outgoingTKGPName not in ('RBT_SERV1','RBT_SERV2')
        and callDuration > 0
--         and substring(prefix,1,2) in ('19')
group by prefix--,prefix1,prefix2
order by prefix1
;



--         ('MO_CALL_RECORD',
--         'MT_CALL_RECORD',
--         'INC_GATEWAY_RECORD',
--         'OUT_GATEWAY_RECORD',
--         'MCF_CALL_RECORD',
--         'ROAM_RECORD')

;1834620,1853806.1166666667
select /*incomingTKGP_Name,*/sum(callDuration)/60 callDuration,count()
from (
      select answerTime
           , callReference
           , /*max(callDuration) */callDuration
           , topK(type)             CallType
           , topK(servedMSISDN)     served_MSISDN
           , topK(callingNumber)    calling_Number
           , topK(calledNumber)     called_Number
--      , translatedNumber
--      , topK(connectedNumber)
--      , topK(roamingNumber)
--            , topK(incomingTKGPName) incomingTKGP_Name
--            , outgoingTKGPName outgoingTKGP_Name
      from zte
      where type in ('OUT_GATEWAY_RECORD', 'MT_CALL_RECORD','INC_GATEWAY_RECORD')
--                     ('MO_CALL_RECORD',
--                         'MT_CALL_RECORD',
--                         'INC_GATEWAY_RECORD',
--                         'OUT_GATEWAY_RECORD',
--                         'MCF_CALL_RECORD',
--                         'ROAM_RECORD')
      and incomingTKGPName in
            ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2','OLIB_SBC_OFR')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
--         and (servedMSISDN like (:phoneNumber) or callingNumber like (:phoneNumber)
--                  or calledNumber like (:phoneNumber) or translatedNumber like (:phoneNumber) or routingNumber like (:phoneNumber))
      group by answerTime, callReference, callDuration--,outgoingTKGP_Name
-- order by answerTime
         )--group by outgoingTKGP_Name
limit 500;

select  substring(servedMSISDN,1,2) prefix
--         ,count()
from    zte
where   type in ('MO_CALL_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
group by prefix
order by prefix
;
prefix
19
1A
18
1C
prefix,prefix1
1A,05
1A,12
1A,13
1A,17

;

select   substring(calledNumber,1,2) prefix
        ,substring(calledNumber,3,2) prefix1
        ,substring(calledNumber,3,5) prefix2
        ,servedMSISDN
        ,substring(servedMSISDN,3) calling_Number
        ,callingNumber
        ,calledNumber
        ,case   when substring(calledNumber,3,1) = '0' and substring(calledNumber,3,2) <> '00'
                then '231' || '' || substring(calledNumber,4)
                when substring(calledNumber,3,2) = '00'
                then substring(calledNumber,5)
                when substring(calledNumber,1,2) in ('18') and substring(calledNumber,3,2) in ('77','88','55')
                then '231' || '' || substring(calledNumber,3)
                else substring(calledNumber,3)
                end as called_Number
        ,translatedNumber
        ,connectedNumber
        ,roamingNumber
        ,callDuration
        ,incomingTKGPName
        ,outgoingTKGPName
from    zte
where   type = 'MO_CALL_RECORD'
--         ('MO_CALL_RECORD',
--         'MT_CALL_RECORD',
--         'INC_GATEWAY_RECORD',
--         'OUT_GATEWAY_RECORD',
--         'MCF_CALL_RECORD',
--         'ROAM_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
--         and length(prefix2) > 4
--         and calledNumber not like '1A130%'
        and prefix  in ('19'/*,'18'*/)
--         and prefix1 in ('231')--,'07')
--         and incomingTKGPName <> ''
--         and prefix2 in ('00231'/*,'3A','0A','08'*/)
--         and prefix  not in ('19'/*,'18'*/)
--         and prefix1 not in ('12','13','17')--,'77','06')
--         and prefix2 not in ('00231')--,'88','55','07')
--         and prefix2 not in ('77','88')
limit 500;

select  callReference
        ,answerTime
        ,substring(servedMSISDN,3) calling_Number
        , called_Number
        ,roamingNumber
        ,callDuration
        ,incomingTKGPName
        ,outgoingTKGPName
from    zte
where   type = 'MO_CALL_RECORD'
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
;
----------------  Orange number mapping

select     substring(servedMSISDN,3) calling_Number
          ,case when substring(calledNumber,3,2) in ('05','06','07','08')
                then '231' || '' || substring(calledNumber,4)
                else (case when substring(calledNumber,3,2) = '00'
                            then substring(calledNumber,5)
                            else (case when substring(calledNumber,3,2) = '77'
                                        then '231' || '' || substring(calledNumber,3)
                                        else substring(calledNumber,3)
                                        end)
                            end)
                end as called_Number
from    zte
where   type = 'MO_CALL_RECORD'
--         ('MO_CALL_RECORD',
--         'MT_CALL_RECORD',
--         'INC_GATEWAY_RECORD',
--         'OUT_GATEWAY_RECORD',
--         'MCF_CALL_RECORD',
--         'ROAM_RECORD')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
--         and calledNumber not like '1A130%'
--         and length(calledNumber) > 5
limit 500;


/*
                ,case when type = 'MO_CALL_RECORD'
                then substring(servedMSISDN,3)
                else servedMSISDN
                end as calling_Number
        ,case when substring(calledNumber,3,2) in ('05','06','07','08')
                then '231' || '' || substring(calledNumber,4)
                else (case when substring(calledNumber,3,2) = '00'
                            then substring(calledNumber,5)
                            else (case when substring(calledNumber,3,2) = '77'
                                        then '231' || '' || substring(calledNumber,3)
                                        else substring(calledNumber,3)
                                        end)
                            end)
                end as called_Number
*/
-----------= Orange type List

-- select distinct type from zte

type not in ('COMMON_EQUIP_RECORD')

type
('MO_CALL_RECORD',
'MT_CALL_RECORD',
'INC_GATEWAY_RECORD',
'OUT_GATEWAY_RECORD',
'MCF_CALL_RECORD',
'ROAM_RECORD')

COMMON_EQUIP_RECORD
HLR_INT_RECORD
USSD_RECORD
MO_SMS_RECORD
MT_SMS_RECORD
SS_ACTION_RECORD
MO_LCS_RECORD
TERM_CAMEL_INT_RECORD

MO 222471511
MT 196193168

select callReference,answerTime,calling_Number,called_Number,callDuration,incomingTKGPName,outgoingTKGPName
;
select callReference,MOanswerTime,MOcalling_Number,MOcalled_Number,MOcallDuration,MOincomingTKGPName,MOoutgoingTKGPName
from (
    with
(

    select /*toYYYYMMDD(answerTime) Day,*/distinct callReference call_Reference
    from zte
    where type in
          ('MO_CALL_RECORD',
           'MT_CALL_RECORD'/*,
        'INC_GATEWAY_RECORD',
        'OUT_GATEWAY_RECORD',
        'MCF_CALL_RECORD',
        'ROAM_RECORD'*/)
      and eventTimeStamp >= toDateTime(:from_v)
      and eventTimeStamp < toDateTime(:to_v)
    ) as A /*any left join*/

         select callReference
              , answerTime MOanswerTime
              , substring(servedMSISDN, 3) MOcalling_Number
              , case
                    when substring(calledNumber, 3, 1) = '0' and substring(calledNumber, 3, 2) <> '00'
                        then '231' || '' || substring(calledNumber, 4)
                    when substring(calledNumber, 3, 2) = '00'
                        then substring(calledNumber, 5)
                    when substring(calledNumber, 1, 2) in ('18') and substring(calledNumber, 3, 2) in ('77', '88', '55')
                        then '231' || '' || substring(calledNumber, 3)
                    else substring(calledNumber, 3)
             end as                        MOcalled_Number
--         ,roamingNumber
              , callDuration MOcallDuration
              , incomingTKGPName MOincomingTKGPName
              , outgoingTKGPName MOoutgoingTKGPName
         from zte
         where type = 'MO_CALL_RECORD'
           and eventTimeStamp >= toDateTime(:from_v)
           and eventTimeStamp < toDateTime(:to_v)
           and callDuration > 0
            and callReference in call_Reference limit 10
         )using callReference
limit 500;


;

from (
      select /*toYYYYMMDD(answerTime) Day*/,callReference
           , answerTime MOanswerTime
           , substring(servedMSISDN, 3) MOcalling_Number
           , case
                 when substring(calledNumber, 3, 1) = '0' and substring(calledNumber, 3, 2) <> '00'
                     then '231' || '' || substring(calledNumber, 4)
                 when substring(calledNumber, 3, 2) = '00'
                     then substring(calledNumber, 5)
                 when substring(calledNumber, 1, 2) in ('18') and substring(calledNumber, 3, 2) in ('77', '88', '55')
                     then '231' || '' || substring(calledNumber, 3)
                 else substring(calledNumber, 3)
          end as                        MOcalled_Number
--         ,roamingNumber
           , callDuration MOcallDuration
           , incomingTKGPName MOincomingTKGPName
           , outgoingTKGPName MOoutgoingTKGPName
      from zte
      where type = 'MO_CALL_RECORD'
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0


      select callReference
           , answerTime
           , case
                 when substring(callingNumber, 1, 2) = '12' and substring(callingNumber, 3, 1) = '0'
                     then '231' || '' || substring(callingNumber, 6)
                 when substring(callingNumber, 1, 2) = '12' and substring(callingNumber, 3, 1) <> '0'
                     then '231' || '' || substring(callingNumber, 5)
                 when substring(callingNumber, 1, 2) in ('10', '11') and substring(callingNumber, 5, 2) = '00'
                     then substring(callingNumber, 7)
                 else substring(callingNumber, 5)
          end as                        calling_Number
           , substring(servedMSISDN, 3) called_Number
--         ,roamingNumber
           , callDuration
           , incomingTKGPName
           , outgoingTKGPName
      from zte
      where type = 'MT_CALL_RECORD'
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
         )
group by callReference,answerTime,calling_Number,called_Number,callDuration,incomingTKGPName,outgoingTKGPName
;
create table CountryCode (Direction String,CountryCode String) ENGINE = Memory;

insert into CountryCode
values ('Incoming','221'),('Incoming','224'),('Incoming','225'),('Incoming','228'),('Incoming','229'),('Incoming','232')
        ,('Outgoing','221'),('Outgoing','224'),('Outgoing','225'),('Outgoing','228'),('Outgoing','229'),('Outgoing','232')
        ,('Incoming','Other'),('Incoming','Unknown All'),('Outgoing','Other'),('Outgoing','Unknown All')
;

select  callReference,type,answerTime,callDuration,servedMSISDN,callingNumber,calledNumber,roamingNumber,incomingTKGPName,outgoingTKGPName
;
select incomingTKGPName,sum(callDuration)
from    zte
where   type in --('OUT_GATEWAY_RECORD','MO_CALL_RECORD','ROAM_RECORD')
          ('MO_CALL_RECORD',
           'MT_CALL_RECORD',
        'INC_GATEWAY_RECORD',
        'OUT_GATEWAY_RECORD',
        'MCF_CALL_RECORD',
        'ROAM_RECORD')
--         and outgoingTKGPName in
--             ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and callDuration > 0
group by answerTime,callReference,incomingTKGPName
;


-------------------------------------------------------------------------------------------------------------------

select  toYYYYMM(eventTimeStamp) Month
        ,case when substring(servedMSISDN,3,3) in ('221','224','225','226','228','229','232') then substring(servedMSISDN,3,3) else 'Other' end as RoamCC
        ,case when (
         case when RoamCC = 'Other' then 'Other'
              when substring(calledNumber, 3, 1) = '0' and substring(calledNumber, 3, 2) <> '00'
                  then '231'
              when substring(calledNumber, 3, 2) = '00'
                  then substring(calledNumber, 5,3)
              when substring(calledNumber, 1, 2) in ('18') and substring(calledNumber, 3, 2) in ('77', '88', '55')
                  then '231'
              else substring(calledNumber, 3,3)
         end as CC) in ('221','224','225','226','228','229','232','231')
        then CC else 'Other'
        end    as                        called_Number
        ,sum(callDuration) call_Duration
        ,count()
from    zte
where   type in ('MO_CALL_RECORD'/*,
        'MT_CALL_RECORD'*/)
        and eventTimeStamp >= toDateTime(:from_v)
        and eventTimeStamp < toDateTime(:to_v)
        and substring(servedMSISDN,3,3) not like '231'
        and callDuration > 0
--         and substring(prefix,1,2) in ('19')
group by Month,RoamCC,called_Number
order by Month,RoamCC
;


221
224
225
226
228
229
232

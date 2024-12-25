----Orange----

select 'International Outgoing', round(sum(callDuration) / 60) as minuts
from s_zte
where type = 'MO_CALL_RECORD'
  and outgoingTKGPName in
      ('BICS-4194', 'OCI_ASSB', 'OCI_KM4', 'Orange-12490', 'BICS-4193', 'Orange-12482', 'BARAK SIP 2')
  and eventTimeStamp between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select 'International Incoming', round(sum(callDuration) / 60)
from s_zte
where type = 'MT_CALL_RECORD'
  and incomingTKGPName in
      ('BARAK SIP 2', 'BARAK SIP 1', 'BICS-4194', 'BICS-4193', 'OCI_KM4', 'OCI_ASSB', 'Orange-12482', 'Orange-12490')
  and eventTimeStamp between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select 'Incoming from MTN', round(sum(callDuration) / 60)
from s_zte
where type = 'MT_CALL_RECORD'
  and incomingTKGPName in ('Comium', 'LoneStar')
  and eventTimeStamp between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select 'Outgoing to MTN', round(sum(callDuration) / 60)
from s_zte
where type = 'MO_CALL_RECORD'
  and outgoingTKGPName in ('Comium', 'LoneStar')
  and eventTimeStamp between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select 'On Net', round(sum(callDuration) / 60)
from s_zte
where type = 'MO_CALL_RECORD'
  and outgoingTKGPName in ('', 'IVR1_SERV1', 'IVR_OBD_SERV2', 'CALL_CENTER', 'ISUP-IVR-A', 'ISUP-IVR-C', 'ISUP-IVR-D',
                           'ISUP-IVR-B', 'RBT_SERV1', 'RBT_SERV2', 'VOIPE_PBX_SIP', 'LEC_PBX', 'US AMBASY')
  and eventTimeStamp between '2019-04-14 17:00:00' and '2019-04-15 17:00:00';


select servedMSISDN, destinationNumber
from kafka.s_zte
where type = 'MO_SMS_RECORD'
  and destinationNumber like '18%' and destinationNumber not like '18231%' and length(destinationNumber) > 12
--  and destinationNumber not like '19231%'
limit 100;
select destinationNumber
from kafka.s_zte
where type = 'MO_SMS_RECORD'
  and destinationNumber like '18%';




18 - Local
19 - Internation format may be local and international
1E - 4 SMSs (Not relevant)
0E - short numnber 11 SMS (Not relevant)
08 - short numebr 2 SMSs (Not relevant)


----MTN----

select 'Incoming calls from International'                  desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from s_ericsson
where originForCharging = '1'
  and incomingRoute in ('ZURI', 'ZUR2I', 'BRFI', 'BRF2I', 'GENI', 'GEN2I', 'BRGI', 'BRG2I')
  and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select 'Outgoing calls to International'                    desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from s_ericsson -- 619002
where type in ('M_S_ORIGINATING', 'TRANSIT')
  and outgoingRoute in ('BRGO', 'GENO', 'BRFO', 'ZURO')
  and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
union all
select 'On net'                                             desc,
       round(sum(toUnixTimestamp(chargeableDuration)) / 60) duration
from s_ericsson -- 619002
where type in ('M_S_ORIGINATING', 'TRANSIT')
  and outgoingRoute in ('DJAMO1', )
  and EventDate between '2019-04-14 17:00:00' and '2019-04-15 17:00:00'
;

select callingPartyNumber, calledPartyNumber, translatedNumber
from s_ericsson
where type = 'M_S_ORIGINATING'
  and outgoingRoute = 'MBC1O'
limit 100;

- Inte

GRI
ISON1O
CELLCO
ZURO
GENO
BRGO
BRFO

select 'Offnet', count()
from kafka.s_zte
where (
    destinationNumber like '1823188%'
           or destinationNumber like '1823155%'
           or destinationNumber like '1923188%'
           or destinationNumber like '1923155%'
           or destinationNumber  like '18088%'
           or destinationNumber  like '18055%'
    )
union all
select 'On net', count()
from kafka.s_zte
where (
    destinationNumber like '1823177%'
           or destinationNumber like '1923177%'
           or destinationNumber  like '18077%'
    )

;
with correct_IP as (
    select
         rci.customer_id
    from rm.rmo_company_info rci
    where length(rci.company_inn) = '12'
       and rci.company_kpp is null
          ),
     correct_UL as (
    select
         rci.customer_id
    from rm.rmo_company_info rci
    join rm.rmo_contracts rc on rci.customer_id = rc.customer_id
    where length(rci.company_inn) = '10'
      and length(rci.company_kpp) = '9'
           )
select rrc.ntk_contract_number as contract,
       rrci.company_inn as inn,
       rrci.company_kpp as kpp,
       l.manager_id,
       case when (length(rrci.company_inn) in (10, 12) 
            and (rrci.company_inn !~ '(\d)\1{6}'))
            then 'Верно'
            else 'Неверный ИНН'
       end as inn_check,
       case when (length(rrci.company_inn) = 12 
                 and rrci.company_kpp is not null) 
            then 'Не должно быть КПП'
            when (length(rrci.company_inn) = 10 
                 and  rrci.company_kpp is null)
            then 'Не прописан КПП'
            when (length(rrci.company_inn) = 10 
                 and length(rrci.company_kpp) != 9)
            then 'Неверная длина КПП'
            when rrci.legal_form_code != '11'  ---нужно ли делать такую проверку, если инн неверный/не заполнен и это не ип
                 and length(rrci.company_kpp) != 9
            then 'Неверный КПП'
       end as kpp_check
       
from rm.rmo_company_info rrci
left join rm.rmo_contracts rrc on rrci.customer_id = rrc.customer_id
left join v083.lc l on rrc.ntk_contract_number = l.contract_ident
where not exists (select 1
                  from correct_IP
                  where correct_IP.customer_id = rrc.customer_id)
      and not exists (select 1
                      from correct_UL 
                      where correct_UL.customer_id = rrc.customer_id)
and rrc.provider != 'erth'                    
and l.saldo != '0';
select 
       l.contract_ident as договор,
       rci.company_inn as inn,
       rci.company_kpp as kpp,
  case when (length(rci.company_inn) in (10, 12) 
            and (rci.company_inn !~ '(\d)\1{6}'))
            then 'Верно'
            else 'Неверный ИНН'
       end as inn_check,
       case when (length(rci.company_inn) = 12 
                 and rci.company_kpp is not null) 
            then 'Не должно быть КПП'
            when (rci.company_kpp ~ '(\d)\1{5}')
            then 'Неверный КПП'
            when (length(rci.company_inn) = 12 
                 and rci.company_kpp is null) 
            then 'Верно'
            when (length(rci.company_inn) = 10 
                 and  rci.company_kpp is null)
            then 'Не прописан КПП'
            when (length(rci.company_inn) = 10 
                 and length(rci.company_kpp) != 9)
            then 'Неверная длина КПП'
            when (length(rci.company_inn) = 10 
                 and length(rci.company_kpp) = 9)
            then 'Верно'
            when rci.legal_form_code != '11'  ---нужно ли делать такую проверку, если инн неверный/не заполнен и это не ип
                 and length(rci.company_kpp) != 9
            then 'Неверный КПП, ИП'
       end as kpp_check
from rm.rmo_company_info rci
left join rm.rmo_contracts rc on rci.customer_id = rc.customer_id
left join v083.lc l on rc.customer_id = l.customer_id
where 
  rc.provider != 'erth'                   
  and l.saldo != '0';      
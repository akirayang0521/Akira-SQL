select item_id, item_des,
	   SUM(case when shipped_date between '2023-4-1' and '2023-6-30' then quantity else 0 end)/3 as S3,
	   SUM(case when shipped_date between '2023-1-1' and '2023-6-30' then quantity else 0 end)/6 as S6,
	   SUM(case when shipped_date between '2022-7-1' and '2023-6-30' then quantity else 0 end)/6 as S12,
	   SUM(case when shipped_date between '2021-7-1' and '2023-6-30' then quantity else 0 end)/6 as S24
from [SDM].[dbo].[FACT_SALESDETAIL_HISTORY_BP] t1
right join [SDM].[dbo].[sales0717] t2 on t1.ITEM_DES=t2.[Item Desc]
where shipped_date >='2021-7-1' and company_id='00200' 
GROUP BY item_id, item_des
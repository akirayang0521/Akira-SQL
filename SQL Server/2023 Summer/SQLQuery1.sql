 declare @jpyexchangerate float

 set @jpyexchangerate=(SELECT [RATE_CNY] FROM [SDM].[dbo].[LU_EXCRATE] WHERE CURRENCY ='JPY')
 --print @jpyexchangerate

select SFA_ACID
      ,SFA_ACCN
	  ,ISNULL([2019]/@jpyexchangerate,0) AS FY19
	  ,ISNULL([2020]/@jpyexchangerate,0) AS FY20
	  ,ISNULL([2021]/@jpyexchangerate,0) AS FY21
	  ,ISNULL([2022]/@jpyexchangerate,0) AS FY22
	  ,(case when ISNULL([2019]/@jpyexchangerate,0)<500000 
		      AND ISNULL([2020]/@jpyexchangerate,0)<500000
			  AND ISNULL([2021]/@jpyexchangerate,0)<500000
			  AND ISNULL([2022]/@jpyexchangerate,0)<500000 THEN 'A1'

			 when ISNULL([2019]/@jpyexchangerate,0)>500000 
		      AND ISNULL([2020]/@jpyexchangerate,0)=0
			  AND ISNULL([2021]/@jpyexchangerate,0)=0
			  AND ISNULL([2022]/@jpyexchangerate,0)=0 THEN 'A2'

             when ISNULL([2019]/@jpyexchangerate,0)>500000 
		      AND ISNULL([2020]/@jpyexchangerate,0)>1
			  AND ISNULL([2021]/@jpyexchangerate,0)=0
			  AND ISNULL([2022]/@jpyexchangerate,0)=0 THEN 'B1'

             when ISNULL([2019]/@jpyexchangerate,0)=0 
		      AND ISNULL([2020]/@jpyexchangerate,0)>500000
			  AND ISNULL([2021]/@jpyexchangerate,0)=0
			  AND ISNULL([2022]/@jpyexchangerate,0)=0 THEN 'B2'

             when ISNULL([2019]/@jpyexchangerate,0)>500000 
		      AND ISNULL([2020]/@jpyexchangerate,0)=0
			  AND ISNULL([2021]/@jpyexchangerate,0)>1
			  AND ISNULL([2022]/@jpyexchangerate,0)=0 THEN 'C1'

             when ISNULL([2019]/@jpyexchangerate,0)>500000 
		      AND ISNULL([2020]/@jpyexchangerate,0)=0
			  AND ISNULL([2021]/@jpyexchangerate,0)=0
			  AND ISNULL([2022]/@jpyexchangerate,0)>1 THEN 'C2'

             when ISNULL([2019]/@jpyexchangerate,0)=0 
		      AND ISNULL([2020]/@jpyexchangerate,0)>500000
			  AND ISNULL([2021]/@jpyexchangerate,0)>1
			  AND ISNULL([2022]/@jpyexchangerate,0)=0 THEN 'C3'

             when ISNULL([2019]/@jpyexchangerate,0)=0 
		      AND ISNULL([2020]/@jpyexchangerate,0)>500000
			  AND ISNULL([2021]/@jpyexchangerate,0)=0
			  AND ISNULL([2022]/@jpyexchangerate,0)>1 THEN 'C4'

             when ISNULL([2019]/@jpyexchangerate,0)=0 
		      AND ISNULL([2020]/@jpyexchangerate,0)=0
			  AND ISNULL([2021]/@jpyexchangerate,0)>500000
			  AND ISNULL([2022]/@jpyexchangerate,0)=0 THEN 'C5'

             when ISNULL([2019]/@jpyexchangerate,0)=0 
		      AND ISNULL([2020]/@jpyexchangerate,0)=0
			  AND ISNULL([2021]/@jpyexchangerate,0)=0
			  AND ISNULL([2022]/@jpyexchangerate,0)>500000 THEN 'D1'

             when ISNULL([2019]/@jpyexchangerate,0)=0 
		      AND ISNULL([2020]/@jpyexchangerate,0)>1
			  AND ISNULL([2021]/@jpyexchangerate,0)=0
			  AND ISNULL([2022]/@jpyexchangerate,0)=0 THEN 'C6'

             when ISNULL([2019]/@jpyexchangerate,0)=0 
		      AND ISNULL([2020]/@jpyexchangerate,0)=0
			  AND ISNULL([2021]/@jpyexchangerate,0)>1
			  AND ISNULL([2022]/@jpyexchangerate,0)=0 THEN 'C7'
		 end) as customer_type

from(
SELECT [SFA_ACID]
      ,[SFA_ACCN]
	  ,(case when SHIPPED_DATE between '2019-04-01'and '2020-03-31' then '2019'
	         when SHIPPED_DATE between '2020-04-01'and '2021-03-31' then '2020'
			 when SHIPPED_DATE between '2021-04-01'and '2022-03-31' then '2021'
			 when SHIPPED_DATE between '2022-04-01'and '2023-03-31' then '2022'
			 end) as FY
	 ,sum(ext_amt) as AMT
  FROM [SDM].[dbo].[FACT_SALESDETAIL_HISTORY_BP] t1
  inner join lu_item t2 on t1.item_id=t2.item_id 
  where [SHIPPED_DATE] between '2019-04-01'and '2023-03-31'
    and LEFT(segment_id,4) in ('SECA','SECB','SECD','SEDA','SEDB','SVWE','SVWF','SVWG')
     or LEFT(sp_no,2) in ('61','96','91')
  GROUP BY [SFA_ACID]
      ,[SFA_ACCN]
	  ,(case when SHIPPED_DATE between '2019-04-01'and '2020-03-31' then '2019'
	         when SHIPPED_DATE between '2020-04-01'and '2021-03-31' then '2020'
			 when SHIPPED_DATE between '2021-04-01'and '2022-03-31' then '2021'
			 when SHIPPED_DATE between '2022-04-01'and '2023-03-31' then '2022'
			 end) ) as t3
PIVOT
(avg(AMT) FOR FY IN ([2019],[2020],[2021],[2022])) AS p
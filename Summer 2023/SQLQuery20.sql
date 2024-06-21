select [ITEM_ID],[ITEM_DES],[ABBR]
	  ,sum(count1) as FY21
	  ,sum(count2) as FY22
	  ,sum(count3) as FY23
from (
	select [ITEM_DES],[ITEM_ID],[ABBR],sum([QUANTITY]) as count1,0 as count2,0 as count3 
	from [SDM].[dbo].[FACT_SALESDETAIL_ALL_HISTORY_BP]
	where ITEM_ID in ('CP1W0192R','CP1W9001H','CP1W9002F','CP1W9004B','CP1W9005M')
		  and COMPANY_ID='00200' and ORDER_TYPE='CO' and [SHIPPED_DATE] between '2021-04-01'and '2022-03-31'
	group by [ITEM_DES],[ITEM_ID],[ABBR]
union all
	select [ITEM_DES],[ITEM_ID],[ABBR],0 as count1,sum([QUANTITY]) as count2,0 as count3
	from [SDM].[dbo].[FACT_SALESDETAIL_ALL_HISTORY_BP]
	where ITEM_ID in ('CP1W0192R','CP1W9001H','CP1W9002F','CP1W9004B','CP1W9005M')
		  and COMPANY_ID='00200' and ORDER_TYPE='CO' and [SHIPPED_DATE] between '2022-04-01'and '2023-03-31'
	group by [ITEM_DES],[ITEM_ID],[ABBR]
union all
	select [ITEM_DES],[ITEM_ID],[ABBR],0 as count1,0 as count2,sum([QUANTITY]) as count3 
	from [SDM].[dbo].[FACT_SALESDETAIL_ALL_HISTORY_BP]
	where ITEM_ID in ('CP1W0192R','CP1W9001H','CP1W9002F','CP1W9004B','CP1W9005M')
		  and COMPANY_ID='00200' and ORDER_TYPE='CO' and [SHIPPED_DATE] between '2023-04-01'and '2023-07-31'
	group by [ITEM_DES],[ITEM_ID],[ABBR]
) t group by [ITEM_DES],[ITEM_ID],[ABBR]
	order by [ITEM_DES],[ITEM_ID],[ABBR]

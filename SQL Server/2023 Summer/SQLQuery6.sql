select (case when 注力细分='Renewable Energy (PV)' then '半导体'
             when isnull(sfaid,'')<>'' then '其他G10K'
	         else 'G10K以外'
			 end
	   )'行标签'
	   ,yymm
	   ,sum(ext_amt) as total_amt 
from(
select(case when SOLD_TO IN ('22013733','41017994','45374805') then 109924
	        when SOLD_TO IN ('44205155','41014677','45374147') then 109477 
            else acid 
            end
	  )acid
	  ,sold_to
	  ,year(trans_date)*100+month(trans_date) as yymm
	  ,ext_amt
from fact_orderdetail_all_history t1 inner join lu_section t2 on t1.section_id=t2.section_id 
                                     inner join lu_sfa on sp_no=oaspno
where section_desc1 not like 'aoi%' and year(trans_date)*100+month(trans_date)>='202206') t3
left outer join [SDM].[dbo].[FACT_BP_TARGET_MAIN] on acid=sfaid
group by case when 注力细分='Renewable Energy (PV)' then '半导体'
              when isnull(sfaid,'')<>'' then '其他G10K'
	          else 'G10K以外'
			  end,yymm
order by case when 注力细分='Renewable Energy (PV)' then '半导体'
              when isnull(sfaid,'')<>'' then '其他G10K'
	          else 'G10K以外'
			  end,yymm
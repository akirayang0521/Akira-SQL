declare @lastmonth nvarchar(10)
declare @last2month nvarchar(10)
declare @SQL VARCHAR(8000)
set @lastmonth = year(dateadd(mm,-1,getdate()))*100+month(dateadd(mm,-1,getdate()))
set @last2month = year(dateadd(mm,-2,getdate()))*100+month(dateadd(mm,-2,getdate()))--'20230501'
set @SQL = 'SELECT'+' '+@lastmonth+' '+'as yymm,'+''''+'目前时点CO残Amt'+''' '+'as cact, sum(EXT_AMT) as amt'+'
into ##TEMP_OPENCO FROM snapshot.dbo.FACT_OPENCO_'+@lastmonth

if exists (select * from tempdb.dbo.sysobjects where id = object_id(N'tempdb..##TEMP_OPENCO')) drop table ##TEMP_OPENCO 

exec(@SQL) 

select * from ##TEMP_OPENCO
	union all
select @lastmonth as yymm, '目前时点Overdue Amt' as cact, sum(EXT_AMT) as amt
from [SDM].[dbo].[FACT_BACKLOG]
where year(REQUEST_DATE)*100+month(REQUEST_DATE)<@lastmonth
	union all
select @last2month as yymm, '本月Sales Order' as cact, sum(EXT_AMT) as amt
from [SDM].[dbo].[FACT_SALESDETAIL_HISTORY_BP]
where year(REQUEST_DATE)*100+month(REQUEST_DATE)<@last2month
	union all
select @last2month as yymm, '本月Cancel Order' as cact, sum(SDUORG*SDUPRC)/10000 as amt
from [SDM].[dbo].[RF4211]
where year([SDM].[dbo].CJULIAN(SDCNDJ))*100+month([SDM].[dbo].CJULIAN(SDCNDJ))<@lastmonth AND SDLTTR=980 AND SDDCTO IN ('C1','C2','C5','CA','CB','CO')
	union all
select @last2month as yymm, '未变动过的Overdue' as cact, sum(EXT_AMT) as amt
from [SDM].[dbo].[FACT_BACKLOG]
where year(REQUEST_DATE)*100+month(REQUEST_DATE)<@last2month and year(TRANS_DATE)*100+month(TRANS_DATE)<@lastmonth
	union all
select @last2month as yymm, '新增Overdue' as cact, sum(EXT_AMT) as amt
from [SDM].[dbo].[FACT_BACKLOG]
where year(REQUEST_DATE)*100+month(REQUEST_DATE)=@lastmonth




--select sum(count1) as '目前时点Overdue Amt'
--	  ,sum(count2) as '本月Sales Order' 
--	  ,sum(count3) as '本月Cancel Order'
--	  ,sum(count4) as '未变动过的Overdue'
--	  ,sum(count5) as '本月Request 延期Order'
--	  ,sum(count6) as '新增Overdue'
--from (
--	select EXT_AMT as count1, 0 as count2, 0 as count3, 0 as count4, 0 as count5, 0 as count6
--	from [SDM].[dbo].[FACT_BACKLOG]
--	where year(REQUEST_DATE)*100+month(REQUEST_DATE)<@lastmonth
--		union all
--	select 0 as count1, EXT_AMT as count2, 0 as count3, 0 as count4, 0 as count5, 0 as count6
--	from [SDM].[dbo].[FACT_SALESDETAIL_HISTORY_BP]
--	where year(REQUEST_DATE)*100+month(REQUEST_DATE)<@last2month
--		union all
--	select 0 as count1, 0 as count2, 0 as count3, EXT_AMT as count4, 0 as count5, 0 as count6
--	from [SDM].[dbo].[FACT_BACKLOG]
--	where year(REQUEST_DATE)*100+month(REQUEST_DATE)<@last2month and year(TRANS_DATE)*100+month(TRANS_DATE)<@lastmonth
--		union all
--	select 0 as count1, 0 as count2, 0 as count3, 0 as count4, 0 as count5, EXT_AMT as count6
--	from [SDM].[dbo].[FACT_BACKLOG]
--	where year(REQUEST_DATE)*100+month(REQUEST_DATE)=@lastmonth
--) t
DECLARE @calamonth int
DECLARE @last12month int
DECLARE @oezsalesamt decimal(36,2)
DECLARE @usdtocny float

set @last12month=year(dateadd(mm,-12,getdate()))*100+month(dateadd(mm,-12,getdate()))
set @calamonth=year(dateadd(mm,-1,getdate()))*100+month(dateadd(mm,-1,getdate()))
set @oezsalesamt=(select sum(ext_amt) from fact_salesdetail_history_bp where company_id='00200' and WAREHOUSE_ID not in ('ASU','ACB') and order_type in ('CO','CR') and year(shipped_date)*100+month(shipped_date)>=@last12month)
set @usdtocny=(SELECT  [CXCRRD] FROM SDMDOL.[APPDB].[dbo].[IP_EXCHANGERATE] WHERE CXCRCD='CNY' AND CXCRDC='USD')

 EXEC rp_FACT_standarditemdetail--  @calamonth,@last12month
--print @last12month
--print @calamonth
--print @oezsalesamt
--print @usdtocny

truncate table fact_rop_t1_salesbytype
insert into fact_rop_t1_salesbytype
select case when type='ISD' and aban85='20710190' then 'ISD2' when type='' then 'OTH' ELSE TYPE END AS TYPE,sum(ext_amt) as salesamt,getdate() as CRDA
from fact_salesdetail_history_bp inner join rf4102 on item_id=iblitm and warehouse_id=ltrim(ibmcu)
     inner join rf0101 on ibvend=aban8
where company_id='00200' and WAREHOUSE_ID not in ('ASU','ACB') and order_type in ('CO','CR') and year(shipped_date)*100+month(shipped_date)>=@last12month
group by case when type='ISD' and aban85='20710190' then 'ISD2' when type='' then 'OTH' ELSE TYPE END


truncate table fact_rop_t2_slowdead
insert into fact_rop_t2_slowdead
SELECT ITEM_LITM,WH,
sum(case when status='D' then quantity else 0 end) as Dqty,
sum(case when status='S1' then quantity else 0 end) as S1qty,
sum(case when status='S2' then quantity else 0 end) as S2qty,
getdate() as CRDA
FROM [REPORTOPT].[dbo].[FACT_SLOW_DEAD_STOCK_EMDS_IAB]
where company_id='00200' AND STATUS<>'A' 
GROUP BY ITEM_LITM,WH

truncate table fact_rop_t3_outofstock
insert into fact_rop_t3_outofstock
SELECT WAREHOUSE,ITEM_ID,SUM(L3NUM) AS L3NUM,SUM(L2NUM) AS L2NUM,SUM(L1NUM) AS L1NUM,GETDATE() AS CRDA
FROM
(
 SELECT WAREHOUSE, a.ITEM_ID,CASE WHEN IA <= 0 THEN 1 ELSE 0 END L3NUM,0 AS L2NUM,0 AS L1NUM
 FROM FACT_OUTOFSTOCK_DETAIL_NSUPLIMT a
 INNER JOIN workdate_oo ON TRANS_DATE = thedate AND isHoliday = 1
 WHERE YEAR(TRANS_DATE)*100+MONTH(TRANS_DATE) =YEAR(DATEADD(MM,-3,GETDATE()))*100+MONTH(DATEADD(MM,-3,GETDATE()))
       AND STCLASS IN ('A','B') AND WAREHOUSE NOT LIKE 'D__'
 UNION ALL
  SELECT WAREHOUSE, a.ITEM_ID,0 AS L3NUM,CASE WHEN IA <= 0 THEN 1 ELSE 0 END L2NUM,0 AS L1NUM
 FROM FACT_OUTOFSTOCK_DETAIL_NSUPLIMT a
 INNER JOIN workdate_oo ON TRANS_DATE = thedate AND isHoliday = 1
 WHERE YEAR(TRANS_DATE)*100+MONTH(TRANS_DATE) =YEAR(DATEADD(MM,-2,GETDATE()))*100+MONTH(DATEADD(MM,-2,GETDATE()))
       AND STCLASS IN ('A','B') AND WAREHOUSE NOT LIKE 'D__'
  UNION ALL
  SELECT WAREHOUSE, a.ITEM_ID,0 AS L3NUM,0 AS  L2NUM,CASE WHEN IA <= 0 THEN 1 ELSE 0 END AS L1NUM
 FROM FACT_OUTOFSTOCK_DETAIL_NSUPLIMT a
 INNER JOIN workdate_oo ON TRANS_DATE = thedate AND isHoliday = 1
 WHERE YEAR(TRANS_DATE)*100+MONTH(TRANS_DATE) =YEAR(DATEADD(MM,-1,GETDATE()))*100+MONTH(DATEADD(MM,-1,GETDATE()))
       AND STCLASS IN ('A','B') AND WAREHOUSE NOT LIKE 'D__'
)MAIN
GROUP BY WAREHOUSE,ITEM_ID

 truncate table fact_rop_t4_acx_repoint_class
 insert into fact_rop_t4_acx_repoint_class
 SELECT ITEM_ID,WAREHOUSE,REPOINT,IBSRP6 AS STCLASS,IMEV01 as ACXFLAG,FA,IM56PDDT,GETDATE() AS CRDA
 FROM FACT_STOCKITEM INNER JOIN RF574101 ON ITEM_ID=IMLITM INNER JOIN RF4102 ON ITEM_ID=IBLITM AND WAREHOUSE=LTRIM(IBMCU)
 WHERE WAREHOUSE IN ('ACU','ATU','AGU','ASU') 

 truncate table fact_rop_t5_logirop
 insert into fact_rop_t5_logirop
SELECT   YYMM, ITEM_ID, WAREHOUSE_ID, SUM(Order1) AS Order1, SUM(Order2) AS Order2, SUM(Order3) AS Order3, 
                SUM(Order4) AS Order4, SUM(Order5) AS Order5, SUM(Order6) AS Order6, SUM(Order7) AS Order7, SUM(Order8) 
                AS Order8, SUM(Order9) AS Order9, SUM(Order10) AS Order10, SUM(Order11) AS Order11, SUM(Order12) AS Order12, 
                SUM(Sales1) AS Sales1, SUM(Sales2) AS Sales2, SUM(Sales3) AS Sales3, SUM(Sales4) AS Sales4, SUM(Sales5) 
                AS Sales5, SUM(Sales6) AS Sales6, SUM(Sales7) AS Sales7, SUM(Sales8) AS Sales8, SUM(Sales9) AS Sales9, 
                SUM(Sales10) AS Sales10, SUM(Sales11) AS Sales11, SUM(Sales12) AS Sales12
				,SUM(SALES_MONTH6) AS SALES_MONTH6,SUM(SALES_MONTH12) AS SALES_MONTH12,SUM(CUSTOMER_COUNT) AS CUSTOMER_COUNT,SUM(ABBR_COUNT) AS ABBR_COUNT,SUM(SLIP_COUNT) AS SLIP_COUNT,SUM(ORDERMONTH12) AS ORDERMONTH12 , SUM(ORDERMONTH6) AS ORDERMONTH6
				,ROUND((SUM(Order1)+SUM(Order2)+SUM(Order3)+SUM(Order4)+SUM(Order5)+SUM(Order6)+SUM(Order7)+SUM(Order8)+SUM(Order9)+SUM(Order10)+SUM(Order11)+SUM(Order12))/12,0) AS L12O
				,ROUND((SUM(Order1)+SUM(Order2)+SUM(Order3)+SUM(Order4)+SUM(Order5)+SUM(Order6))/6,0) AS L6O
				,ROUND((SUM(Order1)+SUM(Order2)+SUM(Order3))/3,0) AS L3O
				,ROUND((SUM(Sales1)+SUM(Sales2)+SUM(Sales3)+SUM(Sales4)+SUM(Sales5)+SUM(Sales6)+SUM(Sales7)+SUM(Sales8)+SUM(Sales9)+SUM(Sales10)+SUM(Sales11)+SUM(Sales12))/12,0) AS L12S
				,ROUND((SUM(Sales1)+SUM(Sales2)+SUM(Sales3)+SUM(Sales4)+SUM(Sales5)+SUM(Sales6))/6,0) AS L6S
				,ROUND((SUM(Sales1)+SUM(Sales2)+SUM(Sales3))/3,0) AS L3S
				,ROUND(SUM(AVG6),0)*21*0.6 +ROUND(SUM(AVG12),0) *21*0.4 AS SALES_ADJ,
				 GETDATE() AS CRDA
FROM      (SELECT   YYMM, ITEM_ID, WAREHOUSE_ID, LAST1 AS Order1, LAST2 AS Order2, LAST3 AS Order3, LAST4 AS Order4, 
                                 LAST5 AS Order5, LAST6 AS Order6, LAST7 AS Order7, LAST8 AS Order8, LAST9 AS Order9, 
                                 LAST10 AS Order10, LAST11 AS Order11, LAST12 AS Order12, 0 AS Sales1, 0 AS Sales2, 0 AS Sales3, 
                                 0 AS Sales4, 0 AS Sales5, 0 AS Sales6, 0 AS Sales7, 0 AS Sales8, 0 AS Sales9, 0 AS Sales10, 0 AS Sales11, 
                                 0 AS Sales12, 0 as SALES_MONTH6,0 as SALES_MONTH12,0 as CUSTOMER_COUNT,0 as ABBR_COUNT,0 as SLIP_COUNT , ORDERMONTH12, ORDERMONTH6,
                                  0 as AVG6,0 AS AVG12
                 FROM      SDM.dbo.FACT_LOGI_ROP_ORDER
                 WHERE   (YYMM = @calamonth)
                 UNION ALL
                 SELECT   YYMM, ITEM_ID, WAREHOUSE_ID, 0 AS Order1, 0 AS Order2, 0 AS Order3, 0 AS Order4, 0 AS Order5, 
                                 0 AS Order6, 0 AS Order7, 0 AS Order8, 0 AS Order9, 0 AS Order10, 0 AS Order11, 0 AS Order12, 
                                 LAST1 AS Sales1, LAST2 AS Sales2, LAST3 AS Sales3, LAST4 AS Sales4, LAST5 AS Sales5, LAST6 AS Sales6, 
                                 LAST7 AS Sales7, LAST8 AS Sales8, LAST9 AS Sales9, LAST10 AS Sales10, LAST11 AS Sales11, 
                                  LAST12 AS Sales12, SALES_MONTH6,SALES_MONTH12,CUSTOMER_COUNT,ABBR_COUNT,SLIP_COUNT,0 AS ORDERMONTH12,0 AS ORDERMONTH6,
                                   AVG6,AVG12
                 FROM      SDM.dbo.FACT_LOGI_ROP
                 WHERE   (YYMM = @calamonth)) AS MAIN
GROUP BY YYMM, ITEM_ID, WAREHOUSE_ID

truncate table  fact_rop_t6_logirop_nowh
insert into  fact_rop_t6_logirop_nowh
SELECT   YYMM, ITEM_ID,'OEZ' AS  WAREHOUSE_ID, SUM(Order1) AS Order1, SUM(Order2) AS Order2, SUM(Order3) AS Order3, 
                SUM(Order4) AS Order4, SUM(Order5) AS Order5, SUM(Order6) AS Order6, SUM(Order7) AS Order7, SUM(Order8) 
                AS Order8, SUM(Order9) AS Order9, SUM(Order10) AS Order10, SUM(Order11) AS Order11, SUM(Order12) AS Order12, 
                SUM(Sales1) AS Sales1, SUM(Sales2) AS Sales2, SUM(Sales3) AS Sales3, SUM(Sales4) AS Sales4, SUM(Sales5) 
                AS Sales5, SUM(Sales6) AS Sales6, SUM(Sales7) AS Sales7, SUM(Sales8) AS Sales8, SUM(Sales9) AS Sales9, 
                SUM(Sales10) AS Sales10, SUM(Sales11) AS Sales11, SUM(Sales12) AS Sales12
					,SUM(SALES_MONTH6) AS SALES_MONTH6,SUM(SALES_MONTH12) AS SALES_MONTH12,SUM(CUSTOMER_COUNT) AS CUSTOMER_COUNT,SUM(ABBR_COUNT) AS ABBR_COUNT,SUM(SLIP_COUNT) AS SLIP_COUNT,SUM(ORDERMONTH12) AS ORDERMONTH12 , SUM(ORDERMONTH6) AS ORDERMONTH6
				,ROUND((SUM(Order1)+SUM(Order2)+SUM(Order3)+SUM(Order4)+SUM(Order5)+SUM(Order6)+SUM(Order7)+SUM(Order8)+SUM(Order9)+SUM(Order10)+SUM(Order11)+SUM(Order12))/12,0) AS L12O
				,ROUND((SUM(Order1)+SUM(Order2)+SUM(Order3)+SUM(Order4)+SUM(Order5)+SUM(Order6))/6,0) AS L6O
				,ROUND((SUM(Order1)+SUM(Order2)+SUM(Order3))/3,0) AS L3O
				,ROUND((SUM(Sales1)+SUM(Sales2)+SUM(Sales3)+SUM(Sales4)+SUM(Sales5)+SUM(Sales6)+SUM(Sales7)+SUM(Sales8)+SUM(Sales9)+SUM(Sales10)+SUM(Sales11)+SUM(Sales12))/12,0) AS L12S
				,ROUND((SUM(Sales1)+SUM(Sales2)+SUM(Sales3)+SUM(Sales4)+SUM(Sales5)+SUM(Sales6))/6,0) AS L6S
				,ROUND((SUM(Sales1)+SUM(Sales2)+SUM(Sales3))/3,0) AS L3S
				,ROUND(SUM(AVG6),0)*21*0.6 +ROUND(SUM(AVG12),0) *21*0.4 AS SALES_ADJ,
				GETDATE() AS CRDA
FROM      (SELECT   YYMM, ITEM_ID,  LAST1 AS Order1, LAST2 AS Order2, LAST3 AS Order3, LAST4 AS Order4, 
                                 LAST5 AS Order5, LAST6 AS Order6, LAST7 AS Order7, LAST8 AS Order8, LAST9 AS Order9, 
                                 LAST10 AS Order10, LAST11 AS Order11, LAST12 AS Order12, 0 AS Sales1, 0 AS Sales2, 0 AS Sales3, 
                                 0 AS Sales4, 0 AS Sales5, 0 AS Sales6, 0 AS Sales7, 0 AS Sales8, 0 AS Sales9, 0 AS Sales10, 0 AS Sales11, 
                                 0 AS Sales12, 0 as SALES_MONTH6,0 as SALES_MONTH12,0 as CUSTOMER_COUNT,0 as ABBR_COUNT,0 as SLIP_COUNT , ORDERMONTH12, ORDERMONTH6,
                                   0 AS AVG6,0 AS AVG12
                 FROM      SDM.dbo.FACT_LOGI_ROP_ORDER_NOWH
                 WHERE   (YYMM = @calamonth)
                 UNION ALL
                 SELECT   YYMM, ITEM_ID, 0 AS Order1, 0 AS Order2, 0 AS Order3, 0 AS Order4, 0 AS Order5, 
                                 0 AS Order6, 0 AS Order7, 0 AS Order8, 0 AS Order9, 0 AS Order10, 0 AS Order11, 0 AS Order12, 
                                 LAST1 AS Sales1, LAST2 AS Sales2, LAST3 AS Sales3, LAST4 AS Sales4, LAST5 AS Sales5, LAST6 AS Sales6, 
                                 LAST7 AS Sales7, LAST8 AS Sales8, LAST9 AS Sales9, LAST10 AS Sales10, LAST11 AS Sales11, 
                                 LAST12 AS Sales12, SALES_MONTH6,SALES_MONTH12,CUSTOMER_COUNT,ABBR_COUNT,SLIP_COUNT,0 AS ORDERMONTH12,0 AS ORDERMONTH6,
                                   AVG6,AVG12
                 FROM      SDM.dbo.FACT_LOGI_ROP_NOWH
                 WHERE   (YYMM = @calamonth)) AS MAIN
GROUP BY YYMM, ITEM_ID

truncate table   fact_rop_t7_logirop_base
insert into  fact_rop_t7_logirop_base
SELECT distinct ITEM_ID,WAREHOUSE_ID,ITEM_FMLY ,TYPE,VENDO,FACTORYCODE ,FACTORYDESC ,MAQ,STATUS,DISCSTATUS,GSCFLAG,AOFLAG,SBZ,TP1_CURR,TP1,PLMFLAG,EXT_AMT,LEADTIME
	   ,[ACTUAL_PURCHASE_CIRCLE],[STANDARD_PURCHASE_CIRCLE],[PURCHASE_CIRCLE],ROP,GETDATE() AS CRDA
FROM [SDM].[dbo].[FACT_LOGI_ROP]
WHERE YYMM=@calamonth

truncate table fact_rop_t8_logirop_nowh_base
insert into  fact_rop_t8_logirop_nowh_base
SELECT distinct  ITEM_ID,'OEZ' AS WAREHOUSE_ID,ITEM_FMLY ,TYPE,VENDO,FACTORYCODE ,FACTORYDESC ,MAQ,STATUS,DISCSTATUS,GSCFLAG,AOFLAG,SBZ,TP1_CURR,TP1,PLMFLAG,EXT_AMT,LEADTIME
	   ,[ACTUAL_PURCHASE_CIRCLE],[STANDARD_PURCHASE_CIRCLE],[PURCHASE_CIRCLE],GETDATE() AS CRDA
FROM [SDM].[dbo].[FACT_LOGI_ROP_nowh]
WHERE YYMM=@calamonth

truncate table fact_rop_t8_logirop_stdev
insert into fact_rop_t8_logirop_stdev
SELECT  item_id,warehouse_id,stdev(salesqty) as 需求的标准偏差,GETDATE() AS CRDA 
FROM 
( 
    SELECT item_id,WAREHOUSE_ID,[Sales1],[Sales2],Sales3,Sales4,Sales5,Sales6,Sales7,Sales8,Sales9,Sales10,Sales11,Sales12
    FROM fact_rop_t5_logirop 
) P 
UNPIVOT ( 
            salesqty
            FOR yymm IN 
            ([Sales1],[Sales2],Sales3,Sales4,Sales5,Sales6,Sales7,Sales8,Sales9,Sales10,Sales11,Sales12) 
      ) AS T 
group by  item_id,warehouse_id
union all
SELECT  item_id,warehouse_id,stdev(salesqty) as 需求的标准偏差,GETDATE() AS CRDA 
FROM 
( 
    SELECT item_id,WAREHOUSE_ID,[Sales1],[Sales2],Sales3,Sales4,Sales5,Sales6,Sales7,Sales8,Sales9,Sales10,Sales11,Sales12
    FROM fact_rop_t6_logirop_nowh 
) P 
UNPIVOT ( 
            salesqty
            FOR yymm IN 
            ([Sales1],[Sales2],Sales3,Sales4,Sales5,Sales6,Sales7,Sales8,Sales9,Sales10,Sales11,Sales12) 
      ) AS T 
group by  item_id,warehouse_id
 


 truncate table  rop_t9_standarditemdetail
 insert  into rop_t9_standarditemdetail
 select item_id,WAREHOUSE_ID,OEM占比,OEM月数,GETDATE() AS CRDA 
 from (
	select 
	row_number() over (partition by item_id,WAREHOUSE_ID order by OEM占比 desc,month_count desc) as cc,
	item_id,WAREHOUSE_ID,  OEM占比,month_count as OEM月数
	from (

		select distinct item_id,WAREHOUSE_ID,
		case when total_qty =0 then 0 else qty / total_qty end as OEM占比
		,month_count
		from FACT_standarditemdetail
		where case when total_qty =0 then 0 else qty / total_qty end >= 0.5)
	main )main
where cc=1


truncate table FACT_ROP_REPORT_T
insert into FACT_ROP_REPORT_T
select @calamonth AS YYMM,a.ITEM_ID,a.WAREHOUSE_ID,ITEM_FMLY,a.TYPE,VENDO,FACTORYCODE,FACTORYDESC,MAQ,STATUS,DISCSTATUS,GSCFLAG,AOFLAG,
SBZ,TP1_CURR,TP1,PLMFLAG,EXT_AMT,LEADTIME,ACTUAL_PURCHASE_CIRCLE,STANDARD_PURCHASE_CIRCLE,PURCHASE_CIRCLE,
Order1,Order2,Order3,Order4,Order5,Order6,Order7,Order8,Order9,Order10,Order11,Order12,
Sales1,Sales2,Sales3,Sales4,Sales5,Sales6,Sales7,Sales8,Sales9,Sales10,Sales11,Sales12,
SALES_MONTH6,SALES_MONTH12,CUSTOMER_COUNT,ABBR_COUNT,SLIP_COUNT,ORDERMONTH12,ORDERMONTH6,
L12O,L6O,L3O,L12S,L6S,L3S,SALES_ADJ,REPOINT,STCLASS,ACXFLAG,[L3NUM],[L2NUM],[L1NUM],Dqty,S1qty,S2qty,salesamt,@oezsalesamt as oezsalesamt,
case when a.WAREHOUSE_ID='ACU' THEN 1.28 else 0.67 end as 服务水平 ,case when tp1_curr='CNY' THEN 1  WHEN TP1_CURR='USD' THEN @usdtocny ELSE 0 END as EXRATE,
case when VENDO ='20730950' then 1.5 when VENDO in ('20730837','20730624') then 2 when VENDO in ('20710030','20710364') and PURCHASE_CIRCLE< 1 then 1 
     when VENDO ='20710190' and PURCHASE_CIRCLE< 0.25 then 0.25 when   PURCHASE_CIRCLE< 0.75 then 0.75 end as 采购周期修正值,REPOINT AS ROP,
case when tp1_curr='CNY' then REPOINT*TP1 when tp1_curr='USD' then REPOINT*TP1*@usdtocny else 0 end ROPAMT,OEM占比,OEM月数,FA,GETDATE() AS CRDA
from fact_rop_t7_logirop_base a 
left outer join fact_rop_t5_logirop b on a.item_id=b.item_id and a.warehouse_id=b.WAREHOUSE_ID
left outer join fact_rop_t4_acx_repoint_class c on a.item_id = c.item_id and a.warehouse_id=c.WAREHOUSE
left outer join fact_rop_t3_outofstock d on a.item_id = d.item_id and a.warehouse_id=d.WAREHOUSE
left outer join fact_rop_t2_slowdead e on a.item_id = e.item_litm and a.warehouse_id=e.WH
left outer join fact_rop_t1_salesbytype f on a.TYPE=f.TYPE
left outer join rop_t9_standarditemdetail g on a.item_id=g.item_id and a.WAREHOUSE_ID=g.WAREHOUSE_ID
union all
select @calamonth AS YYMM,a.ITEM_ID,a.WAREHOUSE_ID,ITEM_FMLY,a.TYPE,VENDO,FACTORYCODE,FACTORYDESC,MAQ,STATUS,DISCSTATUS,GSCFLAG,AOFLAG,
SBZ,TP1_CURR,TP1,PLMFLAG,EXT_AMT,LEADTIME,ACTUAL_PURCHASE_CIRCLE,STANDARD_PURCHASE_CIRCLE,PURCHASE_CIRCLE,
Order1,Order2,Order3,Order4,Order5,Order6,Order7,Order8,Order9,Order10,Order11,Order12,
Sales1,Sales2,Sales3,Sales4,Sales5,Sales6,Sales7,Sales8,Sales9,Sales10,Sales11,Sales12,
SALES_MONTH6,SALES_MONTH12,CUSTOMER_COUNT,ABBR_COUNT,SLIP_COUNT,ORDERMONTH12,ORDERMONTH6,
L12O,L6O,L3O,L12S,L6S,L3S,SALES_ADJ ,0 as REPOINT,'' as STCLASS,ACXFLAG,[L3NUM],[L2NUM],[L1NUM],Dqty,S1qty,S2qty,salesamt,@oezsalesamt as oezsalesamt,
  1.28 as 服务水平,case when tp1_curr='CNY' THEN 1  WHEN TP1_CURR='USD' THEN @usdtocny ELSE 0 END as EXRATE,
case when VENDO ='20730950' then 1.5 when VENDO in ('20730837','20730624') then 2 when VENDO in ('20710030','20710364') and PURCHASE_CIRCLE< 1 then 1 
     when VENDO ='20710190' and PURCHASE_CIRCLE< 0.25 then 0.25 when   PURCHASE_CIRCLE< 0.75 then 0.75 end as 采购周期修正值,REPOINT AS ROP,
case when tp1_curr='CNY' then REPOINT*TP1 when tp1_curr='USD' then REPOINT*TP1*@usdtocny else 0 end ROPAMT,
    case when isnull(OEM月数,0) <>0 then 99 else 0 end as OEM占比,OEM月数,0 AS FA,GETDATE() AS CRDA
from fact_rop_t8_logirop_nowh_base a 
left outer join fact_rop_t6_logirop_nowh b on a.item_id=b.item_id and a.warehouse_id=b.WAREHOUSE_ID
left outer join (select item_id,acxflag from fact_rop_t4_acx_repoint_class where warehouse='ACU') c on a.item_id = c.item_id  
left outer join (select item_id,'OEZ' as warehouse,sum(L3NUM) as L3NUM,sum(L2NUM) as L2NUM,sum(L1NUM) as L1NUM from fact_rop_t3_outofstock where warehouse in ('ACU','ATU','AGU') group by item_id) d on a.item_id=d.item_id and a.warehouse_id=d.warehouse
left outer join (select item_litm,'OEZ' as WH,sum(Dqty) as Dqty,sum(S1qty) as S1qty,sum(S2qty) as S2qty from fact_rop_t2_slowdead group by item_litm) e on a.item_id=e.item_litm and a.warehouse_id=e.WH
left outer join fact_rop_t1_salesbytype f on a.TYPE=f.TYPE
left outer join (SELECT ITEM_ID,SUM(REPOINT) AS REPOINT  FROM fact_rop_t4_acx_repoint_class WHERE WAREHOUSE IN ('ACU','ATU','AGU') GROUP BY ITEM_ID) rop on a.item_id=rop.item_id
left outer join ( select item_id,sum(OEM月数) as OEM月数 from rop_t9_standarditemdetail group by item_id) g on a.item_id=g.item_id  

insert into FACT_ROP_REPORT_T(YYMM,ITEM_ID,WAREHOUSE_ID,ITEM_FMLY,TYPE,VENDO,FACTORYCODE,FACTORYDESC,MAQ,STATUS,DISCSTATUS,GSCFLAG,AOFLAG,SBZ,TP1_CURR,TP1,PLMFLAG,STCLASS,ACXFLAG,Dqty,S1qty,S2qty,服务水平,FA,CRDA)
 select YYMM,ITEM_ID,'ACU' AS WAREHOUSE_ID,ITEM_FMLY,TYPE,VENDO,FACTORYCODE,FACTORYDESC,MAQ,STATUS,DISCSTATUS,GSCFLAG,AOFLAG,SBZ,TP1_CURR,TP1,PLMFLAG,STCLASS,ACXFLAG,Dqty,S1qty,S2qty,1.28 AS 服务水平,0 AS FA,GETDATE() from FACT_ROP_REPORT_T where WAREHOUSE_ID ='OEZ'
 AND ITEM_ID NOT IN (SELECT ITEM_ID FROM FACT_ROP_REPORT_T WHERE WAREHOUSE_ID ='ACU')

truncate table  FACT_ROP_REPORT
insert INTO FACT_ROP_REPORT
select YYMM,a.ITEM_ID,a.WAREHOUSE_ID,ITEM_FMLY,TYPE,VENDO,FACTORYCODE,FACTORYDESC,MAQ,STATUS,
DISCSTATUS,GSCFLAG,AOFLAG,SBZ,TP1_CURR,TP1,PLMFLAG,EXT_AMT,LEADTIME,ACTUAL_PURCHASE_CIRCLE,
STANDARD_PURCHASE_CIRCLE,PURCHASE_CIRCLE,Order1,Order2,Order3,Order4,Order5,Order6,Order7,
Order8,Order9,Order10,Order11,Order12,Sales1,Sales2,Sales3,Sales4,Sales5,Sales6,Sales7,
Sales8,Sales9,Sales10,Sales11,Sales12,SALES_MONTH6,SALES_MONTH12,CUSTOMER_COUNT,ABBR_COUNT,
SLIP_COUNT,ORDERMONTH12,ORDERMONTH6,L12O,L6O,L3O,L12S,L6S,L3S,SALES_ADJ,REPOINT,STCLASS,
L3NUM,L2NUM,L1NUM,Dqty,S1qty,S2qty,salesamt,oezsalesamt,服务水平,exrate,采购周期修正值,ROP,ROPAMT,OEM占比
,OEM月数,FA,需求的标准偏差,
' ' AS NOWH, 
case when SALES_MONTH12 >=6 and SALES_MONTH6>=3 and abbr_count >=4 and a.warehouse_id <>'OEZ' then '*' else '' end as WH,
case when ACXFLAG =2 THEN '*' ELSE '' END AS ACXFLAG,
'A' AS 偏差选取,
floor(case when ACXFLAG =2 then SALES_ADJ*0.85 else SALES_ADJ+服务水平*需求的标准偏差 end) as SafetyStock,
round(floor(case when ACXFLAG =2 then SALES_ADJ*0.85 else SALES_ADJ+服务水平*需求的标准偏差 end) *TP1*exrate,2) as 安全库存金额,
round(case when SALES_ADJ =0 then 0 else case when ACXFLAG =2 then SALES_ADJ*0.85 else SALES_ADJ+服务水平*需求的标准偏差 end/SALES_ADJ end,1) as 安全库存月数,
case when ACXFLAG =2 then SALES_ADJ*1.2 else (SALES_ADJ+服务水平*需求的标准偏差)+PURCHASE_CIRCLE*SALES_ADJ end as ROP取整,
0 as 波动AMOUNT,
0 as ROP计算金额,
'' as 是否需要说明,
 case when SALES_ADJ=0 then 0 else case when sales1/SALES_ADJ >0.5 AND  sales1/SALES_ADJ <2 then sales1 else SALES_ADJ end end as SALES1A,
 case when SALES_ADJ=0 then 0 else case when sales2/SALES_ADJ >0.5 AND  sales2/SALES_ADJ <2 then sales2 else SALES_ADJ end end as SALES2A,
 case when SALES_ADJ=0 then 0 else case when sales3/SALES_ADJ >0.5 AND  sales3/SALES_ADJ <2 then sales3 else SALES_ADJ end end as SALES3A,
 case when SALES_ADJ=0 then 0 else case when sales4/SALES_ADJ >0.5 AND  sales4/SALES_ADJ <2 then sales4 else SALES_ADJ end end as SALES4A,
 case when SALES_ADJ=0 then 0 else case when sales5/SALES_ADJ >0.5 AND  sales5/SALES_ADJ <2 then sales5 else SALES_ADJ end end as SALES5A,
 case when SALES_ADJ=0 then 0 else case when sales6/SALES_ADJ >0.5 AND  sales6/SALES_ADJ <2 then sales6 else SALES_ADJ end end as SALES6A,
 case when SALES_ADJ=0 then 0 else case when sales7/SALES_ADJ >0.5 AND  sales7/SALES_ADJ <2 then sales7 else SALES_ADJ end end as SALES7A,
 case when SALES_ADJ=0 then 0 else case when sales8/SALES_ADJ >0.5 AND  sales8/SALES_ADJ <2 then sales8 else SALES_ADJ end end as SALES8A,
 case when SALES_ADJ=0 then 0 else case when sales9/SALES_ADJ >0.5 AND  sales9/SALES_ADJ <2 then sales9 else SALES_ADJ end end as SALES9A,
 case when SALES_ADJ=0 then 0 else case when sales10/SALES_ADJ >0.5 AND  sales10/SALES_ADJ <2 then sales10 else SALES_ADJ end end as SALES10A,
 case when SALES_ADJ=0 then 0 else case when sales11/SALES_ADJ >0.5 AND  sales11/SALES_ADJ <2 then sales11 else SALES_ADJ end end as SALES11A,
 case when SALES_ADJ=0 then 0 else case when sales12/SALES_ADJ >0.5 AND  sales12/SALES_ADJ <2 then sales12 else SALES_ADJ end end as SALES12A,
 0 AS 调整后偏差,
'' AS NEWCLASS,
'' AS 修正后CLASS,
a.CRDA  
from FACT_ROP_REPORT_T a left outer join fact_rop_t8_logirop_stdev b on a.item_id=b.item_id and a.WAREHOUSE_ID =b.warehouse_id 
 


truncate table fact_rop_t10_logirop_stdev_adj
insert into fact_rop_t10_logirop_stdev_adj
SELECT  item_id,warehouse_id,stdev(salesqty) as 调整后偏差T,GETDATE() AS CRDA 
FROM 
( 
    SELECT item_id,WAREHOUSE_ID,[Sales1A],[Sales2A],Sales3A,Sales4A,Sales5A,Sales6A,Sales7A,Sales8A,Sales9A,Sales10A,Sales11A,Sales12A
    FROM FACT_ROP_REPORT 
) P 
UNPIVOT ( 
            salesqty
            FOR yymm IN 
            ([Sales1A],[Sales2A],Sales3A,Sales4A,Sales5A,Sales6A,Sales7A,Sales8A,Sales9A,Sales10A,Sales11A,Sales12A) 
      ) AS T 
group by  item_id,warehouse_id
 
update a
set 调整后偏差=调整后偏差T
 from FACT_ROP_REPORT a 
 inner join fact_rop_t10_logirop_stdev_adj b 
 on a.item_id=b.item_id and a.warehouse_id=b.warehouse_id

UPDATE FACT_ROP_REPORT
SET NOWH='*' 
WHERE ITEM_ID IN (SELECT ITEM_ID FROM  FACT_ROP_REPORT where SALES_MONTH12>=6 and SALES_MONTH6>=3 and ABBR_COUNT>=4 and warehouse_id='OEZ')
 
 UPDATE FACT_ROP_REPORT SET ROP取整=0 where WAREHOUSE_ID ='ACU'

 UPDATE FACT_ROP_REPORT SET ROP取整=ACUROP取整
 FROM FACT_ROP_REPORT INNER JOIN 
     (SELECT ITEM_ID,SUM(OEZROP取整)-SUM(ATUROP取整)-SUM(AGUROP取整) AS ACUROP取整
		FROM(
			SELECT ITEM_ID,ROP取整 as OEZROP取整,0 AS ATUROP取整,0 AS AGUROP取整 FROM FACT_ROP_REPORT WHERE WAREHOUSE_ID ='OEZ'
			UNION ALL
			SELECT ITEM_ID,0 as OEZROP取整,ROP取整 AS ATUROP取整,0 AS AGUROP取整 FROM FACT_ROP_REPORT WHERE WAREHOUSE_ID ='ATU'
			UNION ALL
			SELECT ITEM_ID,0 as OEZROP取整,0 AS ATUROP取整,ROP取整 AS AGUROP取整 FROM FACT_ROP_REPORT WHERE WAREHOUSE_ID ='AGU')MAIN
		GROUP BY ITEM_ID)B ON FACT_ROP_REPORT.item_id=b.item_id
WHERE WAREHOUSE_ID ='ACU'

UPDATE FACT_ROP_REPORT SET ROP取整=
      case when ROP取整<9 then round(ROP取整,0) 
	       when ROP取整>=9 and ROP取整<100 then round(ROP取整/5,0)* 5
		   when ROP取整>=100 and ROP取整<1000 then round(ROP取整/100,1)* 100
		   when ROP取整>=1000 and ROP取整<10000 then round(ROP取整/1000,1)* 1000
		   when ROP取整>=10000 and ROP取整<100000 then round(ROP取整/10000,2)* 10000 END

UPDATE FACT_ROP_REPORT SET ROP计算金额=ROP取整*exrate*TP1

UPDATE FACT_ROP_REPORT SET 是否需要说明='*' WHERE CASE WHEN SALES_ADJ=0 THEN 0 ELSE ROP取整/SALES_ADJ END>=4.3

UPDATE FACT_ROP_REPORT SET 波动AMOUNT=ROP计算金额-ROPAMT

UPDATE FACT_ROP_REPORT SET NEWCLASS=STCLASS WHERE STCLASS IN ('BP','BZ') 

UPDATE FACT_ROP_REPORT SET NEWCLASS='BE' WHERE isnuLl(OEM占比,0)<>0 AND WAREHOUSE_ID <>'OEZ' AND ISNULL(NEWCLASS,'')=''

UPDATE FACT_ROP_REPORT SET NEWCLASS='BX' WHERE isnull(Dqty,0)+isnull(S1qty,0)+ isnull(S2qty,0)>0 AND ISNULL(NEWCLASS,'')=''

UPDATE FACT_ROP_REPORT SET NEWCLASS='BC' 
WHERE WAREHOUSE_ID <>'OEZ' AND (case when isnull((Sales10+Sales11+Sales12),0)=0 then 2 else  (Sales7+Sales8+Sales9)/(Sales10+Sales11+Sales12) end>=2
or  case when isnull((Sales10+Sales11+Sales12),0)=0 then 2 else  (Sales7+Sales8+Sales9)/(Sales10+Sales11+Sales12) end <0.5)
AND ISNULL(NEWCLASS,'')=''

UPDATE FACT_ROP_REPORT SET NEWCLASS='AA' 
WHERE WAREHOUSE_ID <>'OEZ' AND SALES_MONTH12>10 AND ORDERMONTH12>10 and CUSTOMER_COUNT>5 and SLIP_COUNT>19 AND isnull(Dqty,0)+isnull(S1qty,0)+ isnull(S2qty,0)<0 AND PLMFLAG IN ('A','B')
      AND ISNULL(NEWCLASS,'')=''

UPDATE FACT_ROP_REPORT SET NEWCLASS='BN' 
WHERE WAREHOUSE_ID <>'OEZ' AND ISNULL(NEWCLASS,'')=''

UPDATE FACT_ROP_REPORT
SET NEWCLASS='BS'
WHERE ITEM_ID IN (
	SELECT  a.item_id
	FROM FACT_ROP_REPORT a INNER JOIN (
		 SELECT ITEM_ID,MAX(ROP取整) AS MAXROP FROM FACT_ROP_REPORT 
		 WHERE WAREHOUSE_ID IN ('ATU','AGU') GROUP BY ITEM_ID) b
	ON a.item_id=b.item_id
	 WHERE WAREHOUSE_ID='ACU' AND MAXROP-ROP取整>0  )
AND NEWCLASS IN ('AA','BN')
 
 UPDATE a
SET  NEWCLASS='AP' 
FROM FACT_ROP_REPORT a INNER JOIN (
	SELECT ITEM_ID,SUM(FA) AS FATOTAL FROM fact_rop_t4_acx_repoint_class
	WHERE WAREHOUSE IN ('ACU','ATU','AGU','ASU') GROUP BY ITEM_ID HAVING SUM(FA) <>0) b
ON a.item_id=b.item_id
where isnull(ROP取整,0) <>0 and FATOTAL/ROP取整>2 AND NEWCLASS='AA' 

UPDATE a
SET  NEWCLASS='BW' 
FROM FACT_ROP_REPORT a INNER JOIN (
	SELECT ITEM_ID,SUM(FA) AS FATOTAL FROM fact_rop_t4_acx_repoint_class
	WHERE WAREHOUSE IN ('ACU','ATU','AGU','ASU') GROUP BY ITEM_ID HAVING SUM(FA) <>0) b
ON a.item_id=b.item_id
where isnull(ROP取整,0) <>0 and FATOTAL/ROP取整>2 AND NEWCLASS='BN' 

UPDATE FACT_ROP_REPORT SET NEWCLASS='' WHERE [STATUS]='U'
 
UPDATE FACT_ROP_REPORT SET NEWCLASS='' WHERE ISNULL(TP1,0)=0

UPDATE FACT_ROP_REPORT SET NEWCLASS='' WHERE Sales7+Sales8+Sales9+Sales10+Sales11+Sales12=0

UPDATE FACT_ROP_REPORT SET NEWCLASS='' WHERE ISNULL(NOWH,'')=''  AND STCLASS<>'BP'

UPDATE FACT_ROP_REPORT SET NEWCLASS='' WHERE ISNULL(WH,'')=''  AND STCLASS<>'BP'

UPDATE a
SET NEWCLASS=''
FROM FACT_ROP_REPORT a inner join fact_rop_t4_acx_repoint_class b 
on a.item_id=b.item_id and warehouse_id=warehouse
where im56pddt <>'000000' and discstatus <>'' and [status]='S' AND
      YEAR(GETDATE())*100+MONTH(GETDATE()) -CONVERT(INT,IM56PDDT)<7
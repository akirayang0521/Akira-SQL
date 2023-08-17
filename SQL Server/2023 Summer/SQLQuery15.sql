--CREATE VIEW [dbo].[View_230703_1]
--AS
select [name] AS [Account Manager Name]
	  ,CustomerScene.acid AS [CUSTOMER_ID]
	  ,acc01.accn AS [Customer Name]
	  ,case LevelClassification when '经营层' then 'Top Management' 
								when '管理层' then 'Middle Management'
								when '工程师层' then 'Operations'
								else '' end as [3-Level Classification]
      ,Addressbook.ID as [CONTACT_ID]
	  ,CustomerScene.id as [ACTIVITY_ID]
	  ,SceneType as [Action Type Name]
	  ,'' as [Action Subtype Name]
	  ,JudgmentBasis AS [Sales Action]
	  ,CustomerScene.ModifyDate as [End Date]
	  ,SceneStatus as [Action Status]
	  ,'OEZ' AS [Customer Regrouped Description]
	  ,RTRIM(isnull(FocusedIndustry,'Others')) AS [Focused Industry]
	  ,FocusedGrowingDomain AS [Focused Growing Domain]   
	  ,acud01 AS [Target Account]

from    [TOP_Dev].[dbo].CustomerScene 
left outer join [TOP_Dev].[dbo].[apijson_user] on  CustomerScene.CreateNo= userid
left outer join sfa.dbo.acc01 on CustomerScene.acid=acc01.acid
left outer join   (select * from [SFA].[dbo].CX where fy='fy23') CX ON CustomerScene.ACID =AccountCode 
left outer join [TOP_Dev].[dbo].[Addressbook] ON CustomerScene.DecisionMakerID=Addressbook.ID 
where year(CustomerScene.CreateDate)*100+month(CustomerScene.CreateDate) 
     =DATEPART(YY,(DATEADD(MM,-1,GETDATE())))*100+DATEPART(MM,(DATEADD(MM,-1,GETDATE())))
UNION ALL

select [name] AS [Account Manager Name]
	  ,acid AS [CUSTOMER_ID]
	  ,accn AS [Customer Name]
	  ,case LevelClassification when '经营层' then 'Top Management' 
								when '管理层' then 'Middle Management' 
								when '工程师层' then 'Operations' 
								else '' end as [3-Level Classification]
	  ,Addressbook.ID as [CONTACT_ID]
	  ,[Proposal].id as [ACTIVITY_ID]
	  ,'Proposal' as [Action Type Name]
	  ,'' as [Action Subtype Name]
	  ,ProposalContent AS [Sales Action] 
	  ,ProposalDate as [End Date]
	  ,'2-Completed' as [Action Status]
	  ,'OEZ' AS [Customer Regrouped Description]
	  ,RTRIM(isnull(FocusedIndustry,'Others'))  AS [Focused Industry]
	  ,'' AS [Focused Growing Domain] 
	  ,'Target Account' AS [Target Account]

from    [TOP_Dev].[dbo].[Proposal] 
INNER JOIN [TOP_Dev].[dbo].[apijson_user] on  CreateNo= userid
INNER JOIN (select * from [SFA].[dbo].CX where fy='fy23') CX ON ACID =AccountCode 
INNER JOIN [TOP_Dev].[dbo].[Addressbook] ON ProposalUserID=Addressbook.ID
WHERE ACID IN (select TPACID from sfa.dbo.acctop where tpcuflag='ACM') 
	  AND YEAR(Proposal.CREATEDATE)*100+MONTH(Proposal.CREATEDATE)
	     =DATEPART(YY,(DATEADD(MM,-1,GETDATE())))*100+DATEPART(MM,(DATEADD(MM,-1,GETDATE())))
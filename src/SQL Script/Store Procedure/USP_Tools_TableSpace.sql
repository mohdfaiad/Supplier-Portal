SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE type='P' AND name='USP_Tools_TableSpace') 
     DROP PROCEDURE USP_Tools_TableSpace 
GO

CREATE PROCEDURE [dbo].USP_Tools_TableSpace 
AS 
begin      
	DECLARE @tblname varchar(50)            --�Y�ϱ����Q(ʹ�����Y�ϱ����Q׃��)
	if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[#TableStatics_TEMP]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE [dbo].[#TableStatics_TEMP]   --�����Y�ϱ�
	 

	CREATE TABLE #TableStatics_TEMP (       --���������Y�ϱ�
		[name] [varchar] (50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL ,        --�Y�ϱ����Q
		[rows] [varchar] (50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL ,        --�Y�ϱ�F�е��Y���Д�
		[reserved] [varchar] (50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL ,    --�Y�ώ��е���������õĿ��g��С
		[data] [varchar] (50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL ,        --�Y�����õĿ��g��С
		[index_size] [varchar] (50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL ,  --�������õĿ��g��С
		[unused] [varchar] (50) COLLATE Chinese_Taiwan_Stroke_CI_AS NULL )      --�����o�Y�ώ���֮�������δʹ�õĿ��g��С
	 

	DECLARE cur_TableStatics CURSOR FORWARD_ONLY FOR
		SELECT name FROM sysobjects WHERE xtype='U' ORDER BY name               --ȡ��ʹ�����Y�ϱ����Q
	OPEN cur_TableStatics
	FETCH NEXT FROM cur_TableStatics
	INTO @tblname
		WHILE @@FETCH_STATUS = 0
			BEGIN  
				INSERT #TableStatics_TEMP
					EXEC sp_spaceused @tblname,@updateusage = N'TRUE'           --�@ʾ�Y�ϱ�����P�ŵ����g�YӍ
				FETCH NEXT FROM cur_TableStatics
				INTO @tblname
			END
	CLOSE cur_TableStatics
	DEALLOCATE cur_TableStatics
	   
	SELECT name,rows,
		CONVERT(varchar(18),CONVERT(NUMERIC(18,2),SUBSTRING(reserved,1,LEN(reserved)-2))/1024) + 'MB' AS reserved,
		CONVERT(varchar(18),CONVERT(NUMERIC(18,2),SUBSTRING(data,1,LEN(data)-2))/1024) + 'MB' AS data,
		CONVERT(varchar(18),CONVERT(NUMERIC(18,2),SUBSTRING(index_size,1,LEN(index_size)-2))/1024) + 'MB' AS index_siz,
		CONVERT(varchar(18),CONVERT(NUMERIC(18,2),SUBSTRING(unused,1,LEN(unused)-2))/1024) + 'MB' AS unused
	FROM #TableStatics_TEMP where rows <> '0'           --��ԃ�����Y�ϱ��Y�ϱȔ�������Y�ϱ�
	 

	DROP TABLE #TableStatics_TEMP                               --�Ƴ������Y�ϱ�
end            

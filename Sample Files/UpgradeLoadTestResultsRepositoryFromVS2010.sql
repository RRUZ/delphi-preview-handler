USE [LoadTest2010]
GO

IF NOT EXISTS(SELECT name FROM sysindexes WHERE name = 'LoadTestTestDetail7')
  CREATE NONCLUSTERED INDEX [LoadTestTestDetail7] ON [dbo].[LoadTestTestDetail] ([LoadTestRunId] ASC,[NetworkId] ASC) INCLUDE ([TestDetailId])

IF NOT EXISTS(SELECT name FROM sysindexes WHERE name = 'LoadTestPageDetail6')
  CREATE NONCLUSTERED INDEX [LoadTestPageDetail6] ON [dbo].[LoadTestPageDetail] ([LoadTestRunId] ASC, [PageId] ASC, [GoalExceeded] ASC, [InMeasurementInterval] ASC)

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Prc_UpdateTestSummary3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Prc_UpdateTestSummary3]
GO

CREATE PROCEDURE [dbo].[Prc_UpdateTestSummary3] @LoadTestRunId int
AS

If IsNull(object_id('tempdb..#numberedTestDetails'),0) <> 0 DROP TABLE #numberedTestDetails

  SELECT * INTO #numberedTestDetails FROM 
  (
      SELECT ElapsedTime, LoadTestRunId, TestCaseId, 
	   rowNumber=ROW_NUMBER() 
	   OVER (PARTITION BY LoadTestRunId, TestCaseId 
                 ORDER BY ElapsedTime DESC),
	   COUNT(*) 
           OVER (PARTITION BY LoadTestRunId, TestCaseId) AS rCount
      FROM LoadTestTestDetail
      WHERE LoadTestRunId = @LoadTestRunId AND
        InMeasurementInterval = 1) AS allRows
  WHERE allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 100) OR 
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 20)  OR 
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 10)  OR
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 2) 
 
  UPDATE LoadTestTestSummaryData  
  SET Percentile90 = ElapsedTime
  FROM  LoadTestTestSummaryData  JOIN #numberedTestDetails ON
        LoadTestTestSummaryData.LoadTestRunId = #numberedTestDetails.LoadTestRunId AND
        LoadTestTestSummaryData.TestCaseId = #numberedTestDetails.TestCaseId
  WHERE #numberedTestDetails.rowNumber = ceiling(CAST(#numberedTestDetails.rCount AS Float)/10)

  UPDATE LoadTestTestSummaryData  
  SET Percentile95 = ElapsedTime
  FROM  LoadTestTestSummaryData  JOIN #numberedTestDetails ON
        LoadTestTestSummaryData.LoadTestRunId = #numberedTestDetails.LoadTestRunId AND
        LoadTestTestSummaryData.TestCaseId = #numberedTestDetails.TestCaseId
  WHERE #numberedTestDetails.rowNumber = ceiling(CAST(#numberedTestDetails.rCount AS Float)/20)

  UPDATE LoadTestTestSummaryData  
  SET Percentile99 = ElapsedTime
  FROM  LoadTestTestSummaryData  JOIN #numberedTestDetails ON
        LoadTestTestSummaryData.LoadTestRunId = #numberedTestDetails.LoadTestRunId AND
        LoadTestTestSummaryData.TestCaseId = #numberedTestDetails.TestCaseId
  WHERE #numberedTestDetails.rowNumber = ceiling(CAST(#numberedTestDetails.rCount AS Float)/100)

  UPDATE LoadTestTestSummaryData  
  SET Median = ElapsedTime
  FROM  LoadTestTestSummaryData  JOIN #numberedTestDetails ON
        LoadTestTestSummaryData.LoadTestRunId = #numberedTestDetails.LoadTestRunId AND
        LoadTestTestSummaryData.TestCaseId = #numberedTestDetails.TestCaseId
  WHERE #numberedTestDetails.rowNumber = ceiling(CAST(#numberedTestDetails.rCount AS Float)/2)

  DROP TABLE #numberedTestDetails

GO

GRANT EXECUTE ON [dbo].[Prc_UpdateTestSummary3] TO PUBLIC
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Prc_UpdateTransactionSummary3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Prc_UpdateTransactionSummary3]
GO

CREATE PROCEDURE [dbo].[Prc_UpdateTransactionSummary3] @LoadTestRunId int
AS
If IsNull(object_id('tempdb..#numberedTransactionDetails'),0) <> 0 DROP TABLE #numberedTransactionDetails

  SELECT * INTO #numberedTransactionDetails FROM 
  (
      SELECT ResponseTime, LoadTestRunId, TransactionId, 
	   rowNumber=ROW_NUMBER() 
	   OVER (PARTITION BY LoadTestRunId, TransactionId 
                 ORDER BY ResponseTime DESC),
	   COUNT(*) 
           OVER (PARTITION BY LoadTestRunId, TransactionId) AS rCount
      FROM LoadTestTransactionDetail
      WHERE LoadTestRunId = @LoadTestRunId AND
        InMeasurementInterval = 1) AS allRows
  WHERE allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 100) OR 
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 20)  OR 
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 10)  OR
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 2) 


  UPDATE LoadTestTransactionSummaryData  
  SET Percentile90 = ResponseTime
  FROM  LoadTestTransactionSummaryData  JOIN #numberedTransactionDetails ON
        LoadTestTransactionSummaryData.LoadTestRunId = #numberedTransactionDetails.LoadTestRunId AND
        LoadTestTransactionSummaryData.TransactionId = #numberedTransactionDetails.TransactionId
  WHERE #numberedTransactionDetails.rowNumber = ceiling(CAST(#numberedTransactionDetails.rCount AS Float)/10)


  UPDATE LoadTestTransactionSummaryData  
  SET Percentile95 = ResponseTime
  FROM  LoadTestTransactionSummaryData  JOIN #numberedTransactionDetails ON
        LoadTestTransactionSummaryData.LoadTestRunId = #numberedTransactionDetails.LoadTestRunId AND
        LoadTestTransactionSummaryData.TransactionId = #numberedTransactionDetails.TransactionId
  WHERE #numberedTransactionDetails.rowNumber = ceiling(CAST(#numberedTransactionDetails.rCount AS Float)/20)


  UPDATE LoadTestTransactionSummaryData  
  SET Percentile99 = ResponseTime
  FROM  LoadTestTransactionSummaryData  JOIN #numberedTransactionDetails ON
        LoadTestTransactionSummaryData.LoadTestRunId = #numberedTransactionDetails.LoadTestRunId AND
        LoadTestTransactionSummaryData.TransactionId = #numberedTransactionDetails.TransactionId
  WHERE #numberedTransactionDetails.rowNumber = ceiling(CAST(#numberedTransactionDetails.rCount AS Float)/100)



  UPDATE LoadTestTransactionSummaryData  
  SET Median = ResponseTime
  FROM  LoadTestTransactionSummaryData  JOIN #numberedTransactionDetails ON
        LoadTestTransactionSummaryData.LoadTestRunId = #numberedTransactionDetails.LoadTestRunId AND
        LoadTestTransactionSummaryData.TransactionId = #numberedTransactionDetails.TransactionId
  WHERE #numberedTransactionDetails.rowNumber = ceiling(CAST(#numberedTransactionDetails.rCount AS Float)/2)

  DROP TABLE #numberedTransactionDetails
GO
GRANT EXECUTE ON [dbo].[Prc_UpdateTransactionSummary3] TO PUBLIC
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Prc_UpdatePageSummary3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Prc_UpdatePageSummary3]
GO

CREATE PROCEDURE [dbo].[Prc_UpdatePageSummary3] @LoadTestRunId int
AS
If IsNull(object_id('tempdb..#numberedPageDetails'),0) <> 0 DROP TABLE #numberedPageDetails

  SELECT * INTO #numberedPageDetails FROM 
  (
      SELECT ResponseTime, LoadTestRunId, PageId, 
	   rowNumber=ROW_NUMBER() 
	   OVER (PARTITION BY LoadTestRunId, PageId 
                 ORDER BY ResponseTime DESC),
	   COUNT(*) 
           OVER (PARTITION BY LoadTestRunId, PageId) AS rCount
      FROM LoadTestPageDetail
      WHERE LoadTestRunId = @LoadTestRunId AND
        InMeasurementInterval = 1) AS allRows
  WHERE allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 100) OR 
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 20)  OR 
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 10)  OR
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 2) 


  UPDATE LoadTestPageSummaryData 
  SET Percentile90 = ResponseTime
  FROM  LoadTestPageSummaryData  JOIN #numberedPageDetails ON
        LoadTestPageSummaryData.LoadTestRunId = #numberedPageDetails.LoadTestRunId AND
        LoadTestPageSummaryData.PageId = #numberedPageDetails.PageId
  WHERE #numberedPageDetails.rowNumber = ceiling(CAST(#numberedPageDetails.rCount AS Float)/10)

  UPDATE LoadTestPageSummaryData 
  SET Percentile95 = ResponseTime
  FROM  LoadTestPageSummaryData  JOIN #numberedPageDetails ON
        LoadTestPageSummaryData.LoadTestRunId = #numberedPageDetails.LoadTestRunId AND
        LoadTestPageSummaryData.PageId = #numberedPageDetails.PageId
  WHERE #numberedPageDetails.rowNumber = ceiling(CAST(#numberedPageDetails.rCount AS Float)/20)

  UPDATE LoadTestPageSummaryData 
  SET Percentile99 = ResponseTime
  FROM  LoadTestPageSummaryData  JOIN #numberedPageDetails ON
        LoadTestPageSummaryData.LoadTestRunId = #numberedPageDetails.LoadTestRunId AND
        LoadTestPageSummaryData.PageId = #numberedPageDetails.PageId
  WHERE #numberedPageDetails.rowNumber = ceiling(CAST(#numberedPageDetails.rCount AS Float)/100)

  UPDATE LoadTestPageSummaryData 
  SET Median = ResponseTime
  FROM  LoadTestPageSummaryData  JOIN #numberedPageDetails ON
        LoadTestPageSummaryData.LoadTestRunId = #numberedPageDetails.LoadTestRunId AND
        LoadTestPageSummaryData.PageId = #numberedPageDetails.PageId
  WHERE #numberedPageDetails.rowNumber = ceiling(CAST(#numberedPageDetails.rCount AS Float)/2)


  DROP TABLE #numberedPageDetails
GO
GRANT EXECUTE ON [dbo].[Prc_UpdatePageSummary3] TO PUBLIC
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Prc_UpdatePageSummaryByNetwork3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Prc_UpdatePageSummaryByNetwork3]
GO

CREATE PROCEDURE [dbo].[Prc_UpdatePageSummaryByNetwork3] @LoadTestRunId int
AS

If IsNull(object_id('tempdb..#numberedPageAndTestDetails'),0) <> 0 DROP TABLE #numberedPageAndTestDetails

SELECT * INTO #numberedPageAndTestDetails FROM
 (
     SELECT pageDetail.ResponseTime, pageDetail.LoadTestRunId, testDetail.TestCaseId, 
           pageDetail.PageId, testDetail.NetworkId,
	       rowNumber=ROW_NUMBER() 
	       OVER (PARTITION BY pageDetail.LoadTestRunId, pageDetail.PageId , 
	         testDetail.NetworkId ORDER BY pageDetail.ResponseTime DESC),
	       COUNT(*) 
	       OVER (PARTITION BY pageDetail.LoadTestRunId, pageDetail.PageId, 
		     testDetail.NetworkId) AS rCount,
	       SUM(CASE WHEN GoalExceeded=0 THEN 1 ELSE 0 END)
	       OVER (PARTITION BY pageDetail.LoadTestRunId, pageDetail.PageId, 
		   testDetail.NetworkId) AS pagesMeetingGoal
  FROM LoadTestPageDetail AS pageDetail JOIN LoadTestTestDetail AS testDetail
  ON  pageDetail.LoadTestRunId = testDetail.LoadTestRunId AND 
      pageDetail.TestDetailId = testDetail.TestDetailId
  WHERE pageDetail.LoadTestRunId = @LoadTestRunId AND
        pageDetail.InMeasurementInterval = 1) AS allRows
  WHERE allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 100) OR 
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 20)  OR 
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 10)  OR
        allRows.rowNumber = ceiling(CAST(allRows.rCount AS Float) / 2) 


  UPDATE LoadTestPageSummaryByNetwork 
  SET Percentile90 = ResponseTime
  FROM  LoadTestPageSummaryByNetwork  JOIN #numberedPageAndTestDetails ON
        LoadTestPageSummaryByNetwork.LoadTestRunId = #numberedPageAndTestDetails.LoadTestRunId AND
        LoadTestPageSummaryByNetwork.PageId = #numberedPageAndTestDetails.PageId AND
        LoadTestPageSummaryByNetwork.NetworkId = #numberedPageAndTestDetails.NetworkId
  WHERE #numberedPageAndTestDetails.rowNumber = ceiling(CAST(#numberedPageAndTestDetails.rCount AS Float)/10)

  UPDATE LoadTestPageSummaryByNetwork 
  SET Percentile95 = ResponseTime
  FROM  LoadTestPageSummaryByNetwork  JOIN #numberedPageAndTestDetails ON
        LoadTestPageSummaryByNetwork.LoadTestRunId = #numberedPageAndTestDetails.LoadTestRunId AND
        LoadTestPageSummaryByNetwork.PageId = #numberedPageAndTestDetails.PageId AND
        LoadTestPageSummaryByNetwork.NetworkId = #numberedPageAndTestDetails.NetworkId
  WHERE #numberedPageAndTestDetails.rowNumber = ceiling(CAST(#numberedPageAndTestDetails.rCount AS Float)/20)

  UPDATE LoadTestPageSummaryByNetwork 
  SET Percentile99 = ResponseTime
  FROM  LoadTestPageSummaryByNetwork  JOIN #numberedPageAndTestDetails ON
        LoadTestPageSummaryByNetwork.LoadTestRunId = #numberedPageAndTestDetails.LoadTestRunId AND
        LoadTestPageSummaryByNetwork.PageId = #numberedPageAndTestDetails.PageId AND
        LoadTestPageSummaryByNetwork.NetworkId = #numberedPageAndTestDetails.NetworkId
  WHERE #numberedPageAndTestDetails.rowNumber = ceiling(CAST(#numberedPageAndTestDetails.rCount AS Float)/100)

  UPDATE LoadTestPageSummaryByNetwork 
  SET Median = ResponseTime
  FROM  LoadTestPageSummaryByNetwork  JOIN #numberedPageAndTestDetails ON
        LoadTestPageSummaryByNetwork.LoadTestRunId = #numberedPageAndTestDetails.LoadTestRunId AND
        LoadTestPageSummaryByNetwork.PageId = #numberedPageAndTestDetails.PageId AND
        LoadTestPageSummaryByNetwork.NetworkId = #numberedPageAndTestDetails.NetworkId
  WHERE #numberedPageAndTestDetails.rowNumber = ceiling(CAST(#numberedPageAndTestDetails.rCount AS Float)/2)

 UPDATE LoadTestPageSummaryByNetwork 
  SET PagesMeetingGoal =  results.pagesMeetingGoal
  FROM
  (SELECT  LoadTestRunId, PageId, NetworkId,  pagesMeetingGoal FROM #numberedPageAndTestDetails 
   GROUP BY LoadTestRunId, PageId, NetworkId, pagesMeetingGoal) AS results
   JOIN  LoadTestPageSummaryByNetwork
  ON LoadTestPageSummaryByNetwork.LoadTestRunId = results.LoadTestRunId AND
     LoadTestPageSummaryByNetwork.PageId = results.PageId AND
     LoadTestPageSummaryByNetwork.NetworkId = results.NetworkId
  DROP TABLE #numberedPageAndTestDetails

GO
GRANT EXECUTE ON [dbo].[Prc_UpdatePageSummaryByNetwork3] TO PUBLIC
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Prc_UpdateSummaryData3]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Prc_UpdateSummaryData3]
GO

CREATE PROCEDURE [dbo].[Prc_UpdateSummaryData3] @LoadTestRunId int, @DeleteDetailTables bit
AS
BEGIN
	INSERT INTO LoadTestTestSummaryData 
	    (LoadTestRunId, TestCaseId, TestsRun, Average, Minimum, Maximum, StandardDeviation)
	   SELECT LoadTestRunId, TestCaseId,
	          count(*) as TestsRun,
	          avg(ElapsedTime) as Average, 
	          min(ElapsedTime) as Minimum,
	          max(ElapsedTime) as Maximum,
              ISNULL(STDEVP(ElapsedTime),0) AS StandardDeviation
	    FROM  LoadTestTestDetail 
		WHERE LoadTestRunId=@LoadTestRunId
		      AND InMeasurementInterval = 1
	    GROUP BY LoadTestRunId, TestCaseId

        EXEC Prc_UpdateTestSummary3 @LoadTestRunId


	INSERT INTO LoadTestTransactionSummaryData 
	    (LoadTestRunId, TransactionId, TransactionCount, Average, Minimum, Maximum,AvgTransactionTime, StandardDeviation)
	    SELECT LoadTestRunId, TransactionId,
	           count(*) as TransactionCount,
	           avg(ResponseTime) as Average, 
	           min(ResponseTime) as Minimum,
                   max(ResponseTime) as Maximum,
                   avg(ElapsedTime) as AverageTransactionTime,
                   ISNULL(STDEVP(ResponseTime),0) AS StandardDeviation
	    FROM LoadTestTransactionDetail 
		WHERE  LoadTestRunId=@LoadTestRunId
		       AND InMeasurementInterval = 1
	    GROUP BY LoadTestRunId, TransactionId

        EXEC Prc_UpdateTransactionSummary3 @LoadTestRunId


	INSERT INTO LoadTestPageSummaryData 
	    (LoadTestRunId, PageId, PageCount, Average, Minimum, Maximum, StandardDeviation)
	    SELECT LoadTestRunId, PageId,
	           count(*) as PageCount,
	           avg(ResponseTime) as Average, 
	           min(ResponseTime) as Minimum,
	           max(ResponseTime) as Maximum,
                   ISNULL(STDEVP(ResponseTime),0) AS StandardDeviation
	    FROM   LoadTestPageDetail 
		WHERE  LoadTestRunId=@LoadTestRunId
		       AND InMeasurementInterval = 1
	    GROUP BY LoadTestRunId, PageId

        EXEC Prc_UpdatePageSummary3 @LoadTestRunId


	INSERT INTO LoadTestPageSummaryByNetwork
	    (LoadTestRunId, PageId, NetworkId, PageCount, Average, Minimum, Maximum, Goal, StandardDeviation)
	    SELECT pageDetail.LoadTestRunId, pageDetail.PageId, testDetail.NetworkId,
	           count(*) as PageCount,
	           avg(ResponseTime) as Average, 
	           min(ResponseTime) as Minimum,
	           max(ResponseTime) as Maximum,
	           avg(ResponseTimeGoal) as Goal,
                   ISNULL(STDEVP(ResponseTime),0) AS StandardDeviation
	    FROM   LoadTestPageDetail as pageDetail
	    INNER JOIN LoadTestTestDetail as testDetail
	    ON pageDetail.LoadTestRunId = testDetail.LoadTestRunId
	          AND pageDetail.TestDetailId = testDetail.TestDetailId
	    WHERE pageDetail.LoadTestRunId = @LoadTestRunId
		      AND pageDetail.InMeasurementInterval = 1
	    GROUP BY pageDetail.LoadTestRunId, PageId, testDetail.NetworkId
        
        EXEC Prc_UpdatePageSummaryByNetwork3 @LoadTestRunId

	IF @DeleteDetailTables = 1
	BEGIN
		DELETE from LoadTestTestDetail where LoadTestRunId = @LoadTestRunId
		DELETE from LoadTestTransactionDetail where LoadTestRunId = @LoadTestRunId
		DELETE from LoadTestPageDetail where LoadTestRunId = @LoadTestRunId
	END
END
GO
GRANT EXECUTE ON [dbo].[Prc_UpdateSummaryData3] TO PUBLIC
GO



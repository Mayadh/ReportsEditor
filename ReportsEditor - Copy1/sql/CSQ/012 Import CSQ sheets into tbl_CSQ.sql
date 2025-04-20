USE ReportsDB;
GO

BEGIN TRY
    -- Import CSQ data
    MERGE dbo.tbl_CSQ AS target
    USING (
        SELECT 
            csq.[Node ID - Session ID - Sequence No] AS Node_Session_Seq,
            TRY_CONVERT(DATETIME, csq.[Call Start Time]) AS CallStartTime,
            TRY_CONVERT(DATETIME, csq.[Call End Time]) AS CallEndTime,
            TRY_CONVERT(INT, csq.[Contact Disposition]) AS ContactDisposition,
            csq.[Originator DN (Calling Number)] AS OriginatorDN,
            csq.[Destination DN] AS DestinationDN,
            csq.[Called Number] AS CalledNumber,
            csq.[Application Name] AS ApplicationName,
            csq.[CSQ Names] AS CSQNames,
            DATEADD(SECOND, DATEDIFF(SECOND, '1899-12-31', csq.[Queue Time]), '00:00:00') AS QueueTime,
            csq.[Agent Name] AS AgentName,
            DATEADD(SECOND, DATEDIFF(SECOND, '1899-12-31', csq.[Ring Time]), '00:00:00') AS RingTime,
            DATEADD(SECOND, DATEDIFF(SECOND, '1899-12-31', csq.[Talk Time]), '00:00:00') AS TalkTime,
            DATEADD(SECOND, DATEDIFF(SECOND, '1899-12-31', csq.[Work Time]), '00:00:00') AS WorkTime
        FROM OPENROWSET(
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0; Database=C:\ReportsEditor\Report_Files\CSQ.xlsx; HDR=YES; IMEX=1',
            'SELECT [Node ID - Session ID - Sequence No], [Call Start Time], [Call End Time], [Contact Disposition], 
                    [Originator DN (Calling Number)], [Destination DN], [Called Number], [Application Name], 
                    [CSQ Names], [Queue Time], [Agent Name], [Ring Time], [Talk Time], [Work Time] 
             FROM [CSQ$A2:Z]'
        ) AS csq
        WHERE csq.[Node ID - Session ID - Sequence No] IS NOT NULL
          AND LEN(csq.[Node ID - Session ID - Sequence No]) = 15
    ) AS source
    ON target.Node_Session_Seq = source.Node_Session_Seq
        AND target.CallStartTime = source.CallStartTime
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Node_Session_Seq, CallStartTime, CallEndTime, ContactDisposition, OriginatorDN, DestinationDN, 
                CalledNumber, ApplicationName, CSQNames, QueueTime, AgentName, RingTime, TalkTime, WorkTime)
        VALUES (source.Node_Session_Seq, source.CallStartTime, source.CallEndTime, source.ContactDisposition, source.OriginatorDN, source.DestinationDN, 
                source.CalledNumber, source.ApplicationName, source.CSQNames, source.QueueTime, source.AgentName, source.RingTime, source.TalkTime, 
                source.WorkTime);

    -- Log the number of records inserted
    PRINT 'CSQ data import completed successfully.';
    PRINT 'Number of records inserted: ' + CAST(@@ROWCOUNT AS VARCHAR);
END TRY
BEGIN CATCH
    PRINT 'An error occurred while importing CSQ data.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
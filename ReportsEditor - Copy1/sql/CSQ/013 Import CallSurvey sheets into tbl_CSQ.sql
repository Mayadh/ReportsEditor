USE ReportsDB;
GO

BEGIN TRY
    -- Import CallSurvey data
    MERGE dbo.tbl_CSQ AS target
    USING (
        SELECT 
            -- Extract SessionID by removing the first 2 characters and the last 2 characters
            SUBSTRING(
                cs.[Node ID- Session ID - Sequence No], 
                3, 
                LEN(cs.[Node ID- Session ID - Sequence No]) - 4
            ) AS SessionID,
            cs.[Customer feedback] AS CallSurvey
        FROM OPENROWSET(
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0; Database=C:\ReportsEditor\Report_Files\CallSurvey.xlsx; HDR=YES; IMEX=1',
            'SELECT [Node ID- Session ID - Sequence No], [Customer feedback] FROM [CallSurvey$A2:Z]'
        ) AS cs
        WHERE cs.[Customer feedback] IN ('Yes', 'No') -- Only include records with "Yes" or "No" feedback
          AND LEN(cs.[Node ID- Session ID - Sequence No]) = 15 -- Ensure the length is correct
    ) AS source
    ON target.SessionID = source.SessionID -- Match on SessionID
    WHEN MATCHED THEN
        UPDATE SET
            CallSurvey = source.CallSurvey; -- Update all matching records with the same SessionID
END TRY
BEGIN CATCH
    PRINT 'An error occurred while importing CallSurvey data.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
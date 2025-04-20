USE ReportsDB;
GO

DROP TABLE IF EXISTS dbo.tbl_CSQ_Violations;
GO

-- Create the table to store the violations from the CSQ report
-- This table will store the violations from the CSQ report, including Abandoned/Missed calls, long ring times, and customer feedback from the survey.
-- The table will also include additional fields for notes and approvals.
-- The table will have the same ID as in tbl_CSQ to maintain the relationship between the original and violation records.
-- The computed fields will be persisted to store the calculated values.

CREATE TABLE dbo.tbl_CSQ_Violations
(
    ID INT PRIMARY KEY,  -- Same ID as in tbl_CSQ
    Node_Session_Seq NVARCHAR(50) NOT NULL,
    CallStartTime DATETIME NULL,
    CallEndTime DATETIME NULL,
    ContactDisposition INT NULL,
    OriginatorDN NVARCHAR(50) NULL,
    DestinationDN NVARCHAR(50) NULL,
    CalledNumber NVARCHAR(20) NULL,
    ApplicationName NVARCHAR(100) NULL,
    CSQNames NVARCHAR(100) NULL,
    QueueTime TIME NULL,
    AgentName NVARCHAR(100) NULL,
    RingTime TIME NULL,
    TalkTime TIME NULL,
    WorkTime TIME NULL,
    SessionID NVARCHAR(50) NULL,
    CallSurvey NVARCHAR(10) NULL,
    Violation_ABD BIT NULL,
    Violation_Ring BIT NULL,
    Violation_CallSurvey BIT NULL,
    -- Additional fields for notes and approvals
    Violation_ABD_Reason NVARCHAR(255) NULL,
    Violation_ABD_Approval BIT NULL,
    Violation_Ring_Reason NVARCHAR(255) NULL,
    Violation_Ring_Approval BIT NULL,
    Violation_CallSurvey_Reason NVARCHAR(255) NULL,
    Violation_CallSurvey_Approval BIT NULL
);
GO

-- Insert existing records with violations
INSERT INTO dbo.tbl_CSQ_Violations
SELECT 
    ID, Node_Session_Seq, CallStartTime, CallEndTime, ContactDisposition, 
    OriginatorDN, DestinationDN, CalledNumber, ApplicationName, CSQNames, 
    QueueTime, AgentName, RingTime, TalkTime, WorkTime, SessionID, 
    CallSurvey, Violation_ABD, Violation_Ring, Violation_CallSurvey,
    NULL AS Violation_ABD_Reason,
    NULL AS Violation_ABD_Approval,
    NULL AS Violation_Ring_Reason,
    NULL AS Violation_Ring_Approval,
    NULL AS Violation_CallSurvey_Reason,
    NULL AS Violation_CallSurvey_Approval
FROM 
    dbo.tbl_CSQ
WHERE 
    Violation_ABD = 1 OR Violation_Ring = 1 OR Violation_CallSurvey = 1;
GO

-- Drop the existing insert trigger if it exists
IF OBJECT_ID('dbo.trg_Insert_CSQ_Violations', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Insert_CSQ_Violations;
GO

-- Create a trigger to keep the table updated on insert
CREATE TRIGGER trg_Insert_CSQ_Violations
ON dbo.tbl_CSQ
AFTER INSERT
AS
BEGIN
    -- Update existing records in tbl_CSQ_Violations
    UPDATE v
    SET 
        v.Node_Session_Seq = i.Node_Session_Seq,
        v.CallStartTime = i.CallStartTime,
        v.CallEndTime = i.CallEndTime,
        v.ContactDisposition = i.ContactDisposition,
        v.OriginatorDN = i.OriginatorDN,
        v.DestinationDN = i.DestinationDN,
        v.CalledNumber = i.CalledNumber,
        v.ApplicationName = i.ApplicationName,
        v.CSQNames = i.CSQNames,
        v.QueueTime = i.QueueTime,
        v.AgentName = i.AgentName,
        v.RingTime = i.RingTime,
        v.TalkTime = i.TalkTime,
        v.WorkTime = i.WorkTime,
        v.SessionID = i.SessionID,
        v.CallSurvey = i.CallSurvey,
        v.Violation_ABD = i.Violation_ABD,
        v.Violation_Ring = i.Violation_Ring,
        v.Violation_CallSurvey = i.Violation_CallSurvey
    FROM 
        dbo.tbl_CSQ_Violations v
    INNER JOIN 
        inserted i ON v.ID = i.ID;

    -- Insert new records into tbl_CSQ_Violations
    INSERT INTO dbo.tbl_CSQ_Violations
    SELECT 
        i.ID, i.Node_Session_Seq, i.CallStartTime, i.CallEndTime, i.ContactDisposition, 
        i.OriginatorDN, i.DestinationDN, i.CalledNumber, i.ApplicationName, i.CSQNames, 
        i.QueueTime, i.AgentName, i.RingTime, i.TalkTime, i.WorkTime, i.SessionID, 
        i.CallSurvey, i.Violation_ABD, i.Violation_Ring, i.Violation_CallSurvey,
        NULL AS Violation_ABD_Reason,
        NULL AS Violation_ABD_Approval,
        NULL AS Violation_Ring_Reason,
        NULL AS Violation_Ring_Approval,
        NULL AS Violation_CallSurvey_Reason,
        NULL AS Violation_CallSurvey_Approval
    FROM 
        inserted i
    WHERE 
        (i.Violation_ABD = 1 OR i.Violation_Ring = 1 OR i.Violation_CallSurvey = 1)
        AND i.ID NOT IN (SELECT ID FROM dbo.tbl_CSQ_Violations);
END;
GO

-- Drop the existing update trigger if it exists
IF OBJECT_ID('dbo.trg_Update_CSQ_Violations', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Update_CSQ_Violations;
GO

-- Create a trigger to keep the table updated on update
CREATE TRIGGER trg_Update_CSQ_Violations
ON dbo.tbl_CSQ
AFTER UPDATE
AS
BEGIN
    -- Update existing records in tbl_CSQ_Violations
    UPDATE v
    SET 
        v.Node_Session_Seq = i.Node_Session_Seq,
        v.CallStartTime = i.CallStartTime,
        v.CallEndTime = i.CallEndTime,
        v.ContactDisposition = i.ContactDisposition,
        v.OriginatorDN = i.OriginatorDN,
        v.DestinationDN = i.DestinationDN,
        v.CalledNumber = i.CalledNumber,
        v.ApplicationName = i.ApplicationName,
        v.CSQNames = i.CSQNames,
        v.QueueTime = i.QueueTime,
        v.AgentName = i.AgentName,
        v.RingTime = i.RingTime,
        v.TalkTime = i.TalkTime,
        v.WorkTime = i.WorkTime,
        v.SessionID = i.SessionID,
        v.CallSurvey = i.CallSurvey,
        v.Violation_ABD = i.Violation_ABD,
        v.Violation_Ring = i.Violation_Ring,
        v.Violation_CallSurvey = i.Violation_CallSurvey
    FROM 
        dbo.tbl_CSQ_Violations v
    INNER JOIN 
        inserted i ON v.ID = i.ID;

    -- Insert new records into tbl_CSQ_Violations
    INSERT INTO dbo.tbl_CSQ_Violations
    SELECT 
        i.ID, i.Node_Session_Seq, i.CallStartTime, i.CallEndTime, i.ContactDisposition, 
        i.OriginatorDN, i.DestinationDN, i.CalledNumber, i.ApplicationName, i.CSQNames, 
        i.QueueTime, i.AgentName, i.RingTime, i.TalkTime, i.WorkTime, i.SessionID, 
        i.CallSurvey, i.Violation_ABD, i.Violation_Ring, i.Violation_CallSurvey,
        NULL AS Violation_ABD_Reason,
        NULL AS Violation_ABD_Approval,
        NULL AS Violation_Ring_Reason,
        NULL AS Violation_Ring_Approval,
        NULL AS Violation_CallSurvey_Reason,
        NULL AS Violation_CallSurvey_Approval
    FROM 
        inserted i
    WHERE 
        (i.Violation_ABD = 1 OR i.Violation_Ring = 1 OR i.Violation_CallSurvey = 1)
        AND i.ID NOT IN (SELECT ID FROM dbo.tbl_CSQ_Violations);
END;
GO

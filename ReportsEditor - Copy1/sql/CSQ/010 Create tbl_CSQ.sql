USE ReportsDB;
GO

DROP TABLE IF EXISTS dbo.tbl_CSQ;
GO

-- Create the table to store the raw data from the Excel file
-- and the computed fields for the CSQ report
-- This table will store the data from the Excel file and additional calculated fields for the CSQ report.
-- The calculated fields will include flags for Abandoned/Missed calls, long ring times, and customer feedback from the survey.
-- The table will also include a new ID column for primary key.
-- The computed fields will be persisted to store the calculated values.
-- The session ID will be extracted from the Node_Session_Seq column.
-- The CallSurvey column will be used to store the customer feedback from the CallSurvey.xlsx file.

CREATE TABLE dbo.tbl_CSQ
(
    ID INT IDENTITY(1,1) PRIMARY KEY,  -- New ID column
    -- Raw data from the Excel file
    Node_Session_Seq       NVARCHAR(50)    NOT NULL,  -- Original (Node ID - Session ID - Sequence No)
    CallStartTime          DATETIME       NULL,
    CallEndTime            DATETIME       NULL,
    ContactDisposition     INT            NULL,      -- 1=Abandoned, 2=Received, 4=Call Issue
    OriginatorDN           NVARCHAR(50)    NULL,      -- Calling Number
    DestinationDN          NVARCHAR(50)    NULL,
    CalledNumber           NVARCHAR(20)    NULL,      -- (9000) indicates inbound
    ApplicationName        NVARCHAR(100)   NULL,
    CSQNames               NVARCHAR(100)   NULL,
    QueueTime              TIME           NULL,
    AgentName              NVARCHAR(100)   NULL,
    RingTime               TIME           NULL,
    TalkTime               TIME           NULL,
    WorkTime               TIME           NULL,
    
    -- Computed or looked-up/calculated fields
    SessionID AS (
         RIGHT(LEFT(Node_Session_Seq, LEN(Node_Session_Seq) - 2),
               LEN(LEFT(Node_Session_Seq, LEN(Node_Session_Seq) - 2)) - 2)
    ) PERSISTED,  -- Extracted session id
    
    CallSurvey NVARCHAR(10) NULL,  -- From CallSurvey.xlsx   
    
    Violation_ABD AS (
        CASE 
            WHEN ContactDisposition = 1 
                 AND CalledNumber = '9000'
                 AND DATEDIFF(SECOND, '00:00:00', QueueTime) > 60 
            THEN 1 ELSE 0 
        END
    ),  -- Calculated flag for Abandoned/Missed call
    
    Violation_Ring AS (
        CASE 
            WHEN ContactDisposition = 2 
                 AND CalledNumber = '9000'
                 AND DATEDIFF(SECOND, '00:00:00', RingTime) > 12 
            THEN 1 ELSE 0 
        END
    ),  -- Calculated flag for Received call with long ring time
    
    Violation_CallSurvey AS (
        CASE 
            WHEN CallSurvey = 'No'
            THEN 1 ELSE 0 
        END
    ),  -- Calculated flag based on call customer feedback

    
);
GO
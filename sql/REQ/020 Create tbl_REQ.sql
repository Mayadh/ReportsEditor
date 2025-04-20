USE ReportsDB;
GO

-- Drop the table if it exists
DROP TABLE IF EXISTS dbo.tbl_REQ;
GO

-- Create the table to store the raw data from the Excel file
-- and the computed fields for the REQ report
CREATE TABLE dbo.tbl_REQ
(
    ID INT IDENTITY(1,1) PRIMARY KEY,  -- New ID column
    -- Raw data from the Excel file
    Submit_Date_Time          DATETIME       NULL,
    Approved_Date             DATETIME       NULL,
    Responded_Date            DATETIME       NULL,
    Completion_Date_Time      DATETIME       NULL,
    Closed_Date_Time          DATETIME       NULL,
    Re_Opened_Date            DATETIME       NULL,
    Last_Resolved_Date        DATETIME       NULL,
    Completion_Closed_Date    DATETIME       NULL,
    Last_Modified_Date_INC    DATETIME       NULL,
    Last_Modified_Date_WO     DATETIME       NULL,
    Last_Modified_Date_REQ    DATETIME       NULL,
    Request_Number            NVARCHAR(50)    NULL,
    Incident_Number           NVARCHAR(50)    NULL,  -- New column
    Work_Order_ID             NVARCHAR(50)    NULL,  -- New column
    Request_Priority          NVARCHAR(50)    NULL,
    Request_Categorization1   NVARCHAR(100)   NULL,
    Request_Categorization2   NVARCHAR(100)   NULL,
    Request_Categorization3   NVARCHAR(100)   NULL,
    CST_FCR                   NVARCHAR(50)    NULL,
    Full_Name                 NVARCHAR(100)   NULL,
    Customer_Full_Name        NVARCHAR(100)   NULL,
    Customer_Internet_Email   NVARCHAR(100)   NULL,
    Customer_Phone_Number     NVARCHAR(50)    NULL,
    Phone_Number              NVARCHAR(50)    NULL,
    Summary                   NVARCHAR(MAX)   NULL,
    Request_VIP               BIT            NULL,
    Request_Type              NVARCHAR(50)    NULL,
    Request_Group             NVARCHAR(50)    NULL,
    Request_Assignee          NVARCHAR(100)   NULL,
    Request_SLM_Status        NVARCHAR(50)    NULL,
    SRM_Status                NVARCHAR(50)    NULL,
    Sum_ReqSurvey_Rating      NVARCHAR(50)    NULL,
    ReqSurvey_Response        NVARCHAR(MAX)   NULL,

    -- Computed column for unique identifier
    Unique_Identifier AS (
        Request_Number + '-' + ISNULL(Incident_Number, '') + '-' + ISNULL(Work_Order_ID, '')
    ) PERSISTED,  -- Concatenated unique identifier

    -- Calculated fields
    Violation_SLM AS (
        CASE 
            WHEN Request_SLM_Status = N'Service Targets Breached' 
            THEN 1 ELSE 0 
        END
    ) PERSISTED,  -- Calculated flag for SLM violation

    Violation_ReqSurvey AS (
        CASE 
            WHEN TRY_CONVERT(DECIMAL(3,2), Sum_ReqSurvey_Rating) IN (1.00, 2.00)
            THEN 1 ELSE 0 
        END
    ) PERSISTED  -- Calculated flag for survey violation
);
GO
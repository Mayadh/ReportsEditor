USE ReportsDB;
GO

-- Drop the table if it exists
DROP TABLE IF EXISTS dbo.tbl_REQ_Violations;
GO

-- Create the table to store violations from the REQ report
CREATE TABLE dbo.tbl_REQ_Violations
(
    ID INT PRIMARY KEY,  -- Same ID as in tbl_REQ
    Submit_Date_Time DATETIME NULL,
    Approved_Date DATETIME NULL,
    Responded_Date DATETIME NULL,
    Completion_Date_Time DATETIME NULL,
    Closed_Date_Time DATETIME NULL,
    Re_Opened_Date DATETIME NULL,
    Last_Resolved_Date DATETIME NULL,
    Completion_Closed_Date DATETIME NULL,
    Last_Modified_Date_INC DATETIME NULL,
    Last_Modified_Date_WO DATETIME NULL,
    Last_Modified_Date_REQ DATETIME NULL,
    Request_Number NVARCHAR(50) NULL,
    Incident_Number NVARCHAR(50) NULL,  -- New column
    Work_Order_ID NVARCHAR(50) NULL,    -- New column
    Request_Priority NVARCHAR(50) NULL,
    Request_Categorization1 NVARCHAR(100) NULL,
    Request_Categorization2 NVARCHAR(100) NULL,
    Request_Categorization3 NVARCHAR(100) NULL,
    CST_FCR NVARCHAR(50) NULL,
    Full_Name NVARCHAR(100) NULL,
    Customer_Full_Name NVARCHAR(100) NULL,
    Customer_Internet_Email NVARCHAR(100) NULL,
    Customer_Phone_Number NVARCHAR(50) NULL,
    Phone_Number NVARCHAR(50) NULL,
    Summary NVARCHAR(MAX) NULL,
    Request_VIP BIT NULL,
    Request_Type NVARCHAR(50) NULL,
    Request_Group NVARCHAR(50) NULL,
    Request_Assignee NVARCHAR(100) NULL,
    Request_SLM_Status NVARCHAR(50) NULL,
    SRM_Status NVARCHAR(50) NULL,
    Sum_ReqSurvey_Rating NVARCHAR(50) NULL,
    ReqSurvey_Response NVARCHAR(MAX) NULL,
    Violation_SLM BIT NULL,
    Violation_ReqSurvey BIT NULL,
    -- Additional fields for notes and approvals
    Violation_SLM_Reason NVARCHAR(255) NULL,
    Violation_SLM_Approval BIT NULL,
    Violation_ReqSurvey_Reason NVARCHAR(255) NULL,
    Violation_ReqSurvey_Approval BIT NULL,
    -- Computed column for unique identifier
    Unique_Identifier AS (
        Request_Number + '-' + ISNULL(Incident_Number, '') + '-' + ISNULL(Work_Order_ID, '')
    ) PERSISTED  -- Concatenated unique identifier
);
GO

-- Insert existing records with violations
INSERT INTO dbo.tbl_REQ_Violations
SELECT 
    ID, Submit_Date_Time, Approved_Date, Responded_Date, Completion_Date_Time, 
    Closed_Date_Time, Re_Opened_Date, Last_Resolved_Date, Completion_Closed_Date, 
    Last_Modified_Date_INC, Last_Modified_Date_WO, Last_Modified_Date_REQ, 
    Request_Number, Incident_Number, Work_Order_ID,  -- New columns
    Request_Priority, Request_Categorization1, Request_Categorization2, 
    Request_Categorization3, CST_FCR, Full_Name, Customer_Full_Name, Customer_Internet_Email, 
    Customer_Phone_Number, Phone_Number, Summary, Request_VIP, Request_Type, 
    Request_Group, Request_Assignee, Request_SLM_Status, SRM_Status, Sum_ReqSurvey_Rating, 
    ReqSurvey_Response, Violation_SLM, Violation_ReqSurvey,
    NULL AS Violation_SLM_Reason,
    NULL AS Violation_SLM_Approval,
    NULL AS Violation_ReqSurvey_Reason,
    NULL AS Violation_ReqSurvey_Approval
FROM 
    dbo.tbl_REQ
WHERE 
    Request_Group = 'Service Desk' AND (Violation_SLM = 1 OR Violation_ReqSurvey = 1);
GO

-- Drop the existing insert trigger if it exists
IF OBJECT_ID('dbo.trg_Insert_REQ_Violations', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Insert_REQ_Violations;
GO

-- Create a trigger to keep the table updated on insert
CREATE TRIGGER trg_Insert_REQ_Violations
ON dbo.tbl_REQ
AFTER INSERT
AS
BEGIN
    -- Update existing records in tbl_REQ_Violations
    UPDATE v
    SET 
        v.Submit_Date_Time = i.Submit_Date_Time,
        v.Approved_Date = i.Approved_Date,
        v.Responded_Date = i.Responded_Date,
        v.Completion_Date_Time = i.Completion_Date_Time,
        v.Closed_Date_Time = i.Closed_Date_Time,
        v.Re_Opened_Date = i.Re_Opened_Date,
        v.Last_Resolved_Date = i.Last_Resolved_Date,
        v.Completion_Closed_Date = i.Completion_Closed_Date,
        v.Last_Modified_Date_INC = i.Last_Modified_Date_INC,
        v.Last_Modified_Date_WO = i.Last_Modified_Date_WO,
        v.Last_Modified_Date_REQ = i.Last_Modified_Date_REQ,
        v.Request_Number = i.Request_Number,
        v.Incident_Number = i.Incident_Number,  -- New column
        v.Work_Order_ID = i.Work_Order_ID,      -- New column
        v.Request_Priority = i.Request_Priority,
        v.Request_Categorization1 = i.Request_Categorization1,
        v.Request_Categorization2 = i.Request_Categorization2,
        v.Request_Categorization3 = i.Request_Categorization3,
        v.CST_FCR = i.CST_FCR,
        v.Full_Name = i.Full_Name,
        v.Customer_Full_Name = i.Customer_Full_Name,
        v.Customer_Internet_Email = i.Customer_Internet_Email,
        v.Customer_Phone_Number = i.Customer_Phone_Number,
        v.Phone_Number = i.Phone_Number,
        v.Summary = i.Summary,
        v.Request_VIP = i.Request_VIP,
        v.Request_Type = i.Request_Type,
        v.Request_Group = i.Request_Group,
        v.Request_Assignee = i.Request_Assignee,
        v.Request_SLM_Status = i.Request_SLM_Status,
        v.SRM_Status = i.SRM_Status,
        v.Sum_ReqSurvey_Rating = i.Sum_ReqSurvey_Rating,
        v.ReqSurvey_Response = i.ReqSurvey_Response,
        v.Violation_SLM = i.Violation_SLM,
        v.Violation_ReqSurvey = i.Violation_ReqSurvey
    FROM 
        dbo.tbl_REQ_Violations v
    INNER JOIN 
        inserted i ON v.ID = i.ID;

    -- Insert new records into tbl_REQ_Violations
    INSERT INTO dbo.tbl_REQ_Violations
    SELECT 
        i.ID, i.Submit_Date_Time, i.Approved_Date, i.Responded_Date, i.Completion_Date_Time, 
        i.Closed_Date_Time, i.Re_Opened_Date, i.Last_Resolved_Date, i.Completion_Closed_Date, 
        i.Last_Modified_Date_INC, i.Last_Modified_Date_WO, i.Last_Modified_Date_REQ, 
        i.Request_Number, i.Incident_Number, i.Work_Order_ID,  -- New columns
        i.Request_Priority, i.Request_Categorization1, i.Request_Categorization2, 
        i.Request_Categorization3, i.CST_FCR, i.Full_Name, i.Customer_Full_Name, i.Customer_Internet_Email, 
        i.Customer_Phone_Number, i.Phone_Number, i.Summary, i.Request_VIP, i.Request_Type, 
        i.Request_Group, i.Request_Assignee, i.Request_SLM_Status, i.SRM_Status, i.Sum_ReqSurvey_Rating, 
        i.ReqSurvey_Response, i.Violation_SLM, i.Violation_ReqSurvey,
        NULL AS Violation_SLM_Reason,
        NULL AS Violation_SLM_Approval,
        NULL AS Violation_ReqSurvey_Reason,
        NULL AS Violation_ReqSurvey_Approval
    FROM 
        inserted i
    WHERE 
        i.Request_Group = 'Service Desk' AND (i.Violation_SLM = 1 OR i.Violation_ReqSurvey = 1)
        AND i.ID NOT IN (SELECT ID FROM dbo.tbl_REQ_Violations);
END;
GO

-- Drop the existing update trigger if it exists
IF OBJECT_ID('dbo.trg_Update_REQ_Violations', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_Update_REQ_Violations;
GO

-- Create a trigger to keep the table updated on update
CREATE TRIGGER trg_Update_REQ_Violations
ON dbo.tbl_REQ
AFTER UPDATE
AS
BEGIN
    -- Update existing records in tbl_REQ_Violations
    UPDATE v
    SET 
        v.Submit_Date_Time = i.Submit_Date_Time,
        v.Approved_Date = i.Approved_Date,
        v.Responded_Date = i.Responded_Date,
        v.Completion_Date_Time = i.Completion_Date_Time,
        v.Closed_Date_Time = i.Closed_Date_Time,
        v.Re_Opened_Date = i.Re_Opened_Date,
        v.Last_Resolved_Date = i.Last_Resolved_Date,
        v.Completion_Closed_Date = i.Completion_Closed_Date,
        v.Last_Modified_Date_INC = i.Last_Modified_Date_INC,
        v.Last_Modified_Date_WO = i.Last_Modified_Date_WO,
        v.Last_Modified_Date_REQ = i.Last_Modified_Date_REQ,
        v.Request_Number = i.Request_Number,
        v.Incident_Number = i.Incident_Number,  -- New column
        v.Work_Order_ID = i.Work_Order_ID,      -- New column
        v.Request_Priority = i.Request_Priority,
        v.Request_Categorization1 = i.Request_Categorization1,
        v.Request_Categorization2 = i.Request_Categorization2,
        v.Request_Categorization3 = i.Request_Categorization3,
        v.CST_FCR = i.CST_FCR,
        v.Full_Name = i.Full_Name,
        v.Customer_Full_Name = i.Customer_Full_Name,
        v.Customer_Internet_Email = i.Customer_Internet_Email,
        v.Customer_Phone_Number = i.Customer_Phone_Number,
        v.Phone_Number = i.Phone_Number,
        v.Summary = i.Summary,
        v.Request_VIP = i.Request_VIP,
        v.Request_Type = i.Request_Type,
        v.Request_Group = i.Request_Group,
        v.Request_Assignee = i.Request_Assignee,
        v.Request_SLM_Status = i.Request_SLM_Status,
        v.SRM_Status = i.SRM_Status,
        v.Sum_ReqSurvey_Rating = i.Sum_ReqSurvey_Rating,
        v.ReqSurvey_Response = i.ReqSurvey_Response,
        v.Violation_SLM = i.Violation_SLM,
        v.Violation_ReqSurvey = i.Violation_ReqSurvey
    FROM 
        dbo.tbl_REQ_Violations v
    INNER JOIN 
        inserted i ON v.ID = i.ID;

    -- Insert new records into tbl_REQ_Violations
    INSERT INTO dbo.tbl_REQ_Violations
    SELECT 
        i.ID, i.Submit_Date_Time, i.Approved_Date, i.Responded_Date, i.Completion_Date_Time, 
        i.Closed_Date_Time, i.Re_Opened_Date, i.Last_Resolved_Date, i.Completion_Closed_Date, 
        i.Last_Modified_Date_INC, i.Last_Modified_Date_WO, i.Last_Modified_Date_REQ, 
        i.Request_Number, i.Incident_Number, i.Work_Order_ID,  -- New columns
        i.Request_Priority, i.Request_Categorization1, i.Request_Categorization2, 
        i.Request_Categorization3, i.CST_FCR, i.Full_Name, i.Customer_Full_Name, i.Customer_Internet_Email, 
        i.Customer_Phone_Number, i.Phone_Number, i.Summary, i.Request_VIP, i.Request_Type, 
        i.Request_Group, i.Request_Assignee, i.Request_SLM_Status, i.SRM_Status, i.Sum_ReqSurvey_Rating, 
        i.ReqSurvey_Response, i.Violation_SLM, i.Violation_ReqSurvey,
        NULL AS Violation_SLM_Reason,
        NULL AS Violation_SLM_Approval,
        NULL AS Violation_ReqSurvey_Reason,
        NULL AS Violation_ReqSurvey_Approval
    FROM 
        inserted i
    WHERE 
        i.Request_Group = 'Service Desk' AND (i.Violation_SLM = 1 OR i.Violation_ReqSurvey = 1)
        AND i.ID NOT IN (SELECT ID FROM dbo.tbl_REQ_Violations);
END;
GO
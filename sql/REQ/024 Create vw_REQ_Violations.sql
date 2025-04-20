USE ReportsDB;
GO

-- Create a SQL View vw_REQ_Violations

CREATE VIEW vw_REQ_Violations
AS
SELECT 
    ID,
    Request_Number,
    Submit_Date_Time,
    Approved_Date,
    Responded_Date,
    Completion_Date_Time,
    Closed_Date_Time,
    Re_Opened_Date,
    Last_Resolved_Date,
    Completion_Closed_Date,
    Last_Modified_Date_INC,
    Last_Modified_Date_WO,
    Last_Modified_Date_REQ,
    Request_Priority,
    Request_Categorization1,
    Request_Categorization2,
    Request_Categorization3,
    CST_FCR,
    Full_Name,
    Customer_Full_Name,
    Customer_Internet_Email,
    Customer_Phone_Number,
    Phone_Number,
    Summary,
    Request_VIP,
    Request_Type,
    Request_Group,
    Request_Assignee,
    Request_SLM_Status,
    SRM_Status,
    Sum_ReqSurvey_Rating,
    ReqSurvey_Response,
    Violation_SLM,
    Violation_SLM_Reason,
    Violation_SLM_Approval,
    Violation_ReqSurvey,
    Violation_ReqSurvey_Reason,
    Violation_ReqSurvey_Approval,
    Unique_Identifier
FROM dbo.tbl_REQ_Violations;
GO

USE ReportsDB;
GO

-- Create a SQL View vw_REQ_Violations_Missing_Justifications
CREATE VIEW vw_REQ_Violations_Missing_Reasons
AS
SELECT 
    ID,
    Request_Number,
    Submit_Date_Time,
    Full_Name,
    Customer_Full_Name,
    Summary,
    Request_VIP,
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
FROM dbo.tbl_REQ_Violations
WHERE (Violation_SLM = 1 AND Violation_SLM_Reason IS NULL)
   OR (Violation_ReqSurvey = 1 AND Violation_ReqSurvey_Reason IS NULL);
GO

USE ReportsDB;
GO

-- Create a SQL View vw_CSQ_Violations
CREATE VIEW vw_CSQ_Violations
AS
SELECT 
    ID,
    Node_Session_Seq,
    SessionID,
    CallStartTime,
    CallEndTime,
    ContactDisposition,
    OriginatorDN,
    CalledNumber,
    QueueTime,
    AgentName,
    RingTime,
    TalkTime,
    CallSurvey,
    Violation_ABD,
    Violation_ABD_Reason,
    Violation_ABD_Approval,
    Violation_Ring,
    Violation_Ring_Reason,
    Violation_Ring_Approval,
    Violation_CallSurvey,
    Violation_CallSurvey_Reason,
    Violation_CallSurvey_Approval
FROM dbo.tbl_CSQ_Violations;
GO

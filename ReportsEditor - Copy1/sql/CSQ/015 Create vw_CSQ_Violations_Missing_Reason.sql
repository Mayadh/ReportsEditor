USE ReportsDB;
GO

-- Create a SQL View vw_CSQ_Violations_Missing_Justifications
CREATE VIEW vw_CSQ_Violations_Missing_Reasons
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
FROM dbo.tbl_CSQ_Violations
WHERE (Violation_ABD = 1 AND Violation_ABD_Reason IS NULL)
   OR (Violation_Ring = 1 AND Violation_Ring_Reason IS NULL)
   OR (Violation_CallSurvey = 1 AND Violation_CallSurvey_Reason IS NULL);
GO

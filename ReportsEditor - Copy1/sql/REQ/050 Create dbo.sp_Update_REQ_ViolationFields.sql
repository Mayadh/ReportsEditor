USE ReportsDB;
GO

-- Stored Procedures for Updating Violations from Web dbo.sp_Update_REQ_ViolationFields

CREATE PROCEDURE dbo.sp_Update_REQ_ViolationFields
    @ID INT,
    @ViolationType VARCHAR(10),  -- e.g., 'SLM' or 'ReqSurvey'
    @Reason VARCHAR(255),
    @Approval BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @ViolationType = 'SLM'
    BEGIN
        UPDATE dbo.tbl_REQ_Violations
        SET Violation_SLM_Reason = @Reason,
            Violation_SLM_Approval = @Approval
        WHERE ID = @ID;
    END
    ELSE IF @ViolationType = 'ReqSurvey'
    BEGIN
        UPDATE dbo.tbl_REQ_Violations
        SET Violation_ReqSurvey_Reason = @Reason,
            Violation_ReqSurvey_Approval = @Approval
        WHERE ID = @ID;
    END
END;
GO

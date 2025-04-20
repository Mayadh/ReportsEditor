USE ReportsDB;
GO

-- Stored Procedures for Updating Violations from Web dbo.sp_Update_CSQ_ViolationFields

CREATE PROCEDURE dbo.sp_Update_CSQ_ViolationFields
    @ID INT,
    @ViolationType VARCHAR(10),  -- e.g., 'ABD', 'Ring', or 'CallSurvey'
    @Reason VARCHAR(255),
    @Approval BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @ViolationType = 'ABD'
    BEGIN
        UPDATE dbo.tbl_CSQ_Violations
        SET Violation_ABD_Reason = @Reason,
            Violation_ABD_Approval = @Approval
        WHERE ID = @ID;
    END
    ELSE IF @ViolationType = 'Ring'
    BEGIN
        UPDATE dbo.tbl_CSQ_Violations
        SET Violation_Ring_Reason = @Reason,
            Violation_Ring_Approval = @Approval
        WHERE ID = @ID;
    END
    ELSE IF @ViolationType = 'CallSurvey'
    BEGIN
        UPDATE dbo.tbl_CSQ_Violations
        SET Violation_CallSurvey_Reason = @Reason,
            Violation_CallSurvey_Approval = @Approval
        WHERE ID = @ID;
    END
END;
GO

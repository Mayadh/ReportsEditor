USE ReportsDB;
GO

BEGIN TRY
    -- Perform the MERGE operation
    MERGE dbo.tbl_REQ AS target
    USING (
        SELECT 
            TRY_CONVERT(DATETIME, req.[Submit Date Time]) AS Submit_Date_Time,
            TRY_CONVERT(DATETIME, req.[Approved Date]) AS Approved_Date,
            TRY_CONVERT(DATETIME, req.[Responded Date]) AS Responded_Date,
            TRY_CONVERT(DATETIME, req.[Completion Date Time]) AS Completion_Date_Time,
            TRY_CONVERT(DATETIME, req.[Closed Date Time]) AS Closed_Date_Time,
            TRY_CONVERT(DATETIME, req.[Re-Opened Date]) AS Re_Opened_Date,
            TRY_CONVERT(DATETIME, req.[Last Resolved Date]) AS Last_Resolved_Date,
            TRY_CONVERT(DATETIME, req.[Completion_Closed_Date]) AS Completion_Closed_Date,
            TRY_CONVERT(DATETIME, req.[Last Modified Date INC]) AS Last_Modified_Date_INC,
            TRY_CONVERT(DATETIME, req.[Last Modified Date WO]) AS Last_Modified_Date_WO,
            TRY_CONVERT(DATETIME, req.[Last Modified Date REQ]) AS Last_Modified_Date_REQ,
            req.[Request Number] AS Request_Number,
            req.[Incident Number] AS Incident_Number,  -- New column
            req.[Work Order ID] AS Work_Order_ID,      -- New column
            req.[Request_Priority] AS Request_Priority,
            req.[Request_Categorization1] AS Request_Categorization1,
            req.[Request_Categorization2] AS Request_Categorization2,
            req.[Request_Categorization3] AS Request_Categorization3,
            req.[CST_FCR] AS CST_FCR,
            req.[Full Name] AS Full_Name,
            req.[Customer Full Name] AS Customer_Full_Name,
            req.[Customer Internet E-mail] AS Customer_Internet_Email,
            req.[Customer Phone Number] AS Customer_Phone_Number,
            req.[Phone Number] AS Phone_Number,
            req.[Summary] AS Summary,
            CASE 
                WHEN req.[Request_VIP] = 'Yes' THEN 1
                WHEN req.[Request_VIP] = 'No' THEN 0
                ELSE NULL
            END AS Request_VIP,
            req.[Request_Type] AS Request_Type,
            req.[Request_Group] AS Request_Group,
            req.[Request_Assignee] AS Request_Assignee,
            req.[Request_SLM_Status] AS Request_SLM_Status,
            req.[SRM Status] AS SRM_Status,
            TRY_CONVERT(DECIMAL(3,2), req.[Sum Survey Rating]) AS Sum_ReqSurvey_Rating,
            req.[Survey Response] AS ReqSurvey_Response
        FROM OPENROWSET(
            'Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0; Database=C:\ReportsEditor\Report_Files\REQ.xlsx; HDR=YES; IMEX=1',
            'SELECT * FROM [REQ Y2Q1 Dell MS SD$A3:AZ]'
        ) AS req
        WHERE req.[Request Number] IS NOT NULL
    ) AS source
    ON target.Unique_Identifier = source.Request_Number + '-' + ISNULL(source.Incident_Number, '') + '-' + ISNULL(source.Work_Order_ID, '')
    WHEN MATCHED AND (
        source.Last_Modified_Date_INC > target.Last_Modified_Date_INC OR
        source.Last_Modified_Date_WO > target.Last_Modified_Date_WO OR
        source.Last_Modified_Date_REQ > target.Last_Modified_Date_REQ
    ) THEN
        UPDATE SET
            Submit_Date_Time = source.Submit_Date_Time,
            Approved_Date = source.Approved_Date,
            Responded_Date = source.Responded_Date,
            Completion_Date_Time = source.Completion_Date_Time,
            Closed_Date_Time = source.Closed_Date_Time,
            Re_Opened_Date = source.Re_Opened_Date,
            Last_Resolved_Date = source.Last_Resolved_Date,
            Completion_Closed_Date = source.Completion_Closed_Date,
            Last_Modified_Date_INC = source.Last_Modified_Date_INC,
            Last_Modified_Date_WO = source.Last_Modified_Date_WO,
            Last_Modified_Date_REQ = source.Last_Modified_Date_REQ,
            Request_Priority = source.Request_Priority,
            Request_Categorization1 = source.Request_Categorization1,
            Request_Categorization2 = source.Request_Categorization2,
            Request_Categorization3 = source.Request_Categorization3,
            CST_FCR = source.CST_FCR,
            Full_Name = source.Full_Name,
            Customer_Full_Name = source.Customer_Full_Name,
            Customer_Internet_Email = source.Customer_Internet_Email,
            Customer_Phone_Number = source.Customer_Phone_Number,
            Phone_Number = source.Phone_Number,
            Summary = source.Summary,
            Request_VIP = source.Request_VIP,
            Request_Type = source.Request_Type,
            Request_Group = source.Request_Group,
            Request_Assignee = source.Request_Assignee,
            Request_SLM_Status = source.Request_SLM_Status,
            SRM_Status = source.SRM_Status,
            Sum_ReqSurvey_Rating = source.Sum_ReqSurvey_Rating,
            ReqSurvey_Response = source.ReqSurvey_Response
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Submit_Date_Time, Approved_Date, Responded_Date, Completion_Date_Time, Closed_Date_Time, 
            Re_Opened_Date, Last_Resolved_Date, Completion_Closed_Date, Last_Modified_Date_INC, 
            Last_Modified_Date_WO, Last_Modified_Date_REQ, Request_Number, Incident_Number, Work_Order_ID, 
            Request_Priority, Request_Categorization1, Request_Categorization2, Request_Categorization3, CST_FCR, 
            Full_Name, Customer_Full_Name, Customer_Internet_Email, Customer_Phone_Number, 
            Phone_Number, Summary, Request_VIP, Request_Type, Request_Group, Request_Assignee, 
            Request_SLM_Status, SRM_Status, Sum_ReqSurvey_Rating, ReqSurvey_Response
        )
        VALUES (
            source.Submit_Date_Time, source.Approved_Date, source.Responded_Date, source.Completion_Date_Time, source.Closed_Date_Time, 
            source.Re_Opened_Date, source.Last_Resolved_Date, source.Completion_Closed_Date, source.Last_Modified_Date_INC, 
            source.Last_Modified_Date_WO, source.Last_Modified_Date_REQ, source.Request_Number, source.Incident_Number, source.Work_Order_ID, 
            source.Request_Priority, source.Request_Categorization1, source.Request_Categorization2, source.Request_Categorization3, source.CST_FCR, 
            source.Full_Name, source.Customer_Full_Name, source.Customer_Internet_Email, source.Customer_Phone_Number, 
            source.Phone_Number, source.Summary, source.Request_VIP, source.Request_Type, source.Request_Group, source.Request_Assignee, 
            source.Request_SLM_Status, source.SRM_Status, source.Sum_ReqSurvey_Rating, source.ReqSurvey_Response
        );

    -- Log the number of records inserted or updated
    PRINT 'Data import completed successfully.';
    PRINT 'Number of records inserted: ' + CAST(@@ROWCOUNT AS VARCHAR);
END TRY
BEGIN CATCH
    PRINT 'An error occurred while importing data.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
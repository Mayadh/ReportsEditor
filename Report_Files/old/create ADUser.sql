-- Drop the table if it exists
IF OBJECT_ID('tbl_ADUsers', 'U') IS NOT NULL
    DROP TABLE tbl_ADUsers;

-- Create the table
CREATE TABLE tbl_ADUsers (
    DisplayName NVARCHAR(255),
    SamAccountName NVARCHAR(255),
    EmailAddress NVARCHAR(255),
    Enabled NVARCHAR(255),
    Department NVARCHAR(255),
    Title NVARCHAR(255),
    TelephoneNumber NVARCHAR(50),
    IPPhone NVARCHAR(50),
    MobilePhone NVARCHAR(50),
    AccountExpires NVARCHAR(MAX),
    ManagerDisplayName NVARCHAR(255),
    ManagerEmail NVARCHAR(255),
    ManagerTitle NVARCHAR(255),
    MemberOf NVARCHAR(MAX),
    LastLogin NVARCHAR(MAX),
    DistinguishedName NVARCHAR(MAX),
    PostalCode NVARCHAR(MAX)
);

-- Delete existing data from the table (if it already exists)
DELETE FROM tbl_ADUsers;

-- Import new data from the Excel file using OPENROWSET
INSERT INTO tbl_ADUsers (
    DisplayName,
    SamAccountName,
    EmailAddress,
    Enabled,
    Department,
    Title,
    TelephoneNumber,
    IPPhone,
    MobilePhone,
    AccountExpires,
    ManagerDisplayName,
    ManagerEmail,
    ManagerTitle,
    MemberOf,
    LastLogin,
    DistinguishedName,
    PostalCode
)
SELECT 
    DisplayName,
    SamAccountName,
    EmailAddress,
    Enabled,
    Department,
    Title,
    TelephoneNumber,
    IPPhone,
    MobilePhone,
    AccountExpires,
    ManagerDisplayName,
    ManagerEmail,
    ManagerTitle,
    MemberOf,
    LastLogin,
    DistinguishedName,
    PostalCode
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 Xml;HDR=YES;Database=C:\ReportsEditor\Report_Files\ADUserReport.xlsx',
    'SELECT * FROM [ADUserReport$]'
);
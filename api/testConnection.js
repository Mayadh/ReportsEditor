const sql = require('mssql');

const config = {
    user: 'sa',
    password: 'A123456a',
    server: 'localhost',
    database: 'ReportsDB',
    options: {
        encrypt: true,
        enableArithAbort: true,
        trustServerCertificate: true
    }
};

async function testConnection() {
    try {
        await sql.connect(config);
        console.log('Connected to SQL Server successfully!');
        const result = await sql.query('SELECT 1 AS test');
        console.log('Query result:', result.recordset);
    } catch (err) {
        console.error('Error connecting to SQL Server:', err);
    } finally {
        sql.close();
    }
}

testConnection();
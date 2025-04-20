const express = require('express');
const sql = require('mssql');
const path = require('path');
const app = express();
const port = 3000;

app.use(express.json());

// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, '../public')));

const config = {
    user: 'sa',
    password: 'A123456a',
    server: 'localhost',
    database: 'ReportsDB',
    options: {
        encrypt: true,
        enableArithAbort: true,
        trustServerCertificate: true // Add this line to trust the self-signed certificate
    }
};

// Update REQ Violation
app.post('/updateREQViolation', async (req, res) => {
    const { id, violationType, reason, approval } = req.body;

    console.log('Request body:', req.body); // Log the request body for debugging

    try {
        await sql.connect(config);

        const request = new sql.Request();
        request.input('ID', sql.Int, id);
        request.input('ViolationType', sql.VarChar(10), violationType);
        request.input('Reason', sql.VarChar(255), reason);
        // Convert the approval string to a proper boolean
        request.input('Approval', sql.Bit, approval === '1' || approval === 1 || approval === true);

        const query = `
            EXEC dbo.sp_Update_REQ_ViolationFields 
                @ID = @ID, 
                @ViolationType = @ViolationType, 
                @Reason = @Reason, 
                @Approval = @Approval
        `;

        console.log('Executing query:', query); // Log the query for debugging
        console.log('Approval value being sent:', approval === '1' || approval === 1 || approval === true);

        await request.query(query);

        res.status(200).send('REQ Violation updated successfully');
    } catch (err) {
        console.error('Error updating REQ violation:', err);
        res.status(500).json({ error: 'Error updating REQ violation', details: err.message });
    }
});

// Update CSQ Violation
app.post('/updateCSQViolation', async (req, res) => {
    const { id, violationType, reason, approval } = req.body;

    console.log('Request body:', req.body); // Log the request body for debugging

    try {
        await sql.connect(config);

        const request = new sql.Request();
        request.input('ID', sql.Int, id);
        request.input('ViolationType', sql.VarChar(10), violationType);
        request.input('Reason', sql.VarChar(255), reason);
        // Convert the approval string to a proper boolean
        request.input('Approval', sql.Bit, approval === '1' || approval === 1 || approval === true);

        const query = `
            EXEC dbo.sp_Update_CSQ_ViolationFields 
                @ID = @ID, 
                @ViolationType = @ViolationType, 
                @Reason = @Reason, 
                @Approval = @Approval
        `;

        console.log('Executing query:', query); // Log the query for debugging
        console.log('Approval value being sent:', approval === '1' || approval === 1 || approval === true);

        await request.query(query);

        res.status(200).send('CSQ Violation updated successfully');
    } catch (err) {
        console.error('Error updating CSQ violation:', err);
        res.status(500).json({ error: 'Error updating CSQ violation', details: err.message });
    }
});

// Get REQ Violations Missing Justifications
app.get('/api/req-violations-missing', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query(`
            SELECT * FROM vw_REQ_Violations_Missing_Reasons
        `);
        res.status(200).json(result.recordset);
    } catch (err) {
        console.error('Error fetching REQ violations:', err);
        res.status(500).json({ error: 'Error fetching REQ violations', details: err.message });
    }
});

// Get CSQ Violations Missing Justifications
app.get('/api/csq-violations-missing', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query(`
            SELECT * FROM vw_CSQ_Violations_Missing_Reasons
        `);
        res.status(200).json(result.recordset);
    } catch (err) {
        console.error('Error fetching CSQ violations:', err);
        res.status(500).json({ error: 'Error fetching CSQ violations', details: err.message });
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

// Get All CSQ Violations
app.get('/api/csq-violations-all', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query(`
            SELECT * FROM vw_CSQ_Violations
        `);
        res.status(200).json(result.recordset);
    } catch (err) {
        console.error('Error fetching all CSQ violations:', err);
        res.status(500).json({ error: 'Error fetching all CSQ violations', details: err.message });
    }
});

// Get All REQ Violations
app.get('/api/req-violations-all', async (req, res) => {
    try {
        await sql.connect(config);
        const result = await sql.query(`
            SELECT * FROM vw_REQ_Violations
        `);
        res.status(200).json(result.recordset);
    } catch (err) {
        console.error('Error fetching all REQ violations:', err);
        res.status(500).json({ error: 'Error fetching all REQ violations', details: err.message });
    }
});
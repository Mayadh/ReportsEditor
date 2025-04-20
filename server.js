const express = require('express');
const sql = require('mssql');
const app = express();

const config = {
  user: 'sa',
  password: '123456',
  server: 'localhost',
  database: 'mtalal',
  port: 1433,
  options: {
    encrypt: false,               // <-- هذا هو اللي يمنع التشفير
    trustServerCertificate: true  // <-- هذا يخلي الاتصال يضبط بدون مشاكل شهادات
  }
};

app.get('/data', async (req, res) => {
  try {
    await sql.connect(config);
    const result = await sql.query('SELECT * FROM Table_1');
    res.json(result.recordset);
  } catch (err) {
    console.log('❌ DATABASE ERROR:');
    console.error(err);
    res.status(500).send('Internal Server Error');
  }
});

app.listen(3001, () => {
  console.log('✅ Server running on http://localhost:3001');
});

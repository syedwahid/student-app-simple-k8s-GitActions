const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 9393;

console.log('🚀 Student Management System - Production Version');

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage
let students = [
    { id: 1, name: 'John Doe', age: 20, grade: 'A', email: 'john@school.com' },
    { id: 2, name: 'Jane Smith', age: 21, grade: 'B', email: 'jane@school.com' },
    { id: 3, name: 'Mike Johnson', age: 19, grade: 'A', email: 'mike@school.com' },
    { id: 4, name: 'Sarah Wilson', age: 22, grade: 'C', email: 'sarah@school.com' },
    { id: 5, name: 'Tom Brown', age: 18, grade: 'B', email: 'tom@school.com' }
];

let nextId = 6;

// API Endpoints
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Student Management Backend is running',
        timestamp: new Date().toISOString(),
        studentCount: students.length,
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'production'
    });
});

app.get('/api/students', (req, res) => {
    res.json(students);
});

app.get('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const student = students.find(s => s.id === id);
    if (!student) return res.status(404).json({ error: 'Student not found' });
    res.json(student);
});

app.post('/api/students', (req, res) => {
    const { name, age, grade, email } = req.body;
    
    if (!name || !age || !grade || !email) {
        return res.status(400).json({ error: 'All fields are required' });
    }
    
    const newStudent = {
        id: nextId++,
        name: name.trim(),
        age: parseInt(age),
        grade: grade.toUpperCase(),
        email: email.trim()
    };
    
    students.push(newStudent);
    res.status(201).json({
        message: 'Student created successfully',
        student: newStudent
    });
});

app.put('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const { name, age, grade, email } = req.body;
    
    const studentIndex = students.findIndex(s => s.id === id);
    if (studentIndex === -1) {
        return res.status(404).json({ error: 'Student not found' });
    }
    
    const updatedStudent = {
        id,
        name: name.trim(),
        age: parseInt(age),
        grade: grade.toUpperCase(),
        email: email.trim()
    };
    
    students[studentIndex] = updatedStudent;
    res.json({
        message: 'Student updated successfully',
        student: updatedStudent
    });
});

app.delete('/api/students/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const studentIndex = students.findIndex(s => s.id === id);
    
    if (studentIndex === -1) {
        return res.status(404).json({ error: 'Student not found' });
    }
    
    const deletedStudent = students.splice(studentIndex, 1)[0];
    res.json({
        message: 'Student deleted successfully',
        student: deletedStudent
    });
});

app.get('/api/students/search/:query', (req, res) => {
    const query = req.params.query.toLowerCase();
    const results = students.filter(s => 
        s.name.toLowerCase().includes(query) ||
        s.email.toLowerCase().includes(query) ||
        s.grade.toLowerCase().includes(query)
    );
    res.json(results);
});

// Simple frontend
app.get('/', (req, res) => {
    res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>Student Management System</title>
        <style>
            body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
            .header { background: #4CAF50; color: white; padding: 20px; border-radius: 5px; }
            .endpoint { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
            code { background: #e0e0e0; padding: 2px 5px; border-radius: 3px; }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>Student Management System</h1>
            <p>Production Deployment via GitHub Actions CI/CD</p>
        </div>
        
        <h2>API Endpoints:</h2>
        
        <div class="endpoint">
            <h3>Health Check</h3>
            <code>GET /api/health</code>
            <p><a href="/api/health" target="_blank">Test Now</a></p>
        </div>
        
        <div class="endpoint">
            <h3>Get All Students</h3>
            <code>GET /api/students</code>
            <p><a href="/api/students" target="_blank">Test Now</a></p>
        </div>
        
        <div class="endpoint">
            <h3>Get Student by ID</h3>
            <code>GET /api/students/1</code>
            <p><a href="/api/students/1" target="_blank">Test Now</a></p>
        </div>
        
        <div class="endpoint">
            <h3>Search Students</h3>
            <code>GET /api/students/search/john</code>
            <p><a href="/api/students/search/john" target="_blank">Test Now</a></p>
        </div>
        
        <h3>Other endpoints:</h3>
        <ul>
            <li><code>POST /api/students</code> - Create new student</li>
            <li><code>PUT /api/students/{id}</code> - Update student</li>
            <li><code>DELETE /api/students/{id}</code> - Delete student</li>
        </ul>
        
        <h3>Test with curl:</h3>
        <pre>curl http://localhost:9393/api/health</pre>
    </body>
    </html>
    `);
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Production Server running on port ${PORT}`);
    console.log(`✅ Health endpoint: http://localhost:${PORT}/api/health`);
    console.log(`✅ Student count: ${students.length}`);
});
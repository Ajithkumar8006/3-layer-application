const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

// Enable CORS so the browser (port 30080) can talk to this API (port 3002)
app.use(cors()); 
app.use(express.json());

// Console log every request to help you debug
app.use((req, res, next) => {
    console.log(`Incoming Request: ${req.method} ${req.url}`);
    next();
});

// MongoDB Connection
// 'mongodb-service' must match the name of your MongoDB Service in K8s
mongoose.connect('mongodb://192.168.1.254:27017/persondb')
    .then(() => console.log("✅ Connected to MongoDB"))
    .catch(err => console.error("❌ MongoDB Connection Error:", err));

// Schema Definition
const personSchema = new mongoose.Schema({
    name: String,
    age: Number,
    gender: String,
    place: String
});

const Person = mongoose.model('Person', personSchema);

// API Routes
app.get('/api/persons', async (req, res) => {
    try {
        const persons = await Person.find();
        res.json(persons);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/api/persons', async (req, res) => {
    try {
        const newPerson = new Person(req.body);
        await newPerson.save();
        res.status(201).json({ message: "Data updated successfully!" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Listen on 0.0.0.0 to accept external connections
app.listen(3002, '0.0.0.0', () => {
    console.log('🚀 Backend server running on port 3002');
});
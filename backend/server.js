const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();

// Middleware
app.use(bodyParser.json());
app.use(cors());

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/nutrivision', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Routes
const authRoutes = require('./routes/auth'); // Import the auth routes
const eventRoutes = require('./routes/events'); // Import the event routes

app.use('/api/auth', authRoutes); // Use the auth routes
app.use('/api', eventRoutes); // Use the event routes

// Set the port to 5000
const PORT = 5000;

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

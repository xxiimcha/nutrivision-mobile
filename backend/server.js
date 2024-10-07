const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
  },
});

const PORT = 5000; // Mobile server running on port 5000
const connectedMobileUsers = {}; // To track connected mobile users

// Middleware
app.use(bodyParser.json());
app.use(cors());

// MongoDB connection
mongoose.connect('mongodb+srv://nutrivision:nutrivision123@nutrivision.04lzv.mongodb.net/nutrivision?retryWrites=true&w=majority&appName=nutrivision', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.log('MongoDB connection error:', err));

// Socket.io connection for mobile
io.on('connection', (socket) => {
  console.log(`Mobile user connected: ${socket.id}`);

  // Register mobile user and associate socket ID
  socket.on('register-mobile-user', (userId) => {
    connectedMobileUsers[userId] = socket.id;
    console.log(`Mobile user registered: ${userId}, socket ID: ${socket.id}`);
    console.log('Connected mobile users:', connectedMobileUsers);
  });

  // Handle call initiation from web
  socket.on('call-mobile-user', ({ callerId, receiverId, callType, roomUrl }) => {
    console.log(`Call initiated from ${callerId} to mobile user ${receiverId}`);

    if (connectedMobileUsers[receiverId]) {
      io.to(connectedMobileUsers[receiverId]).emit('incoming-mobile-call', {
        callerId,
        callType,
        roomUrl,
      });
      console.log(`Incoming call emitted to mobile user: ${receiverId}`);
    } else {
      console.log(`Mobile user ${receiverId} is not connected.`);
    }
  });

  // Handle disconnect event
  socket.on('disconnect', () => {
    console.log(`Mobile user disconnected: ${socket.id}`);
    for (const userId in connectedMobileUsers) {
      if (connectedMobileUsers[userId] === socket.id) {
        delete connectedMobileUsers[userId];
        console.log(`Mobile user ${userId} removed from connected users.`);
        break;
      }
    }
  });
});

// Routes (for other API endpoints)
const authRoutes = require('./routes/auth');
const eventRoutes = require('./routes/events');
const patientRoutes = require('./routes/patients');
const userRoutes = require('./routes/users');
const notifRoutes = require('./routes/notifications');
const mealPlanRoutes = require('./routes/mealplans');
const messagesRouter = require('./routes/messages');
const callRoutes = require('./routes/calls');

app.use('/api/calls', callRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/users', userRoutes);
app.use('/api/notifications', notifRoutes);
app.use('/api/mealplans', mealPlanRoutes);
app.use('/api/messages', messagesRouter);

// Start the mobile server on port 5000
server.listen(PORT, () => {
  console.log(`Mobile server running at http://localhost:${PORT}`);
});

// messages.js (Express route)
const express = require('express');
const Message = require('../models/Message'); // Assuming a Message model
const User = require('../models/User'); // Assuming a User model
const router = express.Router();

// Get all users that have sent messages to the logged-in user
router.get('/conversations/:userId', async (req, res) => {
  const { userId } = req.params;
  
  try {
    // Get all distinct sender IDs that have sent messages to the logged-in user
    const senders = await Message.find({ recipient: userId }).distinct('sender');
    
    // Fetch user details from the User model
    const users = await User.find({ _id: { $in: senders } }, 'name email'); // Select name and email

    res.status(200).json(users);
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const Message = require('../models/Message');

// Fetch messages by receiver (userId)
router.get('/:userId', async (req, res) => {
  try {
    const messages = await Message.find({ receiver: req.params.userId }).sort({ timestamp: -1 });
    
    if (messages.length === 0) {
      return res.status(404).json({ message: 'No messages found' });
    }
    
    res.status(200).json(messages);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

module.exports = router;

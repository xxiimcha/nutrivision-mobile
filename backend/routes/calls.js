const express = require('express');
const router = express.Router();
const CallSignal = require('../models/CallSignal'); // Assuming you have a CallSignal model

// Get call signals for the logged-in user (callee)
router.get('/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    // Fetch only the "calling" status signals for the receiver
    const calls = await CallSignal.find({
      receiverId: userId,
      status: 'calling',
    });

    res.status(200).json(calls);
  } catch (err) {
    console.error('Error fetching call signals:', err.message);
    res.status(500).send('Server error');
  }
});

// Update call status
router.post('/:callId/status', async (req, res) => {
  const { callId } = req.params;
  const { status } = req.body; // e.g., "answered" or "declined"

  try {
    // Find the call by ID
    const call = await CallSignal.findById(callId);
    if (!call) {
      return res.status(404).json({ msg: 'Call not found' });
    }

    // Update the call's status
    call.status = status;
    await call.save();

    res.status(200).json({ msg: 'Call status updated', call });
  } catch (err) {
    console.error('Error updating call status:', err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;

const express = require('express');
const User = require('../models/User'); // Assuming you have a User model

const router = express.Router();

// Signup route
router.post('/signup', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    let user = await User.findOne({ email });

    if (user) {
      console.log(`Signup failed: User already exists with email: ${email}`);
      return res.status(400).json({ msg: 'User already exists' });
    }

    user = new User({
      username,
      email,
      password, // Store password as plain text
    });

    await user.save();

    console.log(`User registered successfully: ${username} - ${email}`);
    res.status(201).json({ msg: 'User registered successfully' });
  } catch (err) {
    console.error('Error during signup:', err.message);
    res.status(500).send('Server error');
  }
});

// Login route
router.post('/login', async (req, res) => {
  const { identifier, password } = req.body; // 'identifier' can be either username or email

  try {
    // Find user by either username or email
    const user = await User.findOne({
      $or: [{ email: identifier }, { username: identifier }],
    });

    if (!user) {
      console.log('User not found with identifier:', identifier);
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    console.log('Stored password:', user.password);
    console.log('Provided password:', password);

    // Compare the provided password with the plain text password in the database
    if (password !== user.password) {
      console.log('Passwords do not match');
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    console.log(`Login successful for user: ${user.username}`);
    res.status(200).json({ msg: 'Login successful' });
  } catch (err) {
    console.error('Error during login:', err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;

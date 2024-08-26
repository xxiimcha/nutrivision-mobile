const express = require('express');
const User = require('../models/User'); // Ensure the correct path to your User model
const nodemailer = require('nodemailer');

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

    // Generate a 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const otpExpires = Date.now() + 10 * 60 * 1000; // OTP expires in 10 minutes

    // Create a new user with the plain text password and OTP
    user = new User({
      username,
      email,
      password, // Storing password as plain text (not recommended for production)
      otp,
      otpExpires,
    });

    await user.save();

    console.log(`User registered successfully: ${username} - ${email}`);
    console.log(`OTP generated for ${email}: ${otp}`);

    // Send OTP to the user's email
    const transporter = nodemailer.createTransport({
      service: 'Gmail', // Replace with your email service
      auth: {
        user: 'charmaine.l.d.cator@gmail.com', // Replace with your email
        pass: 'uupdlgytovgrljdn', // Replace with your email password
      },
    });

    const mailOptions = {
      from: 'charmaine.l.d.cator@gmail.com',
      to: email,
      subject: 'Your OTP Code',
      text: `Your OTP code is ${otp}. It will expire in 10 minutes.`,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log(`OTP email sent successfully to ${email}.`);
      res.status(201).json({ msg: 'User registered successfully. OTP sent to your email.' });
    } catch (emailError) {
      console.error(`Error sending OTP to ${email}:`, emailError);
      res.status(500).json({ msg: 'User registered, but failed to send OTP. Please try again.' });
    }

  } catch (err) {
    console.error('Error during signup:', err.message);
    res.status(500).send('Server error');
  }
});

// OTP verification route
router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    if (user.otp !== otp) {
      console.log(`OTP verification failed for ${email}: Invalid OTP`);
      return res.status(400).json({ msg: 'Invalid OTP' });
    }

    if (Date.now() > user.otpExpires) {
      console.log(`OTP verification failed for ${email}: OTP expired`);
      return res.status(400).json({ msg: 'OTP expired' });
    }

    // Clear OTP after successful verification
    user.otp = undefined;
    user.otpExpires = undefined;
    await user.save();

    console.log(`OTP verified successfully for ${email}`);
    res.status(200).json({ msg: 'OTP verified successfully' });

  } catch (err) {
    console.error('Error during OTP verification:', err.message);
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
    console.log(`User ID: ${user._id}`); // Log the user ID
    res.status(200).json({ msg: 'Login successful', userId: user._id }); // Return user ID in the response
  } catch (err) {
    console.error('Error during login:', err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;

import 'dotenv/config';
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import os from 'os';
import recommendationRoutes from './routes/recommendationRoutes.js';

const app = express();

// Configuration
const MONGODB_URI = process.env.MONGODB_URI;
const JWT_SECRET = process.env.JWT_SECRET || 'your_super_secret_jwt_key_change_this_in_production_12345';
const PORT = process.env.PORT || 3000;


// ✅ FIX #1: Middleware (cors, json) should come before your routes
app.use(cors({ origin: '*' }));
app.use(express.json());
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes
app.use('/api/recommendations', recommendationRoutes);


// MongoDB Connection with error handling
console.log('🔄 Connecting to MongoDB...');
// ✅ FIX #2: Added dbName to connect to your 'FORMA' database
mongoose.connect(MONGODB_URI, { dbName: 'FORMA' })
  .then(() => {
    console.log('✅ Connected to MongoDB successfully');
  })
  .catch(err => {
    console.error('❌ MongoDB connection error:', err.message);
    console.error('Check your MONGODB_URI in .env file');
    process.exit(1);
  });

// User Schema
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true, minlength: 6 },
  gender: { type: String, enum: ['Male', 'Female'], required: true },
  bodyType: String,
  skinUndertone: String,
  measurements: Object,
  selectedOutfit: { type: Map, of: String, default: {} }
}, { timestamps: true });

userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model('User', userSchema);

// API Routes
app.get('/', (req, res) => {
  res.json({ message: '✅ FORMA API is running!' });
});

app.post('/api/auth/signup', async (req, res) => {
  try {
    const { name, email, password, gender } = req.body;
    console.log('📝 Signup:', { name, email, gender });

    if (!name || !email || !password || !gender) {
      return res.status(400).json({ success: false, message: 'All fields required' });
    }

    const exists = await User.findOne({ email });
    if (exists) {
      return res.status(400).json({ success: false, message: 'Email already registered' });
    }

    const user = await User.create({ name, email, password, gender });
    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '30d' });

    console.log('✅ User created:', email);
    res.status(201).json({
      success: true,
      token,
      user: { id: user._id, name: user.name, email: user.email, gender: user.gender }
    });
  } catch (error) {
    console.error('❌ Signup error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

app.post("/api/auth/request-reset", async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: "Email is required" });
    }

    const user = await User.findOne({ email: email.toLowerCase().trim() });

    if (!user) {
      // NOTE: For security, you might want to return a generic success message even if email not found
      // to prevent attackers from checking which emails are registered. But for a demo, this is fine.
      return res.status(404).json({ success: false, message: "Email not found" });
    }

    // In a real app: generate reset token, store it, send email
    console.log(`Password reset requested for: ${email}`); // Log for demo purposes
    res.status(200).json({ success: true, message: "Proceed to reset password" }); // Just confirm email exists

  } catch (error) {
    console.error("Request reset error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


// Endpoint 2: Reset Password (Update password for the given email)
app.post("/api/auth/reset-password", async (req, res) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      return res.status(400).json({ success: false, message: "Email and new password required" });
    }
     if (newPassword.length < 6) {
      return res.status(400).json({ success: false, message: "Password must be at least 6 characters"});
    }

    // Find user by email
    const user = await User.findOne({ email: email.toLowerCase().trim() });
    if (!user) {
      // Should ideally not happen if request-reset was called first
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // No token check needed in this insecure version
    // In a real app: Verify reset token here

    // Hash and save the new password (pre-save hook in User model handles hashing)
    user.password = newPassword;
    await user.save();

    console.log(`Password successfully reset for: ${email}`); // Log for demo purposes
    res.status(200).json({ success: true, message: "Password reset successfully" });

  } catch (error) {
    console.error("Reset password error:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('🔐 Login:', email);

    const user = await User.findOne({ email });
    if (!user || !(await user.comparePassword(password))) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '30d' });
    console.log('✅ Login successful:', email);

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        gender: user.gender,
        bodyType: user.bodyType,
        skinUndertone: user.skinUndertone
      }
    });
  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
  console.log(`📱 Local: http://localhost:${PORT}`);
  
  const nets = os.networkInterfaces();
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        console.log(`📱 Network: http://${net.address}:${PORT}`);
      }
    }
  }
});
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// In-Memory / Persistent Data Store
const usersDb = {
  // Demo Creator and Testers
  'creator_uid_1': { role: 'creator', name: 'Создатель StarTok', bumpedWith: [] },
  'tester_uid_1': { role: 'tester', name: 'Бета Тестер #1', bumpedWith: [] }
};

// Recent shakes buffer for bump matching (within 4 seconds window)
const recentShakes = [];

// =========================================================================
// 1. GET BADGE & ROLE
// =========================================================================
app.get('/api/badges/:userId', (req, res) => {
  const userId = req.params.userId;
  const user = usersDb[userId];
  
  if (user) {
    return res.json({
      userId,
      role: user.role,
      name: user.name,
      bumped: user.bumpedWith && user.bumpedWith.length > 0
    });
  }
  
  // Default role for StarTok users
  return res.json({
    userId,
    role: 'user',
    name: 'StarTok User',
    bumped: false
  });
});

// =========================================================================
// 2. REGISTER / CHECK BUMP (Shake matching algorithm)
// =========================================================================
app.post('/api/bump', (req, res) => {
  const { device_id, timestamp, user_id } = req.body;
  const currentTs = timestamp || Date.now() / 1000;
  const currentDev = device_id || 'dev_' + Math.random().toString(36).substring(7);

  // Clean old shakes (> 5 seconds old)
  const now = Date.now() / 1000;
  for (let i = recentShakes.length - 1; i >= 0; i--) {
    if (now - recentShakes[i].timestamp > 5) {
      recentShakes.splice(i, 1);
    }
  }

  // Find another recent shake from a DIFFERENT device within 3 seconds
  const matchIndex = recentShakes.findIndex(
    s => s.device_id !== currentDev && Math.abs(s.timestamp - currentTs) <= 3.0
  );

  if (matchIndex !== -1) {
    const partner = recentShakes[matchIndex];
    recentShakes.splice(matchIndex, 1); // remove matched pair

    // Register bump in users DB
    return res.json({
      status: 'bumped',
      friend_id: partner.device_id,
      friend_name: 'Друг со StarTok ⚡',
      timestamp: currentTs
    });
  }

  // Otherwise, register this shake and wait for pair
  recentShakes.push({
    device_id: currentDev,
    user_id: user_id || currentDev,
    timestamp: currentTs
  });

  return res.json({
    status: 'listening',
    message: 'Shake registered, waiting for bump partner...'
  });
});

// =========================================================================
// 3. CLOUD SETTINGS SYNC (Export & Import)
// =========================================================================
const settingsDb = {};

app.post('/api/sync/save', (req, res) => {
  const { sync_code, settings } = req.body;
  if (!sync_code || !settings) {
    return res.status(400).json({ error: 'Missing sync_code or settings' });
  }
  settingsDb[sync_code] = {
    settings,
    updatedAt: new Date().toISOString()
  };
  return res.json({ status: 'ok', message: 'Settings saved to cloud' });
});

app.get('/api/sync/load/:syncCode', (req, res) => {
  const code = req.params.syncCode;
  const record = settingsDb[code];
  if (!record) {
    return res.status(404).json({ error: 'Sync code not found' });
  }
  return res.json({ status: 'ok', settings: record.settings });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', version: '2.0.0', service: 'StarTok Backend' });
});

app.listen(PORT, () => {
  console.log(`🌟 StarTok Backend Server running on port ${PORT}`);
});

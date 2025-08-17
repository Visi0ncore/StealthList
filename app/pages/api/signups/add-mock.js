const { Pool } = require('pg');
const { showWarningOnce } = require('../../../lib/warnings');

// Local database connection using POSTGRES_URL from .env.local (same as existing setup)
let localPool = null;
if (process.env.POSTGRES_URL && process.env.POSTGRES_URL.trim() !== '') {
  try {
    localPool = new Pool({
      connectionString: process.env.POSTGRES_URL,
    });
  } catch (error) {
    console.warn('⚠️  Local database configuration error:', error.message);
  }
} else {
  showWarningOnce('local-db-config', '⚠️  No local database configuration found. Run "bun run setup" to configure your local database.');
}

// Mock user data generator
function generateMockUser() {
  const domains = ['gmail.com', 'outlook.com', 'yahoo.com', 'icloud.com', 'hotmail.com'];
  const firstNames = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank', 'Grace', 'Henry', 'Ivy', 'Jack'];
  const lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'];

  const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
  const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
  const domain = domains[Math.floor(Math.random() * domains.length)];
  const email = `${firstName.toLowerCase()}.${lastName.toLowerCase()}${Math.floor(Math.random() * 1000)}@${domain}`;

  return email;
}

export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Check if local database is configured
  if (!localPool) {
    return res.status(503).json({
      error: 'Local database not configured',
      message: 'Please run "bun run setup" to configure your local database.'
    });
  }

  try {
    const { count = 1 } = req.body;

    // Validate count
    const numCount = parseInt(count);
    if (isNaN(numCount) || numCount < 1 || numCount > 100) {
      return res.status(400).json({
        error: 'Invalid count',
        message: 'Count must be between 1 and 100'
      });
    }

    // Generate and insert mock users
    const mockUsers = [];
    for (let i = 0; i < numCount; i++) {
      const email = generateMockUser();
      mockUsers.push(email);
    }

    // Insert users into database
    const values = mockUsers.map((email, index) => `($${index + 1})`).join(', ');
    const query = `INSERT INTO waitlist_signups (email) VALUES ${values} RETURNING id, email, created_at`;

    const result = await localPool.query(query, mockUsers);

    res.status(200).json({
      success: true,
      message: `Successfully added ${numCount} mock user${numCount === 1 ? '' : 's'}`,
      addedUsers: result.rows,
      count: numCount
    });

  } catch (error) {
    // Log error without exposing sensitive details
    console.error('Error adding mock users:', error.message || 'Unknown error');
    res.status(500).json({
      error: 'Failed to add mock users',
      message: 'Please try again later'
    });
  }
}; 
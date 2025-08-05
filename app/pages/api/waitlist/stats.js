const { Pool } = require('pg');
const { configureCORS } = require('../../../lib/cors');

// Check if database configuration exists
const hasDatabaseConfig = process.env.POSTGRES_URL && process.env.POSTGRES_URL.trim() !== '';

let pool = null;
if (hasDatabaseConfig) {
  try {
    pool = new Pool({
      connectionString: process.env.POSTGRES_URL,
    });
  } catch (error) {
    console.warn('⚠️  Database configuration error:', error.message);
  }
} else {
  console.log('⚠️  No database configuration found. Run "bun run setup" to configure your local database.');
}

export default async function handler(req, res) {
  configureCORS(req, res, '/api/waitlist/stats');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method === 'GET') {
    // Check if database is configured
    if (!pool) {
      return res.status(200).json({
        count: 0,
        latestSignups: 0,
        message: 'Database not configured. Run "bun run setup" to get started.'
      });
    }

    try {
      const client = await pool.connect();
      
      try {
        // Get total count of all signups
        const countResult = await client.query('SELECT COUNT(*) FROM waitlist_signups');
        const count = parseInt(countResult.rows[0].count);

        // Get recent signups (last 24 hours)
        const recentResult = await client.query(
          "SELECT COUNT(*) FROM waitlist_signups WHERE created_at >= NOW() - INTERVAL '24 hours'"
        );
        const latestSignups = parseInt(recentResult.rows[0].count);

        res.status(200).json({
          count: count || 0,
          latestSignups: latestSignups || 0
        });
      } finally {
        client.release();
      }
    } catch (error) {
      console.error('Stats error:', error);
      res.status(500).json({ 
        error: 'Failed to fetch stats',
        count: 0,
        latestSignups: 0
      });
    }
  } else {
    res.setHeader('Allow', ['GET']);
    res.status(405).json({ 
      error: `Method ${req.method} Not Allowed` 
    });
  }
} 
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

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
  console.log('⚠️  No local database configuration found. Run "bun run setup" to configure your local database.');
}

// Function to load production database URL from .env.prod
function loadProdDatabaseUrl() {
  try {
    const envProdPath = path.join(process.cwd(), '.env.prod');
    
    // Check if file exists before trying to read it
    if (!fs.existsSync(envProdPath)) {
      console.log('⚠️  No .env.prod file found. Production database will not be available.');
      return null;
    }
    
    const envProdContent = fs.readFileSync(envProdPath, 'utf8');
    const postgresUrlMatch = envProdContent.match(/POSTGRES_URL="([^"]+)"/);
    if (postgresUrlMatch) {
      return postgresUrlMatch[1];
    }
  } catch (error) {
    console.warn('⚠️  Error loading .env.prod:', error.message);
  }
  return null;
}

// Production database connection using POSTGRES_URL from .env.prod (same as existing scripts)
const prodDatabaseUrl = loadProdDatabaseUrl();
const prodPool = prodDatabaseUrl ? new Pool({
  connectionString: prodDatabaseUrl,
}) : null;

export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  // Add security headers
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  const { env } = req.query;

  if (!env || !['local', 'prod'].includes(env)) {
    return res.status(400).json({
      error: 'Invalid or missing environment parameter. Use "local" or "prod"'
    });
  }

  const pool = env === 'local' ? localPool : prodPool;

  if (!pool) {
    if (env === 'local') {
      return res.status(503).json({
        error: 'Local database not configured',
        message: 'Please run "bun run setup" to configure your local database.'
      });
    } else {
      return res.status(503).json({
        error: 'Production database not configured',
        message: 'Please configure your .env.prod file with production database credentials.'
      });
    }
  }

  if (req.method === 'GET') {
    try {
      const client = await pool.connect();
      
      try {
        // Get total count
        const countResult = await client.query('SELECT COUNT(*) FROM waitlist_signups');
        const totalSignups = parseInt(countResult.rows[0].count);

        // Get all signups with details
        const signupsResult = await client.query(
          'SELECT id, email, created_at FROM waitlist_signups ORDER BY created_at DESC'
        );

        // Get recent stats
        const recentResult = await client.query(
          `SELECT 
            COUNT(CASE WHEN created_at >= NOW() - INTERVAL '24 hours' THEN 1 END) as last_24h,
            COUNT(CASE WHEN created_at >= NOW() - INTERVAL '7 days' THEN 1 END) as last_7_days
           FROM waitlist_signups`
        );

        const stats = recentResult.rows[0];

        res.status(200).json({
          environment: env,
          totalSignups,
          signups: signupsResult.rows,
          stats: {
            last24Hours: parseInt(stats.last_24h),
            last7Days: parseInt(stats.last_7_days),
          }
        });
      } finally {
        client.release();
      }
    } catch (error) {
      console.error(`Error fetching ${env} signups:`, error);
      res.status(500).json({
        error: `Failed to fetch ${env} signup data`
      });
    }
  } else if (req.method === 'DELETE') {
    // Only allow deletion for local environment
    if (env !== 'local') {
      return res.status(403).json({
        error: 'Deletion is only allowed for local environment'
      });
    }

    if (!localPool) {
      return res.status(500).json({
        error: 'Local database configuration not found'
      });
    }

    try {
      const client = await localPool.connect();
      
      try {
        // Get count before deletion
        const beforeCount = await client.query('SELECT COUNT(*) FROM waitlist_signups');
        const deletedCount = parseInt(beforeCount.rows[0].count);

        // Delete all signups
        await client.query('DELETE FROM waitlist_signups');

        console.log(`🗑️ Deleted ${deletedCount} local signup records`);

        res.status(200).json({
          success: true,
          message: `Successfully deleted ${deletedCount} signup records`,
          deletedCount
        });
      } finally {
        client.release();
      }
    } catch (error) {
      console.error('Error deleting local signups:', error);
      res.status(500).json({
        error: 'Failed to delete local signup data'
      });
    }
  } else {
    res.setHeader('Allow', ['GET', 'DELETE']);
    res.status(405).json({
      error: `Method ${req.method} Not Allowed`
    });
  }
} 
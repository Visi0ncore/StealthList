const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Local database connection using POSTGRES_URL from .env.local (same as existing setup)
const localPool = new Pool({
  connectionString: process.env.POSTGRES_URL,
});

// Function to load production database URL from .env.prod
function loadProdDatabaseUrl() {
  try {
    const envProdPath = path.join(process.cwd(), '.env.prod');
    const envProdContent = fs.readFileSync(envProdPath, 'utf8');
    const postgresUrlMatch = envProdContent.match(/POSTGRES_URL="([^"]+)"/);
    if (postgresUrlMatch) {
      return postgresUrlMatch[1];
    }
  } catch (error) {
    console.error('Error loading .env.prod:', error);
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
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
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

  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET']);
    return res.status(405).json({
      error: `Method ${req.method} Not Allowed`
    });
  }

  const { env, format = 'csv' } = req.query;

  if (!env || !['local', 'prod'].includes(env)) {
    return res.status(400).json({
      error: 'Invalid or missing environment parameter. Use "local" or "prod"'
    });
  }

  if (!['csv', 'json'].includes(format)) {
    return res.status(400).json({
      error: 'Invalid format parameter. Use "csv" or "json"'
    });
  }

  const pool = env === 'local' ? localPool : prodPool;

  if (!pool) {
    return res.status(500).json({
      error: `Database configuration not found for ${env} environment`
    });
  }

  try {
    const client = await pool.connect();
    
    try {
      // Get all signups with details
      const signupsResult = await client.query(
        'SELECT id, email, created_at FROM waitlist_signups ORDER BY created_at DESC'
      );

      const signups = signupsResult.rows;

      if (format === 'json') {
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', `attachment; filename="signups-${env}-${new Date().toISOString().split('T')[0]}.json"`);
        res.status(200).json({
          environment: env,
          exportDate: new Date().toISOString(),
          totalSignups: signups.length,
          signups: signups
        });
      } else {
        // CSV format
        const csvHeader = 'ID,Email,Signup Date\n';
        const csvRows = signups.map(signup => 
          `${signup.id},"${signup.email}","${new Date(signup.created_at).toISOString()}"`
        ).join('\n');
        const csvContent = csvHeader + csvRows;

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename="signups-${env}-${new Date().toISOString().split('T')[0]}.csv"`);
        res.status(200).send(csvContent);
      }

    } finally {
      client.release();
    }
  } catch (error) {
    console.error(`Error exporting ${env} signups:`, error);
    res.status(500).json({
      error: `Failed to export ${env} signup data`
    });
  }
} 
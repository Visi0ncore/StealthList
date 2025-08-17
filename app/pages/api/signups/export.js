const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const { configureCORS } = require('../../../lib/cors');
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

// Function to load production database URL from .env.prod
function loadProdDatabaseUrl() {
  try {
    const envProdPath = path.join(process.cwd(), '.env.prod');

    // Check if file exists before trying to read it
    if (!fs.existsSync(envProdPath)) {
      showWarningOnce('prod-env-file', 'ℹ️  No .env.prod file found. Production database will not be available.');
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
  configureCORS(req, res, '/api/signups/export');

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
    // Log error without exposing sensitive details
    console.error(`Error exporting ${env} signups:`, error.message || 'Unknown error');
    res.status(500).json({
      error: `Failed to export ${env} signup data`
    });
  }
} 
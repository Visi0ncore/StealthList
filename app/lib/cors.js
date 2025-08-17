const ALLOWED_ORIGINS = [
  'http://localhost:3000',
  'http://localhost:3001',
  // Add your production domain here
  'https://yourdomain.com',
  'https://www.yourdomain.com'
];

const ALLOWED_METHODS = {
  '/api/waitlist': ['POST', 'OPTIONS'],
  '/api/signups': ['GET', 'DELETE', 'OPTIONS'],
  '/api/signups/export': ['GET', 'OPTIONS'],
  '/api/waitlist/stats': ['GET', 'OPTIONS']
};

function isOriginAllowed(origin) {
  if (!origin) return false;

  // Allow localhost in development
  if (process.env.NODE_ENV === 'development') {
    return origin.startsWith('http://localhost:');
  }

  return ALLOWED_ORIGINS.includes(origin);
}

function configureCORS(req, res, endpoint) {
  const origin = req.headers.origin;
  const allowedMethods = ALLOWED_METHODS[endpoint] || ['GET', 'OPTIONS'];

  if (isOriginAllowed(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  } else {
    res.setHeader('Access-Control-Allow-Origin', 'null');
  }

  res.setHeader('Access-Control-Allow-Methods', allowedMethods.join(', '));
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Max-Age', '86400'); // 24 hours

  // Security headers
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
}

module.exports = { configureCORS, isOriginAllowed }; 
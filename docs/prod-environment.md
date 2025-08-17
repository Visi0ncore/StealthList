# Production Environment Setup - Deploy to Vercel

This guide will walk you through deploying StealthList to Vercel with a production-ready PostgreSQL database. Users can fork and deploy within minutes.

## 🚀 Quick Deploy (Recommended)

### Option 1: One-Click Deploy with Vercel

1. **Fork the Repository**
   - Click the "Fork" button on the GitHub repository
   - This creates your own copy of the project

2. **Deploy to Vercel**
   - Visit [vercel.com](https://vercel.com) and sign up/login
   - Click "New Project"
   - Import your forked repository
   - Vercel will automatically detect it's a Next.js project

3. **Configure Environment Variables**
   - In the Vercel dashboard, go to your project settings
   - Navigate to "Environment Variables"
   - Add the following variables (see Database Setup section below):

### Option 2: Manual Setup

Follow the detailed steps below for complete control over your deployment.

## 📋 Prerequisites

- GitHub account
- Vercel account (free tier available)
- PostgreSQL database (we'll use Vercel Postgres or external provider)

## 🗄️ Database Setup

### Option A: Vercel Postgres (Recommended)

1. **Create Vercel Postgres Database**
   - In your Vercel project dashboard, go to "Storage"
   - Click "Create Database" → "Postgres"
   - Choose your plan (Hobby plan is free)
   - Select your preferred region
   - Click "Create"

2. **Get Connection Details**
   - Vercel will automatically add these environment variables:
     - `POSTGRES_URL`
     - `POSTGRES_PRISMA_URL`
     - `POSTGRES_URL_NON_POOLING`
     - `POSTGRES_USER`
     - `POSTGRES_HOST`
     - `POSTGRES_PASSWORD`
     - `POSTGRES_DATABASE`

3. **Create Database Schema**
   - Go to your Vercel Postgres dashboard
   - Click "Connect" → "SQL Editor"
   - Run the following SQL:

```sql
CREATE TABLE waitlist_signups (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Option B: External PostgreSQL (Supabase, Railway, etc.)

1. **Create External Database**
   - [Supabase](https://supabase.com) (Recommended - free tier)
   - [Railway](https://railway.app) (Free tier available)
   - [Neon](https://neon.tech) (Serverless PostgreSQL)
   - [PlanetScale](https://planetscale.com) (MySQL compatible)

2. **Get Connection String**
   - Copy your database connection URL
   - Format: `postgresql://username:password@host:port/database`

3. **Set Environment Variables**
   - Add to Vercel environment variables:
     - `POSTGRES_URL`: Your connection string
     - `POSTGRES_PRISMA_URL`: Same as above
     - `POSTGRES_URL_NON_POOLING`: Same as above

4. **Create Database Schema**
   - Connect to your database and run the schema creation SQL above

## ⚙️ Environment Variables Configuration

In your Vercel project settings → Environment Variables, add:

### Required Variables
```bash
# Database (auto-added if using Vercel Postgres)
POSTGRES_URL=postgresql://username:password@host:port/database
POSTGRES_PRISMA_URL=postgresql://username:password@host:port/database?pgbouncer=true&connect_timeout=15
POSTGRES_URL_NON_POOLING=postgresql://username:password@host:port/database

# Security Settings
RATE_LIMIT_MAX_REQUESTS=5
RATE_LIMIT_WINDOW_MS=3600000
BURST_LIMIT_MAX_REQUESTS=3
BURST_LIMIT_WINDOW_MS=60000
EMAIL_COOLDOWN_HOURS=24
IP_BLOCK_DURATION_HOURS=1

# CORS Settings (update with your domain)
ALLOWED_ORIGINS=https://yourdomain.vercel.app,https://www.yourdomain.com
```

### Optional Variables
```bash
# Analytics (if using)
NEXT_PUBLIC_GA_ID=your-google-analytics-id
NEXT_PUBLIC_GTM_ID=your-google-tag-manager-id

# Email Service (if implementing email notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
```

## 🔧 Project Configuration

### 1. Update CORS Settings

Edit `app/lib/cors.js` to include your production domain:

```javascript
const ALLOWED_ORIGINS = [
  'http://localhost:3000',
  'http://localhost:3001',
  'https://yourdomain.vercel.app',  // Add your Vercel domain
  'https://yourdomain.com',         // Add your custom domain
  'https://www.yourdomain.com'      // Add www version
];
```

### 2. Update Next.js Configuration

Ensure `app/next.config.js` is optimized for production:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  experimental: {
    serverComponentsExternalPackages: ['pg'],
  },
  // Add security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
    ];
  },
};

module.exports = nextConfig;
```

### 3. Update Package.json Scripts

Ensure your `app/package.json` has the correct build scripts:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  }
}
```

## 🚀 Deployment Steps

### 1. Connect Repository to Vercel

1. Go to [vercel.com](https://vercel.com)
2. Click "New Project"
3. Import your GitHub repository
4. Vercel will auto-detect Next.js settings

### 2. Configure Build Settings

- **Framework Preset**: Next.js
- **Root Directory**: `app` (if your Next.js app is in the app folder)
- **Build Command**: `npm run build` or `bun run build`
- **Output Directory**: `.next`
- **Install Command**: `npm install` or `bun install`

### 3. Set Environment Variables

Add all the environment variables listed above in the Vercel dashboard.

### 4. Deploy

Click "Deploy" and wait for the build to complete.

## 🔍 Post-Deployment Verification

### 1. Test API Endpoints

Test your deployed endpoints:

```bash
# Test waitlist signup
curl -X POST https://yourdomain.vercel.app/api/waitlist \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# Test stats endpoint
curl https://yourdomain.vercel.app/api/waitlist/stats
```

### 2. Check Database Connection

Verify your database is working by checking the stats endpoint returns data.

### 3. Test Rate Limiting

Verify rate limiting is working by making multiple rapid requests.

## 🔧 Custom Domain Setup (Optional)

1. **Add Custom Domain**
   - In Vercel dashboard, go to "Domains"
   - Add your custom domain
   - Follow DNS configuration instructions

2. **Update CORS Settings**
   - Add your custom domain to `ALLOWED_ORIGINS` in `cors.js`
   - Redeploy the application

3. **SSL Certificate**
   - Vercel automatically provides SSL certificates
   - No additional configuration needed

## 📊 Monitoring & Analytics

### 1. Vercel Analytics

Enable Vercel Analytics in your project dashboard for performance monitoring.

### 2. Database Monitoring

- **Vercel Postgres**: Built-in monitoring in dashboard
- **External DB**: Use your provider's monitoring tools

### 3. Error Tracking

Consider adding error tracking:

```bash
# Add to environment variables
NEXT_PUBLIC_SENTRY_DSN=your-sentry-dsn
```

## 🔒 Security Considerations

### 1. Environment Variables

- Never commit sensitive data to your repository
- Use Vercel's environment variable encryption
- Rotate database passwords regularly

### 2. Rate Limiting

The application includes built-in rate limiting:
- 5 signups per IP per hour
- 3 requests per minute burst limit
- 24-hour email cooldown

### 3. CORS Configuration

Ensure only trusted domains can access your API endpoints.

## 🚨 Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Node.js version compatibility
   - Verify all dependencies are in `package.json`
   - Check build logs in Vercel dashboard

2. **Database Connection Issues**
   - Verify environment variables are set correctly
   - Check database is accessible from Vercel's servers
   - Ensure database schema is created

3. **CORS Errors**
   - Update `ALLOWED_ORIGINS` with your domain
   - Redeploy after changes

4. **Rate Limiting Too Strict**
   - Adjust rate limit values in environment variables
   - Monitor logs for abuse patterns

### Debug Commands

```bash
# Check environment variables
echo $POSTGRES_URL

# Test database connection
psql $POSTGRES_URL -c "SELECT 1;"

# View application logs
vercel logs
```

## 📈 Scaling Considerations

### 1. Database Scaling

- **Vercel Postgres**: Upgrade plan as needed
- **External DB**: Monitor usage and scale accordingly

### 2. Application Scaling

- Vercel automatically scales based on traffic
- Consider using Vercel Edge Functions for global performance

### 3. Rate Limiting

- Current in-memory rate limiting works for single instances
- For high traffic, consider Redis-based rate limiting

## 🎉 Success!

Your StealthList application is now deployed and ready to collect waitlist signups!

### Next Steps

1. **Customize the UI** - Update colors, branding, and content
2. **Add Analytics** - Track signup conversions and user behavior
3. **Set up Notifications** - Email users when you launch
4. **Monitor Performance** - Use Vercel Analytics and database monitoring

### Support

- [Vercel Documentation](https://vercel.com/docs)
- [Next.js Documentation](https://nextjs.org/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Deployment Time**: ~5-10 minutes  
**Cost**: Free tier available on Vercel and most database providers  
**Maintenance**: Minimal - Vercel handles most infrastructure

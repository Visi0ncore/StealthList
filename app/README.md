# 🥷 StealthList Application

> ⚠️ **WORK IN PROGRESS** ⚠️  
> This README.md is currently being updated and may contain incomplete information.

This directory contains the main StealthList application - a secure, production-ready waitlist management system built with Next.js and PostgreSQL.

## ✨ Features

- 📝 **Waitlist Management**: PostgreSQL database for email signups
- 🛡️ **Basic Security**: Rate limiting and input validation
- 📊 **Real-time Stats**: Live counter updates via API
- 🎨 **Clean UI**: Static HTML pages with Tailwind CSS
- 🔧 **Easy Setup**: Automated installation and configuration
- 📱 **Responsive Design**: Works on desktop and mobile

## 🔒 Security Features

**Rate Limiting:**
- 5 signups per IP per hour
- 3 requests per minute per IP
- 24-hour cooldown per email address

**Input Validation:**
- Email format validation
- 254 character limit
- SQL injection protection via parameterized queries

**Basic Monitoring:**
- Logs successful signups
- Tracks failed attempts
- Automatic cleanup of old rate limit data



## 📊 Available Scripts

### Development
```bash
bun run dev          # Start development server
bun run build        # Build for production
bun run start        # Start production server
```

### Setup & Configuration
```bash
bun run setup        # Complete automated setup
bun run destroy      # Completely destroy setup (for fresh start)
```

### Database Management
```bash
bun run db:connect   # Connect to database interactively
bun run db:stats     # View total signup count
bun run db:list      # List all signups
bun run db:recent    # View recent signups (last 24h)
bun run db:reset     # Reset database (delete all data)
```

### Production Scripts
```bash
./scripts/waitlist-stats.sh    # View production statistics (requires .env.prod)
./scripts/waitlist-recent.sh   # View recent production signups (requires .env.prod)
```

## 🌐 API Endpoints

### Waitlist Management
- `POST /api/waitlist` - Add email to waitlist
- `GET /api/waitlist/stats` - Get waitlist statistics

### Signup Management
- `GET /api/signups?env=local|prod` - Get signup data
- `DELETE /api/signups?env=local` - Delete all local signups
- `GET /api/signups/export?env=local|prod&format=csv|json` - Export signup data

## 🛡️ Security Implementation

### Rate Limiting
- 5 signups per IP per hour
- 3 requests per minute per IP
- 24-hour cooldown per email address

### Input Validation
- Email format validation
- 254 character maximum length
- Parameterized queries to prevent SQL injection

### Monitoring
- Logs successful signups
- Tracks failed attempts with IP addresses
- Automatic cleanup of old rate limit data

## 📁 Project Structure

```
stealthlist/
├── lib/
│   └── security.js          # Security middleware and validation
├── pages/
│   └── api/
│       ├── waitlist.js      # Waitlist signup endpoint
│       ├── waitlist/
│       │   └── stats.js     # Waitlist statistics
│       ├── signups.js       # Signup management
│       └── signups/
│           └── export.js    # Data export functionality
├── public/
│   ├── index.html          # Main landing page
│   └── signups.html        # Signup dashboard
├── scripts/
│   ├── setup.sh            # Interactive setup script
│   ├── waitlist-stats.sh   # Production statistics
│   └── waitlist-recent.sh  # Recent signups
├── db-connect.sh           # Database connection
├── db-reset.sh             # Database reset
├── package.json            # Dependencies and scripts
└── next.config.js          # Next.js configuration
```

## 🚀 Deployment

### Vercel Deployment

1. **Connect Repository**: Link your GitHub repository to Vercel
2. **Environment Variables**: Set `POSTGRES_URL` in Vercel dashboard
3. **Build Command**: `bun run build`
4. **Output Directory**: `.next`
5. **Install Command**: `bun install`

### Production Database

For production, use a managed PostgreSQL service:
- **Vercel Postgres**: Native integration
- **Supabase**: Open source alternative
- **Neon**: Serverless PostgreSQL
- **Railway**: Simple deployment

## 📈 Analytics & Monitoring

### Built-in Features
- Real-time signup counter on landing page
- Signup management dashboard
- CSV and JSON export options
- Local and production data separation

### Basic Monitoring
- Logs successful signups
- Tracks failed attempts
- Monitors rate limit usage



## 🆘 Support

- **Documentation**: Check this README and inline comments
- **Issues**: Report bugs and feature requests on GitHub
- **Security**: Report security vulnerabilities privately
- **Community**: Join discussions in GitHub Discussions

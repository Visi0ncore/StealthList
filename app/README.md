# 🥷 StealthList Application

This directory contains the main StealthList application - a secure, production-ready waitlist management system built with Next.js and PostgreSQL.

## ✨ Features

- 📝 **Waitlist Management**: PostgreSQL database for email signups
- 🛡️ **Security**: Rate limiting, input validation, and SQL injection protection
- 📊 **Real-time Stats**: Live counter updates via API
- 🎨 **Custom UI**: Professional interface with custom error handling
- 🔧 **Easy Setup**: One-command automated installation and configuration
- 📱 **Responsive Design**: Works perfectly on desktop and mobile
- 🔄 **Modular Architecture**: Reusable components and clean separation of concerns



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

<!-- ### Production Scripts
```bash
./scripts/waitlist-stats.sh    # View production statistics (requires .env.prod)
./scripts/waitlist-recent.sh   # View recent production signups (requires .env.prod)
``` -->

## 🌐 API Endpoints

### Waitlist Management
- `POST /api/waitlist` - Add email to waitlist
- `GET /api/waitlist/stats` - Get waitlist statistics

### Signup Management
- `GET /api/signups?env=local|prod` - Get signup data
- `DELETE /api/signups?env=local` - Delete all local signups
- `GET /api/signups/export?env=local|prod&format=csv|json` - Export signup data

## 🔒 Security Features

### Rate Limiting
- 5 signups per IP per hour
- 3 requests per minute per IP
- 24-hour cooldown per email address

### Input Validation
- Email format validation with custom error handling
- 254 character maximum length
- Parameterized queries to prevent SQL injection
- Custom validation (no browser popups)

### Monitoring & Protection
- Logs successful signups with IP tracking
- Tracks failed attempts with IP addresses
- Automatic cleanup of old rate limit data
- One-time warning system for cleaner logs
- CORS configuration for secure cross-origin requests

## 📚 Documentation

For more detailed information, see:
- **[Application Structure](../docs/application-structure.md)** - Architecture overview and page navigation
- **[Local Environment](../docs/local-environment.md)** - Local development setup and management  
- **[Production Deployment](../docs/prod-environment.md)** - Deploy to Vercel and other platforms

## 📁 Project Structure

```
app/
├── components/              # Reusable React components
│   ├── Layout.js           # Main layout with header
│   ├── Button.js           # Reusable button component
│   ├── Modal.js            # Modal dialog component
│   ├── StatsCard.js        # Statistics display card
│   ├── SignupsTable.js     # Signup data table
│   └── EnvironmentSection.js # Complete environment dashboard
├── lib/                    # Utility libraries
│   ├── security.js         # Rate limiting and validation
│   ├── cors.js             # CORS configuration
│   └── warnings.js         # One-time warning system
├── pages/                  # Next.js pages
│   ├── index.js            # Main waitlist page (/)
│   ├── dashboard.js        # Production dashboard (/dashboard)
│   ├── local-dashboard.js  # Local dashboard (/local-dashboard)
│   └── _app.js             # App wrapper
├── scripts/                # Automation scripts
│   ├── setup.sh            # Complete setup script
│   ├── destroy.sh          # Environment cleanup
│   ├── db-connect.sh       # Database connection
│   ├── db-reset.sh         # Database reset
│   ├── waitlist-stats.sh   # Production statistics
│   └── waitlist-recent.sh  # Recent signups
├── styles/                 # Global styles
│   └── globals.css         # Tailwind + custom styles
└── public/                 # Static assets
    ├── index.html          # Original static page (reference)
    └── signups.html        # Original dashboard (reference)
```

<!-- ## 🚀 Deployment

For detailed deployment instructions, see **[Production Deployment](../docs/prod-environment.md)**. -->

## 📈 Analytics & Monitoring

### Built-in Features
- Real-time signup counter on landing page
- Signup management dashboard with separate local/production views
- CSV and JSON export options
- Local and production data separation

### Basic Monitoring
- Logs successful signups
- Tracks failed attempts with IP addresses
- Monitors rate limit usage
- One-time warning system for cleaner logs



## 🆘 Support

- **Documentation**: Check this README and inline comments
- **Issues**: Report bugs and feature requests on GitHub
- **Security**: Report security vulnerabilities privately
- **Community**: [Contact me on X](https://x.com/stealthlist)

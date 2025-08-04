# 🥷 StealthList

> **Secure, scalable waitlist management platform with comprehensive security and abuse prevention**

A bulletproof Next.js website with PostgreSQL-backed waiting list functionality, featuring comprehensive security and abuse prevention. This component serves as the public-facing website for StealthList with secure user registration capabilities.

![Next.js](https://img.shields.io/badge/Next.js-14-black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-blue)
![Security](https://img.shields.io/badge/Security-Multi--Layer-green)

## ✨ Features

- ✅ **Secure Waiting List**: PostgreSQL database with direct pg client
- ✅ **Multi-Layer Security**: Rate limiting, IP blocking, and abuse prevention
- ✅ **Email Validation**: Enhanced client and server-side validation
- ✅ **Database Management**: Secure command-line tools with no password exposure
- ✅ **Static HTML Frontend**: Fast, reliable UI with Tailwind CSS styling
- ✅ **Real-time Statistics**: Live counter updates via API
- ✅ **Production Ready**: Comprehensive error handling and monitoring

## 🔒 Security Features

🛡️ **Backend Protection:**
- **Rate Limiting**: Max 5 signups per IP per hour
- **Burst Protection**: Max 3 requests per minute per IP
- **IP Blocking**: 1-hour automatic blocks for abusers
- **Email Deduplication**: 24-hour cooldown per email address
- **Input Sanitization**: Email cleaning and validation
- **SQL Injection Protection**: Parameterized queries only
- **Security Headers**: XSS, CSRF, and clickjacking protection

🪖 **Frontend Protection:**
- **5-second cooldown** between form submissions
- **Enhanced email validation** (254 character limit, proper regex)
- **User-friendly error messages** with visual feedback
- **Network error handling** with retry guidance

⛑️ **Monitoring & Logging:**
- **Successful signups logged** with email and count
- **Failed attempts logged** with IP addresses and timestamps
- **Automatic cleanup** of old rate limit data
- **Attack pattern detection** and blocking

## 🚀 Quick Start

### 1. Install Dependencies

```bash
bun install
```

### 2. Set Up Database

**Local PostgreSQL Setup:**

```bash
# Install PostgreSQL locally
# Create database and user with secure credentials
psql -U postgres -c "CREATE DATABASE stealthlist_waitlist;"
psql -U postgres -c "CREATE USER stealthlist_user WITH ENCRYPTED PASSWORD 'your_secure_password';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE stealthlist_waitlist TO stealthlist_user;"
```

**Create the waitlist table:**

```sql
CREATE TABLE waitlist_signups (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. Configure Environment

Set up your local database configuration:

```bash
# Option 1: Use the setup script (recommended)
bun run setup

# Option 2: Manual setup
cp .env.example.local .env.local
nano .env.local
```

**Example .env.local content:**
```bash
POSTGRES_URL="postgresql://your_username:your_password@localhost:5432/your_database"
POSTGRES_PRISMA_URL="postgresql://your_username:your_password@localhost:5432/your_database?pgbouncer=true&connect_timeout=15"
POSTGRES_URL_NON_POOLING="postgresql://your_username:your_password@localhost:5432/your_database"
```

**Generate a secure password:**
```bash
openssl rand -base64 32
```

**Database Setup Tips:**
- Create a PostgreSQL database for your waitlist
- Use a dedicated user with appropriate permissions
- Ensure the database is accessible from localhost:5432

### 4. Set Up Secure Database Access

The system automatically creates a secure `.pgpass` file for password-free database access.

### 5. Start Development Server

```bash
bun run dev
```

Visit [http://localhost:3000](http://localhost:3000)

## 📊 Available Scripts

### Development
```bash
bun run dev          # Start development server
bun run build        # Build for production
bun run start        # Start production server
```

### Database Management
```bash
bun run db:connect   # Connect to database interactively
bun run db:stats     # View total signup count
bun run db:list      # List all signups
bun run db:recent    # View recent signups (last 24h)
bun run db:reset     # Reset database (delete all data)
```

### Testing
```bash
bun run test         # Run comprehensive test suite
```

### Production Scripts
```bash
./scripts/waitlist-stats.sh    # View production statistics
./scripts/waitlist-recent.sh   # View recent production signups
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
- **Per IP**: 5 signups per hour
- **Burst Protection**: 3 requests per minute
- **Email Cooldown**: 24-hour cooldown per email
- **IP Blocking**: 1-hour automatic blocks for abuse

### Input Validation
- **Email Format**: RFC-compliant email validation
- **Length Limits**: 254 character maximum
- **Sanitization**: Email cleaning and normalization
- **SQL Injection**: Parameterized queries only

### Monitoring
- **Success Logging**: All successful signups logged
- **Error Tracking**: Failed attempts with IP addresses
- **Cleanup**: Automatic cleanup of old rate limit data
- **Pattern Detection**: Attack pattern recognition

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
│   ├── test-suite.sh       # Comprehensive test suite
│   ├── waitlist-stats.sh   # Production statistics
│   └── waitlist-recent.sh  # Recent signups
├── db-connect.sh           # Database connection
├── db-reset.sh             # Database reset
├── package.json            # Dependencies and scripts
└── next.config.js          # Next.js configuration
```

## 🔧 Configuration

### Environment Variables

**Required:**
- `POSTGRES_URL` - PostgreSQL connection string

**Optional:**
- `POSTGRES_PRISMA_URL` - Prisma-compatible connection string
- `POSTGRES_URL_NON_POOLING` - Non-pooling connection string

### Database Schema

```sql
CREATE TABLE waitlist_signups (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
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

## 🧪 Testing

### Comprehensive Test Suite
The project includes a comprehensive test suite that validates all functionality:

```bash
bun run test
```

**Test Coverage:**
- ✅ **Page Loading**: Landing page and dashboard accessibility
- ✅ **API Endpoints**: All endpoints with proper error handling
- ✅ **First-Run Experience**: Setup state and user guidance
- ✅ **UI Components**: Icons, buttons, and styling
- ✅ **Error Handling**: Graceful degradation and user feedback
- ✅ **HTTP Status Codes**: Proper response codes for different states
- ✅ **Security Headers**: CORS and security header validation
- ✅ **Database Integration**: Connection handling and error states
- ✅ **Modal System**: Custom modals for setup and data management
- ✅ **Setup Script**: Dynamic file creation and step numbering

**Test Categories:**
- **📄 Page Tests**: Verify pages load correctly
- **📊 API Tests**: Validate all API endpoints
- **🎨 UI Tests**: Check icons, styling, and interactions
- **🛡️ Security Tests**: Verify headers and protection
- **🔧 Setup Tests**: Ensure first-run experience works
- **⚙️ Script Tests**: Validate setup script functionality

## 📈 Analytics & Monitoring

### Built-in Analytics
- **Real-time Counter**: Live signup count on landing page
- **Dashboard**: Comprehensive signup management interface
- **Export Capabilities**: CSV and JSON export options
- **Environment Separation**: Local and production data isolation

### Monitoring Features
- **Success Tracking**: All successful signups logged
- **Error Monitoring**: Failed attempts with detailed logging
- **Rate Limit Tracking**: IP-based abuse prevention
- **Performance Metrics**: Response time and throughput

## 🔒 Security Best Practices

### Implemented Protections
- ✅ **Rate Limiting**: Prevents abuse and spam
- ✅ **Input Validation**: Server-side email validation
- ✅ **SQL Injection**: Parameterized queries
- ✅ **XSS Protection**: Security headers and sanitization
- ✅ **CSRF Protection**: Same-origin policy enforcement
- ✅ **Clickjacking**: X-Frame-Options header
- ✅ **Content Sniffing**: X-Content-Type-Options header

### Recommended Additional Measures
- **HTTPS Only**: Force HTTPS in production
- **CORS Configuration**: Restrict cross-origin requests
- **API Key Protection**: Add authentication for admin endpoints
- **Log Monitoring**: Set up alerts for suspicious activity
- **Backup Strategy**: Regular database backups

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request

### Development Guidelines
- Follow existing code style
- Add tests for new features
- Update documentation
- Ensure security best practices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check this README and inline comments
- **Issues**: Report bugs and feature requests on GitHub
- **Security**: Report security vulnerabilities privately
- **Community**: Join discussions in GitHub Discussions

---

**Built with ❤️ for secure waitlist management**
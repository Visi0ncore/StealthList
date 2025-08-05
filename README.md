# 🥷 StealthList

StealthList is a bulletproof Next.js application that provides secure, production-ready waitlist management with PostgreSQL backend.  
Built with security-first principles, it includes multi-layer protection against abuse, comprehensive monitoring, and enterprise-grade reliability.

![Next.js](https://img.shields.io/badge/Next.js-14-black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-blue)
![Security](https://img.shields.io/badge/Security-Multi--Layer-green)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🏗️ Architecture

StealthList is built as a modern web application with the following architecture:

- **Frontend**: Next.js with static HTML pages and Tailwind CSS
- **Backend**: Next.js API routes with PostgreSQL database
- **Security**: Multi-layer protection including rate limiting, IP blocking, and input validation
- **Database**: PostgreSQL with secure connection management
- **Deployment**: Optimized for Vercel with support for other platforms

## ✨ Key Features

- 🔒 **Multi-Layer Security**: Rate limiting, IP blocking, email deduplication
- 📊 **Real-time Analytics**: Live signup counters and comprehensive dashboards
- 🛡️ **Abuse Prevention**: Automatic detection and blocking of malicious activity
- 📈 **Production Ready**: Comprehensive error handling and monitoring
- 🔧 **Developer Friendly**: Secure CLI tools and comprehensive documentation

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ or Bun
- PostgreSQL 13+
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/StealthList.git
   cd StealthList
   ```

2. **Navigate to the app directory**
   ```bash
   cd app
   ```

3. **Install dependencies**
   ```bash
   bun install
   ```

4. **Set up the database and environment**
   ```bash
   bun run setup
   ```

5. **Start the development server**
   ```bash
   bun run dev
   ```

Visit [http://localhost:3000](http://localhost:3000) to see your waitlist in action.

## 📚 Documentation

For detailed documentation, setup instructions, API reference, and development guides, see the [app README](./app/README.md).

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](./CONTRIBUTING.md) for details on how to:

- Report bugs and feature requests
- Submit pull requests
- Follow our development guidelines
- Set up your development environment

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ by [Chris](https://x.com/Hiccup_za)**
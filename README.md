# 🥷 StealthList

StealthList is a Next.js application that provides waitlist management with a PostgreSQL backend.

![Next.js](https://img.shields.io/badge/Next.js-14-black)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-blue)
![License](https://img.shields.io/badge/License-MIT-blue)

## 🏗️ Architecture

StealthList is built as a modern web application with the following architecture:

- **Frontend**: Next.js with static HTML pages and Tailwind CSS
- **Backend**: Next.js API routes with PostgreSQL database
- **Security**: Basic protection including rate limiting and input validation
- **Database**: PostgreSQL with secure connection management
- **Deployment**: Optimized for Vercel with support for other platforms

## ✨ Key Features

- 🔒 **Basic Security**: Rate limiting and input validation
- 📊 **Real-time Stats**: Live signup counters and dashboard
- 🛡️ **Simple Protection**: Basic rate limiting and email validation
- 📈 **Easy Setup**: Automated installation and configuration
- 🔧 **Developer Friendly**: CLI tools and documentation

## 🚀 Quick Start

### Prerequisites
- Bun
- PostgreSQL

### Setup & Run

```bash
cd app
bun run setup
```

This single command will:
- 📦 Install all dependencies
- 🔌 Create database and user with secure credentials
- 🪄 Generate environment files
- 🧪 Test the complete setup
- 🚀 Start the development server

Visit [http://localhost:3000](http://localhost:3000)

### Additional Commands

```bash
bun run destroy      # Destroy setup (fresh start)
```

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
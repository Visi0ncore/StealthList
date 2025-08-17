# Local Environment Management

This guide explains how to set up and destroy your local StealthList development environment.

## 🚀 Setting Up Your Environment

The setup script automates the entire process of creating a local development environment.

### Prerequisites

Before running the setup, ensure you have:

- **Bun** - JavaScript runtime and package manager
- **PostgreSQL** - Database server

### Installation Commands

**Bun:**
```bash
curl -fsSL https://bun.sh/install | bash
```

**PostgreSQL (macOS with Homebrew):**
```bash
brew install postgresql@15
brew services start postgresql@15
```

### Running the Setup

1. Navigate to the StealthList app directory
2. Run the setup script:
   ```bash
   ./scripts/setup.sh
   ```

### What the Setup Does

The script automatically:

1. **Installs Dependencies** - Downloads all required packages
2. **Creates Database** - Sets up PostgreSQL database and user with secure credentials
3. **Configures Environment** - Creates `.env.local` with database connection settings
4. **Tests Setup** - Verifies database connection and API endpoints
5. **Starts Development Server** - Launches the application locally

### Files Created

- `.env.local` - Environment configuration
- `.pgpass` - Database password file (for secure access)
- Database credentials (temporarily stored during setup)

### Troubleshooting

If PostgreSQL connection fails:
- Ensure PostgreSQL is running: `brew services start postgresql@15`
- Test connection: `psql postgres -c 'SELECT 1;'`

## 🗑️ Destroying Your Environment

The destroy script completely removes your local setup and all associated data.

### Running the Destroy

1. Navigate to the StealthList app directory
2. Run the destroy script:
   ```bash
   ./scripts/destroy.sh
   ```
3. Type `DESTROY` when prompted to confirm

### What Gets Destroyed

The script removes:

- **Database** - Complete PostgreSQL database
- **User** - Database user account
- **All Data** - All local signup information
- **Environment Files** - `.env.local` and `.pgpass`
- **Cache** - Next.js build cache
- **Temporary Files** - Any credential files created during setup

### Safety Features

- **Confirmation Required** - Must type `DESTROY` to proceed
- **Graceful Handling** - Continues even if some components don't exist
- **Server Termination** - Stops any running development servers
- **Connection Validation** - Verifies PostgreSQL before attempting destruction

### When to Use

Use the destroy script when you want to:
- Start fresh with a clean environment
- Remove all local data
- Troubleshoot persistent issues
- Reset to initial state

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Setup | `./scripts/setup.sh` | Create complete local environment |
| Destroy | `./scripts/destroy.sh` | Remove all local setup and data |
| Start Dev | `bun run dev` | Launch development server |
| Stop Dev | `Ctrl+C` | Stop development server |

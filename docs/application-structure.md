# StealthList Application Structure

This document explains the application structure and how to access different parts of StealthList.

## 🚀 **Application Pages**

### **Main Waitlist Page** (`/`)
- **URL**: `http://localhost:3000/` or just `http://localhost:3000`
- **Purpose**: Public-facing waitlist signup page
- **Features**: 
  - Email collection form with custom error handling
  - Real-time signup counter
  - Product information and features
  - Setup instructions for developers

### **Production Dashboard** (`/dashboard`)
- **URL**: `http://localhost:3000/dashboard`
- **Purpose**: View and manage production environment data
- **Features**:
  - View production signups
  - Export data (CSV/JSON)
  - Real-time statistics
  - Read-only access (no destructive actions)

### **Local Dashboard** (`/local-dashboard`)
- **URL**: `http://localhost:3000/local-dashboard`
- **Purpose**: Full development environment with all features
- **Features**:
  - View local signups
  - Add mock users for testing
  - Export data (CSV/JSON)
  - Delete all data (nuke functionality)
  - Setup instructions
  - Real-time statistics

## 🏗️ **Architecture Overview**

### **Component Structure**
```
app/
├── components/           # Reusable React components
│   ├── Layout.js        # Main layout with header navigation
│   ├── Button.js        # Reusable button component
│   ├── Modal.js         # Modal dialog component
│   ├── StatsCard.js     # Statistics display card
│   ├── SignupsTable.js  # Signup data table
│   └── EnvironmentSection.js # Complete environment dashboard
├── pages/               # Next.js pages
│   ├── index.js         # Main waitlist page (/)
│   ├── dashboard.js     # Production dashboard (/dashboard)
│   ├── local-dashboard.js # Local dashboard (/local-dashboard)
│   └── _app.js          # App wrapper
├── lib/                 # Utility libraries
│   ├── security.js      # Rate limiting and validation
│   ├── cors.js          # CORS configuration
│   └── warnings.js      # One-time warning system
├── styles/              # Global styles
│   └── globals.css      # Tailwind + custom styles
└── public/              # Static assets
    ├── index.html       # Original static page (kept for reference)
    └── signups.html     # Original dashboard (kept for reference)
```

### **Key Benefits**
1. **Modular Components**: Reusable across different pages
2. **Consistent UI**: Same design language throughout
3. **Easy Navigation**: Clear separation between public and admin areas
4. **Scalable**: Easy to add new features or environments
5. **Security**: Built-in rate limiting and validation

## 🔧 **Development Workflow**

### **Starting the Application**
```bash
cd app
bun run setup        # Complete automated setup
bun run dev          # Start development server
```

### **Accessing Different Pages**
1. **Public Waitlist**: Visit `http://localhost:3000`
2. **Production Dashboard**: Visit `http://localhost:3000/dashboard`
3. **Local Dashboard**: Visit `http://localhost:3000/local-dashboard`

### **Navigation**
- The header navigation allows switching between dashboards
- The logo on any page takes you back to the main waitlist page
- Each dashboard has its own specific functionality

## 📱 **User Experience**

### **For End Users**
- Visit the main page to join the waitlist
- Clean, professional interface with custom error handling
- Real-time feedback on signup status
- Mobile-responsive design
- No browser validation popups - custom error messages

### **For Administrators**
- Separate dashboards for different environments
- Production dashboard for monitoring real users
- Local dashboard for development and testing
- Export capabilities for data analysis
- Mock user generation for testing

## 🔄 **Migration from Static HTML**

The original static HTML files are preserved in the `public/` folder:
- `public/index.html` - Original waitlist page
- `public/signups.html` - Original dashboard

The new Next.js application provides the same functionality but with:
- Better component reusability
- Improved maintainability
- Enhanced user experience
- Modern React patterns
- Custom error handling
- One-time warning system to prevent log spam

## 🎯 **Key Features**

### **Security & Validation**
- Custom email validation (no browser popups)
- Rate limiting (5 signups per IP per hour)
- Input sanitization and SQL injection protection
- One-time warning system for cleaner logs

### **User Interface**
- Custom error messages with proper styling
- Real-time signup counter
- Responsive design for all devices
- Professional error handling with icons and animations

### **Development Experience**
- Automated setup with `bun run setup`
- Database management scripts
- Mock user generation for testing
- Export functionality (CSV/JSON)

The application is now fully modularized and ready for production use!

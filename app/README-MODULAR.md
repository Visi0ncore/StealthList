# StealthList Modular Application

This document explains the new modular structure and how to access different parts of the application.

## 🚀 **How to Access Different Pages**

### **Main Waitlist Page** (`/`)
- **URL**: `http://localhost:3000/` or just `http://localhost:3000`
- **Purpose**: Public-facing waitlist signup page
- **Features**: 
  - Email collection form
  - Real-time signup counter
  - Product information and features
  - Setup instructions

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
  - Add mock users
  - Export data (CSV/JSON)
  - Delete all data (nuke)
  - Setup instructions
  - Real-time statistics

## 🏗️ **Architecture Overview**

### **Component Structure**
```
app/
├── components/           # Reusable React components
│   ├── Layout.js        # Main layout with header
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

## 🔧 **Development Workflow**

### **Starting the Application**
```bash
cd app
bun install          # Install dependencies
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
- Clean, professional interface
- Real-time feedback on signup status
- Mobile-responsive design

### **For Administrators**
- Separate dashboards for different environments
- Production dashboard for monitoring real users
- Local dashboard for development and testing
- Export capabilities for data analysis

## 🔄 **Migration from Static HTML**

The original static HTML files are preserved in the `public/` folder:
- `public/index.html` - Original waitlist page
- `public/signups.html` - Original dashboard

The new Next.js application provides the same functionality but with:
- Better component reusability
- Improved maintainability
- Enhanced user experience
- Modern React patterns

## 🎯 **Next Steps**

1. **Test all functionality** on each page
2. **Verify API endpoints** work correctly
3. **Check mobile responsiveness**
4. **Test export functionality**
5. **Verify navigation between pages**

The application is now fully modularized and ready for production use!

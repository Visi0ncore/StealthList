# StealthList Component Architecture

This document outlines the modular component structure for the StealthList dashboard application.

## Component Structure

### Core Components

#### `Layout.js`
- **Purpose**: Main layout wrapper that includes header and common styling
- **Props**: 
  - `children`: React children
  - `title`: Page title (default: "StealthList")
  - `description`: Page description
- **Features**: Header with navigation, responsive design, dark theme

#### `Button.js`
- **Purpose**: Reusable button component with multiple variants
- **Props**:
  - `children`: Button content
  - `variant`: "outline" | "primary" | "destructive" (default: "outline")
  - `onClick`: Click handler
  - `disabled`: Disabled state (default: false)
  - `className`: Additional CSS classes
  - `type`: Button type (default: "button")

#### `Modal.js`
- **Purpose**: Reusable modal component with backdrop and keyboard support
- **Props**:
  - `isOpen`: Modal visibility state
  - `onClose`: Close handler
  - `children`: Modal content
  - `title`: Modal title (optional)
  - `description`: Modal description (optional)
- **Features**: ESC key to close, backdrop click to close, body scroll lock

#### `StatsCard.js`
- **Purpose**: Displays statistics with icon and color variants
- **Props**:
  - `title`: Card title
  - `value`: Statistic value
  - `icon`: SVG icon component
  - `color`: "blue" | "green" | "purple" | "red" | "yellow" (default: "blue")

#### `SignupsTable.js`
- **Purpose**: Displays signup data in a table format
- **Props**:
  - `signups`: Array of signup objects with id, email, created_at

#### `EnvironmentSection.js`
- **Purpose**: Complete environment dashboard section with all functionality
- **Props**:
  - `environment`: "local" | "prod"
  - `title`: Section title
  - `showSetupButton`: Show setup button (default: false)
  - `showAddUserButton`: Show add user button (default: false)
  - `showNukeButton`: Show delete all button (default: false)
- **Features**: Data loading, error handling, export, delete, add users

## Pages

### `/dashboard` (Production Dashboard)
- Uses `EnvironmentSection` with `environment="prod"`
- Shows only refresh and export functionality
- No setup, add user, or delete buttons

### `/local-dashboard` (Local Dashboard)
- Uses `EnvironmentSection` with `environment="local"`
- Shows all functionality including setup, add users, and delete
- Full feature set for development

### `/` (Index)
- Redirects to `/dashboard`

## Styling

### Tailwind Configuration
- Custom color palette matching the original design
- Dark mode by default
- Custom animations and utilities

### Global Styles (`globals.css`)
- Base styles for dark theme
- Custom animations (fadeIn, slideUp, loading)
- Component-specific styles

## Benefits of This Architecture

1. **Reusability**: Components can be used across different pages
2. **Maintainability**: Changes to components affect all instances
3. **Consistency**: Uniform UI/UX across the application
4. **Scalability**: Easy to add new features or modify existing ones
5. **Separation of Concerns**: Each component has a single responsibility
6. **Type Safety**: Props are clearly defined and documented

## Usage Example

```jsx
import Layout from '../components/Layout';
import EnvironmentSection from '../components/EnvironmentSection';

export default function MyPage() {
  return (
    <Layout title="My Dashboard" description="Custom dashboard">
      <EnvironmentSection 
        environment="local"
        title="My Environment"
        showSetupButton={true}
        showAddUserButton={true}
        showNukeButton={false}
      />
    </Layout>
  );
}
```

## Future Enhancements

1. **TypeScript**: Add TypeScript for better type safety
2. **Testing**: Add unit tests for components
3. **Storybook**: Add Storybook for component documentation
4. **State Management**: Add global state management if needed
5. **Error Boundaries**: Add error boundaries for better error handling

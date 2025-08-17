import { useState, useEffect } from 'react';
import StatsCard from './StatsCard';
import SignupsTable from './SignupsTable';
import Button from './Button';
import Modal from './Modal';

export default function EnvironmentSection({
  environment,
  title,
  showAddUserButton = false,
  showNukeButton = false
}) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [exportModalOpen, setExportModalOpen] = useState(false);
  const [nukeModalOpen, setNukeModalOpen] = useState(false);
  const [addUserModalOpen, setAddUserModalOpen] = useState(false);
  const [userCount, setUserCount] = useState(5);
  const [nukeSuccessModalOpen, setNukeSuccessModalOpen] = useState(false);
  const [nukeErrorModalOpen, setNukeErrorModalOpen] = useState(false);
  const [nukeSuccessCount, setNukeSuccessCount] = useState(0);
  const [nukeErrorMessage, setNukeErrorMessage] = useState('');
  const [addUserSuccessModalOpen, setAddUserSuccessModalOpen] = useState(false);
  const [addUserErrorModalOpen, setAddUserErrorModalOpen] = useState(false);
  const [addUserSuccessMessage, setAddUserSuccessMessage] = useState('');
  const [addUserErrorMessage, setAddUserErrorMessage] = useState('');
  const [exportErrorModalOpen, setExportErrorModalOpen] = useState(false);
  const [exportErrorMessage, setExportErrorMessage] = useState('');

  const loadData = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(`/api/signups?env=${environment}`);
      const result = await response.json();

      if (result.error) {
        setError(result.error);
      } else {
        setData(result);
      }
    } catch (err) {
      setError('Failed to load data. Please check your connection.');
    } finally {
      setLoading(false);
    }
  };

  const exportData = async (format) => {
    try {
      const response = await fetch(`/api/signups/export?env=${environment}&format=${format}`);

      if (!response.ok) {
        throw new Error('Export failed');
      }

      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `signups-${environment}-${new Date().toISOString().split('T')[0]}.${format}`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
      setExportModalOpen(false);
    } catch (error) {
      console.error('Export error:', error);
      setExportErrorMessage('Export failed. Please try again.');
      setExportErrorModalOpen(true);
    }
  };

  const nukeData = async () => {
    try {
      const response = await fetch(`/api/signups?env=${environment}`, {
        method: 'DELETE'
      });

      const result = await response.json();

      if (result.success) {
        setNukeSuccessCount(result.deletedCount);
        setNukeSuccessModalOpen(true);
        loadData();
      } else {
        setNukeErrorMessage(result.error || 'Unknown error');
        setNukeErrorModalOpen(true);
      }
      setNukeModalOpen(false);
    } catch (error) {
      console.error('Nuke error:', error);
      setNukeErrorMessage('Failed to delete data. Please try again.');
      setNukeErrorModalOpen(true);
    }
  };

  const addMockUsers = async () => {
    try {
      const response = await fetch('/api/signups/add-mock', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ count: userCount })
      });

      const result = await response.json();

      if (result.success) {
        setAddUserSuccessMessage(result.message);
        setAddUserSuccessModalOpen(true);
        loadData();
      } else {
        setAddUserErrorMessage(result.message || 'Failed to add users');
        setAddUserErrorModalOpen(true);
      }
      setAddUserModalOpen(false);
    } catch (error) {
      console.error('Error adding mock users:', error);
      setAddUserErrorMessage('Failed to add users. Please try again.');
      setAddUserErrorModalOpen(true);
    }
  };

  useEffect(() => {
    loadData();
  }, [environment]);

  const formatNumber = (num) => {
    return num.toLocaleString();
  };

  if (loading) {
    return (
      <div className="space-y-4">
        <div className="animate-pulse">
          <div className="h-8 bg-muted rounded w-48 mb-4"></div>
          <div className="h-4 bg-muted rounded w-32"></div>
          <div className="h-4 bg-muted rounded w-24"></div>
        </div>
      </div>
    );
  }

  if (error) {
    const isSetupMessage = error.includes('not configured') || error.includes('setup');

    return (
      <div className="bg-card border border-border rounded-lg p-6 text-center">
        <div className="flex items-center justify-center w-12 h-12 mx-auto bg-muted rounded-full mb-4">
          <svg className="w-6 h-6 text-muted-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
        </div>
        <h3 className="text-lg font-semibold mb-2">
          {isSetupMessage ? 'Setup Required' : 'Error Loading Data'}
        </h3>
        <p className="text-sm text-muted-foreground mb-4">Local database not configured</p>
        {isSetupMessage && (
          <p className="text-xs text-muted-foreground">
            {environment === 'local'
              ? 'Run the setup command to configure your local database'
              : 'Configure your .env.prod file for production access'
            }
          </p>
        )}
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-3xl md:text-4xl font-bold tracking-tight text-foreground">{title}</h2>
        <div className="flex gap-2">
          {showAddUserButton && (
            <Button variant="primary" onClick={() => setAddUserModalOpen(true)}>
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              Add Users
            </Button>
          )}

          <Button onClick={loadData}>
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Refresh
          </Button>

          <Button
            onClick={() => setExportModalOpen(true)}
            disabled={data.totalSignups === 0}
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            Export
          </Button>

          {showNukeButton && (
            <Button
              variant="destructive"
              onClick={() => setNukeModalOpen(true)}
              disabled={data.totalSignups === 0}
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </Button>
          )}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <StatsCard
          title="Total Signups"
          value={formatNumber(data.totalSignups)}
          color="blue"
          icon={
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
          }
        />

        <StatsCard
          title="Last 24 Hours"
          value={formatNumber(data.stats.last24Hours)}
          color="green"
          icon={
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          }
        />

        <StatsCard
          title="Last 7 Days"
          value={formatNumber(data.stats.last7Days)}
          color="purple"
          icon={
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          }
        />
      </div>

      <SignupsTable signups={data.signups} />

      {/* Export Modal */}
      <Modal
        isOpen={exportModalOpen}
        onClose={() => setExportModalOpen(false)}
        title="Export Data"
        description="Choose the format for your export file"
      >
        <div className="flex gap-2">
          <Button
            variant="outline"
            className="flex-1"
            onClick={() => exportData('csv')}
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            CSV
          </Button>
          <Button
            variant="outline"
            className="flex-1"
            onClick={() => exportData('json')}
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
            </svg>
            JSON
          </Button>
        </div>
        <Button
          variant="outline"
          className="w-full mt-4"
          onClick={() => setExportModalOpen(false)}
        >
          Cancel
        </Button>
      </Modal>

      {/* Nuke Modal */}
      <Modal
        isOpen={nukeModalOpen}
        onClose={() => setNukeModalOpen(false)}
        title="Danger Zone"
        description="This will permanently delete ALL local signup data and cannot be undone."
      >
        <div className="flex gap-2">
          <Button
            variant="destructive"
            className="flex-1"
            onClick={nukeData}
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
            Delete All Data
          </Button>
          <Button
            variant="outline"
            className="flex-1"
            onClick={() => setNukeModalOpen(false)}
          >
            Cancel
          </Button>
        </div>
      </Modal>

      {/* Add User Modal */}
      <Modal
        isOpen={addUserModalOpen}
        onClose={() => setAddUserModalOpen(false)}
        title="Add Mock Users"
        description="Add test users to your local database"
      >
        <div className="space-y-3">
          <div className="flex items-center gap-2">
            <label htmlFor="userCount" className="text-sm font-medium">Number of users:</label>
            <input
              type="number"
              id="userCount"
              min="1"
              max="100"
              value={userCount}
              onChange={(e) => setUserCount(parseInt(e.target.value) || 5)}
              className="w-20 px-2 py-1 text-sm border border-border rounded bg-background text-foreground"
            />
          </div>
          <div className="flex gap-2">
            <Button
              variant="primary"
              className="flex-1"
              onClick={addMockUsers}
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              Add Users
            </Button>
            <Button
              variant="outline"
              onClick={() => setAddUserModalOpen(false)}
            >
              Cancel
            </Button>
          </div>
        </div>
      </Modal>

      {/* Nuke Success Modal */}
      <Modal
        isOpen={nukeSuccessModalOpen}
        onClose={() => setNukeSuccessModalOpen(false)}
      >
        <div className="text-center space-y-4">
          <div className="flex items-center justify-center w-16 h-16 mx-auto bg-green-500/20 rounded-full">
            <svg className="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <div>
            <h3 className="text-xl font-semibold text-green-400 mb-2">Data Deleted Successfully</h3>
            <p className="text-sm text-muted-foreground">Successfully deleted {nukeSuccessCount} signup records</p>
          </div>
          <div className="flex justify-center pt-2">
            <Button
              variant="primary"
              onClick={() => setNukeSuccessModalOpen(false)}
              className="px-6"
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
              </svg>
              Got it
            </Button>
          </div>
        </div>
      </Modal>

      {/* Nuke Error Modal */}
      <Modal
        isOpen={nukeErrorModalOpen}
        onClose={() => setNukeErrorModalOpen(false)}
      >
        <div className="text-center space-y-4">
          <div className="flex items-center justify-center w-16 h-16 mx-auto bg-red-500/20 rounded-full">
            <svg className="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <div>
            <h3 className="text-xl font-semibold text-red-400 mb-2">Delete Failed</h3>
            <p className="text-sm text-muted-foreground">{nukeErrorMessage}</p>
          </div>
          <div className="flex justify-center pt-2">
            <Button
              variant="outline"
              onClick={() => setNukeErrorModalOpen(false)}
              className="px-6"
            >
              Got it
            </Button>
          </div>
        </div>
      </Modal>

      {/* Add User Success Modal */}
      <Modal
        isOpen={addUserSuccessModalOpen}
        onClose={() => setAddUserSuccessModalOpen(false)}
      >
        <div className="text-center space-y-4">
          <div className="flex items-center justify-center w-16 h-16 mx-auto bg-green-500/20 rounded-full">
            <svg className="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <div>
            <h3 className="text-xl font-semibold text-green-400 mb-2">Users Added Successfully</h3>
            <p className="text-sm text-muted-foreground">{addUserSuccessMessage}</p>
          </div>
          <div className="flex justify-center pt-2">
            <Button
              variant="primary"
              onClick={() => setAddUserSuccessModalOpen(false)}
              className="px-6"
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
              </svg>
              Got it
            </Button>
          </div>
        </div>
      </Modal>

      {/* Add User Error Modal */}
      <Modal
        isOpen={addUserErrorModalOpen}
        onClose={() => setAddUserErrorModalOpen(false)}
      >
        <div className="text-center space-y-4">
          <div className="flex items-center justify-center w-16 h-16 mx-auto bg-red-500/20 rounded-full">
            <svg className="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <div>
            <h3 className="text-xl font-semibold text-red-400 mb-2">Failed to Add Users</h3>
            <p className="text-sm text-muted-foreground">{addUserErrorMessage}</p>
          </div>
          <div className="flex justify-center pt-2">
            <Button
              variant="outline"
              onClick={() => setAddUserErrorModalOpen(false)}
              className="px-6"
            >
              Got it
            </Button>
          </div>
        </div>
      </Modal>

      {/* Export Error Modal */}
      <Modal
        isOpen={exportErrorModalOpen}
        onClose={() => setExportErrorModalOpen(false)}
      >
        <div className="text-center space-y-4">
          <div className="flex items-center justify-center w-16 h-16 mx-auto bg-red-500/20 rounded-full">
            <svg className="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <div>
            <h3 className="text-xl font-semibold text-red-400 mb-2">Export Failed</h3>
            <p className="text-sm text-muted-foreground">{exportErrorMessage}</p>
          </div>
          <div className="flex justify-center pt-2">
            <Button
              variant="outline"
              onClick={() => setExportErrorModalOpen(false)}
              className="px-6"
            >
              Got it
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}

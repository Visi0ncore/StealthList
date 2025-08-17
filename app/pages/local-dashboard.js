import Layout from '../components/Layout';
import EnvironmentSection from '../components/EnvironmentSection';

export default function LocalDashboard() {
  return (
    <Layout
      title="Local Dashboard - StealthList"
      description="View and manage local waitlist signups for StealthList."
      currentPage="local-dashboard"
    >
      <EnvironmentSection
        environment="local"
        title="Local Environment"
        showAddUserButton={true}
        showNukeButton={true}
      />
    </Layout>
  );
}

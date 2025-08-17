import Layout from '../components/Layout';
import EnvironmentSection from '../components/EnvironmentSection';

export default function Dashboard() {
  return (
    <Layout
      title="Production Dashboard - StealthList"
      description="View and manage production waitlist signups for StealthList."
      currentPage="dashboard"
    >
      <EnvironmentSection
        environment="prod"
        title="Production Environment"
        showSetupButton={false}
        showAddUserButton={false}
        showNukeButton={false}
      />
    </Layout>
  );
}

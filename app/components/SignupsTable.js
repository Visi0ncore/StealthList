export default function SignupsTable({ signups }) {
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleString();
  };

  return (
    <div className="bg-card border border-border rounded-lg overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left p-4 font-medium">ID</th>
              <th className="text-left p-4 font-medium">Email</th>
              <th className="text-left p-4 font-medium">Signup Date</th>
            </tr>
          </thead>
          <tbody>
            {signups.map(signup => (
              <tr key={signup.id} className="border-t border-border hover:bg-muted/30 transition-colors">
                <td className="p-4 text-sm">{signup.id}</td>
                <td className="p-4 text-sm font-mono">{signup.email}</td>
                <td className="p-4 text-sm text-muted-foreground">{formatDate(signup.created_at)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

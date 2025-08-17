export default function StatsCard({ title, value, icon, color = "blue" }) {
  const colorClasses = {
    blue: "bg-blue-500/20 text-blue-500",
    green: "bg-green-500/20 text-green-500",
    purple: "bg-purple-500/20 text-purple-500",
    red: "bg-red-500/20 text-red-500",
    yellow: "bg-yellow-500/20 text-yellow-500"
  };

  return (
    <div className="bg-card border border-border rounded-lg p-6">
      <div className="flex items-center gap-3">
        <div className={`w-10 h-10 ${colorClasses[color]} rounded-lg flex items-center justify-center`}>
          {icon}
        </div>
        <div>
          <p className="text-sm text-muted-foreground">{title}</p>
          <p className="text-2xl font-bold">{value}</p>
        </div>
      </div>
    </div>
  );
}

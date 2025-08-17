export default function Button({
  children,
  variant = "outline",
  onClick,
  disabled = false,
  className = "",
  type = "button"
}) {
  const baseClasses = "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium h-9 px-3 transition-all duration-200";

  const variantClasses = {
    outline: "bg-transparent text-foreground border border-border hover:bg-muted hover:transform hover:-translate-y-0.5",
    primary: "bg-primary text-primary-foreground hover:bg-primary/90 hover:transform hover:-translate-y-0.5 hover:shadow-lg",
    destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90 hover:transform hover:-translate-y-0.5"
  };

  const disabledClasses = disabled ? "opacity-50 cursor-not-allowed transform-none" : "";

  return (
    <button
      type={type}
      className={`${baseClasses} ${variantClasses[variant]} ${disabledClasses} ${className}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}

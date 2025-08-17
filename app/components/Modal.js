import { useEffect } from 'react';

export default function Modal({ 
  isOpen, 
  onClose, 
  children, 
  title, 
  description 
}) {
  useEffect(() => {
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    if (isOpen) {
      document.addEventListener('keydown', handleEscape);
      document.body.style.overflow = 'hidden';
    }

    return () => {
      document.removeEventListener('keydown', handleEscape);
      document.body.style.overflow = 'unset';
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div 
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm transition-opacity"
      onClick={onClose}
    >
      <div 
        className="bg-card border border-border rounded-lg p-6 max-w-md w-full mx-4 transform transition-transform"
        onClick={(e) => e.stopPropagation()}
      >
        {title && (
          <div className="text-center mb-4">
            <h3 className="text-lg font-semibold">{title}</h3>
            {description && (
              <p className="text-sm text-muted-foreground mt-1">{description}</p>
            )}
          </div>
        )}
        {children}
      </div>
    </div>
  );
}

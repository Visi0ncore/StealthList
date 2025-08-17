import { useState, useEffect } from 'react';
import Head from 'next/head';

export default function Home() {
  const [email, setEmail] = useState('');
  const [statusMessage, setStatusMessage] = useState('');
  const [statusType, setStatusType] = useState('');
  const [joinedCount, setJoinedCount] = useState(0);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [lastSubmitTime, setLastSubmitTime] = useState(0);

  const SUBMIT_COOLDOWN = 5000; // 5 seconds between attempts

  // Load real stats from API
  const loadWaitlistStats = async () => {
    try {
      const response = await fetch('/api/waitlist/stats');
      const data = await response.json();
      if (!data.error) {
        const count = data.count || 0;
        setJoinedCount(count);
      }
    } catch (error) {
      console.error('Failed to load stats:', error);
    }
  };

  useEffect(() => {
    loadWaitlistStats();
  }, []);

  const showSuccess = (message) => {
    setStatusMessage(message);
    setStatusType('success');
  };

  const showError = (message) => {
    setStatusMessage(message);
    setStatusType('error');
  };

  const clearStatus = () => {
    setStatusMessage('');
    setStatusType('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Clear any previous status message
    clearStatus();
    
    // Check rate limiting (frontend protection)
    const now = Date.now();
    if (now - lastSubmitTime < SUBMIT_COOLDOWN) {
      const remainingTime = Math.ceil((SUBMIT_COOLDOWN - (now - lastSubmitTime)) / 1000);
      showError(`Please wait ${remainingTime} seconds before trying again.`);
      return;
    }
    
    // Enhanced email validation
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    
    if (!email) {
      showError('Please enter your email address.');
      return;
    }
    
    if (email.length > 254) {
      showError('Email address is too long.');
      return;
    }
    
    if (!emailRegex.test(email)) {
      showError('Please enter a valid email address.');
      return;
    }

    // Record attempt time
    setLastSubmitTime(now);
    setIsSubmitting(true);
    
    try {
      // Call real API
      const response = await fetch('/api/waitlist', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email })
      });

      const data = await response.json();

      if (data.success) {
        // Update counter with real count
        if (data.count) {
          setJoinedCount(data.count);
        }
        
        // Clear input and show success
        setEmail('');
        showSuccess(data.message);
      } else {
        // Show user-friendly error message
        showError(data.message || 'Something went wrong. Please try again.');
      }
    } catch (error) {
      console.error('Waitlist error:', error);
      showError('Network error. Please check your connection and try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleEmailChange = (e) => {
    setEmail(e.target.value);
    clearStatus();
  };

  return (
    <>
      <Head>
        <title>StealthList - Open Source Waitlist Platform</title>
        <meta name="description" content="Open-source waitlist management platform. Collect emails, track signups, and manage your waitlist with a clean, easy-to-use interface." />
        <link rel="icon" type="image/jpeg" href="/logo.jpeg" />
        
        {/* Open Graph / Facebook */}
        <meta property="og:type" content="website" />
        <meta property="og:url" content="https://stealthlist.vercel.app/" />
        <meta property="og:title" content="StealthList - Open Source Waitlist Platform" />
        <meta property="og:description" content="Open-source waitlist management platform. Collect emails, track signups, and manage your waitlist with a clean, easy-to-use interface." />
        <meta property="og:image" content="https://stealthlist.vercel.app/logo.jpeg" />
        <meta property="og:image:width" content="1200" />
        <meta property="og:image:height" content="630" />
        <meta property="og:image:alt" content="StealthList - Secure Waitlist Management" />
        
        {/* Twitter */}
        <meta property="twitter:card" content="summary_large_image" />
        <meta property="twitter:url" content="https://stealthlist.vercel.app/" />
        <meta property="twitter:title" content="StealthList - Open Source Waitlist Platform" />
        <meta property="twitter:description" content="Open-source waitlist management platform. Collect emails, track signups, and manage your waitlist with a clean, easy-to-use interface." />
        <meta property="twitter:image" content="https://stealthlist.vercel.app/logo.jpeg" />
        <meta property="twitter:image:alt" content="StealthList - Open Source Waitlist Platform" />
        <meta name="twitter:creator" content="@StealthList" />
        <meta name="twitter:site" content="@StealthList" />
      </Head>

      <div className="hero-gradient min-h-screen">
        {/* Header */}
        <header className="fixed top-0 left-0 right-0 z-50 bg-background/80 backdrop-blur-md border-b border-border">
          <div className="container mx-auto px-6 py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 cursor-pointer hover:opacity-80 transition-opacity" onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}>
                <span className="text-2xl">🥷</span>
                <h1 className="text-xl font-bold tracking-tight text-foreground">StealthList</h1>
              </div>
              <nav className="hidden md:flex items-center gap-6">
                <a href="/dashboard" className="text-muted-foreground hover:text-foreground transition-colors">Dashboard</a>
                <a href="https://x.com/StealthList" target="_blank" rel="noopener noreferrer" className="text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1">
                  <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                  </svg>
                </a>
                <a href="https://github.com/Visi0ncore/StealthList" target="_blank" rel="noopener noreferrer" className="text-muted-foreground hover:text-foreground transition-colors">
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                  </svg>
                </a>
              </nav>
            </div>
          </div>
        </header>

        {/* Hero Section */}
        <main className="container mx-auto px-6 py-12 pt-32">
          <div className="max-w-4xl mx-auto text-center space-y-8">
            <div className="fade-in">
              <h1 className="text-4xl md:text-6xl font-bold tracking-tight text-foreground mb-4">
                StealthList
              </h1>
              <p className="text-xl md:text-2xl text-muted-foreground max-w-2xl mx-auto leading-relaxed">
                Open-source waitlist management for your projects
              </p>
              <div className="flex flex-wrap justify-center gap-2 mt-6">
                <span className="px-3 py-1 bg-primary/10 text-primary text-sm font-medium rounded-full border border-primary/20">🌐 Open Source</span>
                <span className="px-3 py-1 bg-primary/10 text-primary text-sm font-medium rounded-full border border-primary/20">📊 Real-time Stats</span>
                <span className="px-3 py-1 bg-primary/10 text-primary text-sm font-medium rounded-full border border-primary/20">⚡ Easy Setup</span>
                <span className="px-3 py-1 bg-primary/10 text-primary text-sm font-medium rounded-full border border-primary/20">🎨 Clean UI</span>
              </div>
            </div>
            
            <div className="slide-up pt-8">
              <div className="max-w-md mx-auto space-y-4">
                <form onSubmit={handleSubmit} className="space-y-2">
                  <div className="flex gap-2">
                    <input 
                      type="email" 
                      value={email}
                      onChange={handleEmailChange}
                      placeholder="hello@0.email" 
                      className="flex-1 h-9 px-2 py-1 text-sm rounded-md bg-input border border-border text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:border-transparent"
                      disabled={isSubmitting}
                    />
                    <button 
                      type="submit"
                      disabled={isSubmitting}
                      className="btn-primary inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium h-9 px-3 shadow-lg disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isSubmitting ? 'Joining...' : 'Join Waitlist'}
                    </button>
                  </div>
                  {statusMessage && (
                    <div className={`text-sm min-h-[1rem] px-1 mt-6 ${statusType === 'success' ? 'text-green-400' : 'text-red-400'}`}>
                      {statusMessage}
                    </div>
                  )}
                </form>
                <div className="flex items-center justify-center gap-2 text-sm">
                  <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                  <span className="text-muted-foreground">
                    <span className="text-foreground font-medium">{joinedCount.toLocaleString()}</span> people have joined the waitlist
                  </span>
                </div>
              </div>
            </div>
          </div>
        </main>

        {/* Get Started Section */}
        <section id="get-started" className="container mx-auto px-6 py-8">
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-8 fade-in">
              <h2 className="text-3xl md:text-4xl font-bold tracking-tight text-foreground mb-4">
                Get Started in Minutes
              </h2>
              <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
                One command to get your waitlist running
              </p>
            </div>
            
            <div className="bg-card border border-border rounded-lg p-6 mb-8">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-3 h-3 bg-red-500 rounded-full"></div>
                <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
                <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                <span className="text-muted-foreground text-sm ml-2">Terminal</span>
              </div>
              <div className="bg-background border border-border rounded-lg p-4 font-mono text-sm">
                <div className="text-green-400">$ cd app</div>
                <div className="text-green-400">$ bun run setup</div>
                <div className="text-muted-foreground"># Installing dependencies...</div>
                <div className="text-muted-foreground"># Creating database...</div>
                <div className="text-muted-foreground"># Starting server...</div>
                <div className="text-green-400">✅ Ready! Visit http://localhost:3000</div>
              </div>
            </div>
          </div>
        </section>

        {/* Core Features Section */}
        <section id="features" className="container mx-auto px-6 py-8">
          <div className="max-w-6xl mx-auto">
            <div className="text-center mb-8 fade-in">
              <h2 className="text-3xl md:text-4xl font-bold tracking-tight text-foreground mb-4">
                Core Features
              </h2>
              <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
                Everything you need to collect emails and manage your waitlist
              </p>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="card-hover bg-card border border-border rounded-lg p-6 space-y-4">
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
                  <span className="text-2xl">🛡️</span>
                </div>
                <h3 className="text-xl font-semibold text-card-foreground">Spam Protection</h3>
                <p className="text-muted-foreground">
                  Rate limiting and email validation to prevent spam and ensure data quality.
                </p>
              </div>
              
              <div className="card-hover bg-card border border-border rounded-lg p-6 space-y-4">
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
                  <span className="text-2xl">📊</span>
                </div>
                <h3 className="text-xl font-semibold text-card-foreground">Real-time Stats</h3>
                <p className="text-muted-foreground">
                  Live signup counter and dashboard to track your waitlist growth.
                </p>
              </div>
              
              <div className="card-hover bg-card border border-border rounded-lg p-6 space-y-4">
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center">
                  <span className="text-2xl">⚡</span>
                </div>
                <h3 className="text-xl font-semibold text-card-foreground">Easy Setup</h3>
                <p className="text-muted-foreground">
                  One-command installation with automated database setup and configuration.
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Footer */}
        <footer className="container mx-auto px-6 py-12 border-t border-border">
          <div className="max-w-4xl mx-auto text-center">
            <p className="text-muted-foreground">
              © 2025 StealthList. All rights reserved.
            </p>
          </div>
        </footer>
      </div>
    </>
  );
}

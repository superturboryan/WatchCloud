import { useState } from 'react'
import './App.css'

function App() {
  const [openFaq, setOpenFaq] = useState<number | null>(null)
  const appStoreUrl = 'https://apps.apple.com/us/app/watchcloud/id6466678799'

  const toggleFaq = (index: number) => {
    setOpenFaq(openFaq === index ? null : index)
  }

  const scrollToSection = (id: string) => {
    const element = document.getElementById(id)
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' })
    }
  }

  const faqs = [
    {
      question: "Do I need to bring my iPhone with me?",
      answer: "Nope! After the initial setup with your iPhone, you can stream SoundCloud directly on your Apple Watch over Wi-Fi or cellular. Perfect for runs, gym sessions, or commutes when you want to leave your phone behind."
    },
    {
      question: "Do I need a SoundCloud subscription?",
      answer: "You'll need a SoundCloud account to use WatchCloud, but you don't need a SoundCloud subscription. WatchCloud itself is a one-time purchase with no recurring fees or in-app purchases."
    },
    {
      question: "Is WatchCloud an official SoundCloud app?",
      answer: "WatchCloud is an independent app built by a solo developer and is not affiliated with or endorsed by SoundCloud. It uses the official SoundCloud API in compliance with their API Terms of Use to bring SoundCloud streaming to your Apple Watch."
    },
    {
      question: "Which Apple Watches are supported?",
      answer: "WatchCloud supports modern watchOS versions and works best on cellular-enabled Apple Watch models. The app is optimized for recent watchOS releases but maintains compatibility with older versions."
    },
    {
      question: "Does WatchCloud show ads?",
      answer: "No ads, ever. WatchCloud is a one-time purchase with no ads, no subscriptions, and no in-app purchases. Pay once, enjoy forever."
    }
  ]

  const features = [
    {
      title: "Standalone SoundCloud Streaming",
      description: "Play your playlists, likes, and favourite tracks directly from your wrist, no phone needed."
    },
    {
      title: "Designed for Apple Watch",
      description: "Modern watchOS-style UI with a liquid glass feel, built specifically for smaller screens."
    },
    {
      title: "Full Playback Control",
      description: "Scrub with the Digital Crown, skip tracks, shuffle, repeat, adjust playback speed, and double-tap to like."
    },
    {
      title: "Perfect for Workouts",
      description: "Leave your phone in the locker and stream over Wi-Fi or cellular while you move."
    },
    {
      title: "Siri Shortcuts & Quick Actions",
      description: "Trigger playback and actions hands-free with Siri or Apple Watch double-tap gestures."
    },
    {
      title: "One-Time Purchase",
      description: "No ads, no subscriptions, no in-app purchases. Just pay once and stream forever."
    }
  ]

  const testimonials = [
    {
      quote: "Finally I can run without my phone bouncing in my pocket. This app is a game-changer.",
      author: "Runner from Portland"
    },
    {
      quote: "My commute just got infinitely better. SoundCloud on my wrist while my phone stays in my bag.",
      author: "App Store review"
    },
    {
      quote: "Perfect for the gym. I can focus on my workout without worrying about my phone.",
      author: "WatchCloud user in London"
    },
    {
      quote: "Love the clean interface and the fact that it just works. No fuss, no subscriptions.",
      author: "App Store review"
    }
  ]

  return (
    <>
      <header className="nav">
        <div className="nav-container">
          <div className="nav-logo">
            <img src="/navbar-icon.png" alt="WatchCloud" className="nav-logo-icon" />
            <span className="nav-logo-text">WatchCloud</span>
          </div>
          <nav className="nav-links">
            <button onClick={() => scrollToSection('features')} className="nav-link">
              Features
            </button>
            <button onClick={() => scrollToSection('faq')} className="nav-link">
              FAQ
            </button>
            <button onClick={() => scrollToSection('support')} className="nav-link">
              Support
            </button>
            <a
              href={appStoreUrl}
              className="button button-primary button-small"
              target="_blank"
              rel="noopener noreferrer"
            >
              Download
            </a>
          </nav>
        </div>
      </header>

      <main>
        {/* Hero Section */}
        <section className="hero">
          <div className="container">
            <div className="hero-content">
              <div className="hero-text">
                <p className="hero-label">WatchCloud</p>
                <h1 className="hero-title">
                  SoundCloud on Apple Watch — no phone needed
                </h1>
                <p className="hero-subtitle">
                  Stream your SoundCloud playlists, likes, and favourite tracks directly from your Apple Watch. No ads, no subscriptions, no iPhone required once you're set up.
                </p>
                <div className="hero-buttons">
                  <a
                    href={appStoreUrl}
                    className="button button-primary"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    Download on the App Store
                  </a>
                  <button
                    onClick={() => scrollToSection('features')}
                    className="button button-secondary"
                  >
                    How it works
                  </button>
                </div>
                <ul className="hero-benefits">
                  <li><span className="benefit-icon">⚡</span>Phone-free streaming</li>
                  <li><span className="benefit-icon">✓</span>One-time purchase</li>
                  <li><span className="benefit-icon">🏃</span>Great for workouts & commuting</li>
                </ul>
              </div>
              <div className="hero-visual">
                <div className="watch-mockup">
                  <img
                    src="/now-playing.png"
                    alt="WatchCloud app running on Apple Watch showing SoundCloud playback interface"
                    className="watch-screenshot"
                  />
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Features Section */}
        <section id="features" className="features">
          <div className="container">
            <h2 className="section-title">Why you'll love WatchCloud</h2>
            <p className="section-intro">
              Everything you need to enjoy SoundCloud on your Apple Watch, designed for life on the go.
            </p>
            <div className="features-grid">
              {features.map((feature, index) => (
                <div key={index} className="feature-card">
                  <h3 className="feature-title">{feature.title}</h3>
                  <p className="feature-description">{feature.description}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Testimonials Section */}
        <section className="testimonials">
          <div className="container">
            <h2 className="section-title">Loved by runners, commuters, and focus-workers</h2>
            <div className="testimonials-grid">
              {testimonials.map((testimonial, index) => (
                <div key={index} className="testimonial-card">
                  <p className="testimonial-quote">"{testimonial.quote}"</p>
                  <p className="testimonial-author">— {testimonial.author}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* FAQ Section */}
        <section id="faq" className="faq">
          <div className="container-narrow">
            <h2 className="section-title">Frequently Asked Questions</h2>
            <div className="faq-list">
              {faqs.map((faq, index) => (
                <div key={index} className="faq-item">
                  <button
                    className="faq-question"
                    onClick={() => toggleFaq(index)}
                    aria-expanded={openFaq === index}
                  >
                    <span>{faq.question}</span>
                    <span className={`faq-icon ${openFaq === index ? 'open' : ''}`}>
                      {openFaq === index ? '−' : '+'}
                    </span>
                  </button>
                  <div className={`faq-answer ${openFaq === index ? 'open' : ''}`}>
                    <p>{faq.answer}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Support & Final CTA Section */}
        <section id="support" className="support">
          <div className="container-narrow">
            <div className="final-cta">
              <h2 className="section-title">Ready to leave your iPhone behind?</h2>
              <p className="final-cta-text">
                Download WatchCloud and start streaming SoundCloud directly from your Apple Watch.
              </p>
              <a
                href={appStoreUrl}
                className="button button-primary"
                target="_blank"
                rel="noopener noreferrer"
              >
                Download on the App Store
              </a>
            </div>

            <div className="disclaimer">
              <p>
                WatchCloud is an independent app and is not affiliated with or endorsed by SoundCloud.
                SoundCloud is a registered trademark of its respective owners.
              </p>
            </div>
          </div>
        </section>
      </main>

      <footer className="footer">
        <div className="container">
          <div className="footer-content">
            <p className="footer-copyright">
              © {new Date().getFullYear()} WatchCloud
            </p>
            <p className="footer-tagline">
              Made with 🧡 by <a href="https://ryanforsyth.dev" target="_blank" rel="noopener noreferrer" className="link">SuperTurboRyan</a>
            </p>
            <div className="footer-links">
              <a
                href={appStoreUrl}
                className="footer-link"
                target="_blank"
                rel="noopener noreferrer"
              >
                Download
              </a>
              <a href="mailto:watchcloud.app@gmail.com" className="footer-link">
                Support
              </a>
              <a href="/privacy.html" className="footer-link">
                Privacy
              </a>
            </div>
          </div>
        </div>
      </footer>
    </>
  )
}

export default App

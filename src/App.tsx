import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [openFaq, setOpenFaq] = useState<number | null>(null)
  const [showStickyBar, setShowStickyBar] = useState(false)
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

  // Show sticky CTA bar when user scrolls past hero section
  useEffect(() => {
    let lastScrollY = 0
    let ticking = false

    const handleScroll = () => {
      lastScrollY = window.scrollY

      if (!ticking) {
        window.requestAnimationFrame(() => {
          // Simple threshold: show after scrolling down 600px
          setShowStickyBar(lastScrollY > 600)
          ticking = false
        })
        ticking = true
      }
    }

    window.addEventListener('scroll', handleScroll, { passive: true })
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

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
      answer: "WatchCloud works on any Apple Watch running watchOS 10 or later, and is fully optimized for watchOS 26 with a refreshed, modern UI."
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
      author: " App Store review"
    },
    {
      quote: "My commute just got infinitely better. SoundCloud on my wrist while my phone stays in my bag.",
      author: " App Store review"
    },
    {
      quote: "Perfect for the gym. I can focus on my workout without worrying about my phone.",
      author: " App Store review"
    },
    {
      quote: "Love the clean interface and the fact that it just works. No fuss, no subscriptions.",
      author: " App Store review"
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
                  Stream your SoundCloud playlists and likes straight from Apple Watch. No ads, no subscriptions. Just music.
                </p>
                <ul className="hero-benefits">
                  <li className="hero-benefit">
                    <svg className="hero-benefit-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z" clipRule="evenodd" />
                    </svg>
                    <span>Leave your iPhone at home</span>
                  </li>
                  <li className="hero-benefit">
                    <svg className="hero-benefit-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z" clipRule="evenodd" />
                    </svg>
                    <span>Stream playlists & likes</span>
                  </li>
                  <li className="hero-benefit">
                    <svg className="hero-benefit-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z" clipRule="evenodd" />
                    </svg>
                    <span>One-time purchase, no ads</span>
                  </li>
                </ul>
                <div className="hero-social-proof">
                  <div className="hero-rating">
                    <div className="hero-stars">
                      {[...Array(5)].map((_, i) => (
                        <svg key={i} className="hero-star" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                          <path fillRule="evenodd" d="M10.868 2.884c-.321-.772-1.415-.772-1.736 0l-1.83 4.401-4.753.381c-.833.067-1.171 1.107-.536 1.651l3.62 3.102-1.106 4.637c-.194.813.691 1.456 1.405 1.02L10 15.591l4.069 2.485c.713.436 1.598-.207 1.404-1.02l-1.106-4.637 3.62-3.102c.635-.544.297-1.584-.536-1.65l-4.752-.382-1.831-4.401z" clipRule="evenodd" />
                        </svg>
                      ))}
                    </div>
                    <span className="hero-rating-text">4.8/5 from 2,000+ users</span>
                  </div>
                </div>
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
                    Learn more
                  </button>
                </div>
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
                <div key={index} className="card feature-card">
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
                <div key={index} className="card testimonial-card">
                  <p className="testimonial-quote">"{testimonial.quote}"</p>
                  <p className="testimonial-author">{testimonial.author}</p>
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
              <div className="final-cta-content">
                <h2 className="section-title">Ready to leave your iPhone behind?</h2>
                <p className="final-cta-text">
                  Download WatchCloud and start streaming SoundCloud directly from your Apple Watch.
                </p>
                <a
                  href={appStoreUrl}
                  className="button button-primary final-cta-button"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Download on the App Store
                </a>
              </div>
              <div className="final-cta-image">
                <img
                  src="/player-options.png"
                  alt="WatchCloud player options on Apple Watch"
                  className="player-options-screenshot"
                />
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Sticky Bottom CTA Bar - Mobile Only */}
      <div className={`sticky-cta-bar ${showStickyBar ? 'visible' : ''}`}>
        <a
          href={appStoreUrl}
          className="button button-primary sticky-cta-button"
          target="_blank"
          rel="noopener noreferrer"
        >
          Download on the App Store
        </a>
      </div>

      <footer className="footer">
        <div className="container">
          <div className="footer-content">
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
              <a href="/privacy" className="footer-link">
                Privacy
              </a>
            </div>
            <p className="footer-disclaimer">
              WatchCloud is an independent app and is not affiliated with or endorsed by SoundCloud. SoundCloud is a registered trademark of its respective owners.
            </p>
            <p className="footer-copyright">
              © {new Date().getFullYear()} WatchCloud
            </p>
            <p className="footer-tagline">
              Made with 🧡 by <a href="https://ryanforsyth.dev" target="_blank" rel="noopener noreferrer" className="link">Ryan</a>
            </p>
          </div>
        </div>
      </footer>
    </>
  )
}

export default App

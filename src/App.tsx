import { useEffect, useState } from 'react'
import './App.css'
import { AppStoreLink, Footer, Header } from './SiteChrome'

const faqs = [
  {
    question: 'Can I stream without my iPhone nearby?',
    answer: 'Yes. After signing in with the iPhone companion app, WatchCloud streams directly from your Apple Watch over Wi-Fi or cellular. Your iPhone does not need to stay nearby during playback.',
  },
  {
    question: 'Do I need a paid SoundCloud subscription?',
    answer: 'No. You need a SoundCloud account, but WatchCloud does not require a paid SoundCloud subscription. WatchCloud is a $3.99 one-time purchase with no recurring fee.',
  },
  {
    question: 'What do I need to listen?',
    answer: 'You need an Apple Watch running watchOS 10 or later, an internet connection through Wi-Fi or cellular, a SoundCloud account, and a compatible audio output such as Bluetooth headphones.',
  },
  {
    question: 'Is WatchCloud the official SoundCloud app?',
    answer: 'No. WatchCloud is an independent app created by a solo developer. It uses the official SoundCloud API and is not affiliated with or endorsed by SoundCloud.',
  },
  {
    question: 'Where can I get help?',
    answer: 'The WatchCloud support page covers installation, sign-in, connectivity, playlists, and playback. You can also contact the developer directly if the guides do not solve the problem.',
  },
]

const features = [
  {
    title: 'Crown-first playback',
    description: 'Scrub through long mixes, skip tracks, shuffle, repeat, and adjust playback speed from your wrist.',
  },
  {
    title: 'Your SoundCloud library',
    description: 'Open your likes and playlists, search for music, and discover tracks without reaching for your phone.',
  },
  {
    title: 'Quick actions',
    description: 'Use Siri Shortcuts and Apple Watch double-tap gestures for fast, hands-free control.',
  },
  {
    title: 'Made for movement',
    description: 'Stream over Wi-Fi or cellular while running, training, commuting, or working phone-free.',
  },
]

function WatchImage({
  name,
  alt,
  className,
  loading = 'lazy',
}: {
  name: 'now-playing' | 'library' | 'player-options'
  alt: string
  className: string
  loading?: 'eager' | 'lazy'
}) {
  return (
    <picture>
      <source
        type="image/webp"
        srcSet={`/${name}-420.webp 420w, /${name}-845.webp 845w`}
        sizes="(max-width: 767px) 300px, 360px"
      />
      <img
        src={`/${name}.png`}
        alt={alt}
        className={className}
        width="845"
        height="1448"
        loading={loading}
        decoding="async"
        fetchPriority={loading === 'eager' ? 'high' : 'auto'}
      />
    </picture>
  )
}

function App() {
  const [openFaq, setOpenFaq] = useState<number | null>(null)
  const [showStickyBar, setShowStickyBar] = useState(false)

  useEffect(() => {
    const targetId = window.location.hash.slice(1)
    if (!targetId) return

    const frame = window.requestAnimationFrame(() => {
      document.getElementById(targetId)?.scrollIntoView()
    })

    return () => window.cancelAnimationFrame(frame)
  }, [])

  useEffect(() => {
    const hero = document.querySelector('.hero')
    if (!hero) return

    const observer = new IntersectionObserver(
      ([entry]) => setShowStickyBar(!entry.isIntersecting),
      { threshold: 0.05 },
    )

    observer.observe(hero)
    return () => observer.disconnect()
  }, [])

  return (
    <>
      <Header />

      <main id="main-content">
        <section className="hero">
          <div className="container hero-container">
            <div className="hero-content">
              <div className="hero-text">
                <p className="eyebrow">SoundCloud on Apple Watch</p>
                <h1 className="hero-title">Leave your iPhone behind. Keep your SoundCloud.</h1>
                <p className="hero-subtitle">
                  Stream likes, playlists, and tracks directly from Apple Watch over Wi-Fi or cellular.
                  No SoundCloud subscription required.
                </p>
                <div className="hero-buttons">
                  <AppStoreLink placement="hero" className="button button-primary button-large">
                    Download for $3.99
                  </AppStoreLink>
                  <a href="#how-it-works" className="button button-secondary">See how it works</a>
                </div>
                <ul className="proof-list" aria-label="WatchCloud requirements and pricing">
                  <li>One-time purchase</li>
                  <li>watchOS 10+</li>
                  <li>Wi-Fi or cellular</li>
                  <li>No ads</li>
                </ul>
              </div>
              <div className="hero-visual" aria-label="WatchCloud player preview">
                <div className="watch-mockup">
                  <WatchImage
                    name="now-playing"
                    alt="WatchCloud playing a SoundCloud track on Apple Watch"
                    className="watch-screenshot"
                    loading="eager"
                  />
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="how-it-works" className="section how-it-works">
          <div className="container">
            <div className="section-heading">
              <p className="eyebrow">Quick start</p>
              <h2>From download to phone-free listening</h2>
              <p>Sign in once, then take your music with you.</p>
            </div>
            <ol className="steps-grid">
              <li className="step-card"><span>1</span><h3>Install WatchCloud</h3><p>Buy the app on your iPhone and install its Apple Watch app.</p></li>
              <li className="step-card"><span>2</span><h3>Connect SoundCloud</h3><p>Open the iPhone companion and sign in securely through SoundCloud.</p></li>
              <li className="step-card"><span>3</span><h3>Listen from your wrist</h3><p>Connect headphones, choose Wi-Fi or cellular, and leave your phone behind.</p></li>
            </ol>
            <p className="section-link"><a href="/how-to-listen-to-soundcloud-on-apple-watch">Read the complete setup guide →</a></p>
          </div>
        </section>

        <section className="section showcase">
          <div className="container">
            <div className="section-heading">
              <p className="eyebrow">See it in action</p>
              <h2>Your SoundCloud library, designed for a smaller screen</h2>
              <p>Browse, play, and control music without squeezing an iPhone interface onto your watch.</p>
            </div>
            <div className="showcase-grid">
              <article className="showcase-card">
                <div className="showcase-image"><WatchImage name="library" alt="WatchCloud SoundCloud library on Apple Watch" className="showcase-screenshot" /></div>
                <div><p className="showcase-kicker">Find your music</p><h3>Likes, playlists, and search</h3><p>Open the music you already love and discover what to play next.</p></div>
              </article>
              <article className="showcase-card showcase-card-reverse">
                <div className="showcase-image"><WatchImage name="player-options" alt="WatchCloud playback controls on Apple Watch" className="showcase-screenshot" /></div>
                <div><p className="showcase-kicker">Stay in control</p><h3>Built around the Digital Crown</h3><p>Scrub precisely, change speed, repeat, shuffle, and like tracks from the player.</p></div>
              </article>
            </div>
          </div>
        </section>

        <section id="features" className="section features">
          <div className="container">
            <div className="section-heading">
              <p className="eyebrow">Watch-native features</p>
              <h2>More than a remote control</h2>
              <p>WatchCloud is built for direct playback on Apple Watch, not just controlling an iPhone.</p>
            </div>
            <div className="features-grid">
              {features.map((feature) => (
                <article key={feature.title} className="feature-card">
                  <h3>{feature.title}</h3>
                  <p>{feature.description}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="section comparison">
          <div className="container">
            <div className="comparison-layout">
              <div className="comparison-copy">
                <p className="eyebrow">Why WatchCloud</p>
                <h2>SoundCloud that works when your iPhone stays home</h2>
                <p>
                  The official SoundCloud watch experience controls playback on a connected iPhone.
                  WatchCloud streams directly from the watch instead.
                </p>
                <a href="https://help.soundcloud.com/hc/en-us/articles/28529652794523-Apple-Watch" target="_blank" rel="noopener noreferrer" className="text-link">
                  Read SoundCloud’s Apple Watch requirements →
                </a>
              </div>
              <div className="comparison-table-wrap">
                <table>
                  <caption className="sr-only">WatchCloud compared with the official SoundCloud Apple Watch app</caption>
                  <thead><tr><th>Capability</th><th>WatchCloud</th><th>Official app</th></tr></thead>
                  <tbody>
                    <tr><th>Direct watch streaming</th><td className="yes">Yes</td><td>No</td></tr>
                    <tr><th>Works away from iPhone</th><td className="yes">Yes</td><td>No</td></tr>
                    <tr><th>Paid SoundCloud plan</th><td>Not required</td><td>Required</td></tr>
                    <tr><th>Payment</th><td>$3.99 once</td><td>Subscription</td></tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </section>

        <section id="faq" className="section faq">
          <div className="container-narrow">
            <div className="section-heading">
              <p className="eyebrow">Before you download</p>
              <h2>Frequently asked questions</h2>
            </div>
            <div className="faq-list">
              {faqs.map((faq, index) => {
                const panelId = `faq-panel-${index}`
                const buttonId = `faq-button-${index}`
                const isOpen = openFaq === index
                return (
                  <div key={faq.question} className="faq-item">
                    <h3>
                      <button
                        id={buttonId}
                        className="faq-question"
                        onClick={() => setOpenFaq(isOpen ? null : index)}
                        aria-expanded={isOpen}
                        aria-controls={panelId}
                      >
                        <span>{faq.question}</span><span className="faq-icon" aria-hidden="true">{isOpen ? '−' : '+'}</span>
                      </button>
                    </h3>
                    <div id={panelId} role="region" aria-labelledby={buttonId} className="faq-answer" hidden={!isOpen}>
                      <p>{faq.answer}</p>
                    </div>
                  </div>
                )
              })}
            </div>
            <p className="section-link"><a href="/support">Visit WatchCloud Support →</a></p>
          </div>
        </section>

        <section className="section final-cta-section">
          <div className="container-narrow final-cta">
            <p className="eyebrow">Ready when you are</p>
            <h2>Take SoundCloud out for a run.</h2>
            <p>Get WatchCloud for $3.99. No subscription, ads, or in-app purchases.</p>
            <AppStoreLink placement="final" className="button button-primary button-large">Download on the App Store</AppStoreLink>
          </div>
        </section>
      </main>

      {showStickyBar && (
        <div className="sticky-cta-bar" role="region" aria-label="Download WatchCloud">
          <AppStoreLink placement="sticky" className="button button-primary sticky-cta-button">Download for $3.99</AppStoreLink>
        </div>
      )}

      <Footer />
    </>
  )
}

export default App

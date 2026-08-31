import './App.css'
import './ContentPage.css'
import { AppStoreLink, Footer, Header } from './SiteChrome'

function Guide() {
  return (
    <>
      <Header />
      <main id="main-content">
        <header className="content-hero">
          <div className="container content-hero-inner">
            <nav className="breadcrumbs" aria-label="Breadcrumb"><a href="/">Home</a><span>/</span><span>Setup guide</span></nav>
            <p className="eyebrow">Step-by-step guide</p>
            <h1>How to listen to SoundCloud on Apple Watch without your iPhone</h1>
            <p className="content-hero-intro">Install WatchCloud, connect your SoundCloud account, and stream directly over Wi-Fi or cellular.</p>
          </div>
        </header>

        <div className="container content-layout">
          <article className="content-main">
            <div className="answer-box">
              <strong>Can Apple Watch play SoundCloud without an iPhone nearby?</strong>
              <p>Yes. WatchCloud streams SoundCloud directly from Apple Watch after the initial account setup on iPhone. The watch needs Wi-Fi or cellular and a compatible audio output, but the iPhone can stay at home.</p>
            </div>

            <section id="requirements">
              <h2>What you need</h2>
              <div className="requirements-grid">
                <div className="requirement-card"><strong>Apple Watch</strong><p>Running watchOS 10 or later</p></div>
                <div className="requirement-card"><strong>WatchCloud</strong><p>$3.99 one-time App Store purchase</p></div>
                <div className="requirement-card"><strong>SoundCloud account</strong><p>No paid SoundCloud subscription required</p></div>
                <div className="requirement-card"><strong>Connection and audio</strong><p>Wi-Fi or cellular plus Bluetooth headphones</p></div>
              </div>
            </section>

            <section id="steps">
              <h2>Set up SoundCloud on Apple Watch</h2>
              <ol className="numbered-steps">
                <li><strong>Download WatchCloud.</strong> Buy WatchCloud from the App Store on your paired iPhone.</li>
                <li><strong>Install the watch app.</strong> Open the Watch app on iPhone, find WatchCloud under Available Apps, and install it. You can also install it from the App Store on Apple Watch.</li>
                <li><strong>Sign in to SoundCloud.</strong> Open WatchCloud on iPhone and use the SoundCloud sign-in page. Complete any CAPTCHA or account-provider step there.</li>
                <li><strong>Connect your headphones.</strong> Pair Bluetooth headphones with Apple Watch from Settings → Bluetooth.</li>
                <li><strong>Confirm your connection.</strong> Use a known Wi-Fi network or verify that the cellular watch has an active data plan.</li>
                <li><strong>Start listening.</strong> Open WatchCloud on Apple Watch, choose your likes or playlists, and play a track.</li>
              </ol>
            </section>

            <section id="wifi-cellular">
              <h2>Wi-Fi versus cellular</h2>
              <h3>Using Wi-Fi</h3>
              <p>Your iPhone can be turned off or left behind as long as Apple Watch connects to a compatible Wi-Fi network it knows.</p>
              <h3>Using cellular</h3>
              <p>A cellular-capable Apple Watch needs an active carrier plan and adequate signal. Streaming audio uses data and may affect watch battery life more quickly than offline playback.</p>
            </section>

            <section id="official-app">
              <h2>Why not use the official SoundCloud watch app?</h2>
              <p>The official SoundCloud Apple Watch app currently requires a SoundCloud subscription and controls SoundCloud on a connected iPhone. It does not stream directly from Apple Watch. WatchCloud is designed specifically for direct Wi-Fi or cellular playback.</p>
              <p><a className="text-link" href="https://help.soundcloud.com/hc/en-us/articles/28529652794523-Apple-Watch" target="_blank" rel="noopener noreferrer">View SoundCloud’s current Apple Watch requirements →</a></p>
            </section>

            <section id="troubleshooting">
              <h2>If it does not work</h2>
              <ul>
                <li>Install the newest WatchCloud version on both devices.</li>
                <li>Open the iPhone companion again and confirm that you are signed in.</li>
                <li>Test the watch’s Wi-Fi or cellular connection.</li>
                <li>Restart WatchCloud or Apple Watch before trying again.</li>
              </ul>
              <p>For sign-in, playback, and connection fixes, visit <a className="text-link" href="/support">WatchCloud Support</a>.</p>
            </section>
          </article>

          <aside className="content-sidebar" aria-label="On this page">
            <nav className="contents-card">
              <strong>On this page</strong>
              <a href="#requirements">Requirements</a>
              <a href="#steps">Setup steps</a>
              <a href="#wifi-cellular">Wi-Fi or cellular</a>
              <a href="#official-app">Official app comparison</a>
              <a href="#troubleshooting">Troubleshooting</a>
            </nav>
          </aside>
        </div>

        <section className="content-cta">
          <div className="container-narrow">
            <h2>Take SoundCloud with you.</h2>
            <p>Pay once, connect your headphones, and leave your iPhone behind.</p>
            <AppStoreLink placement="content" className="button button-primary button-large">Download WatchCloud for $3.99</AppStoreLink>
          </div>
        </section>
      </main>
      <Footer />
    </>
  )
}

export default Guide

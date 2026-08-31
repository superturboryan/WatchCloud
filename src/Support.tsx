import './App.css'
import './ContentPage.css'
import { AppStoreLink, Footer, Header } from './SiteChrome'

function Support() {
  return (
    <>
      <Header />
      <main id="main-content">
        <header className="content-hero">
          <div className="container content-hero-inner">
            <nav className="breadcrumbs" aria-label="Breadcrumb"><a href="/">Home</a><span>/</span><span>Support</span></nav>
            <p className="eyebrow">WatchCloud Support</p>
            <h1>Get back to your music.</h1>
            <p className="content-hero-intro">Setup help and straightforward fixes for sign-in, connectivity, playlists, and playback on Apple Watch.</p>
          </div>
        </header>

        <div className="container content-layout">
          <article className="content-main">
            <div className="answer-box">
              <strong>New to WatchCloud?</strong>
              <p>Start with the <a className="text-link" href="/how-to-listen-to-soundcloud-on-apple-watch">complete installation and listening guide</a>. It covers requirements, sign-in, headphones, Wi-Fi, and cellular playback.</p>
            </div>

            <section id="quick-start">
              <h2>Quick start checklist</h2>
              <ol className="numbered-steps">
                <li><strong>Update WatchCloud.</strong> Install the latest version from the App Store on your iPhone and Apple Watch.</li>
                <li><strong>Sign in on iPhone.</strong> Open the companion app and complete SoundCloud authentication there.</li>
                <li><strong>Check the watch connection.</strong> Use Wi-Fi or an active cellular plan when your iPhone is not nearby.</li>
                <li><strong>Connect your audio.</strong> Pair Bluetooth headphones or another supported audio output with Apple Watch.</li>
                <li><strong>Open WatchCloud on the watch.</strong> Choose a like, playlist, or search result and start playback.</li>
              </ol>
            </section>

            <section id="sign-in">
              <h2>Sign-in help</h2>
              <h3>The watch says no account was found</h3>
              <p>Open WatchCloud on your paired iPhone and sign in to SoundCloud there first. Keep both devices connected while the account is passed to the watch, then reopen WatchCloud on Apple Watch.</p>
              <h3>SoundCloud asks for a CAPTCHA</h3>
              <p>Complete the CAPTCHA in the sign-in page on your iPhone. If it does not appear correctly, close the sign-in page, confirm that iOS and WatchCloud are up to date, and try again.</p>
              <h3>Your account uses Apple, Google, or Facebook</h3>
              <p>Choose the same provider you normally use for SoundCloud. WatchCloud never receives your SoundCloud password; authentication happens on SoundCloud’s website.</p>
            </section>

            <section id="connection">
              <h2>Wi-Fi and cellular problems</h2>
              <ul>
                <li>Confirm the watch can load another internet-based app.</li>
                <li>When using cellular, verify that Apple Watch has an active data plan and a usable signal.</li>
                <li>Temporarily turn Wi-Fi or cellular off and on from Apple Watch Control Center.</li>
                <li>Force-close WatchCloud, reopen it, and retry the track.</li>
                <li>Restart Apple Watch if the network connection remains stuck.</li>
              </ul>
            </section>

            <section id="playback">
              <h2>Playback or playlists are not loading</h2>
              <p>First install the newest WatchCloud version. SoundCloud API changes can require an app update before streaming works correctly again.</p>
              <ul>
                <li>Refresh the library by closing and reopening WatchCloud.</li>
                <li>Check whether the same track remains available in SoundCloud.</li>
                <li>Try a different playlist or liked track to isolate the problem.</li>
                <li>Confirm that headphones are connected to Apple Watch rather than only to iPhone.</li>
              </ul>
            </section>

            <section id="requirements">
              <h2>Compatibility and requirements</h2>
              <div className="requirements-grid">
                <div className="requirement-card"><strong>Apple Watch</strong><p>watchOS 10 or later</p></div>
                <div className="requirement-card"><strong>SoundCloud</strong><p>A free or paid account</p></div>
                <div className="requirement-card"><strong>Internet</strong><p>Wi-Fi or cellular for direct streaming</p></div>
                <div className="requirement-card"><strong>Audio</strong><p>Bluetooth headphones or supported output</p></div>
              </div>
            </section>

            <section id="contact" className="contact-card">
              <h2>Still need help?</h2>
              <p>Include your Apple Watch model, watchOS version, WatchCloud version, connection type, and the steps that led to the problem.</p>
              <a className="button button-secondary" href="mailto:watchcloud.app@gmail.com?subject=WatchCloud%20Support">Email WatchCloud Support</a>
            </section>
          </article>

          <aside className="content-sidebar" aria-label="On this page">
            <nav className="contents-card">
              <strong>On this page</strong>
              <a href="#quick-start">Quick start</a>
              <a href="#sign-in">Sign-in help</a>
              <a href="#connection">Wi-Fi and cellular</a>
              <a href="#playback">Playback and playlists</a>
              <a href="#requirements">Requirements</a>
              <a href="#contact">Contact</a>
            </nav>
          </aside>
        </div>

        <section className="content-cta">
          <div className="container-narrow">
            <h2>Ready to listen from your wrist?</h2>
            <p>WatchCloud is a $3.99 one-time purchase with no subscription or ads.</p>
            <AppStoreLink placement="content" className="button button-primary button-large">Download on the App Store</AppStoreLink>
          </div>
        </section>
      </main>
      <Footer />
    </>
  )
}

export default Support

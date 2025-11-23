import './App.css'
import './Privacy.css'

function Privacy() {
  return (
    <>
      <header className="nav">
        <div className="nav-container">
          <a href="/" className="nav-logo">
            <img src="/navbar-icon.png" alt="WatchCloud" className="nav-logo-icon" />
            <span className="nav-logo-text">WatchCloud</span>
          </a>
          <nav className="nav-links">
            <a href="/" className="nav-link">
              Home
            </a>
            <a
              href="https://apps.apple.com/us/app/watchcloud/id6466678799"
              className="button button-primary button-small"
              target="_blank"
              rel="noopener noreferrer"
            >
              Download
            </a>
          </nav>
        </div>
      </header>

      <main className="privacy-page">
        <div className="container-narrow">
          <article className="privacy-content">
            <h1>Privacy Policy</h1>

            <section>
              <h2>Information Collected</h2>
              <p>
                WatchCloud does not collect any personal information from you such as your name, email, or date of birth.
              </p>
              <p>
                WatchCloud collects app diagnostic data for the sole purpose of improving the app experience and guiding feature development.
              </p>
            </section>

            <section>
              <h2>Third‑Party Services (SoundCloud)</h2>
              <p>
                WatchCloud uses the official SoundCloud API to enable search and playback of SoundCloud content you choose to access. Authentication is performed on SoundCloud's website using OAuth; WatchCloud receives an access token to perform requests on your behalf.
              </p>
              <ul>
                <li>Your SoundCloud credentials are stored securely on your device and are not transmitted to any developer‑controlled server.</li>
                <li>You can revoke WatchCloud's access at any time in your SoundCloud account settings.</li>
                <li>Any personal data processed by SoundCloud is governed by SoundCloud's own terms and privacy policy.</li>
              </ul>
            </section>

            <section>
              <h2>Affiliation Disclaimer</h2>
              <p>
                WatchCloud is an independent app that uses the official SoundCloud API and is not affiliated with or endorsed by SoundCloud.
              </p>
            </section>

            <section>
              <h2>Notification of Privacy Statement Changes</h2>
              <p>
                We may update this privacy statement to reflect changes to our information practices. If we make any material changes we will notify you by means of a notice in the app or an app update prior to the change becoming effective.
              </p>
              <p>
                We encourage you to periodically review this page for the latest information on our privacy practices.
              </p>
            </section>

            <div className="privacy-footer">
              <a href="/" className="button button-secondary">
                Back to Home
              </a>
            </div>
          </article>
        </div>
      </main>

      <footer className="footer">
        <div className="container">
          <div className="footer-content">
            <div className="footer-links">
              <a
                href="https://apps.apple.com/us/app/watchcloud/id6466678799"
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

export default Privacy

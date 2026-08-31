import './App.css'
import './Privacy.css'
import { Footer, Header } from './SiteChrome'

function Privacy() {
  return (
    <>
      <Header />
      <main id="main-content" className="privacy-page">
        <div className="container-narrow">
          <article className="privacy-content">
            <h1>Privacy Policy</h1>

            <section>
              <h2>Information Collected</h2>
              <p>WatchCloud does not collect personal information such as your name, email address, or date of birth.</p>
              <p>WatchCloud collects app diagnostic data for the sole purpose of improving the app experience and guiding feature development.</p>
            </section>

            <section>
              <h2>Third-Party Services (SoundCloud)</h2>
              <p>WatchCloud uses the official SoundCloud API to enable search and playback of content you choose to access. Authentication is performed on SoundCloud&apos;s website using OAuth; WatchCloud receives an access token to perform requests on your behalf.</p>
              <ul>
                <li>Your SoundCloud credentials are stored securely on your device and are not transmitted to a developer-controlled server.</li>
                <li>You can revoke WatchCloud&apos;s access at any time in your SoundCloud account settings.</li>
                <li>Personal data processed by SoundCloud is governed by SoundCloud&apos;s own terms and privacy policy.</li>
              </ul>
            </section>

            <section>
              <h2>Affiliation Disclaimer</h2>
              <p>WatchCloud is an independent app that uses the official SoundCloud API and is not affiliated with or endorsed by SoundCloud.</p>
            </section>

            <section>
              <h2>Privacy Statement Changes</h2>
              <p>We may update this statement to reflect changes to our information practices. Material changes will be communicated in the app or through an app update before they take effect.</p>
            </section>

            <div className="privacy-footer"><a href="/" className="button button-secondary">Back to Home</a></div>
          </article>
        </div>
      </main>
      <Footer />
    </>
  )
}

export default Privacy

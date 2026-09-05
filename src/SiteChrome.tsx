import type { ReactNode } from 'react'

export const APP_STORE_URL = 'https://apps.apple.com/app/id6466678799'

type AppStorePlacement = 'header' | 'hero' | 'showcase' | 'sticky' | 'final' | 'footer' | 'content'

type AppStoreLinkProps = {
  placement: AppStorePlacement
  className?: string
  children: ReactNode
}

declare global {
  interface Window {
    dataLayer?: Array<Record<string, unknown>>
    plausible?: (event: string, options?: { props?: Record<string, string> }) => void
  }
}

function trackAppStoreClick(placement: AppStorePlacement) {
  const detail = {
    placement,
    page_path: window.location.pathname,
    device_class: window.matchMedia('(max-width: 767px)').matches ? 'mobile' : 'desktop',
    locale: document.documentElement.lang || 'en',
  }

  window.dataLayer?.push({ event: 'app_store_click', ...detail })
  window.plausible?.('App Store Click', { props: detail })
  window.dispatchEvent(new CustomEvent('watchcloud:app-store-click', { detail }))
}

export function AppStoreLink({ placement, className = '', children }: AppStoreLinkProps) {
  return (
    <a
      href={APP_STORE_URL}
      className={className}
      target="_blank"
      rel="noopener noreferrer"
      data-cta-placement={placement}
      onClick={() => trackAppStoreClick(placement)}
    >
      {children}
    </a>
  )
}

export function Header() {
  return (
    <>
      <a href="#main-content" className="skip-link">Skip to content</a>
      <header className="nav">
        <div className="nav-container">
        <a href="/" className="nav-logo" aria-label="WatchCloud home">
          <img src="/navbar-icon.png" alt="" className="nav-logo-icon" width="48" height="48" />
          <span className="nav-logo-text">WatchCloud</span>
        </a>
        <nav className="nav-links" aria-label="Primary navigation">
          <a href="/#how-it-works" className="nav-link nav-secondary-link">How it works</a>
          <a href="/#features" className="nav-link nav-secondary-link">Features</a>
          <a href="/support" className="nav-link nav-secondary-link">Support</a>
          <AppStoreLink placement="header" className="button button-small header-cta">
            Get the app
          </AppStoreLink>
        </nav>
        </div>
      </header>
    </>
  )
}

export function Footer() {
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-content">
          <div className="footer-links">
            <AppStoreLink placement="footer" className="footer-link">Download</AppStoreLink>
            <a href="/support" className="footer-link">Support</a>
            <a href="/how-to-listen-to-soundcloud-on-apple-watch" className="footer-link">Setup guide</a>
            <a href="/privacy" className="footer-link">Privacy</a>
          </div>
          <p className="footer-disclaimer">
            <span>WatchCloud is an independent app and is not affiliated with or endorsed by SoundCloud.</span>
            <span>SoundCloud is a registered trademark of its respective owners.</span>
          </p>
          <p className="footer-copyright">© {new Date().getFullYear()} WatchCloud</p>
          <p className="footer-tagline">
            Made with 🧡 by <a href="https://ryanforsyth.dev" target="_blank" rel="noopener noreferrer" className="link">Ryan</a>
          </p>
        </div>
      </div>
    </footer>
  )
}

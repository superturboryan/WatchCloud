// Adapted from React Bits SpotlightCard by David Haz.
// https://reactbits.dev/components/spotlight-card — see THIRD_PARTY_NOTICES.md.
import type { PointerEvent, PropsWithChildren } from 'react'
import './SpotlightCard.css'

export default function SpotlightCard({ children, className = '' }: PropsWithChildren<{ className?: string }>) {
  function updateSpotlight(event: PointerEvent<HTMLElement>) {
    if (event.pointerType === 'touch' || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return

    const card = event.currentTarget
    const rect = card.getBoundingClientRect()
    card.style.setProperty('--mouse-x', `${event.clientX - rect.left}px`)
    card.style.setProperty('--mouse-y', `${event.clientY - rect.top}px`)
  }

  return (
    <article className={`card-spotlight ${className}`} onPointerMove={updateSpotlight}>
      {children}
    </article>
  )
}

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import Guide from './Guide'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Guide />
  </StrictMode>,
)

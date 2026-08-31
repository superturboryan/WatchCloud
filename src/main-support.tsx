import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import Support from './Support'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Support />
  </StrictMode>,
)

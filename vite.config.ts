import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        privacy: resolve(__dirname, 'privacy.html'),
        support: resolve(__dirname, 'support.html'),
        guide: resolve(__dirname, 'how-to-listen-to-soundcloud-on-apple-watch.html'),
      },
    },
  },
})

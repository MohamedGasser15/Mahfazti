import path from 'path'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': path.resolve(import.meta.dirname, './src'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'https://mahfazati.runasp.net',
        changeOrigin: true,
        secure: false,
      },
    },
  },
  build: {
    // Target modern JavaScript runtime for optimal execution and smaller bundle size
    target: 'es2022',
    // Split CSS per chunk so pages only load the CSS they need
    cssCodeSplit: true,
    // Prevent sensitive internal source code and structure from being exposed via source maps
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules')) {
            if (id.includes('framer-motion')) return 'vendor-motion';
            if (id.includes('@tanstack') || id.includes('axios')) return 'vendor-query';
            if (id.includes('recharts') || id.includes('d3')) return 'vendor-charts';
            if (id.includes('react-router-dom') || id.includes('react-dom') || id.includes('react')) {
              return 'vendor-react';
            }
          }
        },
      },
    },
  },
})


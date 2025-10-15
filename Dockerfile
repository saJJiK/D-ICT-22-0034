# ---- Build stage ----
FROM node:18-alpine AS builder
WORKDIR /app
# If you have a lockfile, copy it first for better caching
COPY package*.json ./
RUN npm ci --no-audit --no-fund
COPY . .
# Build production assets (uses Vite or CRA scripts depending on your project)
# For Vite: npm run build
# For CRA:  npm run build
RUN npm run build

# ---- Runtime stage ----
FROM nginx:alpine
# Copy build to Nginx html directory (adjust if your build directory differs)
COPY --from=builder /app/dist /usr/share/nginx/html
# If using CRA the build folder is /app/build instead of /app/dist
# COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
# Minimal healthcheck (optional)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost/ || exit 1

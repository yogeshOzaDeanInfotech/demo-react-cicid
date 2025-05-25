# ──────────────── Stage 1: build ────────────────
FROM node:23-alpine AS builder
WORKDIR /app

# 1) Install deps
COPY package.json package-lock.json ./
RUN npm ci

# 2) Copy & build
COPY . .
RUN npm run build

# ──────────────── Stage 2: serve ────────────────
FROM nginx:stable-alpine
# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# 3) Add our Nginx config
COPY nginx.conf /etc/nginx/conf.d/

# 4) Copy built app
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

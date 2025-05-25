# ──────────────── Stage 1: build ────────────────
FROM node:23-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build   # Vite outputs to /app/dist

# ──────────────── Stage 2: serve ────────────────
FROM nginx:stable-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/

# 👇 Copy from /app/dist (not /app/build)
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

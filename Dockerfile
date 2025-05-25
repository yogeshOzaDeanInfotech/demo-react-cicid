# ──────────────── Stage 1: build ────────────────
FROM node:23-alpine AS builder

# set working directory
WORKDIR /app

# install dependencies
COPY package.json package-lock.json ./
RUN npm install --frozen-lockfile

# copy source & build
COPY . .
RUN npm build

# ──────────────── Stage 2: run ─────────────────
FROM nginx:stable-alpine

# remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# copy our nginx config
COPY nginx.conf /etc/nginx/conf.d/

# copy built assets from builder
COPY --from=builder /app/build /usr/share/nginx/html

# expose port 80
EXPOSE 80

# run nginx
CMD ["nginx", "-g", "daemon off;"]

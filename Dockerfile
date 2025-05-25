# ──────────────── Stage 1: Build the React app ────────────────
# Use a lightweight Node.js image to compile your source
FROM node:23-alpine AS builder

# Set /app as the working directory for subsequent commands
WORKDIR /app

# Copy package manifests first (best practice for caching)
COPY package.json package-lock.json ./

# Install all dependencies exactly as specified in package-lock.json
RUN npm ci

# Copy the rest of your source code into the container
COPY . .

# Run the build script (Vite will output production files to /app/dist)
RUN npm run build   # ← outputs compiled static files here

# ──────────────── Stage 2: Serve with Nginx ────────────────
# Switch to an Nginx base image for minimal overhead
FROM nginx:stable-alpine

# Remove the default Nginx site configuration so it doesn't conflict
RUN rm /etc/nginx/conf.d/default.conf

# Copy in your custom Nginx config that handles routing & caching
COPY nginx.conf /etc/nginx/conf.d/

# Copy the built static files from the builder stage into Nginx’s html dir
# Note: we point to /app/dist (Vite’s output), not /app/build
COPY --from=builder /app/dist /usr/share/nginx/html

# Tell Docker the container listens on port 80 at runtime
EXPOSE 80

# Start Nginx in the foreground (daemon off) so Docker can manage the process
CMD ["nginx", "-g", "daemon off;"]

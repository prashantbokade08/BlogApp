# Stage 1: Build Stage
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy the package.json and package-lock.json (if available)
COPY backend/package*.json ./backend/
COPY frontend/package*.json ./frontend/

# Install backend and frontend dependencies
RUN cd backend && npm install
RUN cd ../frontend && npm install

# Copy the application source code
COPY . .

# Build the frontend
RUN cd frontend && npm run build

# Stage 2: Production Stage
FROM node:18-alpine AS production

# Set working directory
WORKDIR /app

# Copy backend dependencies from the build stage
COPY --from=build /app/backend/node_modules ./backend/node_modules

# Copy the backend and built frontend code from the build stage
COPY --from=build /app/backend ./backend
COPY --from=build /app/frontend/build ./frontend/build

# Set the environment variable to production
ENV NODE_ENV=production

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["node", "backend/index.js"]

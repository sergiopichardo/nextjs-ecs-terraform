# ------------------------------
# Base Stage: Use a lightweight Node.js alpine image
# ------------------------------
ARG NODE_VERSION=20-alpine

FROM node:${NODE_VERSION} AS base

RUN apk add --no-cache libc6-compat

WORKDIR /app

COPY package.json package-lock.json ./

# RUN PRISMA_CLI_BINARY_TARGETS=native,debian-openssl-3.0.x,linux-arm64-openssl-3.0.x,rhel-openssl-3.0.x npm ci --legacy-peer-deps

# ------------------------------
# Stage 2: Build the Next.js app
# ------------------------------
FROM base AS builder

COPY --from=base /app/node_modules ./node_modules
COPY . .

# Set the binary target before prisma generate
# ENV PRISMA_CLI_BINARY_TARGETS=rhel-openssl-1.0.x

# generate prisma client
# RUN npx prisma generate

RUN npm run build

# ------------------------------
# Stage 3: Create Production Image with Amazon Linux
# ------------------------------
FROM public.ecr.aws/amazonlinux/amazonlinux:latest AS runner

# Install Node.js from NodeSource
RUN dnf install -y shadow-utils curl-minimal && \
  curl -sL https://rpm.nodesource.com/setup_20.x | bash - && \
  dnf install -y nodejs

# Install Prisma dependencies
RUN dnf install -y openssl-libs zlib libgcc glibc && \
  dnf clean all

# Create a non-root user for security
RUN groupadd -g 1001 nodejs && \
  useradd -r -u 1001 -g nodejs nextjs

# Set environment variables
ENV NODE_ENV=production

WORKDIR /app

# Copy necessary files from builder stage
COPY --from=builder /app/.next/standalone ./app
COPY --from=builder /app/public ./app/public
COPY --from=builder /app/.next/static ./app/.next/static


# Ensure permissions for non-root user
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

EXPOSE 3000

CMD ["node", "app/server.js"]

FROM node:18-slim

# Install required dependencies and debugging tools
RUN apt-get update && apt-get install -y \
    chromium \
    daemonize \
    git \
    # Debugging tools
    vim \
    curl \
    wget \
    net-tools \
    procps \
    htop \
    lsof \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /usr/src/app

# Create scripts directory
RUN mkdir -p scripts

# Initialize package.json and install dependencies
RUN npm init -y && \
    npm install typescript @types/node @types/puppeteer puppeteer@5.5.0 commander pretty-bytes && \
    npm install https://gitlab.com/webliero/headless-launcher.git && \
    npm link && \
    ln -s /usr/src/app/node_modules/.bin/wlhl /usr/local/bin/wlhl

# Copy scripts and entrypoint
COPY scripts/*.js ./scripts/
COPY docker-entrypoint.sh .

# Set proper permissions
RUN chmod -R 755 scripts/ && \
    chmod +x /usr/local/bin/wlhl && \
    chmod +x docker-entrypoint.sh

# Create Chrome wrapper script with WebAssembly flags
RUN echo '#!/bin/bash\nexec /usr/bin/chromium \
    --no-sandbox \
    --disable-setuid-sandbox \
    --disable-dev-shm-usage \
    --disable-web-security \
    --disable-features=IsolateOrigins \
    --enable-features=SharedArrayBuffer \
    --allow-insecure-localhost \
    --ignore-certificate-errors \
    --js-flags="--experimental-wasm-threads" \
    "$@"' > /usr/local/bin/chrome-headless && \
    chmod +x /usr/local/bin/chrome-headless

# Set environment variables
ENV CHROME_PATH=/usr/local/bin/chrome-headless \
    WEBLIERO_TOKEN="" \
    ADMIN_AUTH_KEY="" \
    PATH="/usr/local/bin:${PATH}" \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Create non-root user but allow sudo
RUN useradd -m -s /bin/bash webliero && \
    apt-get update && \
    apt-get install -y sudo && \
    echo "webliero ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R webliero:webliero /usr/src/app

# Switch to non-root user
USER webliero

# Switch to entrypoint
ENTRYPOINT ["./docker-entrypoint.sh"] 
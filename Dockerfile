# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.1
FROM quay.io/evl.ms/fullstaq-ruby:3.3.1-jemalloc-bookworm-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV="production"

# Update gems and bundler
RUN gem update --system --no-document && \
    gem install -N bundler

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl libcairo2-dev \
		        libglib2.0-dev libgirepository1.0-dev libpoppler-glib-dev libpq-dev \
				libvips libyaml-dev unzip

# Install Bun
ARG BUN_VERSION=1.1.8
ENV BUN_INSTALL=/usr/local/bun
ENV PATH=/usr/local/bun/bin:$PATH
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"

# Install application gems
COPY --link Gemfile Gemfile.lock ./
RUN --mount=type=cache,id=bld-gem-cache,sharing=locked,target=/srv/vendor \
    bundle config set app_config .bundle && \
    bundle config set path /srv/vendor && \
    bundle install && \
    bundle exec bootsnap precompile --gemfile && \
    bundle clean && \
    mkdir -p vendor && \
    bundle config set path vendor && \
    cp -ar /srv/vendor .

# Install node modules
COPY --link package.json bun.lockb ./
RUN --mount=type=cache,id=bld-bun-cache,target=/root/.bun \
    bun install --frozen-lockfile

# Copy application code
COPY --link . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y libpoppler-glib-dev libvips \
	nginx postgresql-client ruby-foreman poppler-utils

# configure nginx
RUN gem install foreman && \
    sed -i 's/access_log\s.*;/access_log stdout;/' /etc/nginx/nginx.conf && \
    sed -i 's/error_log\s.*;/error_log stderr info;/' /etc/nginx/nginx.conf

# configure client_max_body_size
COPY <<-EOF /etc/nginx/conf.d/client_max_body_size.conf
client_max_body_size 100M;
EOF

COPY <<-"EOF" /etc/nginx/sites-available/default
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  access_log stdout;

  root /rails/public;

  location /cable {
    proxy_pass http://localhost:8082/cable;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $host;
  }

  location / {
    try_files $uri @backend;
  }

  location @backend {
    proxy_pass http://localhost:3001;
    proxy_set_header Host $http_host;
  }
}
EOF

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Deployment options
ENV PORT="3001" \
	RUBY_YJIT_ENABLE="1" \
	MALLOC_ARENA_MAX="2"

# Build a Procfile for production use
COPY <<-"EOF" /rails/Procfile.prod
nginx: /usr/sbin/nginx -g "daemon off;"
rails: bundle exec rails server -p 3001
EOF

# Start the server by default, this can be overwritten at runtime
EXPOSE 80
CMD ["foreman", "start", "--procfile=Procfile.prod"]

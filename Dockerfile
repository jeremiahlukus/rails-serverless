# Shared image, envs, packages for both devcontainer & prod.
FROM --platform=linux/arm64 ruby:3.2.2-bullseye


# Create a directory for the Lambda function
WORKDIR "/app"

RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends build-essential curl git jq pkg-config libxml2 unzip 

RUN apt-get install -y -qq --no-install-recommends libpq-dev && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install JavaScript dependencies
ARG NODE_VERSION=20.12.2
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# RUN curl -fsSL https://nodejs.org/dist/v20.12.2/node-v20.12.2-linux-arm64.tar.xz | tar -xJf - -C /usr/local --strip-components=1
# RUN npm install -g yarn
# Auto apt build_stage packages

# Install the AWS Lambda Runtime Interface Client & Crypteia for secure SSM-backed envs.
RUN gem install 'aws_lambda_ric'
COPY --from=ghcr.io/rails-lambda/crypteia-extension-debian:1 /opt /opt
ENTRYPOINT [ "/usr/local/bundle/bin/aws_lambda_ric" ]
ENV LD_PRELOAD=/opt/lib/libcrypteia.so


# Copy prod application files and set handler.
# ENV BUNDLE_IGNORE_CONFIG=1
# ENV BUNDLE_PATH=./vendor/bundle
# ENV BUNDLE_CACHE_PATH=./vendor/cache
# ENV RAILS_SERVE_STATIC_FILES=1

COPY . .

# install lambda-insights
COPY LambdaInsightsExtension-Arm64.zip /opt
RUN unzip /opt/LambdaInsightsExtension-Arm64.zip -d /opt/

RUN bundle lock --add-platform $(ruby -e 'puts RUBY_PLATFORM')

RUN bundle install


ENV NODE_OPTIONS="--openssl-legacy-provider"
RUN yarn install

ENV BOOTSNAP_CACHE_DIR=/var/task/tmp/cache
RUN bundle exec bootsnap precompile --gemfile . \
    && bundle exec ruby config/environment.rb


CMD ["config/environment.Lamby.cmd"]
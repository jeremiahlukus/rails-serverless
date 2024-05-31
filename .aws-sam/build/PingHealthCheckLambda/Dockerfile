FROM amazonlinux:2023

# Define custom function directory
ARG FUNCTION_DIR="/function"

# Install ruby, bundler and the Runtime Interface Client
RUN dnf install -y ruby \
  && dnf clean all \
  && gem update --system \
  && gem install bundler \
  && gem install aws_lambda_ric

# Set working directory
WORKDIR ${FUNCTION_DIR}

# Copy Gemfile and Gemfile.lock
COPY lambda/ ${FUNCTION_DIR}/
RUN bundle config set --local deployment 'true' && bundle install


# Call lambda runtime
ENTRYPOINT ["/usr/local/bin/aws_lambda_ric"]
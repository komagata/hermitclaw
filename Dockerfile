FROM ruby:3.2-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --without development

COPY lib/ lib/
COPY bin/ bin/
COPY config.example.yml ./

RUN chmod +x bin/hermitclaw

# Non-root user for security
RUN useradd -m hermit
USER hermit

EXPOSE 4567

CMD ["bin/hermitclaw"]

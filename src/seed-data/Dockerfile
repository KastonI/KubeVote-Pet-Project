FROM python:3.9-slim

RUN apt-get update && apt-get install -y --no-install-recommends apache2-utils && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 10001 app && useradd -u 10001 -g 10001 -m app

WORKDIR /seed

COPY . .

RUN python make-data.py
USER app
CMD ["/seed/generate-votes.sh"]

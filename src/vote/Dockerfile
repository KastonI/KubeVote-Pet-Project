# Originally based on Example Voting App (Apache License 2.0)
# Modified by Illia Savchenko, 2026
FROM python:3.11-slim AS base

RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -fr /var/lib/apt/lists/*

RUN groupadd -g 10001 app && useradd -u 10001 -g 10001 -m app

WORKDIR /usr/local/app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


FROM base AS prod

COPY --chown=app:app . .

ENV PYTHONUNBUFFERED=1

EXPOSE 8080

USER app

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4"]

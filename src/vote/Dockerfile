FROM python:3.11-slim AS base

RUN apt-get update && apt-get install -y --no-install-recommends curl=8.14.1-2+deb13u2 && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


FROM base AS prod

RUN groupadd -g 10001 appuser && useradd -u 10001 -g 10001 -m appuser

COPY --chown=10001:10001 . .

ENV PYTHONUNBUFFERED=1

EXPOSE 8080

USER 10001:10001

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4"]

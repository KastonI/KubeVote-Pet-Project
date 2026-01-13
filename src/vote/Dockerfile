FROM python:3.11-slim AS base

RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 10001 app && useradd -u 10001 -g 10001 -m app

WORKDIR /usr/local/app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


FROM base AS prod

RUN useradd -m -u 10001 appuser

COPY --chown=appuser:appuser . .

ENV PYTHONUNBUFFERED=1

EXPOSE 8080

USER appu
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4"]

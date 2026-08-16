FROM python:3.9.10-slim

ENV PYTHONUNBUFFERED 1

EXPOSE 8000
WORKDIR /app


RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY poetry.lock pyproject.toml ./
RUN pip install "setuptools<70" && \
    pip install poetry-core==1.0.8 poetry==1.1.15 && \
    poetry config virtualenvs.in-project true && \
    poetry install --no-dev

COPY . ./

CMD until nc -z db 5432; do echo "Waiting for postgres..."; sleep 1; done && \
    poetry run alembic upgrade head && \
    poetry run uvicorn --host=0.0.0.0 app.main:app
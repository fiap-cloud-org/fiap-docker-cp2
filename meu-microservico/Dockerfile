# Estágio 1: instala as dependências num virtualenv isolado
FROM python:3.12-alpine AS builder
WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip uninstall -y pip

# Estágio 2: imagem final só com o runtime, sem pip e rodando como usuário comum
FROM python:3.12-alpine
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
RUN python -m pip uninstall -y pip \
    && addgroup -g 1001 -S app \
    && adduser -S -u 1001 -G app -H -s /sbin/nologin app
COPY --from=builder /opt/venv /opt/venv
WORKDIR /app
COPY --chown=app:app . .
USER app

EXPOSE 5000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/status', timeout=2)"

# Gunicorn em vez do servidor de desenvolvimento do Flask
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--access-logfile", "-", "app:app"]

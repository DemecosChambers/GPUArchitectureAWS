FROM python:3.11-slim
RUN pip install --no-cache-dir pandas boto3
WORKDIR /app
COPY main.py /app/main.py
CMD ["python", "/app/main.py"]

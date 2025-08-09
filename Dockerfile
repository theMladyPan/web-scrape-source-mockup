FROM python:3.12-alpine

WORKDIR /app

# Prevents Python from writing .pyc files to disk - saves space
ENV PYTHONDONTWRITEBYTECODE=1 
# Ensures that Python output is sent straight to terminal (e.g. for logging) and not buffered
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

COPY config.json .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
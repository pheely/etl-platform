# Use the official lightweight Python image
# Gunicorn and Flask run optimally on alpine or slim-debian distributions
FROM python:3.11-slim

# Allow statements and log messages to immediately appear in Cloud Logging
ENV PYTHONUNBUFFERED=True

# Set the internal working directory inside the container
WORKDIR /app

# Copy your local dependency list first to leverage Docker's caching layer
COPY requirements.txt .

# Install the dependencies required for the Airflow API handshake
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code (including your python trigger script)
COPY . .

# Expose the port that Cloud Run dynamically injects via the PORT env variable
# Cloud Run defaults to port 8080, but your application should always bind to $PORT
EXPOSE 8080

# Run the web service using Gunicorn (Green Unicorn) for production scale
# It uses 1 worker and 8 concurrent threads to handle rapid web requests efficiently
CMD ["gunicorn", "--bind", ":8080", "--workers", "1", "--threads", "8", "--timeout", "0", "src.main:app"]
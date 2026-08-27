FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Run the application using Gunicorn
CMD gunicorn core.wsgi:application --bind 0.0.0.0:$PORT
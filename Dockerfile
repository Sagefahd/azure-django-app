# Use official Python image
FROM python:3.11-slim

# Prevent Python from writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt requirements.txt 
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project
COPY . .

# Expose port (Container Apps expects 8000)
EXPOSE 8000

# Run app with Gunicorn
CMD ["gunicorn", "myProject.wsgi:application", "--bind", "0.0.0.0:8000"]


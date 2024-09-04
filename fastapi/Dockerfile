# Dockerfile

# Use an official Python runtime as a parent image
FROM python:3.10-slim

ARG PIP_INSTALL=""


# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY src /app

# Install any needed packages specified in requirements.txt

RUN if [ "${PIP_INSTALL}" = "YES" ]; then \
    pip install --no-cache-dir -r requirements.txt;\
    # else\
    # cp asd.txt /asd.txt;\
    fi


# RUN pip install --no-cache-dir -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Run uvicorn server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]

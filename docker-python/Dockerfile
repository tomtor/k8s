# Use an official Python runtime as a parent image
FROM python:3.7-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
#COPY . /app
COPY *.py requirements.txt /app/
COPY archi_test/*.py /app/archi_test/

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME "K8S Python / Redis / PostgreSQL"

# Run app.py when the container launches
CMD ["python", "-u", "app.py"]

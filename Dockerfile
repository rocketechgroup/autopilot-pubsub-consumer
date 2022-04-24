FROM python:3.8.13-slim

ARG CONSUMER_USER=pubsubuser
ARG CONSUMER_HOME=/home/${CONSUMER_USER}
RUN useradd --create-home --shell /bin/bash $CONSUMER_USER

USER $CONSUMER_USER
WORKDIR ${CONSUMER_HOME}

COPY main.py .
COPY requirement.txt .

RUN pip install -r requirement.txt

ENTRYPOINT ["python", "-u", "main.py"]
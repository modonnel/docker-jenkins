FROM jenkins
MAINTAINER Mike O

# Suppress apt installation warnings
ENV DEBIAN_FRONTEND=noninteractive

# Change to root user
USER root

# Used to set the docker group ID
# Set 497 by default, which is the group IS used by AWS Linux ECS instance
#ARG DOCKER_GID=497
ARG DOCKER_GID=989

# Create Docker Group with GID
# Set default value of 497 if DOCKER_GID set to blank string by Docker Compose
#RUN groupadd -g ${DOCKER_GID:-497} docker
RUN groupadd -g 497 docker
RUN groupadd -g 989 docker2
RUN groupadd -g 991 docker3

# Used to control Docker and Docker Compose versions installed
# NOTE: As of February 2016, AWS Linux ECS only supports Docker 1.9.1
ARG DOCKER_ENGINE=1.10.2
ARG DOCKER_COMPOSE=1.6.2

# Install base packages
RUN apt-get update -y && \
    apt-get install vim apt-transport-https curl python-dev python-setuptools gcc make libffi-dev libssl-dev iputils-ping -y && \
    easy_install pip

# Install Docker Engine
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list && \
    apt-get update -y && \
    apt-get purge lxc-docker* -y && \
    apt-get install docker-engine=${DOCKER_ENGINE:-1.10.2}-0~trusty -y && \
    usermod -aG docker jenkins && \
    usermod -aG docker2 jenkins && \
    usermod -aG docker3 jenkins && \
    usermod -aG users jenkins

# Install Docker Compose
RUN pip install docker-compose==${DOCKER_COMPOSE:-1.6.2} && \
    pip install ansible boto boto3
    pip install setuptools --upgrade

# Change to jenkins user
USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

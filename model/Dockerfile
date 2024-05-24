FROM ubuntu:22.04

# Install some basic utilities and system packages (as root)
RUN apt-get update && apt-get install --no-install-recommends -y \
    gcc \
    python3 \
    python3-pip \
    python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USER_ID=1000
ARG USER_NAME=sentiment_analysis
RUN useradd -m --no-log-init --system --uid ${USER_ID} ${USER_NAME}

# Login as non-root user and add local binaries directory to $PATH
USER ${USER_NAME}
ENV PATH="/home/${USER_NAME}/.local/bin:${PATH}"

# Copy the code to the container
COPY --chown=${USER_NAME} . /home/${USER_NAME}/model
# Change working directory
WORKDIR /home/${USER_NAME}/model
RUN chmod +x run.sh
# Install requirements
RUN pip3 install --user --no-cache-dir -r requirements.txt --no-deps

# Expose (open) Docker port 80
EXPOSE 80
ENTRYPOINT ["./run.sh"]
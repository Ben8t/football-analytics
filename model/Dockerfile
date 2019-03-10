FROM ufoym/deepo:all-py36-jupyter-cpu

RUN apt-get -qq update -y && \
    apt-get install curl -y && \
    apt-get install unzip -y && \
    apt-get install -my wget gnupg

RUN pip install flask mlflow

# Set the locale
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

CMD ["/bin/bash"]

FROM ufoym/deepo:all-py36-jupyter-cpu

RUN apt-get -qq update -y && \
    apt-get install curl -y && \
    apt-get install unzip -y && \
    apt-get install -my wget gnupg

RUN pip install flask

CMD ["/bin/bash"]
FROM debian:bullseye

RUN apt update && apt install wget -y

RUN wget -O cadvisor https://github.com/google/cadvisor/releases/download/v0.49.2/cadvisor-v0.49.2-linux-amd64

RUN chmod +x cadvisor



ENTRYPOINT ["/cadvisor", "--port=8080"]
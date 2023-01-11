FROM ubuntu:latest
RUN apt-get update && apt-get install curl ulogd2 ufw rsyslog nano iputils-ping -y

WORKDIR /home

# setup files
COPY iptables-rules.sh iptables-rules.sh
COPY ulogd.conf /etc/ulogd.conf
RUN touch /var/log/syslog.log

# download and install
RUN echo $E 
RUN curl -L -o filebeat.deb https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.16.0-arm64.deb
RUN dpkg -i filebeat.deb

FROM lscr.io/linuxserver/kali-linux:latest
RUN apt-get -y update && apt-get -y upgrade -y && apt-get install -y sudo
RUN sudo apt-get install -y curl ffmpeg git locales nano python3-pip screen ssh unzip wget  
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENTRYPOINT ["/bin/bash"]

FROM base AS wordlists

ARG DEBIAN_FRONTEND=noninteractive

# Install Seclists
RUN mkdir -p /usr/share/seclists \
    # The apt-get install seclists command isn't installing the wordlists, so clone the repo.
    && git clone --depth 1 https://github.com/danielmiessler/SecLists.git /usr/share/seclists

# Prepare rockyou wordlist
RUN mkdir -p /usr/share/wordlists
WORKDIR /usr/share/wordlists
RUN cp /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz /usr/share/wordlists/ \
    && tar -xzf rockyou.txt.tar.gz

WORKDIR /root
# Install ssh, wget, and unzip
RUN apt install ssh  wget unzip -y > /dev/null 2>&1

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3.5-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip

# Create shell script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/kali.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/kali.sh


# Create directory for SSH daemon's runtime files
RUN echo '/usr/sbin/sshd -D' >>/kali.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config # Allow root login via SSH
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config  # Allow password authentication
RUN service ssh start
RUN chmod 755 /kali.sh

# Expose port
EXPOSE 80 443 9050 8888 53 9050 3000 8888 3306 8118 3000

# Start the shell script on container startup


CMD  /kali.sh
VOLUME /config

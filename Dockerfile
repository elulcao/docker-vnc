FROM oraclelinux:7

LABEL vendor=elulcao
LABEL python.version="3.6.8"

# set proxy for download in private networks
#ENV http_proxy http://www:80
#ENV https_proxy http://www:80
#ENV ftp_proxy http://www:80
#ENV no_proxy localhost,127.0.0.1,.www.com,.www.com

# create a dedicated user and grant dir ownership to the dedicated user
RUN yum -y update && yum -y install sudo && yum -y clean all

RUN groupadd sudo && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers && \
	useradd -d /home/elulcao -m elulcao && \
	usermod -a -G sudo elulcao

# install yum packages, for gtk warnings & gui applications
RUN yum -y update && \
	yum -y install \
	ant bash-completion bind-utils bzip2 bzip2-devel \
	cronie db4-devel dbus-x11 dos2unix expect firefox \
	gcc gdbm-devel libX11 libXt libcanberra-gtk2 \
	libpcap-devel libreport-gtk make ncurses-devel openssl-devel \
	python-setuptools python3 readline-devel sqlite-devel \
	subversion tcl tcl-devel tigervnc-server tk tk-devel \
	tmux unzip vim wget xdpyinfo \
	xorg-x11-apps xorg-x11-font-utils xorg-x11-fonts-100dpi \
	xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-server-utils \
	xorg-x11-xauth xorg-x11-xkb-utils xterm xz-devel zlib-devel && \
	yum -y clean all

RUN mkdir -p /scratch/shared

COPY /src /scratch/src
COPY /sshconfig /scratch/sshconfig

RUN chmod -R 777 /scratch/

# SSH a runing container is not working, getting "connection refused" message
EXPOSE 22
EXPOSE 5900
EXPOSE 5901

RUN mkdir /var/run/sshd

## Suppress error message 'Could not load host key: ...'
RUN /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
RUN /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''

# set passwords
RUN echo 'root:welcome1' | chpasswd && \
	echo 'elulcao:welcome1' | chpasswd

RUN sed -i \
	-e 's/^UsePAM yes/#UsePAM yes/g' \
	-e 's/^#UsePAM no/UsePAM no/g' \
	-e 's/^#PermitRootLogin yes/PermitRootLogin yes/g' \
	-e 's/^#UseDNS yes/UseDNS no/g' \
	/etc/ssh/sshd_config

# config vnc display resolution, ignore firefox autostart
RUN sed -i "s/geometry =.*\".*\".*/geometry =\"1280x960\";/g" /usr/bin/vncserver
RUN sed -i "s|^\s*/usr/bin/firefox.*|echo 'firefox skipped'|g" /etc/X11/xinit/Xclients

# Python modules
RUN pip3 install --upgrade pip pyautogui python-dotenv supervisor

USER elulcao
RUN mkdir -p ~elulcao/{.vnc,.ssh} && chmod 700 ~/.ssh && \
	echo welcome1 | vncpasswd -f > ~/.vnc/passwd && \
	chmod 600 ~elulcao/.vnc/passwd && \
	cp /scratch/sshconfig/Xresources ~elulcao/.Xresources && \
	cp /scratch/sshconfig/dbtestkey ~/.ssh && \
	cp /scratch/sshconfig/config ~/.ssh && \
	chmod 600 ~/.ssh/dbtestkey

USER root
RUN mkdir -p ~/{.vnc,.ssh} && chmod 700 ~/.ssh && \
	echo welcome1 | vncpasswd -f > ~/.vnc/passwd && \
	chmod 600 ~/.vnc/passwd && \
	cp /scratch/sshconfig/Xresources ~/.Xresources && \
	cp /scratch/sshconfig/dbtestkey ~/.ssh && \
	cp /scratch/sshconfig/config ~/.ssh && \
	chmod 600 ~/.ssh/dbtestkey && \
	cp /scratch/src/supervisord.conf /root/

RUN echo -e '# elulcao start' >> /etc/profile && \
	echo -e 'export DISPLAY=:0' >> /etc/profile && \
	echo -e 'export JAVA_HOME=/usr/java/jdk1.8.0_131' >> /etc/profile && \
	echo -e 'export PATH=${JAVA_HOME}/bin:$PATH' >> /etc/profile && \
	echo -e 'export CLASSPATH=$JAVA_HOME/lib/tools.jar' >> /etc/profile && \
	#echo -e 'export HTTP_PROXY=www:80' >> /etc/profile && \
	#echo -e 'export HTTPS_PROXY=www:80' >> /etc/profile && \
	#echo -e 'export no_proxy=localhost,127.0.0.1,.www.com,.www.com' >> /etc/profile && \
	echo -e '# elulcao end' >> /etc/profile

# entrypoint
ENTRYPOINT ["sh", "/scratch/src/start.sh"]

FROM debian:buster

RUN apt-get -y update
RUN apt-get -y install ruby-nokogiri ruby-treetop ruby-parse-cron

RUN apt-get -y install git
RUN git clone --depth 1 --branch release-6.4.0 https://github.com/OpenNebula/one.git
RUN apt-get -y remove git git-man liberror-perl libperl5.28 patch perl perl-modules-5.28
RUN apt-get -y clean

RUN mkdir -p /var/lib/one/sunstone /usr/lib/one/sunstone/public/dist/
WORKDIR /one
RUN ./install.sh -c
WORKDIR /
RUN rm -rf one

CMD onevm

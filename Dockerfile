FROM debian:stable-slim
RUN apt-get update && apt-get -y upgrade \
&&  apt-get --no-install-recommends -y install apache2 fping make gcc python3-dev libapache2-mod-perl2 libgd-perl wget libcgi-session-perl
WORKDIR /usr
RUN cpan Digest::MD5 Digest::SHA1 Digest::HMAC Crypt::DES Socket6
ENV PERL5LIB=/usr/local/lib/perl5
ENV PATH=/usr/local/bin:$PATH
WORKDIR /root
RUN wget http://www.tcp4me.com/code/argus-archive/argus-3.7.tgz
#COPY --chown=root file/argus-3.7.tgz /root/argus-3.7.tgz
#RUN ["chown", "0:0", "argus-3.7.tgz"]
RUN tar -zxvf argus-3.7.tgz
#RUN ["chmod", "-R", "777", "/root/argus-3.7"]
WORKDIR /root/argus-3.7
#RUN ["chmod", "+x", "./Configure"]
RUN ./Configure
RUN make
RUN make install
RUN a2enmod cgi
RUN sed -i 's@/var/www/html@/usr/local/htdocs/argus@g' /etc/apache2/sites-enabled/000-default.conf  &&\
    sed -i 's@/usr/lib/cgi-bin@/usr/local/cgi-bin@g' /etc/apache2/conf-enabled/serve-cgi-bin.conf   &&\
    sed -i 's@/var/www@/usr/local/htdocs@g' /etc/apache2/apache2.conf
#    sed -i 's,#LoadModule cgi,LoadModule cgi,g'           /etc/apache2/apache2.conf && \
#    sed -i 's,Options Indexes,Options ,g'                 /etc/apache2/apache2.conf 
RUN sed -i 's/startform/start_form/g' /usr/local/lib/argus/web_login.pl && \
    sed -i 's/endform/end_form/g' /usr/local/lib/argus/web_login.pl
RUN apt clean && apt autoremove && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives && \
    mv /var/argus/users.example /var/argus/users && \
    mv /var/argus/config.example  /var/argus/config

COPY --chown=root file/docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh
RUN ["chmod", "777", "/usr/local/sbin/docker-entrypoint.sh"]
RUN chown -R www-data:www-data /usr/local/htdocs/argus/
EXPOSE 80
ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl","-D","FOREGROUND"]

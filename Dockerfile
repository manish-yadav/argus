FROM alpine:latest
RUN apk update && apk upgrade
RUN apk add --no-cache zlib zlib-dev perl perl-dev apache2 apache2-utils bash fping make
WORKDIR /usr
RUN apk --no-cache add perl-crypt-des perl-digest-md5 perl-digest-sha1 perl-digest-hmac perl-time-hires perl-socket6 perl-gd perl-dbi perl-cgi-session perl-cgi
ENV PERL5LIB=/usr/local/lib/perl5
ENV PATH=/usr/local/bin:$PATH
WORKDIR /root
RUN wget http://www.tcp4me.com/code/argus-archive/argus-3.7.tgz
RUN tar -zxvf argus-3.7.tgz
WORKDIR /root/argus-3.7
RUN ./Configure
RUN make
RUN make install
RUN sed -i 's@/var/www/localhost/cgi-bin@/usr/local/cgi-bin@' /etc/apache2/httpd.conf && \ 
    sed -i 's@/var/www/localhost/htdocs@/usr/local/htdocs/argus@g' /etc/apache2/httpd.conf && \ 
    sed -i 's,#LoadModule cgi,LoadModule cgi,g'           /etc/apache2/httpd.conf && \
    sed -i 's,Options Indexes,Options ,g'                 /etc/apache2/httpd.conf 

RUN sed -i 's/startform/start_form/g' /usr/local/lib/argus/web_login.pl && \
    sed -i 's/endform/end_form/g' /usr/local/lib/argus/web_login.pl
RUN mv /var/argus/users.example /var/argus/users && \
    mv /var/argus/config.example  /var/argus/config
COPY file/docker-entrypoint.sh /usr/local/sbin/
EXPOSE 80
ENTRYPOINT ["/usr/local/sbin/docker-entrypoint.sh"]
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]

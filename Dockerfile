FROM alpine:3.3

MAINTAINER ALTERDATA Altair Moura "altair.nimbus@alterdata.com.br"

RUN apk add --update nginx-lua bash && \
    rm -rf /var/cache/apk/* 


RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]

WORKDIR /etc/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

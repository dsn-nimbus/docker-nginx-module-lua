FROM alpine:3.3

RUN apk add --update nginx-lua bash && \
    rm -rf /var/cache/apk/* 

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

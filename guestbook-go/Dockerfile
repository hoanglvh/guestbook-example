FROM busybox:ubuntu

ADD ./guestbook /app/guestbook
ADD ./public/ /app/public/

WORKDIR /app
CMD ["./guestbook"]
EXPOSE 3000

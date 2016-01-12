FROM busybox:ubuntu-14.04

ADD ./guestbook /app/guestbook
ADD ./public/ /app/public/

WORKDIR /app
CMD ["./guestbook"]
EXPOSE 3000

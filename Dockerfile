FROM nginx:1.17-alpine

WORKDIR /app

COPY ./bin ./bin

ENTRYPOINT [ "/app/bin/run.sh" ]

FROM node:19-buster AS frontend
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm i
COPY . .
RUN npm run build:client

FROM golang:1.19-buster AS backend
WORKDIR /app
COPY backend/go.mod backend/go.sum ./
RUN go env -w GOPROXY=https://goproxy.cn,direct && go mod download
COPY backend/. .
COPY --from=frontend /app/dist /app/dist
RUN go build -o main .

FROM debian:bullseye-slim
WORKDIR /app
COPY --from=backend /app/main ./
CMD ["/app/main"]
EXPOSE 6752

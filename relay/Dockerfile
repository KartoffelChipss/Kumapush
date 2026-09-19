FROM golang:1.26-alpine AS build
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /relay .

# distroless/static ships CA certificates (needed for APNs) and a non-root user.
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /relay /relay

EXPOSE 4321
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD ["/relay", "healthcheck"]
ENTRYPOINT ["/relay"]

# OpenTelemetry Demo Stack

This project provides a ready-to-run **observability sandbox** with the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/), example telemetry generators, and popular backends (Jaeger, Prometheus, Grafana). It lets you explore **traces, metrics, and logs** end-to-end with minimal setup.

---

## What’s Inside

* **OpenTelemetry Collector (Contrib)**
  Receives OTLP telemetry and exports to Jaeger, Prometheus, and console.

* **Telemetry Generators**
  Containers that continuously emit example traces, metrics, and logs.

* **Jaeger (all-in-one)**
  UI for exploring distributed traces.

* **Prometheus**
  Scrapes Collector metrics and pipeline outputs.

* **Grafana**
  Visualizes Prometheus data with dashboards.

---

##  Project Structure

```
📂
├── 📄docker-compose.yml          # Stack definition
├── 📄otel-collector-config.yaml  # Collector pipeline config
└── 📄prometheus.yml              # Prometheus scrape targets
```

---

## Usage

### 1. Start the stack

If you have the `~/Downloads/magicssl.tgz` certificate bundle, use the deployment script so the stack starts with TLS enabled on the public endpoints:

```bash
./deploy.sh
```

You can override the archive path if needed:

```bash
SSL_ARCHIVE=/path/to/magicssl.tgz ./deploy.sh
```

To stop the stack and remove the unpacked certificates:

```bash
./undeploy.sh
```

To stop the stack but keep the unpacked certificates for a later redeploy:

```bash
KEEP_SSL=true ./undeploy.sh
```

For local development without TLS automation, you can still use Compose directly:

```bash
docker-compose up -d
```

### 2. Check container status

```bash
docker ps -a
```

### 3. Stop everything

```bash
docker-compose down
```

---

## Access the UIs

* **Grafana (Dashboards):** [https://localhost/grafana/](https://localhost/grafana/)
  Login: `admin` / `admin`

* **Prometheus (Metrics DB):** [https://localhost/prometheus/](https://localhost/prometheus/)

* **Jaeger UI (Traces):** [https://localhost/jaeger/](https://localhost/jaeger/)
  Search for service names like `sample-tracegen`.

---

## OTLP Endpoints

Your own apps can send telemetry directly to the Collector:

* gRPC with TLS: `localhost:4317`
* HTTP with TLS: `https://localhost:4318`

---

## Configuration Notes

* **Collector Exporters**

  * `otlp/jaeger`: sends traces to Jaeger’s OTLP port
  * `prometheus`: exposes metrics on `:8889`
  * `debug`: prints all data to container logs

* **Telemetrygen Flags**

  * `--duration=inf`: run indefinitely
  * `--rate=N`: items per second
  * For logs you must set `--duration` (or `--logs` count), otherwise it exits immediately.

---

## Troubleshooting

* **Reverse proxy exited** → Check `docker logs reverse-proxy`. This usually means the certificate archive was not unpacked into `.ssl/` or the TLS files are incomplete.
* **Collector exited** → Check `docker logs otel-collector`. Often caused by invalid exporter config.
* **Telemetrygen logs restart** → Ensure `--duration=inf` or `--logs > 0` is set.
* **No traces in Jaeger** → Confirm traces pipeline exporter is `otlp/jaeger` and the container can reach `jaeger:4317`.
* **No metrics in Prometheus** → Check Prometheus targets at `http://localhost:9090/targets`.

---

## References

* [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/)
* [Telemetrygen](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/telemetrygen)
* [Jaeger](https://www.jaegertracing.io/)
* [Prometheus](https://prometheus.io/)
* [Grafana](https://grafana.com/)

---

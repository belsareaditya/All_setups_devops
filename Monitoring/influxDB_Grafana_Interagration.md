# InfluxDB Installation and Setup on Ubuntu

## What is InfluxDB?

InfluxDB is a **time-series database (TSDB)** optimized for time-series data. These are metrics or events tracked, monitored, and aggregated over time. Examples include:

* Server metrics
* Web application performance monitoring
* Sensor/IoT data
* Financial or healthcare analytics

InfluxDB uses a SQL-like query language called **InfluxQL** and provides a built-in HTTP API for writing, reading, and managing data. It integrates with tools like **Grafana**, **Telegraf**, and **Kapacitor** for monitoring and analytics.

---

## Installation of InfluxDB on Ubuntu 20.04/22.04

### Step 1: Update System

```bash
sudo apt-get update
```

### Step 2: Add InfluxData Repository

```bash
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list
```

### Step 3: Install InfluxDB

```bash
sudo apt-get update
sudo apt-get install influxdb2
```

### Step 4: Check InfluxDB Version

```bash
influx version
```

### Step 5: Start and Enable InfluxDB Service

```bash
sudo systemctl start influxdb
sudo systemctl enable influxdb
```

Verify InfluxDB is running:

```bash
sudo service influxdb status
```

Restart/Stop commands:

```bash
sudo service influxdb restart
sudo service influxdb stop
```

---

## Firewall Configuration

Allow TCP traffic on InfluxDB default port (8086):

```bash
sudo ufw allow 8086/tcp
```

---

## Setting up InfluxDB

### Option 1: Web UI Setup

1. Visit: [http://localhost:8086](http://localhost:8086)
2. Click **Get Started**
3. Create:

   * Username
   * Password
   * Organization
   * Bucket

### Option 2: CLI Setup

InfluxDB can also be configured using the command-line interface.

---

## Installing Telegraf (Metrics Collector)

Telegraf is an agent for collecting and reporting metrics to InfluxDB.

### Step 1: Add Repository

```bash
curl --silent --location -O https://repos.influxdata.com/influxdata-archive.key
gpg --show-keys --with-fingerprint --with-colons ./influxdata-archive.key 2>&1 \
| grep -q '^fpr:\+24C975CBA61A024EE1B631787C3D57159FC2F927:$' \
&& cat influxdata-archive.key \
| gpg --dearmor \
| sudo tee /etc/apt/keyrings/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list
```

### Step 2: Install Telegraf

```bash
sudo apt-get update && sudo apt-get install telegraf
```

### Step 3: Configure Telegraf

Edit config file:

```bash
sudo nano /etc/telegraf/telegraf.conf
```

Example output section to send data to InfluxDB:

```toml
[[outputs.influxdb_v2]]
  urls = ["http://localhost:8086"]
  token = "YOUR_INFLUXDB_TOKEN"
  organization = "YOUR_ORG"
  bucket = "YOUR_BUCKET"
```

Restart Telegraf:

```bash
sudo systemctl restart telegraf
```

---

✅ You now have **InfluxDB 2.x installed and running** on Ubuntu with **Telegraf** configured to collect metrics.


<img width="1100" height="545" alt="image" src="https://github.com/user-attachments/assets/068ab963-d038-4080-91d8-67269e0da2e2" />

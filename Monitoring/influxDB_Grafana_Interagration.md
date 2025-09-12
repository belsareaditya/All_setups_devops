# 📊 InfluxDB, Telegraf, and Grafana Installation & Integration on Ubuntu (20.04 / 22.04)

## What is InfluxDB?

**InfluxDB** is a **time-series database (TSDB)** optimized for metrics, events, and logs tracked over time.

Examples of time-series data include:

* Server metrics
* Application performance monitoring
* IoT sensor data
* Financial & healthcare analytics

👉 InfluxDB provides:

* **InfluxQL** (SQL-like query language)
* **Built-in HTTP API** for writing/reading data
* Integrations with **Grafana, Telegraf, and Kapacitor**
* **High performance & scalability**

It is widely used in **IoT, DevOps monitoring, finance, and healthcare**.

---

## Step 1: Install InfluxDB

### Update Ubuntu system

```bash
sudo apt-get update
```

### Add InfluxDB Repository Key

```bash
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c \
&& cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null

echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list
```

### Install InfluxDB

```bash
sudo apt-get update
sudo apt-get install influxdb2 -y
```

### Start & Enable InfluxDB Service

```bash
sudo systemctl start influxdb
sudo systemctl enable influxdb
```

Check status:

```bash
sudo service influxdb status
```

Allow external access (Port 8086):
or open open port 8086 in your security groups

```bash
sudo ufw allow 8086/tcp
```

---

## Step 2: Install Telegraf

Telegraf is a plugin-driven agent that collects metrics and writes them to InfluxDB.

```bash
curl --silent --location -O https://repos.influxdata.com/influxdata-archive.key
gpg --show-keys --with-fingerprint --with-colons ./influxdata-archive.key 2>&1 \
| grep -q '^fpr:\+24C975CBA61A024EE1B631787C3D57159FC2F927:$' \
&& cat influxdata-archive.key | gpg --dearmor | sudo tee /etc/apt/keyrings/influxdata-archive.gpg > /dev/null \
&& echo 'deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' \
| sudo tee /etc/apt/sources.list.d/influxdata.list

sudo apt-get update && sudo apt-get install telegraf -y
```

Edit configuration:

```bash
sudo vim /etc/telegraf/telegraf.conf

make uncomment the url and add your influx db host ip.
```

Start Telegraf:

```bash
sudo systemctl start telegraf
sudo systemctl enable telegraf
```

---

## Step 3: Install Grafana

Grafana is used for **visualizing metrics stored in InfluxDB**.

### Add Grafana Repository

```bash
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
```

### Install Grafana

```bash
sudo apt-get update
sudo apt-get install grafana -y
```

### Start & Enable Grafana

```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

Access Grafana at: [http://localhost:3000](http://localhost:3000)
Default login: **admin / admin** (you’ll be prompted to change password).

---

## Step 4: Connect InfluxDB to Grafana

1. Log in to Grafana.
2. Go to **Configuration → Data Sources**.
3. Select **InfluxDB**.
4. Enter:

   * **URL**: `http://localhost:8086`
   * **Organization**: `myorg`
   * **Token**: `MY_TOKEN`
   * **Bucket**: `testdb`
5. Click **Save & Test**.

---

## Example: Writing & Querying Data

### 1. Write Data to InfluxDB

```bash
influx write --bucket testdb --org myorg --token MY_TOKEN \
'weather,location=delhi temperature=32,humidity=60'
```

### 2. Query Data (Flux)

```bash
influx query '
from(bucket:"testdb")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "weather")
'
```

### 3. Visualize in Grafana

* Create a new **Dashboard**.
* Add a **Panel**.
* Choose **InfluxDB (Flux)** as the data source.
* Run a Flux query to fetch metrics (e.g., temperature).
* Save the dashboard.

✅ Example Grafana graph will show `temperature` and `humidity` trends for location *Delhi*.

---

# ✅ Conclusion

You have successfully installed and integrated:

* **InfluxDB** (time-series database)
* **Telegraf** (metrics collection)
* **Grafana** (visualization)

Now you can write metrics to InfluxDB, collect system stats via Telegraf, and build real-time dashboards with Grafana.

---



<img width="1100" height="545" alt="image" src="https://github.com/user-attachments/assets/068ab963-d038-4080-91d8-67269e0da2e2" />

## Blockchain Best Practices

### Performance Optimizations

- **Disk I/O Optimization:** 
  - **SSD Over HDD:** SSDs provide significantly better read/write speeds, crucial for blockchain nodes, especially during synchronization and block validation processes.
  - **Pruning:** For blockchains like Bitcoin and Ethereum, consider enabling pruning to reduce disk space usage by removing old block data, especially if you don’t need full transaction history.

- **Monitoring:** 
  - **Bandwidth Usage:** Monitor your bandwidth to avoid unexpected throttling or overage charges, particularly if your ISP has data caps. 
  - **Resource Utilization:** Use monitoring tools like Prometheus and Grafana to track CPU, RAM, and disk usage, ensuring your node runs efficiently.

- **Using Snapshots:** 
  - **Why Use Snapshots:** Snapshots can significantly reduce the initial sync time by providing a pre-synced version of the blockchain up to a recent block height.
  - **Where to Get Snapshots:** Many blockchains offer snapshots through community sites or official sources. Always verify the source to ensure it’s trustworthy.

### General Maintenence

- **Regular Updates:** Ensure your Docker and Docker Compose installations are regularly updated to benefit from the latest features and security patches.
- **Backups:** Regularly back up blockchain data, especially for full nodes, to prevent data loss. Automated backup solutions are recommended for handling large datasets.
- **Network Security:** Implement firewall rules, use VPNs or Tor where necessary, and keep your node software up to date to protect against vulnerabilities (or use [Nodevin](https://nodevin.xyz)).

---

## Blockchain Requirements and Sync Time

The table below outlines the specific hardware, storage, and network requirements for running nodes of various blockchain networks supported by this repository. Note that blockchain size increases over time, so allocate additional space accordingly.

| Blockchain                | CPU                | RAM                    | Storage                | Sync Time             | Bandwidth            | Network Port         |
|---------------------------|--------------------|------------------------|------------------------|-----------------------|----------------------|----------------------|
| **[Bitcoin](https://hub.docker.com/r/fiftysix/bitcoin-core)**          | Dual-core 2.0 GHz  | 8 GB min, 16 GB rec.   | ~600 GB            | ~5-7 days             | 200-500 GB/month     | 8333                 |
| **[Bitcoin w/ Ord](https://hub.docker.com/r/fiftysix/ord)**       | Dual-core 2.0 GHz  | 8 GB min, 16 GB rec.   | ~1 TB              | ~8-10 days            | 200-500 GB/month     | 80 (configurable), 8333 |
| **[Ethereum](https://hub.docker.com/r/fiftysix/geth)**         | Quad-core 2.5 GHz  | 16 GB min, 32 GB rec.  | ~1 TB (10 TB+ for archive) | ~7-14 days | 500 GB - 1.5 TB/month | 30303                |
| **[Dogecoin](https://hub.docker.com/r/fiftysix/dogecoin-core)**        | Dual-core 2.0 GHz  | 4 GB min, 8 GB rec.    | ~100 GB           | ~2-4 days              | 100-300 GB/month     | 22556                |
| **[Litecoin](https://hub.docker.com/r/fiftysix/litecoin-core)**         | Dual-core 2.0 GHz  | 8 GB min               | ~200 GB           | ~2-4 days              | 150-400 GB/month     | 9333                 |
| **[Litecoin w/ Ord-Litecoin](https://hub.docker.com/r/fiftysix/ord-litecoin)** | Dual-core 2.0 GHz | 8 GB min             | ~300 GB           | ~3-5 days              | 150-400 GB/month     | 80 (configurable), 9333 |

**Notes:**

- **Bitcoin with Ord and Litecoin with Ord-Litecoin:** Running nodes with ordinal support requires additional storage and specific configurations, which may impact performance. Ensure you monitor disk usage regularly and configure your setup accordingly.
- **Sync Time:** The initial sync time varies depending on your hardware and network speed. Using snapshots can significantly reduce this time.

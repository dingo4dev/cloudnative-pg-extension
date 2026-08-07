# CloudNative PostgreSQL with Oracle FDW - Kubernetes Examples

This directory contains example Kubernetes manifests for deploying PostgreSQL with Oracle FDW support using the CloudNative PostgreSQL operator.

## Prerequisites

1. **Install CloudNative PostgreSQL Operator**
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.22/releases/cnpg-1.22.0.yaml
   ```

2. **Verify operator is running**
   ```bash
   kubectl get pods -n cnpg-system
   ```

## Deployment

### 1. Deploy PostgreSQL Cluster

Deploy a 3-instance PostgreSQL cluster with Oracle FDW:

```bash
kubectl apply -f cluster.yaml
```

Check cluster status:
```bash
kubectl get cluster postgres-oracle-fdw
kubectl get pods -l cnpg.io/cluster=postgres-oracle-fdw
```

### 2. Configure Oracle FDW Connection (Optional)

If you have an Oracle database to connect to:

1. Edit `oracle-fdw-config.yaml` and update the Oracle connection details
2. Apply the configuration:
   ```bash
   kubectl apply -f oracle-fdw-config.yaml
   ```

### 3. Connect to PostgreSQL

Get the connection details:
```bash
# Get the service
kubectl get svc -l cnpg.io/cluster=postgres-oracle-fdw

# Get the app user password
kubectl get secret postgres-oracle-fdw-app -o jsonpath='{.data.password}' | base64 -d
```

Connect using psql:
```bash
kubectl run -it --rm psql --image=postgres:16 --restart=Never -- \
  psql -h postgres-oracle-fdw-rw -U app -d app
```

## Files Description

- **cluster.yaml**: Main cluster definition with 3 replicas
- **oracle-fdw-config.yaml**: Oracle FDW server and foreign table setup

## Cluster Features

The deployed cluster includes:
- ✅ 3 PostgreSQL instances (1 primary, 2 replicas)
- ✅ oracle_fdw extension for Oracle connectivity
- ✅ pg_cron extension for job scheduling
- ✅ PostgreSQL Anonymizer for data masking
- ✅ High availability with automatic failover
- ✅ Connection pooling
- ✅ Pod monitoring enabled

## Customization

### Change PostgreSQL Version

Edit `cluster.yaml` and change the `imageName`:
```yaml
imageName: ghcr.io/dingo4dev/postgres-container:17.1.5  # For PG 17
imageName: ghcr.io/dingo4dev/postgres-container:16.6    # For PG 16
```

### Adjust Resources

Modify the `resources` section in `cluster.yaml`:
```yaml
resources:
  requests:
    memory: "1Gi"
    cpu: "1000m"
  limits:
    memory: "2Gi"
    cpu: "2000m"
```

### Configure Backups

Uncomment the backup section in `cluster.yaml` and configure your S3-compatible storage.

## Monitoring

The cluster has `enablePodMonitor: true`, which allows Prometheus to scrape metrics.

View metrics:
```bash
kubectl port-forward svc/postgres-oracle-fdw-rw 9187:9187
```

## Testing Oracle FDW

Once connected to the database:

```sql
-- Check extensions
\dx

-- List foreign servers
\des+

-- List foreign tables
\dE+

-- Query Oracle data
SELECT * FROM oracle_employees LIMIT 10;
```

## Cleanup

Remove all resources:
```bash
kubectl delete -f oracle-fdw-config.yaml
kubectl delete -f cluster.yaml
```

## Troubleshooting

**Cluster not starting:**
```bash
kubectl describe cluster postgres-oracle-fdw
kubectl logs -l cnpg.io/cluster=postgres-oracle-fdw -c postgres
```

**Extension issues:**
```bash
kubectl exec -it postgres-oracle-fdw-1 -- psql -U postgres -c "\dx"
```

**Oracle connectivity:**
```bash
# Check from pod
kubectl exec -it postgres-oracle-fdw-1 -- bash
tnsping oracle-host:1521
```

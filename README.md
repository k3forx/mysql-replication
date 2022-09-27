# mysql-replication

## Setting Up Binary Log File Position Based Replication

There are some generic tasks that are common to all setups:

- On the source, you must ensure that binary logging is enabled, and configure a unique server ID. This might require a server restart.
  - 設定しないとデフォルトの値が設定されるのでユニークにしないと行けなさそう
  - sourceののバイナリログの設定はONにする必要がある (デフォルトでONになっている)
  - バイナリログのファイル名を設定した方がよい

## Demo

### Setup containers

```bash
docker-compose up -d
```

### Check config

- source

```mysql
mysql> SELECT @@server_id;
+-------------+
| @@server_id |
+-------------+
|         100 |
+-------------+
1 row in set (0.00 sec)

mysql> SELECT @@log_bin;
+-----------+
| @@log_bin |
+-----------+
|         1 |
+-----------+
1 row in set (0.00 sec)
```

- replicas-1

```mysql
mysql> SELECT @@server_id;
+-------------+
| @@server_id |
+-------------+
|         200 |
+-------------+
1 row in set (0.00 sec)
```
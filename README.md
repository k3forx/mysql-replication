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

### Create user in source 

```mysql
mysql> CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
Query OK, 0 rows affected (0.00 sec)

mysql> SHOW MASTER STATUS;
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000008 |      851 |              |                  |                   |
+---------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```

### Start replication in replica

```mysql
mysql> CHANGE REPLICATION SOURCE TO SOURCE_HOST='source', SOURCE_USER=
'repl', SOURCE_PASSWORD='repl', SOURCE_LOG_FILE='binlog.000008', SOURCE_LOG_POS=660;
Query OK, 0 rows affected, 2 warnings (0.01 sec)

mysql> START SLAVE;
Query OK, 0 rows affected, 1 warning (0.02 sec)

mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: source
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: binlog.000008
          Read_Master_Log_Pos: 660
               Relay_Log_File: 3b66b42d5be9-relay-bin.000002
                Relay_Log_Pos: 323
        Relay_Master_Log_File: binlog.000008
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 660
              Relay_Log_Space: 540
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 100
                  Master_UUID: 5ce3b6ec-3e6a-11ed-9900-0242ac120003
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
       Master_public_key_path:
        Get_master_public_key: 0
            Network_Namespace:
1 row in set, 1 warning (0.01 sec)
```

## Optional

Check list of binary log files.

```mysql
mysql> SHOW BINARY LOGS;
+---------------+-----------+-----------+
| Log_name      | File_size | Encrypted |
+---------------+-----------+-----------+
| binlog.000001 |   3026007 | No        |
| binlog.000002 |       180 | No        |
| binlog.000003 |       180 | No        |
| binlog.000004 |       180 | No        |
| binlog.000005 |       180 | No        |
| binlog.000006 |      2445 | No        |
| binlog.000007 |       701 | No        |
| binlog.000008 |       851 | No        |
+---------------+-----------+-----------+
8 rows in set (0.00 sec)

mysql> SHOW BINLOG EVENTS IN 'binlog.000008'\G
*************************** 1. row ***************************
   Log_name: binlog.000008
        Pos: 4
 Event_type: Format_desc
  Server_id: 100
End_log_pos: 126
       Info: Server ver: 8.0.30, Binlog ver: 4
*************************** 2. row ***************************
   Log_name: binlog.000008
        Pos: 126
 Event_type: Previous_gtids
  Server_id: 100
End_log_pos: 157
       Info:
*************************** 3. row ***************************
   Log_name: binlog.000008
        Pos: 157
 Event_type: Anonymous_Gtid
  Server_id: 100
End_log_pos: 236
       Info: SET @@SESSION.GTID_NEXT= 'ANONYMOUS'
*************************** 4. row ***************************
   Log_name: binlog.000008
        Pos: 236
 Event_type: Query
  Server_id: 100
End_log_pos: 440
       Info: CREATE USER 'repl'@'%' IDENTIFIED WITH 'mysql_native_password' AS '*A424E797037BF97C19A2E88CF7891C5C2038C039' /* xid=3 */
*************************** 5. row ***************************
   Log_name: binlog.000008
        Pos: 440
 Event_type: Anonymous_Gtid
  Server_id: 100
End_log_pos: 517
       Info: SET @@SESSION.GTID_NEXT= 'ANONYMOUS'
*************************** 6. row ***************************
   Log_name: binlog.000008
        Pos: 517
 Event_type: Query
  Server_id: 100
End_log_pos: 660
       Info: GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' /* xid=4 */
*************************** 7. row ***************************
   Log_name: binlog.000008
        Pos: 660
 Event_type: Anonymous_Gtid
  Server_id: 100
End_log_pos: 737
       Info: SET @@SESSION.GTID_NEXT= 'ANONYMOUS'
*************************** 8. row ***************************
   Log_name: binlog.000008
        Pos: 737
 Event_type: Query
  Server_id: 100
End_log_pos: 851
       Info: CREATE DATABASE sample /* xid=17 */
8 rows in set (0.00 sec)
```

## 17.1.3 Replication with Global Transaction Identifiers

### 17.1.3.1 GTID Format and Storage

- A global transaction identifier (GTID) is a unique identifier created and associated with each transaction committed on the server of origin (the source).

- The MySQL system table mysql.gtid_executed is used to preserve the assigned GTIDs of all the transactions applied on a MySQL server, except those that are stored in a currently active binary log file.

- A GTID is represented as a pair of coordinates, separated by a colon character (:), as shown here:

	```bash
	GTID = source_id:transaction_id
	```

- The upper limit for sequence numbers for GTIDs on a server instance is the number of non-negative values for a signed 64-bit integer (2 to the power of 63 minus 1, or 9,223,372,036,854,775,807). If the server runs out of GTIDs, it takes the action specified by binlog_error_action. From MySQL 8.0.23, a warning message is issued when the server instance is approaching the limit.

#### GTID Sets

- A GTID set is a set comprising one or more single GTIDs or ranges of GTIDs.

- A range of GTIDs originating from the same server can be collapsed into a single expression, as shown here:

	```bash
	3E11FA47-71CA-11E1-9E33-C80AA9429562:1-5
	```

- Multiple single GTIDs or ranges of GTIDs originating from the same server can also be included in a single expression, with the GTIDs or ranges separated by colons, as in the following example:

	```bash
	3E11FA47-71CA-11E1-9E33-C80AA9429562:1-3:11:47-49
	```

#### mysql.gtid_executed Table

- GTIDs are stored in a table named gtid_executed, in the mysql database.

	```sql
	CREATE TABLE gtid_executed (
		source_uuid CHAR(36) NOT NULL,
		interval_start BIGINT(20) NOT NULL,
		interval_end BIGINT(20) NOT NULL,
		PRIMARY KEY (source_uuid, interval_start)
	)
	```

- The mysql.gtid_executed table is provided for internal use by the MySQL server. It enables a replica to use GTIDs when binary logging is disabled on the replica, and it enables retention of the GTID state when the binary logs have been lost

- GTIDs are stored in the `mysql.gtid_executed` table only when `gtid_mode` is `ON` or `ON_PERMISSIVE`.

### 17.1.3.2 GTID Life Cycle

The life cycle of a GTID consists of the following steps:

1. A transaction is executed and committed on the source. This client transaction is assigned a GTID composed of the source's UUID and the smallest nonzero transaction sequence number not yet used on this server. The GTID is written to the source's binary log (immediately preceding the transaction itself in the log). 

1. If a GTID was assigned for the transaction, the GTID is persisted atomically at commit time by writing it to the binary log at the beginning of the transaction (as a Gtid_log_event). 

1. If a GTID was assigned for the transaction, the GTID is externalized non-atomically (very shortly after the transaction is committed) by adding it to the set of GTIDs in the gtid_executed system variable (@@GLOBAL.gtid_executed). This GTID set contains a representation of the set of all committed GTID transactions, and it is used in replication as a token that represents the server state. With binary logging enabled (as required for the source), the set of GTIDs in the gtid_executed system variable is a complete record of the transactions applied, but the mysql.gtid_executed table is not, because the most recent history is still in the current binary log file.

1. After the binary log data is transmitted to the replica and stored in the replica's relay log, the replica reads the GTID and sets the value of its `gtid_next` system variable as this GTID. This tells the replica that the next transaction must be logged using this GTID. It is important to note that the replica sets gtid_next in a session context.

### 17.1.3.3 GTID Auto-Positioning
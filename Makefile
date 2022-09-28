DB_USER := root
DB_PASS := test
DB_PORT := 3306

.PHONY: source
source: ## Conntect to mysql container (source)
	docker-compose exec source mysql -u$(DB_USER) -p$(DB_PASS)

.PHONY: replicas-1
replicas-1: ## Conntect to mysql container (replicas-1)
	docker-compose exec replicas-1 mysql -u$(DB_USER) -p$(DB_PASS)

.PHONY: replicas-2
replicas-2: ## Conntect to mysql container (replicas-2)
	docker-compose exec replicas-2 mysql -u$(DB_USER) -p$(DB_PASS)

.PHONY: start
start: ## Start mysql containers
	docker-compose up -d

.PHONY: stop
stop:
	docker-compose down

.PHONY: clean
clean: 
	docker volume rm mysql-replication_source && docker volume rm mysql-replication_replicas-1 && docker volume rm mysql-replication_replicas-2
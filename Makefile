FILE = -f srcs/docker-compose.yml
COMPOSE = docker compose


up:
	mkdir -p /home/merboyac/data/mysql
	mkdir -p /home/merboyac/data/wordpress
	$(COMPOSE) $(FILE) up --build -d

build:
	$(COMPOSE) $(FILE) build

down:
	$(COMPOSE) $(FILE) down

restart: down up

clean:
	$(COMPOSE) $(FILE) down -v --remove-orphans
	docker volume rm srcs_data_dir || true
	docker volume rm srcs_wordpress || true
	sudo rm -rf /home/merboyac/data || true


fclean:
	$(COMPOSE) $(FILE) down -v --rmi all --remove-orphans
	docker system prune -af
	sudo rm -rf /home/merboyac/data

logs:
	$(COMPOSE) $(FILE) logs -f




.PHONY: up build down restart clean fclean logs

.PHONY: up down reset logs ps shell

up:
	@docker compose --env-file .env up -d

down:
	@docker compose --env-file .env down

reset:
	@docker compose --env-file .env down -v
	@docker compose --env-file .env up -d

logs:
	@docker compose --env-file .env logs -f

ps:
	@docker compose --env-file .env ps

shell:
	@docker exec -it $$(docker compose --env-file .env ps -q odoo) bash

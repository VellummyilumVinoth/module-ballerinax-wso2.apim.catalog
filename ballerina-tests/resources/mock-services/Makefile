# Makefile for WSO2 APIM Mock Services

.PHONY: help build start stop restart logs test clean status health validate

# Default target
help:
	@echo "WSO2 APIM Mock Services - Docker Management"
	@echo ""
	@echo "Available targets:"
	@echo "  make build      - Build Docker image"
	@echo "  make start      - Start services"
	@echo "  make stop       - Stop services"
	@echo "  make restart    - Restart services"
	@echo "  make logs       - View container logs"
	@echo "  make test       - Run health tests"
	@echo "  make status     - Show container status"
	@echo "  make health     - Check service health"
	@echo "  make validate   - Validate configuration"
	@echo "  make clean      - Stop and remove everything"
	@echo ""

# Build Docker image
build:
	@echo "Building Docker image..."
	docker compose build

# Start services
start:
	@echo "Starting services..."
	docker compose up -d
	@echo "Waiting for services to initialize..."
	@sleep 15
	@make health

# Stop services
stop:
	@echo "Stopping services..."
	docker compose down

# Restart services
restart:
	@echo "Restarting services..."
	docker compose restart
	@sleep 10
	@make health

# View logs
logs:
	docker compose logs -f

# Run tests
test:
	@./test-docker.sh

# Show status
status:
	@echo "Container Status:"
	@docker ps --filter name=wso2-apim-mock-services --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "Network Status:"
	@docker network inspect mock-services_apim-test-network --format '{{.Name}}: {{len .Containers}} containers' 2>/dev/null || echo "Network not found"

# Health check
health:
	@echo "Checking service health..."
	@curl -f -s http://localhost:8080/health > /dev/null && echo "✓ Health check: OK" || echo "✗ Health check: FAILED"
	@nc -z localhost 8080 2>/dev/null && echo "✓ Port 8080: OK" || echo "✗ Port 8080: FAILED"
	@nc -z localhost 9444 2>/dev/null && echo "✓ Port 9444: OK" || echo "✗ Port 9444: FAILED"

# Validate configuration
validate:
	@echo "Validating Docker Compose configuration..."
	@docker compose config > /dev/null && echo "✓ Configuration is valid" || echo "✗ Configuration is invalid"

# Clean everything
clean:
	@echo "Cleaning up..."
	docker compose down -v
	docker system prune -f
	@echo "Cleanup complete"

# Quick test
quick:
	@make build
	@make start
	@make test

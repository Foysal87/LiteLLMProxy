# LiteLLM Proxy Docker Setup

This repository contains a complete Docker setup for LiteLLM proxy with PostgreSQL database support. LiteLLM is a lightweight proxy server that provides a unified interface for calling 100+ LLMs including Azure OpenAI, Anthropic Claude, and more.

## Features

- 🚀 **Unified API**: Call 100+ LLMs through a single OpenAI-compatible interface
- 🔐 **Authentication**: Virtual key management with spend tracking and rate limits
- 📊 **Database Support**: PostgreSQL integration for persistent storage
- 🐳 **Docker Ready**: Complete containerized setup with docker-compose
- 🔄 **Load Balancing**: Built-in load balancing across multiple Azure OpenAI deployments
- 📈 **Monitoring**: Built-in logging, metrics, and health checks

## Pre-configured Models

### Azure OpenAI Models
- **GPT-4**: Load balanced across Central US and Australia East deployments
- **GPT-3.5-turbo**: Load balanced across Central US and East US 2 deployments
- **GPT-4o**: High-capacity model with 120K context (South India)
- **GPT-4o-mini**: Efficient model for lighter tasks (South India)
- **Embeddings**: text-embedding-3-large and text-embedding-3-small (East US 2)

### Anthropic Claude Models
- **Claude 3 Haiku**: Fast and efficient model
- **Claude 3 Sonnet**: Balanced performance model
- **Claude 3 Opus**: Most capable model
- **Claude 3.5 Sonnet**: Enhanced version with 7K max tokens
- **Claude 3.7 Sonnet**: Latest version with 12K max tokens

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- **You need to configure your own API keys** (see Setup section below)

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd LiteLLLMProxy
```

### 2. Configure Environment and API Keys

**IMPORTANT**: You must set up your own API keys before using this proxy.

Copy the example environment file:

```bash
cp env.example .env
```

**Required Setup**: Edit the `.env` file and configure:

1. **Master Key**: Generate a secure master key for admin access
   ```
   LITELLM_MASTER_KEY=your-secure-master-key-here
   ```

2. **Azure OpenAI API Keys**: Add your Azure OpenAI API keys and endpoints
   ```
   AZURE_API_KEY_CENTRAL_US=your-azure-api-key-here
   AZURE_API_BASE_CENTRAL_US=your-azure-endpoint-here
   # ... add other Azure endpoints as needed
   ```

3. **Anthropic Claude API Key**: Add your Anthropic API key
   ```
   ANTHROPIC_API_KEY=your-anthropic-api-key-here
   ```

4. **PostgreSQL Configuration**: The database credentials are pre-configured but you can modify them if needed

### 3. Start the Services

```bash
docker-compose up -d
```

This will start:
- LiteLLM proxy server on port 4000
- PostgreSQL database on port 5432

### 4. Verify Installation

Check if the services are running:

```bash
docker-compose ps
```

Test the proxy health:

```bash
curl -H "Authorization: Bearer YOUR_MASTER_KEY" http://localhost:4000/health
```

## Usage

### Making API Calls

Once running, you can make OpenAI-compatible API calls to your proxy:

```bash
curl -X POST 'http://localhost:4000/chat/completions' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_MASTER_KEY' \
  -d '{
    "model": "gpt-4",
    "messages": [
      {
        "role": "user",
        "content": "Hello, how are you?"
      }
    ]
  }'
```

### Available Models

You can call any of these models:

**Azure OpenAI Models:**
- `gpt-4` (load balanced)
- `gpt-3.5-turbo` (load balanced)
- `gpt-4o`
- `gpt-4o-mini`
- `text-embedding-3-large`
- `text-embedding-3-small`

**Anthropic Claude Models:**
- `claude-3-haiku`
- `claude-3-sonnet`
- `claude-3-opus`
- `claude-3-5-sonnet`
- `claude-3-7-sonnet`

### Creating Virtual Keys

Generate virtual keys for different users or applications:

```bash
curl -X POST 'http://localhost:4000/key/generate' \
  -H 'Authorization: Bearer YOUR_MASTER_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "models": ["gpt-4", "claude-3-5-sonnet"],
    "max_budget": 100,
    "rpm_limit": 60
  }'
```

### Using with OpenAI SDK

```python
import openai

client = openai.OpenAI(
    api_key="sk-your-virtual-key-here",
    base_url="http://localhost:4000"
)

# Use Azure OpenAI GPT-4 (load balanced)
response = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.choices[0].message.content)
```

### Using with Anthropic SDK

```python
import anthropic

client = anthropic.Anthropic(
    api_key="sk-your-virtual-key-here",
    base_url="http://localhost:4000"
)

response = client.messages.create(
    model="claude-3-5-sonnet",
    max_tokens=1000,
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.content[0].text)
```

## Configuration

### Environment Variables

| Variable | Description | Setup Required |
|----------|-------------|----------------|
| `LITELLM_MASTER_KEY` | Master key for admin access | **YOU MUST SET THIS** |
| `LITELLM_SALT_KEY` | Salt key for encryption | Pre-configured |
| `POSTGRES_USER` | PostgreSQL username | `litellm_user` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `litellm_password_123` |
| `POSTGRES_DB` | PostgreSQL database name | `litellm_db` |
| `AZURE_API_KEY_*` | Azure OpenAI API keys | **YOU MUST SET THESE** |
| `AZURE_API_BASE_*` | Azure OpenAI endpoints | **YOU MUST SET THESE** |
| `ANTHROPIC_API_KEY` | Anthropic Claude API key | **YOU MUST SET THIS** |

### Load Balancing

The setup includes automatic load balancing for:

- **GPT-4**: Distributes requests between Central US and Australia East deployments
- **GPT-3.5-turbo**: Distributes requests between Central US and East US 2 deployments

This provides:
- Higher availability
- Better performance
- Automatic failover
- Distributed rate limits

## Monitoring and Logs

### View Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs litellm
docker-compose logs postgres

# Follow logs in real-time
docker-compose logs -f litellm
```

### Health Checks

- Health endpoint: `http://localhost:4000/health`
- Readiness endpoint: `http://localhost:4000/health/readiness`
- Liveness endpoint: `http://localhost:4000/health/liveliness`

### Admin UI

Access the admin UI at `http://localhost:4000/ui` (if enabled in configuration).

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Ensure PostgreSQL is running: `docker-compose ps`
   - Check database logs: `docker-compose logs postgres`
   - Verify environment variables in `.env`

2. **API Key Issues**
   - **Make sure you have configured your own API keys in the `.env` file**
   - Check that environment variables are referenced correctly in `config.yaml`
   - Verify your Azure OpenAI and Anthropic API keys are valid

3. **Model Not Found**
   - Verify model configuration in `config.yaml`
   - Check that the model name matches what you're requesting

4. **Permission Denied**
   - Use your configured master key from the `.env` file
   - Check that you're using the correct authorization header

### Reset Database

To reset the database and start fresh:

```bash
docker-compose down -v
docker-compose up -d
```

## Security Considerations

- **You must generate your own secure master key**
- **You must provide your own API keys for Azure OpenAI and Anthropic**
- Consider rotating API keys regularly in production
- Monitor usage and set appropriate rate limits
- Never commit API keys to version control

## Production Deployment

For production use:

1. Use a managed PostgreSQL service
2. Set up proper SSL certificates
3. Configure reverse proxy (nginx, traefik)
4. Set up monitoring and alerting
5. Use Docker secrets or external secret management
6. Configure backup strategies
7. Ensure all API keys are properly secured

## API Keys Setup Guide

### Required API Keys

You need to obtain and configure the following API keys:

#### 1. Master Key
- Generate a secure random string (minimum 32 characters)
- This will be used for admin access to your LiteLLM proxy
- Example: `sk-your-secure-master-key-here-32-chars-min`

#### 2. Azure OpenAI API Keys
- Sign up for Azure OpenAI service
- Create deployments for the models you want to use
- Get API keys and endpoints for each deployment
- Configure them in your `.env` file

#### 3. Anthropic Claude API Key
- Sign up for Anthropic Claude API access
- Get your API key from the Anthropic console
- Add it to your `.env` file

### Environment File Example

```env
# Master Key (REQUIRED - Generate your own)
LITELLM_MASTER_KEY=your-secure-master-key-here

# Azure OpenAI (REQUIRED - Add your own)
AZURE_API_KEY_CENTRAL_US=your-azure-api-key-here
AZURE_API_BASE_CENTRAL_US=https://your-resource.openai.azure.com/

# Anthropic (REQUIRED - Add your own)
ANTHROPIC_API_KEY=your-anthropic-api-key-here

# Database (Pre-configured, modify if needed)
POSTGRES_USER=litellm_user
POSTGRES_PASSWORD=litellm_password_123
POSTGRES_DB=litellm_db
```

## Support

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## License

This project is licensed under the MIT License - see the LICENSE file for details. 
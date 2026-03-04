# Cloud Deployment Guide

This guide provides instructions for deploying Khoj on cloud infrastructure (e.g., AWS, DigitalOcean, Google Cloud, Azure) using Docker Compose and Nginx as a reverse proxy.

## 1. Hardware Requirements

For a smooth experience, especially when running local models via Ollama, we recommend the following minimum specs:

| Component | Minimum | Recommended |
| :--- | :--- | :--- |
| **CPU** | 2 Cores | 4+ Cores |
| **RAM** | 8 GB | 16 GB+ |
| **Disk** | 20 GB | 50 GB+ (SSD) |
| **GPU** | Optional | NVIDIA T4 / A10G (for local inference speed) |

## 2. Server Setup

### Install Docker and Docker Compose
On most Linux distributions (Ubuntu/Debian):

```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable --now docker
```

### Deploy Khoj
1. Create a directory for Khoj:
   ```bash
   mkdir ~/khoj && cd ~/khoj
   ```
2. Download the `docker-compose.yml`:
   ```bash
   wget https://raw.githubusercontent.com/khoj-ai/khoj/master/docker-compose.yml
   ```
3. Configure your domain and secrets in the `environment` section of the `server` service:
   ```yaml
   - KHOJ_DOMAIN=khoj.yourdomain.com
   - KHOJ_DJANGO_SECRET_KEY=yoursupersecretkey
   - KHOJ_ADMIN_PASSWORD=strongpassword
   ```
4. Start the services:
   ```bash
   docker-compose up -d
   ```

## 3. Reverse Proxy with Nginx & SSL

To access Khoj securely via HTTPS, set up Nginx with Let's Encrypt.

### Install Nginx and Certbot
```bash
sudo apt-get install -y nginx certbot python3-certbot-nginx
```

### Configure Nginx
Create a new configuration file `/etc/nginx/sites-available/khoj`:

```nginx
server {
    server_name khoj.yourdomain.com;

    location / {
        proxy_pass http://localhost:42110;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Required for long-running AI requests
        proxy_read_timeout 300s;
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
    }
}
```

Enable the site and restart Nginx:
```bash
sudo ln -s /etc/nginx/sites-available/khoj /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
```

### Obtain SSL Certificate
```bash
sudo certbot --nginx -d khoj.yourdomain.com
```

## 4. Firewall Settings

Ensure the following ports are open in your cloud provider's firewall (Security Groups):

- **80 (HTTP)**: Redirection to HTTPS
- **443 (HTTPS)**: Encrypted traffic
- **22 (SSH)**: For remote administration

## 5. Using Ollama in the Cloud

If you want to use local models on your cloud instance:

1. Install Ollama on the host VM:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```
2. In your `docker-compose.yml`, ensure the `OPENAI_BASE_URL` is set to `http://host.docker.internal:11434/v1/`.
3. Ensure Docker can reach the host network (often enabled by default or requires adding `extra_hosts` to the service).

## 6. Verification

Access your instance at `https://khoj.yourdomain.com`. You should see the Khoj login page or the chat interface if anonymous mode is enabled.

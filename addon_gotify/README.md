# Gotify Server Add-on

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armv7 Architecture][armv7-shield]

[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/OptimusGREEN/ha-addons-dev/tree/main/addon_gotify)
[![Gotify Version](https://img.shields.io/badge/gotify-2.6.3-green.svg)](https://github.com/gotify/server)

A self-hosted push notification server for Home Assistant, powered by Gotify.

## About

Gotify is a simple server for sending and receiving messages in real-time via WebSocket. This Home Assistant add-on provides a complete notification solution that allows you to:

- Send push notifications to your devices via HTTP API
- Receive real-time notifications through WebSocket connections
- Manage applications and clients through an intuitive web interface
- Support for Android and iOS mobile clients
- Plugin system for extended functionality

## Features

- **Multi-architecture support**: Runs on AMD64, ARM64, and ARMv7 devices
- **Real-time messaging**: WebSocket-based instant message delivery
- **RESTful API**: Simple HTTP API for sending notifications
- **Web UI**: Clean, responsive web interface for management
- **Database persistence**: SQLite database for message and configuration storage
- **Application management**: Create and manage multiple applications with unique tokens
- **Client management**: Handle multiple client connections
- **User management**: Support for multiple users with configurable registration
- **Plugin support**: Extend functionality with custom plugins

## Installation

1. Add this repository to your Home Assistant Supervisor:
   [![Add Repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FOptimusGREEN%2Fha-addons-dev)

2. Navigate to **Supervisor** > **Add-on Store**
3. Find "Gotify Server" in the available add-ons
4. Click **Install**
5. Configure the add-on (see Configuration section below)
6. Click **Start**

## Configuration

### Basic Configuration

```yaml
port: 80
username: admin
password: admin
allow_registration: false
passstrength: 10
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `port` | int | `80` | Port for the Gotify server (1-65535) |
| `username` | string | `admin` | Default admin username |
| `password` | string | `admin` | Default admin password |
| `allow_registration` | bool | `false` | Allow new user registration |
| `passstrength` | int | `10` | Password strength requirement (1-10) |

### Important Notes

- **Change default credentials**: Always change the default username and password before first use
- **Port mapping**: The add-on maps the internal port to 8080 on your Home Assistant host
- **Data persistence**: All configuration, messages, and uploaded images are stored in `/data/`

## Usage

### Web Interface

1. After starting the add-on, access the web interface at: `http://[HOME_ASSISTANT_IP]:8080`
2. Log in with your configured username and password
3. Create applications to get API tokens for sending notifications

### Sending Notifications

#### Using Home Assistant

Create a RESTful notification service in your `configuration.yaml`:

```yaml
notify:
  - name: gotify
    platform: rest
    resource: http://localhost:8080/message
    method: POST_JSON
    headers:
      X-Gotify-Key: YOUR_APPLICATION_TOKEN
    data:
      title: "Home Assistant"
      message: "{{ message }}"
      priority: 5
```

Then use it in automations:

```yaml
service: notify.gotify
data:
  message: "Motion detected in living room"
  title: "Security Alert"
```

#### Using cURL

```bash
curl -X POST "http://your-ha-ip:8080/message" \
  -H "X-Gotify-Key: YOUR_APPLICATION_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Notification",
    "message": "This is a test message",
    "priority": 5
  }'
```

### Mobile Apps

Download the official Gotify mobile apps:
- [Android (Google Play)](https://play.google.com/store/apps/details?id=com.github.gotify)
- [Android (F-Droid)](https://f-droid.org/packages/com.github.gotify/)
- [iOS (App Store)](https://apps.apple.com/app/gotify/id1514102467)

Configure the apps with:
- **Server URL**: `http://[HOME_ASSISTANT_IP]:8080`
- **Client Token**: Generated from the Gotify web interface

## API Reference

### Key Endpoints

- `GET /health` - Health check endpoint
- `POST /message` - Send a message
- `GET /message` - Retrieve messages
- `DELETE /message/{id}` - Delete a message
- `GET /application` - List applications
- `POST /application` - Create application
- `GET /client` - List clients
- `POST /client` - Create client

### Message Priority Levels

- `0` - Low priority
- `1-3` - Normal priority
- `4-7` - High priority
- `8-10` - Emergency priority

## Troubleshooting

### Common Issues

**Add-on won't start**
- Check the logs for specific error messages
- Ensure the configured port is not in use by another service
- Verify Home Assistant has sufficient resources

**Can't access web interface**
- Confirm the add-on is running and healthy
- Check if port 8080 is accessible on your Home Assistant host
- Verify firewall settings if accessing from external network

**Notifications not received**
- Verify the application token is correct
- Check the Gotify logs for API request errors
- Ensure the mobile app is configured with the correct server URL and client token

### Logs

View add-on logs through:
- **Supervisor** > **Gotify Server** > **Log** tab
- Or use the Home Assistant CLI: `ha addons logs addon_gotify`

## Data Persistence

The add-on stores data in the following locations:
- **Database**: `/data/gotify.db` (SQLite)
- **Configuration**: `/data/config.yml`
- **Images**: `/data/images/` (uploaded application icons)
- **Plugins**: `/data/plugins/` (custom plugins)

All data persists across add-on restarts and updates.

## Advanced Configuration

For advanced users, you can modify the generated `/data/config.yml` file directly. However, note that manual changes will be overwritten when the add-on restarts unless you modify the configuration through the add-on options.

## Support

Having trouble with the add-on? Here are your options:

- [GitHub Issues][issue] - Report bugs or request features
- [Home Assistant Community Forum][forum] - General discussion and support
- [Home Assistant Discord][discord-ha] - Real-time chat support
- [Reddit r/homeassistant][reddit] - Community discussions

## Contributing

This add-on is open source! Contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This add-on is licensed under the MIT License. Gotify server is licensed under the MIT License.

## Changelog

### Version 0.1.0
- Updated to Gotify 2.6.3 (latest version)
- Added multi-architecture support (AMD64, ARM64, ARMv7)
- Enhanced configuration options
- Improved error handling and logging
- Added plugin and image upload directory support
- Better security with proper user permissions

### Version 0.0.10
- Initial working version using Gotify 2.4.0

---

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[discord-ha]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/OptimusGREEN/ha-addons-dev/issues
[reddit]: https://reddit.com/r/homeassistant
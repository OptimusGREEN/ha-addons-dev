# Gotify Server Add-on

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armv7 Architecture][armv7-shield]

A self-hosted push notification server (Gotify) for Home Assistant.

## About

Gotify is a simple server for sending and receiving messages in real-time per WebSocket. This add-on allows you to run your own notification server directly within Home Assistant.

## Installation

1. Add this repository to your Home Assistant Supervisor add-on store
2. Install the "Gotify Server" add-on
3. Configure the add-on options
4. Start the add-on

## Configuration

Add-on configuration:

```yaml
port: 80
username: admin
password: admin
allow_registration: false
```

### Option: `port`

The port on which the Gotify server will listen.

### Option: `username`

The default admin username for Gotify.

### Option: `password`

The default admin password for Gotify.

### Option: `allow_registration`

Whether to allow new user registration.

## Usage

1. After starting the add-on, access the Gotify web interface
2. Create applications and get their tokens
3. Use the tokens to send notifications via HTTP POST requests

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Community Add-ons Discord chat server][discord] for add-on support and feature requests.
- The [Home Assistant Discord chat server][discord-ha] for general Home Assistant discussions and questions.
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

You could also [open an issue here][issue] GitHub.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[discord-ha]: https://discord.gg/c5DvZ4e
[discord]: https://discord.me/hassioaddons
[forum]: https://community.home-assistant.io/t/repository-community-hass-io-add-ons/24705?u=frenck
[issue]: https://github.com/OptimusGREEN/haddons/issues
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/OptimusGREEN/haddons
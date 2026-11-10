<p align="center">
  <a href="https://payload.tf">
    <img src="https://payload.tf/logo.svg" alt="payload.tf logo" width="175" height="175">
  </a>
</p>

<h1 align="center">payload-logs-plugin</h1>

<p align="center">Payload's webhook plugin to send logs previews to channels</p>

![Downloads](https://img.shields.io/github/downloads/payload-bot/payload-logs-plugin/total?style=flat-square) ![Last commit](https://img.shields.io/github/last-commit/payload-bot/payload-logs-plugin?style=flat-square) ![Open issues](https://img.shields.io/github/issues/payload-bot/payload-logs-plugin?style=flat-square) ![Closed issues](https://img.shields.io/github/issues-closed/payload-bot/payload-logs-plugin?style=flat-square) ![Size](https://img.shields.io/github/repo-size/payload-bot/payload-logs-plugin?style=flat-square) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/payload-bot/payload-logs-plugin/Compile%20with%20SourceMod?style=flat-square)

## Description

SourceMod plugin to allow sending logs.tf previews to a Discord channel through the Payload API.

## Requirements

-   Sourcemod and Metamod
-   SteamWorks and logstf .inc files (included in releases)

## Installation

1. Grab the latest release from the release page and unzip it in your sourcemod folder.
2. Restart the server, or type `sm plugins load payload-webhook` in the console to load the plugin.
3. Get a webhook token from Payload (use the `/webhooks` commands in DMs / in a Discord channel)
4. Set the convar `sm_payload_token` to the token gained above

You're set! You should now recieve logs.tf previews when logs.tf uploads a log successfully. If you need to see your token again, there is a `show` command.

If you wish to disable the previews, you can set the `sm_payload_send` convar to `0`. To test that the webhook works, you may use the command `sm_payload_test`.

# Issues, Questions

Any issues or questions should be posted on GitHub issues, where they can be more easily tracked. Feature requests are welcome!

# Support this Project

You may back me on my [Patreon](https://www.patreon.com/c43721). Direct sponsorship of this project can be discussed on Discord (24#7644) or by another medium.

# Contributing

Before contributing, please make sure no one else has stated against your proposal. Otherwise, make a Pull Request detailing your proposal and any relevant code changes.

# Useful Links

-   [Main Page](https://payload.tf/)
-   [Invite](https://payload.tf/invite)
-   [Discord](https://payload.tf/discord)
-   [Translation](https://crowdin.com/project/payload)

# License

This project is [MIT licensed](LICENSE).

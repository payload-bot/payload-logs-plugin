#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <anyhttp>
#pragma newdecls required
#pragma semicolon 1

char g_sWebhookToken[128];

Handle g_hCvarWebhookToken;
Handle g_hCvarSendLogs;
Handle g_hCvarApiUrl;

public Plugin myinfo =
{
	name = "payload-webhook",
	author = "24",
	description = "Plugin to send logs.tf previews to a Discord channel.",
	version = "1.0.0",
	url = "https://github.com/payload-bot/payload-logs-plugin"
};

public void OnPluginStart()
{
	g_hCvarWebhookToken = CreateConVar("payload_webhook_token", "", "Channel to post rendered logs to", FCVAR_NEVER_AS_STRING);
	g_hCvarSendLogs = CreateConVar("payload_send", "true", "Send the logs or not", FCVAR_NOTIFY);
	g_hCvarApiUrl = CreateConVar("payload_apiurl", "https://api.payload.tf/api/webhook/v1/logs", "Payload API url" ,FCVAR_NEVER_AS_STRING);

    PrintToChatAll("[Payload] Plugin loaded.");
}

public void LogUploaded(bool success, const char[] logid, const char[] url) 
{
    if (success) {
		bool sendRequest = GetConVarBool(g_hCvarSendLogs);
		if (sendRequest == false) 
			return;

		if (strlen(g_sWebhookToken) == 0) 
			return;

		char BaseUrl[64];
		char FullUrl[128];
		GetConVarString(g_hCvarApiUrl, BaseUrl, sizeof(BaseUrl));
		Format(FullUrl, sizeof(FullUrl), "%s/webhook/v1/logs");

        PrintToChatAll("[Payload] Rendering logs preview...");

		SendRequest(logid, FullUrl);
    }
}

SendRequest(const char[] logid, const char[] fullApiUrl)
{
	AnyHttpForm form = AnyHttp.CreatePost(fullApiUrl);
	
	form.PutString("logid", logid);
	form.PutString("token", g_sWebhookToken);
	form.PutString("requester", "Payload Log Plugin v1.0.0");

	form.Send(SendRequest_Complete);
}

SendRequest_Complete(bool success, const char[] contents, int metadata) 
{
	if(success)
	{
		PrintToChatAll("[Payload] Log preview uploaded");
	}
}
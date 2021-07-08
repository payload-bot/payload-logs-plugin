#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <anyhttp>
#include <logstf>
#pragma newdecls required
#pragma semicolon 1

#define VERSION "1.0.0"

char g_sWebhookToken[128];

ConVar g_hCvarWebhookToken;
ConVar g_hCvarSendLogs;
ConVar g_hCvarApiUrl;

public Plugin myinfo =
{
	name = "payload-webhook",
	author = "24, Bv",
	description = "Plugin to send logs.tf previews to a Discord channel.",
	version = VERSION,
	url = "https://github.com/payload-bot/payload-logs-plugin"
};

public void OnPluginStart()
{
	g_hCvarWebhookToken = CreateConVar("payload_webhook_token", "", "Channel to post rendered logs to", FCVAR_PROTECTED);
	g_hCvarApiUrl = CreateConVar("payload_apiurl", "https://api.payload.tf/api", "Payload API url", FCVAR_PROTECTED);

	g_hCvarSendLogs = CreateConVar("payload_send", "1", "Send the logs or not", FCVAR_NOTIFY);
	
	RegConsoleCmd("payload_testupload", testUpload, "Debug function to simulate an uploaded log");

	PrintToChatAll("[Payload] Plugin loaded.");
	PrintToServer("[Payload] Plugin loaded.");
}

public Action testUpload(int client, int args){
	LogUploaded(true, "2961236", "https://logs.tf/2961236");
	return Plugin_Handled;
}

public int LogUploaded(bool success, const char[] logid, const char[] url) 
{
    if (success) {
		bool sendRequest = GetConVarBool(g_hCvarSendLogs);
		if (sendRequest == false) 
			return;

		// Make sure we update the string value of the token
		GetConVarString(g_hCvarWebhookToken, g_sWebhookToken, sizeof(g_sWebhookToken));
		if (strlen(g_sWebhookToken) == 0) 
			return;

		char BaseUrl[64];
		char FullUrl[128];

		// Store convar for the api Url in BaseUrl
		GetConVarString(g_hCvarApiUrl, BaseUrl, sizeof(BaseUrl));

		// Complete the baseUrl
		Format(FullUrl, sizeof(FullUrl), "%s/webhook/v1/internal/logs", BaseUrl);

		// For debug purposes:
		PrintToServer("FullURL: %s", FullUrl);
		PrintToServer("[Payload] Rendering logs preview...");
		PrintToChatAll("[Payload] Rendering logs preview...");

		SendRequest(logid, FullUrl);
    }
}

public void SendRequest(const char[] logid, const char[] fullApiUrl)
{
	AnyHttpForm form = AnyHttp.CreatePost(fullApiUrl);
	
	form.PutString("logsId", logid);
	form.PutString("token", g_sWebhookToken);
	form.PutString("requester", VERSION);

	form.Send(SendRequest_Complete);
}

public void SendRequest_Complete(bool success, const char[] contents, int metadata) 
{
	if (success)
	{
		PrintToChatAll("[Payload] Log preview uploaded");
		PrintToServer("[Payload] Log preview uploaded");
	}
	else 
	{
		PrintToChatAll("[Payload] Unable to post logs preview");
		PrintToServer("[Payload] Unable to post logs preview");
	}
}
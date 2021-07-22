#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <logstf>
#include <SteamWorks>
#pragma newdecls required
#pragma semicolon 1

#define VERSION "1.1.0"

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
	g_hCvarWebhookToken = CreateConVar("sm_payload_token", "", "Channel to post rendered logs to", FCVAR_PROTECTED);
	g_hCvarApiUrl = CreateConVar("sm_payload_apiurl", "https://api.payload.tf/api", "Payload API url", FCVAR_PROTECTED);

	g_hCvarSendLogs = CreateConVar("sm_payload_send", "1", "Send the logs or not", FCVAR_NOTIFY);
	
	RegConsoleCmd("sm_payload_test", TestUpload, "Debug function to simulate an uploaded log");

	PrintToChatAll("[Payload] Plugin loaded.");
	PrintToServer("[Payload] Plugin loaded.");
}

public Action TestUpload(int client, int args)
{
	bool sendRequest = GetConVarBool(g_hCvarSendLogs);
	if (sendRequest == false) 
	{
		PrintToChatAll("[Payload] sm_payload_send is 0, not sending requests.");
		PrintToServer("[Payload] sm_payload_send is 0, not sending requests.");
		
		return Plugin_Handled;
	}

	// Make sure we update the string value of the token
	GetConVarString(g_hCvarWebhookToken, g_sWebhookToken, sizeof(g_sWebhookToken));

	if (strlen(g_sWebhookToken) == 0) 
		return Plugin_Handled;

	char BaseUrl[64];
	char FullUrl[128];

	// Store convar for the api Url in BaseUrl
	GetConVarString(g_hCvarApiUrl, BaseUrl, sizeof(BaseUrl));

	// Complete the baseUrl
	Format(FullUrl, sizeof(FullUrl), "%s/webhooks/v1/internal/test", BaseUrl);

	PrintToServer("[Payload] Testing webhook...");
	PrintToChatAll("[Payload] Testing webhook...");

	SendTestRequest(FullUrl);
		
	return Plugin_Handled;
}

public int LogUploaded(bool success, const char[] logid, const char[] url) 
{
    if (success) 
	{
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
		Format(FullUrl, sizeof(FullUrl), "%s/webhooks/v1/internal/logs", BaseUrl);

		// For debug purposes:
		PrintToServer("FullURL: %s", FullUrl);
		PrintToServer("[Payload] Rendering logs preview...");
		PrintToChatAll("[Payload] Rendering logs preview...");

		SendRequest(logid, FullUrl);
    }
}

public void SendRequest(const char[] logid, const char[] fullApiUrl)
{
	Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, fullApiUrl);

	// Headers
	SteamWorks_SetHTTPRequestHeaderValue(hRequest, "Content-Type", "x-www-form-urlencoded");
	SteamWorks_SetHTTPRequestHeaderValue(hRequest, "Authorization", g_sWebhookToken);

	// Body
	SteamWorks_SetHTTPRequestGetOrPostParameter(hRequest, "logsId", logid);
	
	SteamWorks_SetHTTPCallbacks(hRequest, OnSteamWorksHTTPComplete);
	SteamWorks_SendHTTPRequest(hRequest);
}

public void SendTestRequest(const char[] fullApiUrl)
{
	Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, fullApiUrl);

	// Headers
	SteamWorks_SetHTTPRequestHeaderValue(hRequest, "Content-Type", "x-www-form-urlencoded");
	SteamWorks_SetHTTPRequestHeaderValue(hRequest, "Authorization", g_sWebhookToken);

	SteamWorks_SetHTTPCallbacks(hRequest, TestWebhookComplete);
	SteamWorks_SendHTTPRequest(hRequest);
}

public int OnSteamWorksHTTPComplete(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data) 
{
	if (bFailure) 
	{
		PrintToChatAll("[Payload] Unable to post logs preview.");
		PrintToServer("[Payload] Unable to post logs preview.");
		PrintToServer("Status Code: %i", eStatusCode);
	}
	else
	{
		PrintToChatAll("[Payload] Log preview uploaded.");
		PrintToServer("[Payload] Log preview uploaded.");
	}
	
	delete hRequest;
}

public int TestWebhookComplete(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data) 
{
	if (bFailure) 
	{
		PrintToChatAll("[Payload] Unable to test webhook.");
		PrintToServer("[Payload] Unable to test preview.");
		PrintToServer("Status Code: %i", eStatusCode);
	}
	else
	{
		PrintToChatAll("[Payload] Webhook test successful.");
		PrintToServer("[Payload] Webhook test successful.");
	}
	
	delete hRequest;
}
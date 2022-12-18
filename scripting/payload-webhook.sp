#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <logstf>
#include <demostf>
#include <SteamWorks>
#pragma newdecls required
#pragma semicolon 1

#define VERSION "1.4.0"

char g_sWebhookToken[128];
bool g_bDemostfLoaded;
char g_sLogId[128];
char g_sDemoId[128];

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

public void OnAllPluginsLoaded()
{
	IsDemosTfPresent();
}

public bool IsDemosTfPresent()
{
	Handle h_demostf = FindPluginByFile("demostf.smx"); 
	if (h_demostf != null && GetPluginStatus(h_demostf) == Plugin_Running)
	{
		char version[64];
		GetPluginInfo(h_demostf, PlInfo_Version, version, sizeof(version));
		
		// Crude way of making sure we're running a version newer than 0.2
		if (strcmp(version, "0.2") > 0) {
			g_bDemostfLoaded = true;
			PrintToServer("[Payload] Demos.tf plugin detected.");
			return true;
		}
	} 
	else
	{
		g_bDemostfLoaded = false;
		return false;
	}
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
	Format(FullUrl, sizeof(FullUrl), "%s/webhooks/test", BaseUrl);

	PrintToServer("[Payload] Testing webhook...");
	PrintToChatAll("[Payload] Testing webhook...");

	SendTestRequest(FullUrl);
		
	return Plugin_Handled;
}

public int LogUploaded(bool success, const char[] logid, const char[] url) 
{
    if (success) 
	{
		strcopy(g_sLogId, sizeof(g_sLogId), logid);
		// Prepare the request if we have received the demoid or if the plugin isn't loaded
		if (!StrEqual(g_sDemoId, "") || !g_bDemostfLoaded)
			PrepareRequest();
    }
}

public int DemoUploaded(bool success, const char[] demoid, const char[] url)
{
	if (success)
	{
		strcopy(g_sDemoId, sizeof(g_sDemoId), demoid);
	}
	// Prepare the request if we have received the logid
	if (!StrEqual(g_sLogId, ""))
		PrepareRequest();
}

public void PrepareRequest()
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
	Format(FullUrl, sizeof(FullUrl), "%s/webhooks/logs", BaseUrl);

	// For debug purposes:
	PrintToServer("FullURL: %s", FullUrl);
	PrintToServer("[Payload] Rendering logs preview...");
	PrintToChatAll("[Payload] Rendering logs preview...");

	SendRequest(FullUrl);
}

public void SendRequest(const char[] fullApiUrl)
{
	Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodPOST, fullApiUrl);

	// Headers
	SteamWorks_SetHTTPRequestHeaderValue(hRequest, "Content-Type", "x-www-form-urlencoded");
	SteamWorks_SetHTTPRequestHeaderValue(hRequest, "Authorization", g_sWebhookToken);

	// Body
	SteamWorks_SetHTTPRequestGetOrPostParameter(hRequest, "logsId", g_sLogId);

	// Only add parameter if the demos.tf plugin was loaded and returned an id
	if (g_bDemostfLoaded && !StrEqual(g_sDemoId, ""))
		SteamWorks_SetHTTPRequestGetOrPostParameter(hRequest, "demosId", g_sDemoId);

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
	// Clear the ids
	g_sDemoId = "";
	g_sLogId = "";

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

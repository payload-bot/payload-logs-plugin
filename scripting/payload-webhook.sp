#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <anyhttp>
#include <logstf>
#pragma newdecls required
#pragma semicolon 1

char g_sWebhookToken[128];

ConVar g_hCvarWebhookToken;
ConVar g_hCvarSendLogs;
ConVar g_hCvarApiUrl;

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
	g_hCvarWebhookToken = CreateConVar("payload_webhook_token", "", "Channel to post rendered logs to", FCVAR_PROTECTED);
	g_hCvarSendLogs = CreateConVar("payload_send", "1", "Send the logs or not", FCVAR_NOTIFY);
	g_hCvarApiUrl = CreateConVar("payload_apiurl", "https://api.payload.tf/api", "Payload API url",FCVAR_PROTECTED);

	
	RegConsoleCmd("testUpload",testUpload,"Debug function to simulate an uploaded log");


	PrintToChatAll("[Payload] Plugin loaded.");
	PrintToServer("[Payload] Plugin loaded.");
}

public Action testUpload(int client, int args){
	LogUploaded(true,"2961236","https://logs.tf/2961236");
	return Plugin_Handled;
}

public int LogUploaded(bool success, const char[] logid, const char[] url) 
{
    if (success) {
		bool sendRequest = GetConVarBool(g_hCvarSendLogs);
		if (sendRequest == false) 
			return;
		//Make sure we update the string value of the token
		GetConVarString(g_hCvarWebhookToken,g_sWebhookToken,sizeof(g_sWebhookToken));
		if (strlen(g_sWebhookToken) == 0) 
			return;

		char BaseUrl[64];
		char FullUrl[128];
		//Store convar for the api Url in BaseUrl
		GetConVarString(g_hCvarApiUrl, BaseUrl, sizeof(BaseUrl));
		//Complete the baseUrl
		Format(FullUrl, sizeof(FullUrl), "%s/webhook/v1/logs",BaseUrl);
		//For debug purposes:
		PrintToServer("FullURL: %s",FullUrl);
		PrintToServer("[Payload] Rendering logs preview...");
		PrintToChatAll("[Payload] Rendering logs preview...");

		SendRequest(logid, FullUrl);
    }
}

public void SendRequest(const char[] logid, const char[] fullApiUrl)
{
	AnyHttpForm form = AnyHttp.CreatePost(fullApiUrl);
	
	form.PutString("logid", logid);
	form.PutString("token", g_sWebhookToken);
	form.PutString("requester", "Payload Log Plugin v1.0.0");

	form.Send(SendRequest_Complete);
}

public void SendRequest_Complete(bool success, const char[] contents, int metadata) 
{
	if(success)
	{
		PrintToChatAll("[Payload] Log preview uploaded");
		PrintToServer("[Payload] Log preview uploaded");
	}
}
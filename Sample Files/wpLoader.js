var clientIsOnline = false;
var clientIsOnlineXml;
var clientUsesProxy;
var clientProxyString;
var clientProxyUser;
var clientProxyPassword;
var clientAppDataFolder;
var appPath;
var wpPath;
var xmlPath;
var xslPath;
var xmlPersonal;
var nodeSettings;
var nodeLanguage;

function debugAlert(msg) {
	getNotification(false).text = msg;
	displayNotification();
}

var classHide = 'wuppdi';
var regHide = /\s*wuppdi/;

function showWait() {
	var c = Working.className;
	Working.className = (c == classHide)?"doShow" : c + " doShow";
}

function hideWait() {
	var regShow = /\s*doShow/;
	var c = Working.className;
	c = (c)?c.replace(regShow, "") : "";
	Working.className = (c == "")?classHide : c;
}

function getLangString(name) {
    var node;

    node = nodeLanguage.selectSingleNode('*[@name="' + name + '"]');
    if (node != null) {
        return node.text
    }
}

function setElementText(elementId, textId) {
    var el;

    el = document.getElementById(elementId);
    if (el != null) {
      el.innerHTML = getLangString(textId);
    }
}

function initializeWP() {
	try {
		loadSettings();
		initializeLanguageData();

		registerNotificationLinks();
		registerProjectLinks();
		registerRssLinks();
		registerOrLinks();

		loadMenus();
		loadProjectsList();
		loadMyFavoritesList();
		updatePageLayout();

		menuGuidCall('');
	} catch(e) {
		debugAlert('initializeWP: ' + e.message);
	}
	hideWait();
}

function loadSettings() {
	try {
		// initialize application variables
		clientIsOnline = true;
		clientUsesProxy = external.Application.UsesProxy;
		clientProxyString = external.Application.ProxyString;
		clientUserAgentString = external.Application.UserAgent;
		clientAppDataFolder = external.Application.AppDataFolder;
		clientProxyUser = '';
		clientProxyPassword = '';
		
		// determine path variables
		appPath = external.Application.ExeName;
		appPath = appPath.substr(0, appPath.lastIndexOf('\\'));
		appPath = appPath.substr(0, appPath.lastIndexOf('\\') + 1);
		wpPath = appPath + 'WelcomePage\\';
		xmlPath = wpPath + 'XML\\';
		xslPath = wpPath + 'XSL\\';
		
		// load settings
		xmlPersonal = loadXmlDocSafe(clientAppDataFolder + '\\welcomePage.xml');
		nodeSettings = getSubNode(xmlPersonal.documentElement, 'settingsEx');
	} catch(e) {
		debugAlert("loadSettings: " + e.message);
	}
}

function initializeLanguageData() {
	// load language data
	nodeLanguage = loadXmlDocSafe(xslPath + 'languageStrings.xsl').documentElement;
	
	setElementText('pageCopyright', 'pageCopyright');
	setElementText('pageReportPiracy', 'pageReportPiracy');
	setElementText('pageLegalNotices', 'pageLegalNotices');
	setElementText('pagePrivacyPolicy', 'pagePrivacyPolicy');
	setElementText('Working', 'pageWorking');
}

function savePersonalSettings()
{
	var settingsFile;

	settingsFile = clientAppDataFolder + '\\welcomePage.xml';
	xmlPersonal.save(settingsFile);
}

function updatePageLayout() {
	Content.style.pixelHeight = document.body.clientHeight - 185;
	ContentArea.style.pixelHeight = Content.style.pixelHeight - ContentHeader.style.pixelHeight - 24;
}

function clearElementContent(element) {
	while (element.childNodes.length != 0)
	{
		element.removeChild(element.childNodes[0]);
	}
}

function setClientIsOnline(e) {
	if (e != clientIsOnline) {
		if (!e) {
            try {
    			clientIsOnlineXml = getNotification(true);
	    		clientIsOnlineXml.text = getLangString('stateOffline');
		    	displayNotification();
            } catch(e) {
                alert(e.message);
            }
		} else {
			removeNotification(clientIsOnlineXml);
		}
		clientIsOnline = e;
	}
}

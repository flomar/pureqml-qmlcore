Activity {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.topMargin: 70;
	name: "root";

	VideoPlayer {
		id: videoPlayer;
		anchors.fill: renderer;
		source: "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
		autoPlay: true;
	}

	ColorTheme { id: colorTheme; }
	Protocol { id: protocol; enabled: true; }

	MouseArea {
		anchors.fill: renderer;
		hoverEnabled: !parent.hasAnyActiveChild;

		onMouseXChanged: { 
			if (this.hoverEnabled)
				infoPanel.active = true;
		}

		onMouseYChanged: {
			if (this.hoverEnabled) 
				infoPanel.active = true;
		}
	}

	InfoPanel {
		id: infoPanel;
		height: 250;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		volume: videoPlayer.volume;

		onMenuCalled:		{ mainMenu.start(); }
		onVolumeUpdated(v):	{ videoPlayer.volume = v; }
	}

	Item {
		id: activityArea;
		anchors.top: topMenu.bottom;
		anchors.bottom: infoPanel.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.topMargin: 2;
		anchors.leftMargin: 101;
	}

	ChannelsPanel {
		id: channelsPanel;
		protocol: parent.protocol;
		anchors.fill: activityArea;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	EPGPanel {
		id: epgPanel;
		anchors.fill: activityArea;

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	VODPanel {
		id: vodPanel;
		anchors.fill: activityArea;

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	SettingsPanel {
		id: settings;
		anchors.fill: activityArea;
		protocol: parent.protocol;

		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	SearchPanel {
		id: searchPanel;
		protocol: parent.protocol;
		anchors.fill: activityArea;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onUpPressed: { mainMenu.forceActiveFocus(); }
	}

	TopMenu {
		id: topMenu;
		active: infoPanel.active || parent.hasAnyActiveChild;

		onSearchRequest(request): {
			this.active = false;
			infoPanel.active = false;
			searchPanel.start();
			searchPanel.searchRequest = request;
			searchPanel.search();
		}

		onCloseAll: {
			infoPanel.active = !infoPanel.active;
			mainWindow.closeAll();
		}
	}

	MainMenu {
		id: mainMenu;
		anchors.left: renderer.left;
		anchors.top: topMenu.bottom;
		anchors.bottom: infoPanel.top;
		anchors.topMargin: 2;
		active: infoPanel.active || parent.hasAnyActiveChild;

		onDownPressed: {
			if (channelsPanel.active)
				channelsPanel.forceActiveFocus();
			else if (epgPanel.active)
				epgPanel.forceActiveFocus();
			else if (vodPanel.active)
				vodPanel.forceActiveFocus();
			else if (settings.active)
				settings.forceActiveFocus();
			else
				infoPanel.forceActiveFocus();
		}

		onOptionChoosed(idx): {
			if (idx == 0)
				channelsPanel.start();
			else if (idx == 1)
				epgPanel.start();
			else if (idx == 2)
				vodPanel.start();
			else if (idx == 3)
				settings.start();
		}
	}

	MuteIcon { mute: videoPlayer.volume <= 0; }

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		videoPlayer.source = channel.url;
		infoPanel.fillChannelInfo(channel);
		infoPanel.active = true;
	}

	onUpPressed:		{ videoPlayer.volumeUp(); }
	onDownPressed:		{ videoPlayer.volumeDown(); }
	onRedPressed:		{ vodPanel.start(); }
	onBluePressed:		{ infoPanel.active = true; }
	onGreenPressed:		{ channelsPanel.start(); }
	onYellowPressed:	{ epgPanel.start(); }
}

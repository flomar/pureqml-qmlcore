Activity {
	id: mainWindow;
	property bool portraitOrientation: false;
	anchors.fill: renderer;
	name: "root";

	Protocol		{ id: protocol; enabled: true; }
	ColorTheme		{ id: colorTheme; }

	LocalStorage {
		id: choosenProvider;
		property string choosed: false;
		name: "choosenProvider";

		onCompleted: {
			this.read();
			this.choosed = choosenProvider.value;
			if (this.choosed)
				categoriesModel.provider = choosenProvider.value;
			else
				settingsPanel.active = true;
		}
	}

	LocalStorage {
		id: lastChannel;
		property string source;
		name: "lastChannel";

		onCompleted: {
			this.read();
			var channelInfo = lastChannel.value ? JSON.parse(lastChannel.value): {};
			if (channelInfo) {
				channelInfo.program = {};
				mainWindow.switchToChannel(channelInfo);
				if (channelInfo.categoryIndex)
					channelsPanel.setCategoryIndex(channelInfo.categoryIndex);
			}
		}
	}

	ProvidersModel {
		id: providersModel;
		protocol: protocol;

		onDefaultProviderChanged: {
			if (!choosenProvider.choosed && value) {
				categoriesModel.provider = value;
				choosenProvider.choosed = true;
			}
		}
	}

	CategoriesModel	{
		id: categoriesModel;
		protocol: protocol;

		onModelUpdated: { channelsPanel.reset(); }
	}

	EPGModel { id: epgModel; protocol: protocol; }

	Timer {
		id: updateTimer;
		interval: 24 * 3600 * 1000;
		repeat: true;

		onTriggered: {
			categoriesModel.update();
			epgModel.update();
		}
	}

	Background {
		anchors.top: settingButton.bottom;
		anchors.bottom: renderer.bottom;
		anchors.left: renderer.left;
		anchors.right: renderer.right;
	}

	BetaLink {
		anchors.top: parent.top;
		anchors.left: channelsPanel.currentCategory.right;
		anchors.right: searchInput.left;
		anchors.rightMargin: 100;
		anchors.leftMargin: 100;
		visible: !renderer.fullscreen;
	}

	VideoPlayer {
		id: videoPlayer;
		anchors.top: mainWindow.top;
		anchors.right: mainWindow.right;
		anchors.rightMargin: renderer.fullscreen ? 0 : 10;
		anchors.topMargin: renderer.fullscreen ? 0 : 60;
		width: renderer.fullscreen ? renderer.width : 
			(mainWindow.portraitOrientation ? parent.width - 20 : parent.width / 2);
		height: renderer.fullscreen ? renderer.height : width / 3 * 2;
		source: lastChannel.source ? lastChannel.source : "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
		visible: !hintText.visible;
		autoPlay: true;

		Preloader {
			anchors.centerIn: videoPlayer;
			visible: !videoPlayer.ready;
		}
	}

	Controls {
		id: controls;
		anchors.fill: videoPlayer;
		visible: videoPlayer.visible;
		showMute: videoPlayer.volume <= 0.05;
		volume: videoPlayer.volume;
		paused: videoPlayer.paused;

		onPauseActivated: 		{ videoPlayer.pause(); }
		onPlayActivated: 		{ videoPlayer.play(); }
		onFullscreenToggled:	{ renderer.fullscreen = !renderer.fullscreen; }
		onVolumeUpdated(value):	{ videoPlayer.volume = value; }
	}

	ProgramInfo {
		id: programInfo;
		height: parent.portraitOrientation ? videoPlayer.height / 2 : parent.height - videoPlayer.height - 20;
		anchors.left: videoPlayer.left;
		anchors.right: videoPlayer.right;
		anchors.top: videoPlayer.bottom;
		anchors.margins: 10;
		visible: !hintText.visible && !renderer.fullscreen;
	}

	ChannelsPanel {
		id: channelsPanel;
		width: parent.portraitOrientation ? parent.width : parent.width - videoPlayer.width - 20;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.margins: 10;
		spacing: parent.portraitOrientation ? videoPlayer.height + programInfo.height + 20 : 0;
		visible: !hintText.visible && !renderer.fullscreen;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
		onProgramSelected(program):	{ programInfo.setProgram(program); }
		onChannelSelected(channel): { programInfo.setChannel(channel); }
	}

	Text {
		id: hintText;
		anchors.top: parent.top;
		anchors.left: parent.left;
		height: renderer.height;
		width: renderer.width;
		verticalAlignment: Text.AlignVCenter;
		horizontalAlignment: Text.AlignHCenter;
		color: colorTheme.disabledTextColor;
		wrap: true;
		text: categoriesModel.count ? (!choosenProvider.choosed ? "Не указан провайдер" : "") : "Произошло что-то странное, похоже каналы выбранного провайдера вам недоступны, если вы все же к нему подключены и считаете, что произошла ошибка, пожалуйста, напишите нам в форме обратной связи, мы все исправим.";
		font.pointSize: 32;
		visible: !choosenProvider.choosed || !categoriesModel.count;
	}

	SearchPanel {
		id: searchPanel;
		searchRequest: searchInput.text;

		onChannelSwitch(channel): {
			channelsPanel.setCategory(channel.genre);
			mainWindow.switchToChannel(channel);
		}
	}

	TextInput {
		id: searchInput;
		anchors.right: searchButton.left;
		anchors.rightMargin: 20;
		anchors.verticalCenter: settingButton.verticalCenter;
		visible: !renderer.fullscreen;

		onSelectPressed: { searchPanel.startSearch(searchInput.text); }
	}

	SettingsPanel {
		id: settingsPanel;

		onChoosed(provider): {
			choosenProvider.value = provider;
			categoriesModel.provider = provider;
			choosenProvider.choosed = provider;
		}

		onAddDialogCalled:		{ addProviderDialog.start(); }
		onFeedBackDialogCalled:	{ feedBackDialog.start(); }
	}

	TopMenuButton {
		id: aboutButton;
		anchors.top: parent.top;
		anchors.right: videoPlayer.right;
		visible: !renderer.fullscreen && !parent.hasAnyActiveChild;
		icon: "res/help.png";

		onClicked: { window.location.href = "http://truba.tv/about.html"; }
	}

	TopMenuButton {
		id: searchButton;
		anchors.top: parent.top;
		anchors.right: settingButton.left;
		anchors.rightMargin: 10;
		visible: !renderer.fullscreen && (!parent.hasAnyActiveChild || searchPanel.active);
		icon: "res/search.png";

		onClicked: { searchPanel.startSearch(searchInput.text); }
	}

	TopMenuButton {
		id: settingButton;
		anchors.top: parent.top;
		anchors.right: aboutButton.left;
		anchors.rightMargin: 10;
		visible: !renderer.fullscreen && (!parent.hasAnyActiveChild || settingsPanel.active);
		icon: "res/settings.png";

		onClicked: {
			if (settingsPanel.active)
				settingsPanel.stop();
			else
				settingsPanel.start();
		}
	}

	AddProviderDialog { id: addProviderDialog; protocol: protocol; }
	FeedBackDialog { id: feedBackDialog; protocol: protocol; }

	updateLayout: {
		if (renderer.width < renderer.height) {
			log("Layout: w:" + renderer.width + "x" + renderer.height + ". Use portrait orientation.");
			this.portraitOrientation = true;
		} else {
			log("Layout: w:" + renderer.width + "x" + renderer.height + ". Use usual orientation.");
			this.portraitOrientation = false;
		}
	}

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		lastChannel.value = JSON.stringify(channel);
		videoPlayer.source = channel.url;
		controls.setChannelInfo(channel);
		programInfo.setChannel(channel);
		programInfo.setProgram(channel.program);
	}

	onHeightChanged:	{ this.updateLayout(); }
	onCompleted:		{ this.updateLayout(); }
}

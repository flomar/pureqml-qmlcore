Activity {
	id: mainWindow;
	anchors.fill: renderer;
	name: "root";

	Protocol		{ id: protocol; enabled: true; }

	ColorTheme		{ id: colorTheme; }

	LocalStorage {
		id: lastChannel;
		name: "lastChannel";

		onCompleted: { this.read(); }
	}

	ProvidersModel {
		id: providersModel;
		protocol: protocol;
	}

	CategoriesModel	{
		id: categoriesModel;
		protocol: protocol;
		providers: providersModel.providers;
	}

	EPGModel {
		id: epgModel;
		protocol: protocol;
	}

	Timer {
		id: updateTimer;
		interval: 24 * 3600 * 1000;
		repeat: true;

		onTriggered: {
			categoriesModel.update();
			epgModel.update();
		}
	}

	Item {
		effects.blur: channelsPanel.active ? 3 : 0;

		VideoPlayer {
			id: videoPlayer;
			anchors.top: mainWindow.top;
			anchors.left: mainWindow.left;
			width: renderer.width;
			height: renderer.height;
			source: lastChannel.value ? lastChannel.value : "http://hlsstr04.svc.iptv.rt.ru/hls/CH_NICKELODEON/variant.m3u8?version=2";
			autoPlay: true;
		}
	}

	Controls {
		id: controls;
		anchors.bottom:			videoPlayer.bottom;
		showListsButton:		!channelsPanel.active;
		protocol:				protocol;
		volume:					videoPlayer.volume;

		onFullscreenToggled:	{ renderer.fullscreen = true; }
		onListsToggled:			{ channelsPanel.start(); }
		onVolumeUpdated(value):	{ videoPlayer.volume = value; }
	}

	ChannelsPanel {
		id: channelsPanel;
		protocol: parent.protocol;

		onChannelSwitched(channel): { mainWindow.switchToChannel(channel); }
	}

	setProgramInfo(program): { controls.setProgramInfo(program); }

	switchToChannel(channel): {
		if (!channel) {
			log("App: Empty channel info.");
			return;
		}
		lastChannel.value = channel.url;
		videoPlayer.source = channel.url;
		controls.setChannelInfo(channel);

		if (!epgModel.protocol)
			return;

		var self = this;
		var channelName = channel.text;
		var program = epgModel.protocol.getCurrentPrograms(function(programs){
			for (var i in programs) {
				if (channelName == programs[i].channel) {
					self.setProgramInfo(programs[i]);
					break;
				}
			}
		});
	}
}

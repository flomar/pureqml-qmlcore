Activity {
	width: active ? 400 : 0;
	anchors.top: parent.top;
	anchors.right: renderer.right;
	anchors.bottom: parent.bottom;

	MouseArea {
		anchors.top: renderer.top;
		anchors.left: renderer.left;
		anchors.right: searchInnerPanel.left;
		anchors.bottom: renderer.bottom;
		hoverEnabled: parent.active;
		visible: parent.active;

		onClicked: { this.parent.stop(); }
	}

	Shadow {
		id: searchShadow;
		active: parent.active;
		leftToRight: false;
		anchors.top: parent.top;
		anchors.right: searchInnerPanel.left;
		anchors.bottom: parent.bottom;
	}

	Rectangle {
		id: searchInnerPanel;
		width: parent.width - searchShadow.width;
		height: parent.height;
		anchors.right: parent.right;
		color: colorTheme.backgroundColor;
		clip: true;

		SectionLine {
			id: searchPanelSectionLine;
			anchors.top: parent.top;
			anchors.topMargin: 50;
		}

		Flickable {
			id: searchContent;
			anchors.top: searchPanelSectionLine.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.topMargin: 21;
			anchors.bottomMargin: 20;
			dragging: true;
			draggingVertically: true;
			contentItem: Column {
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;

				Column {
					id: searchChannelsItem;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;

					Text {
						id: searchChannelLabel;
						anchors.left: parent.left;
						anchors.leftMargin: 10;
						font.pointSize: 16;
						color: colorTheme.textColor;
						text: "Каналы" + (foundChannelsList.count ? " (" + foundChannelsList.count + ")" : "");
						visible: foundChannelsList.count;
					}

					FoundChannels { id: foundChannelsList; }
				}

				Column {
					id: searchProgramItem;
					anchors.left: parent.left;
					anchors.right: parent.right;
					spacing: 20;

					Text {
						id: searchProgramsLabel;
						anchors.left: parent.left;
						anchors.leftMargin: 10;
						font.pointSize: 16;
						color: colorTheme.textColor;
						text: "Программы" + (foundPrograms.count ? " (" + foundPrograms.count + ")" : "");
						visible: foundPrograms.count;
					}

					FoundPrograms { id: foundPrograms; }
				}
			}
		}
	}

	startSearch(searchRequest): {
		if (!searchRequest) {
			log("Empty search request.");
			return;
		}

		if (!this.active)
			this.start();

		this._get("foundPrograms").model.clear();
		this._get("foundChannelsList").model.clear();

		this._get("foundPrograms").model.getEPGForSearchRequest(searchRequest);
		var list = this._get("categoriesModel").findChannels(searchRequest);
		if (list.length) {
			this._get("foundChannelsList").model.setList(list);
			searchContent.contentX = 0;
		}
	}

	Behavior on width { Animation { duration: 300; } }
}

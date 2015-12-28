Item {
	id: watchPageProto;
	signal switched;
	property variant currentList;
	anchors.fill: parent;

	CategoriesList {
		id: categories;

		onGenreChoosed(list): {
			channels.resetIndex()
			channels.setList(list)
			programs.hide()
		}

		onRightPressed: {
			if (channels.count)
				channels.setFocus()
		}

		onActiveFocusChanged: { if (this.activeFocus) categories.active = true }
	}

	ChannelsList {
		id: channels;
		anchors.left: categories.right;
		anchors.leftMargin: 2;

		onLeftPressed:	{ categories.setFocus() }
		onRightPressed:	{ if (programs.count) programs.setFocus() }
		onSwitched(channel): { watchPageProto.switched(channel); watchPageProto.currentList = channel.genre }
		onChannelChoosed(channel): { programs.setChannel(channel) }

		onActiveFocusChanged: { if (this.activeFocus) categories.active = false }
	}

	ProgramsList {
		id: programs;
		anchors.left: channels.right;
		anchors.right: parent.right;
		anchors.leftMargin: 2;

		onLeftPressed: { channels.setFocus() }
		onDisappeared: { channels.setFocus() }

		onActiveFocusChanged: { if (this.activeFocus) categories.active = false }
	}

	reset: { categories.active = true }

	onActiveFocusChanged: {
		categories.active = true
		if (this.activeFocus)
			categories.setFocus()
	}
}

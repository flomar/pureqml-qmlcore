Object {
	property int x;
	property int y;
	property int z;
	property int width;
	property int height;
	property real radius;
	property bool clip;
	property real rotate;

	property bool focus;
	property bool activeFocus;
	property Item focusedChild;

	property bool visible: true;
	property bool recursiveVisible: true;
	property real opacity: 1;

	property Anchors anchors: Anchors { }
	property Effects effects: Effects { }

	property AnchorLine left: AnchorLine	{ boxIndex: 0; }
	property AnchorLine top: AnchorLine		{ boxIndex: 1; }
	property AnchorLine right: AnchorLine	{ boxIndex: 2; }
	property AnchorLine bottom: AnchorLine	{ boxIndex: 3; }

	property AnchorLine horizontalCenter:	AnchorLine	{ boxIndex: 4; }
	property AnchorLine verticalCenter:		AnchorLine	{ boxIndex: 5; }

	//do not use, view internal
	signal boxChanged;
	property int viewX;
	property int viewY;

	constructor: {
		this._styles = {}
		if (this.parent) {
			if (this.element)
				throw "double ctor call"

			this.element = $(document.createElement('div'))
			this.parent.element.append(this.element)
			var self = this
			var updateVisibility = function(value) {
				self._recursiveVisible = value
				self._updateVisibility()
			}
			updateVisibility(this.parent.recursiveVisible)
			this.parent.onChanged('recursiveVisible', updateVisibility)
		} //no parent == top level element, skip
	}

	onVisibleChanged: { this._updateVisibility() }
	onOpacityChanged: { this._updateVisibility() }
	setFocus: { this.forceActiveFocus(); }
}

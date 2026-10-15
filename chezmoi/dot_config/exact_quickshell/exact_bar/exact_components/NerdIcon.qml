import QtQuick

/*!
 * \qmltype NerdIcon
 * \brief Renders one glyph from Symbols Nerd Font Mono.
 *
 * Use enumerated glyph tokens such as `NerdGlyphs.clock` rather than embedding
 * private-use codepoints in widgets.
 */
Item {
  id: root

  required property string glyph
  property color color: "#000000"
  property int iconSize: 15

  implicitWidth: icon.implicitWidth
  implicitHeight: icon.implicitHeight

  Text {
    id: icon

    text: root.glyph
    color: root.color

    font.family: "Symbols Nerd Font Mono"
    font.pixelSize: root.iconSize

    verticalAlignment: Text.AlignVCenter

    anchors.top: parent.top
    anchors.bottom: parent.bottom
  }
}

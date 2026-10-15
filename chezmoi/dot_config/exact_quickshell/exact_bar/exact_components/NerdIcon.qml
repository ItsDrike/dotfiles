import QtQuick

/*!
 * \qmltype NerdIcon
 * \brief Renders one glyph from Symbols Nerd Font Mono.
 *
 * Use enumerated glyph tokens such as `NerdGlyphs.clock` rather than embedding
 * private-use codepoints in widgets.
 */
Text {
  id: root

  required property string glyph
  property int iconSize: 16

  text: root.glyph
  font.family: "Symbols Nerd Font Mono"
  font.pixelSize: root.iconSize
  verticalAlignment: Text.AlignVCenter
}

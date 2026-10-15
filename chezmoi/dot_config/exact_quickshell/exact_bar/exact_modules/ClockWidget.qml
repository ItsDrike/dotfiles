import QtQuick
import qs.components as Components
import qs.services as Services

Row {
  spacing: 4

  Components.NerdIcon {
    glyph: Components.NerdGlyphs.clock
    color: "#89b4fa"

    anchors {
      top: parent.top
      bottom: parent.bottom
    }
  }

  Text {
      text: Services.ClockSource.time

      verticalAlignment: Text.AlignVCenter
      anchors {
        top: parent.top
        bottom: parent.bottom
      }
  }
}

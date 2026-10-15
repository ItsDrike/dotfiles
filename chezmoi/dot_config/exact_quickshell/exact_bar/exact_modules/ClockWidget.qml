import QtQuick
import QtQuick.Layouts
import qs.components as Components
import qs.services as Services

Components.Widget {
  RowLayout {
    spacing: 4

    Components.NerdIcon {
      glyph: Components.NerdGlyphs.clock
      color: "#89b4fa"

      Layout.fillHeight: true
    }

    Components.BarText {
      text: Services.ClockSource.time

      Layout.fillHeight: true
    }
  }
}

pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.modules as Modules

Scope {
  id: root

  required property ShellScreen screen

  readonly property int barHeight: 30
  readonly property int horizontalMargin: 10
  readonly property int widgetSpacing: 5

  component BarLeft: RowLayout {
    spacing: root.widgetSpacing

    Modules.ClockWidget { Layout.fillHeight: true }
  }

  component BarCenter: RowLayout {
    spacing: root.widgetSpacing

    Modules.ClockWidget { Layout.fillHeight: true }
  }

  component BarRight: RowLayout {
    spacing: root.widgetSpacing

    Modules.ClockWidget { Layout.fillHeight: true }
  }

  PanelWindow {
    screen: root.screen

    anchors {
      top: true
      left: true
      right: true
    }

    implicitHeight: root.barHeight

    RowLayout {
      spacing: 0
      anchors.fill: parent
      anchors.leftMargin: root.horizontalMargin
      anchors.rightMargin: root.horizontalMargin

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        BarLeft {
          anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
          }
        }
      }

      BarCenter {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignVCenter
      }

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        BarRight {
          anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
          }
        }
      }
    }
  }
}

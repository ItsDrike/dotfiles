import QtQuick
import Quickshell.Widgets

/*!
 * \qmltype WidgetClickable
 * \brief Provides a clickable bar widget with hover feedback and natural sizing.
 *
 * WidgetClickable exposes a full-height pointer target while keeping its
 * content and rounded hover background naturally sized and vertically
 * centered.
 *
 * It emits the `clicked` signal for primary clicks by default, or for any
 * buttons included in `acceptedButtons` when overridden. If `wheelEnabled` is
 * set, it also emits the `wheel` signal.
 *
 * Provide a visual root as default content (such as a RowLayout or a custom
 * item). WidgetClickable manages that root's outer geometry: do not set its x,
 * y, width, height or anchors.
 *
 * Use `Widget` for static widgets. Widgets with specialized pointer behavior
 * should implement that behavior in their own component.
 */
Item {
  id: root

  default property alias content: background.child

  property color hoverColor: "#d91e1e50"
  property real verticalMargin: 2
  property real radiusDiv: 3
  property int acceptedButtons: Qt.LeftButton
  property bool wheelEnabled: false

  readonly property bool hovered: mouse.containsMouse

  signal clicked(MouseEvent event)
  signal wheel(WheelEvent event)

  // Sizes this public Item from its private MouseArea
  MarginWrapperManager {
    id: sizing
    child: mouse
  }

  WrapperMouseArea {
    id: mouse

    // The MouseArea fills this Widget Item, but its background
    // remains naturally sized and centered.
    resizeChild: false

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    acceptedButtons: root.acceptedButtons
    onClicked: event => root.clicked(event)
    onWheel: event => {
      if (root.wheelEnabled)
        root.wheel(event)
      else
        event.accepted = false
    }

    WrapperRectangle {
      id: background

      topMargin: root.verticalMargin
      bottomMargin: root.verticalMargin

      radius: height / root.radiusDiv
      color: root.hovered ? root.hoverColor : "transparent"

      Behavior on color {
        ColorAnimation {
          duration: 150
        }
      }
    }
  }
}

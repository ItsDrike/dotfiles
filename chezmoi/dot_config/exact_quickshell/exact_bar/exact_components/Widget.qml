import QtQuick
import Quickshell.Widgets

/*!
 * \qmltype Widget
 * \brief Provides natural sizing for a non-interactive bar widget.
 *
 * Widget sizes itself from the visual content root's implicit dimensions. When
 * the widget is given an additional space, the content retains its natural size
 * and is centered rather than stretched.
 *
 * Provide a visual root as default content (such as a RowLayout or a custom
 * item). Widget manages that root's outer geometry: do not set its x, y,
 * width, height or anchors.
 *
 * Use `WidgetClickable` when the widget represents a click action with
 * standard hover feedback.
 */
Item {
  id: root

  default property alias content: sizing.child

  MarginWrapperManager {
    id: sizing
    resizeChild: false
  }
}

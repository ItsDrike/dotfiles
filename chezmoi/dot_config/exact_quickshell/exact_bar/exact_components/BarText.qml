import QtQuick

/*!
 * \qmltype BarText
 * \brief Renders a piece of text styled to fit on the bar
 */
Item {
  id: root

  required property string text

  implicitWidth: child.implicitWidth
  implicitHeight: child.implicitHeight

  Text {
    id: child

    text: root.text
    color: "#cdd6f4"

    font.family: "Monaspace Krypton"
    font.pixelSize: 14

    verticalAlignment: Text.AlignVCenter

    anchors.top: parent.top
    anchors.bottom: parent.bottom
  }
}

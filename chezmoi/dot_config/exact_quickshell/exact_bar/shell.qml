import Quickshell
import QtQuick


ShellRoot {
  Variants {
    model: Quickshell.screens

    delegate: Component {
      Bar {
        required property ShellScreen modelData
        screen: modelData
      }
    }
  }
}

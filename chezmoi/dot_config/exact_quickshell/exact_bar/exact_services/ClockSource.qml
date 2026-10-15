pragma Singleton
import Quickshell

/*!
 * \qmltype ClockSource
 *
 * A single instance reused for any modules that require clock info.
 */
Singleton {
  readonly property string time: Qt.formatDateTime(clock.date, "dd MMM HH:mm")

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4 as OldControls
import QtQuick.Layouts 1.12

import "qrc:/"

ApplicationWindow {

    visible: true

    width: 800
    height: 500

    RowLayout {
        width: 300

        Label {
            text: 'Please choose time:'
        }

        TextField {
            id: textField
            Layout.fillHeight: true
            Layout.fillWidth: true
            readOnly: true
            onReleased: {
                dateTimePicker.x = x
                dateTimePicker.y = y
                dateTimePicker.visible = true
            }
        }
    }

    DateTimePicker {
        id: dateTimePicker
        width: textField.width
        visible: false

        onDateTimePicked: {
            visible = false
            textField.text = dateTime.toLocaleString(Qt.locale('en_GB'), Locale.ShortFormat)
        }
    }

}
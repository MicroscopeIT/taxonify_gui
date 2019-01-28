import QtQuick 2.12
import QtQuick.Layouts 1.12

ColumnLayout {
    property bool valid: (startDateField.valid && endDateField.empty) ||
                         (startDateField.empty && endDateField.valid) ||
                         (startDateField.valid && endDateField.valid &&
                          (endDateField.date - startDateField.date >= 0))
    DateTextField {
        id: startDateField

        description: qsTr("Start date:")
        enabled: parent.enabled
        dateTextColor: (parent.valid || empty) ? 'black' : 'red'
    }

    DateTextField {
        id: endDateField

        description: qsTr("End date:")
        enabled: parent.enabled
        dateTextColor: (parent.valid || empty) ? 'black' : 'red'
    }
}

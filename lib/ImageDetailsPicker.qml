import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    function pickedAttributes() {
        return {
            taxonomy: taxonomyDetails.pickedAttributes(),
            morphometry: morphometricDetails.pickedAttributes(),
            additionalAttributes: additionalAttributesDetails.pickedAttributes(),
            modified_by: modifiedByCheckbox.checked,
            modification_time: modificationTimeCheckbox.checked,
            acquisition_time: acquisitionTimeCheckbox.checked,
            filename: filenameCheckbox.checked,
            tags: tagsCheckbox.checked
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        MenuSeparator {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ImageDetailsList {
                id: taxonomyDetails
                Layout.fillWidth: true
                Layout.fillHeight: true
                detailsArray: ItemAttributes.taxonomyAttributes
                title: "Taxonomy"
            }

            ImageDetailsList {
                id: morphometricDetails
                Layout.fillWidth: true
                Layout.fillHeight: true
                detailsArray: ItemAttributes.morphometricAttributes
                title: "Morphometry"
            }

            ImageDetailsList {
                id: additionalAttributesDetails
                Layout.fillWidth: true
                Layout.fillHeight: true
                detailsArray: ItemAttributes.additionalAttributes
                title: "Additional attributes"
            }
        }

        MenuSeparator {
            Layout.topMargin: 5
            Layout.fillWidth: true
        }

        Flow {
            Layout.fillWidth: true

            CheckBox {
                id: modifiedByCheckbox
                checked: true
                text: 'Modified by'
            }

            CheckBox {
                id: modificationTimeCheckbox
                checked: true
                text: 'Modification time'
            }

            CheckBox {
                id: acquisitionTimeCheckbox
                checked: true
                text: 'Acquisition time'
            }

            CheckBox {
                id: filenameCheckbox
                checked: false
                text: 'Filename'
            }

            CheckBox {
                id: tagsCheckbox
                checked: true
                text: 'Tags'
            }
        }
    }


}

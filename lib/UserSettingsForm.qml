import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.3
import QtQuick.Layouts 1.12

import "qrc:/network"

ColumnLayout {
    id: root
    property ListModel userListModel: ListModel {}
    property string selectedUser: ''
    property string newUser: ''

    signal close()
    signal userListRequested()
    signal addUserRequested(string username)

    function updateUserList(data) {
        console.info(Logger.log, "")
        userListModel.clear()
        for(const item of data) {
            userListModel.append({username: item})
        }
    }

    function addUserResponse(success) {
        console.info(Logger.log, "success=" + success)
        if(success) {
            responseAddUserDialog.title = qsTr("Success")
            responseMessage.text = "User added sucessfully!"
        } else {
            responseAddUserDialog.title = qsTr("Failed!")
            responseMessage.text = "Could not add user: " + root.newUser
        }

        newUser = ''
        userListRequested()
        return responseAddUserDialog.open()
    }

    Component {
        id: userListDelegate
        Item {
            width: parent.width
            height: 50
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                leftPadding: 10
                text: username
            }
            MouseArea {
                anchors.fill: parent
                onClicked: userList.currentIndex = index
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true

        border.color: 'lightgray'

        ColumnLayout {
            anchors.fill: parent

            ListView {
                id: userList
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                ScrollBar.vertical: ScrollBar {
                    parent: userList
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: 5
                }

                model: root.userListModel
                delegate: userListDelegate
                currentIndex: -1

                highlight: Rectangle {
                    color: 'whitesmoke'
                    border.color: 'lightgray'
                }
            }

            Item {
                Layout.fillWidth: true
                height: 10
            }

            RowLayout {
                Layout.rightMargin: 5
                Item {
                    Layout.fillWidth: true
                }

                Button {
                    Layout.preferredHeight: 50
                    Layout.rightMargin: 20
                    text: qsTr('Refresh')

                    Material.primary: Material.Grey
                    Material.background: Material.background

                    onClicked: {
                        console.debug(Logger.log, text)
                        root.userListRequested()
                    }
                }

                Button {
                    Layout.preferredHeight: 50
                    text: qsTr('Add user')

                    Material.primary: Material.Grey
                    Material.background: Material.background

                    onClicked: {
                        console.debug(Logger.log, text)
                        addUserDialog.open()
                        newUsername.forceActiveFocus()
                    }
                }

                Button {
                    Layout.preferredHeight: 50
                    text: qsTr('Close')

                    Material.primary: Material.Grey
                    Material.background: Material.background

                    onClicked: {
                        console.debug(Logger.log, text)
                        root.close()
                    }
                }
            }
        }
    }

    Dialog {
        id: addUserDialog
        modal: true
        parent: ApplicationWindow.overlay

        width: 250
        height: 180

        x: Math.floor((parent.width - width) / 2)
        y: Math.floor((parent.height - height) / 2)

        title: qsTr("Input new user name")
        standardButtons: Dialog.Cancel | Dialog.Ok

        onAccepted: {
            console.debug(Logger.log, "addUserDialog")
            if(newUsername.text.length === 0) {
               newUsername.forceActiveFocus()
               return addUserDialog.open()
            }
            root.newUser = newUsername.text
            newUsername.text = ''
            return confirmAddUserDialog.open()
        }
        onRejected: {
            console.debug(Logger.log, "addUserDialog")
            root.newUser = ''
        }

        TextField {
            id: newUsername
            anchors.centerIn: parent
            width: parent.width - 10
            focus: true

            Material.accent: Material.Pink

            validator: RegExpValidator { regExp: /^[a-zA-Z0-9.]{1,64}$/ }
            placeholderText: "username"
        }
    }

    Dialog {
        id: confirmAddUserDialog

        modal: true
        parent: ApplicationWindow.overlay

        width: 450
        height: 150

        x: Math.floor((parent.width - width) / 2)
        y: Math.floor((parent.height - height) / 2)

        title: qsTr("Confirm adding user")
        standardButtons: Dialog.Yes | Dialog.No

        onAccepted: {
            console.debug(Logger.log, "confirmAddUserDialog")
            root.addUserRequested(root.newUser)
        }

        onRejected: {
            console.debug(Logger.log, "confirmAddUserDialog")
            root.newUser = ''
        }

        Label {
            property int maxWidth: 400

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            width: maxWidth

            onTextChanged: width = Math.min(maxWidth, paintedWidth)

            text: "Are you sure you want to add new user: <b>" + root.newUser + "</b> to the system?"
        }
    }

    Dialog {
        id: responseAddUserDialog

        parent: ApplicationWindow.overlay

        width: 250
        height: 150
        x: Math.floor((parent.width - width) / 2)
        y: Math.floor((parent.height - height) / 2)

        standardButtons: Dialog.Ok

        Label {
          id: responseMessage
          text: qsTr('Server response text')
        }
    }
}

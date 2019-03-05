import QtQuick 2.12
import QtQuick.Controls 2.12

Item {
    id: root

    property real borderWidth: 5
    property real sizeScale: 1
    property int selectedCount: 0
    property var hoveredItem : null
    property var rightClickedItem: null

    property var filter: function(item) {
        return false
    }

    onFilterChanged: {
        selectedCount = 0
        for(let i = 0; i < model.count; i++) {
            let item = model.get(i)
            item.selected = item.selected && !filter(item)
            selectedCount += item.selected
        }
    }

    signal reachedBottom()
    signal itemHovered()
    signal itemRightClicked()


    readonly property ListModel model: ListModel {}
    readonly property int programatic_scroll_step: 100
    readonly property int x_offset_to_content: 1

    clip: true

    function appendData(data, useLastY) {
        for (let item of data) {
            model.append(item)
        }

        update(useLastY)
    }

    function clearData() {
        listModel.clear()
        listView.forceLayout()
        model.clear()
        update(false)
    }

    function getContentY() {
        return listView.contentY
    }

    function setData(data) {

        listModel.clear()
        listView.forceLayout()
        model.clear()

        for (let item of data) {
            model.append(item)
        }

        update(true)
    }

    function setContentY(value) {
        if(value > listView.contentY){
            while(listView.contentY + programatic_scroll_step <= value){
                listView.contentY += programatic_scroll_step
            }
            listView.contentY += (value - listView.contentY) % programatic_scroll_step
        }else{
            while(listView.contentY - programatic_scroll_step >= value){
                listView.contentY -= programatic_scroll_step
            }
            listView.contentY -= (listView.contentY - value) % programatic_scroll_step
        }
    }

    function getLastIdxAfterPotentialNextStep(step){
        let row = listView.model.get(listView.indexAt(x_offset_to_content, listView.contentY + step))
        let lastIdx = row.firstIdx + row.sub.count -1
        return lastIdx
    }

    function setContentYatIndex(idx) {
        setContentY(0)
        listView.forceLayout()
        //move down by programatic_scroll_step pixels until next move would reach the desired line
        while (listView.model.get(listView.indexAt(x_offset_to_content, listView.contentY)) && getLastIdxAfterPotentialNextStep(programatic_scroll_step) < idx){
            listView.contentY += programatic_scroll_step
        }
        //move down by 1 until desired line is actually reached (hence the 0 arg)
        while (listView.model.get(listView.indexAt(x_offset_to_content, listView.contentY)) && getLastIdxAfterPotentialNextStep(0) < idx){
            listView.contentY += 1
        }
    }

    function update(useLastY) {
        listModel.clear()
        listView.forceLayout()
        selectedCount = 0
        setContentY(0)
        let row = []
        let sumWidth = 0
        let maxHeight = 0
        let firstId = 0
        let matchedRow = -1
        for(let i = 0; i < model.count; i++) {

            let item = model.get(i)
            item.selected = item.selected && !filter(item)
            selectedCount += item.selected

            const metadata = item.metadata
            const imageWidth = metadata.image_width * sizeScale
                    + 3 * borderWidth
            const imageHeight = metadata.image_height

            if (sumWidth + imageWidth > width) {
                listModel.append({ sub: row, maxHeight: maxHeight, firstIdx: firstId })
                firstId = i
                sumWidth = 0
                maxHeight = 0
                row = []
            }

            if(i == listView.firstIdInTheFirstRow) {
                matchedRow = listModel.count
            }

            sumWidth += imageWidth
            maxHeight = Math.max(maxHeight, imageHeight)
            row.push({ idx: i })
        }

        if (row.length > 0) {
            listModel.append({ sub: row, maxHeight: maxHeight, firstIdx: firstId })
        }
        listView.forceLayout()

        if (useLastY) {
            setContentY(listView.lastY)
        } else {
            if (matchedRow != -1) {
                setContentYatIndex(listView.firstIdInTheFirstRow)
            } else {
                setContentY(0)
            }
        }

        listView.forceLayout()

        listView.lastY = listView.contentY

        if(listView.indexAt(x_offset_to_content, listView.contentY) >= 0){
            listView.firstIdInTheFirstRow = listView.model.get(listView.indexAt(x_offset_to_content, listView.contentY)).firstIdx
        }
    }

    onWidthChanged: timer.restart()
    onSizeScaleChanged: timer.restart()

    Timer {
        id: timer
        interval: 500
        onTriggered: root.update(false)
    }

    ListView {
        id: listView
        anchors.fill: parent
        property int lastY: 0
        property int firstIdInTheFirstRow: -1
        ScrollIndicator.vertical: ScrollIndicator {
            id: scroll
            onPositionChanged: {
                if (position + size == 1.0) {
                    root.reachedBottom()
                }
            }
        }

        model: ListModel {
            id: listModel
        }

        onMovementEnded: {
            firstIdInTheFirstRow = model.get(indexAt(x_offset_to_content, contentY)).firstIdx
            lastY = contentY
        }

        delegate: Rectangle {
            id: rowRect
            height: maxHeight * sizeScale + 3 * borderWidth
            width: parent.width

            ListView {
                id: rowListView
                anchors.fill: parent
                orientation: Qt.Horizontal
                clip: true

                model: sub

                ScrollBar.horizontal: ScrollBar {}

                delegate: Item {
                    width: img.width + 3 * borderWidth
                    height: img.height + 3 * borderWidth

                    property var item: root.model.get(modelData)

                    Rectangle {
                        id: rect

                        anchors.centerIn: parent
                        width: parent.width - borderWidth
                        height: parent.height - borderWidth
                        states: [
                            State {
                                when: filter(item)
                                name: "grayout"

                                PropertyChanges {
                                    target: img
                                    opacity: 0.4
                                }
                                PropertyChanges {
                                    target: rect
                                    border.color: 'darkblue'
                                }
                            },
                            State {
                                when: !item.selected
                                name: "basic"

                                PropertyChanges {
                                    target: rect

                                    border.color: 'darkblue'
                                    border.width: borderWidth / 2
                                    color: 'lightgray'
                                }
                            },
                            State {
                                when: item.selected
                                name: "selected"
                                PropertyChanges {
                                    target: rect

                                    border.color: 'red'
                                    border.width: borderWidth
                                    color: 'lightblue'
                                }
                            }
                        ]

                        Image {
                            id: img
                            source: item.image
                            anchors.centerIn: parent

                            height: item.metadata.image_height * sizeScale
                            width: item.metadata.image_width * sizeScale
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onPositionChanged: {
                                let currentItem = root.model.get(modelData)
                                hoveredItem = currentItem
                                itemHovered()
                            }

                            onExited: {
                                hoveredItem = null
                                itemHovered()
                            }

                            onClicked: {
                                let currentItem = root.model.get(modelData)

                                if (mouse.button & Qt.LeftButton) {
                                    if (rect.state == "grayout")
                                        return

                                    if (item.selected) {
                                        item.selected = false
                                        selectedCount -= 1
                                    } else {
                                        item.selected = true
                                        selectedCount += 1
                                    }

                                    item = currentItem
                                } else if (mouse.button & Qt.RightButton) {
                                    rightClickedItem = currentItem
                                    itemRightClicked()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

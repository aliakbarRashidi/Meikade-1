import QtQuick 2.0
import SialanTools 1.0

Rectangle {
    id: cat_item
    width: parent.width
    x: outside? parent.width : 0
    y: startInit? 0 : startY
    height: startInit? parent.height : startHeight
    clip: true
    color: "#dddddd"

    property alias catId: category.catId
    property alias root: cat_title.root

    property bool outside: false
    property bool startInit: false

    property real startY: 0
    property real startHeight: 0

    property Component categoryComponent
    property Component poemsComponent
    property variant baseFrame

    Behavior on x {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
    }
    Behavior on y {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
    }
    Behavior on height {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
    }

    Timer {
        id: destroy_timer
        interval: 400
        onTriggered: cat_item.destroy()
    }

    Timer {
        id: start_timer
        interval: 400
        onTriggered: cat_item.startInit = true
    }

    Category {
        id: category
        topMargin: item.visible? item.height : itemsSpacing
        height: cat_item.parent.height
        width: cat_item.parent.width
        header: root? desc_component : footer

        onCategorySelected: {
            var item = categoryComponent.createObject(baseFrame, {"catId": cid, "startY": rect.y, "startHeight": rect.height,
                                                      "root": (cat_item.catId == 0)} )
            item.start()

            if( list.count != 0 )
                list.last().outside = true

            list.append(item)
        }
        onPoemSelected: {
            var item = poemsComponent.createObject(baseFrame, {"catId": pid})
            item.inited = true

            if( list.count != 0 )
                list.last().outside = true

            list.append(item)
        }
    }

    Rectangle {
        id: item
        x: category.itemsSpacing
        width: category.width - 2*x
        height: 55*physicalPlatformScale
        border.width: 1*physicalPlatformScale
        border.color: "#cccccc"
        opacity: startInit? 0 : 1
        visible: cat_title.cid != 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
        }
    }

    Rectangle {
        height: item.height
        width: parent.width
        color: "#e0ffffff"
        opacity: startInit? 1 : 0
        visible: cat_title.cid != 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
        }
    }

    CategoryItem {
        id: cat_title
        anchors.fill: item
        cid: category.catId
    }

    Component {
        id: desc_component
        Rectangle {
            id: desc_header
            width: cat_item.width
            height: expand? desc_text.height + desc_text.y*2 : 80*physicalPlatformScale
            color: "#444444"
            clip: true

            property bool expand: false

            onExpandChanged: {
                if( expand )
                    BackHandler.pushHandler( desc_header, desc_header.unexpand )
                else
                    BackHandler.removeHandler(desc_header)
            }

            Behavior on height {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            Text {
                id: desc_text
                anchors.left: parent.left
                anchors.right: parent.right
                y: 8*physicalPlatformScale
                anchors.margins: y
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: "#ffffff"
                font.family: SApp.globalFontFamily
                font.pixelSize: 9*fontsScale
                text: Database.poetDesctiption(catId)
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 30*physicalPlatformScale
                opacity: desc_header.expand? 0 : 1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#00000000" }
                    GradientStop { position: 1.0; color: desc_header.color }
                }

                Behavior on opacity {
                    NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: desc_header.expand = !desc_header.expand
            }

            function unexpand() {
                expand = false
            }
        }
    }

    function start() {
        start_timer.start()
    }

    function end() {
        startInit = false
        destroy_timer.start()
    }
}

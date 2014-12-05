/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Meikade is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Meikade is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtGraphicalEffects 1.0
import SialanTools 1.0

Rectangle {
    id: view

    property int poemId: -1
    property bool onEdit: view_list.currentIndex != -1

    property alias header: view_list.header

    property color highlightColor: "#11000000"
    property color textColor: "#333333"
    property color highlightTextColor: "#333333"

    property real fontScale: Meikade.fontPointScale(Meikade.poemsFont)
    property bool editable: true
    property bool headerVisible: true

    property bool rememberBar: false

    onPoemIdChanged: {
        view_list.refresh()

        var cat = Database.poemCat(poemId)
        var fileName = cat
        var filePath = "banners/" + fileName + ".jpg"
        while( !Meikade.fileExists(filePath) ) {
            fileName = Database.parentOf(fileName)
            filePath = "banners/" + fileName + ".jpg"
        }

        img.source = filePath
    }

    signal itemSelected( int pid, int vid )

    Connections {
        target: Meikade
        onPoemsFontChanged: view.fontScale = Meikade.fontPointScale(Meikade.poemsFont)
    }

    Timer {
        id: highlight_disabler
        interval: 2500
        repeat: false
        onTriggered: view_list.highlightedVid = -1
    }

    Timer {
        id: highlight_enabler
        interval: 500
        repeat: false
        onTriggered: view_list.highlightedVid = vid

        property int vid
    }

    Item {
        id: header_back
        anchors.left: parent.left
        anchors.right: parent.right
        height: img.height
        visible: catTop>=-height && headerVisible
        clip: true

        property real catTop: -contentY<0? view_list.y : -contentY+view_list.y
        property real headerHeight: 0
        property real contentY: contentAbsY - (headerHeight+view_list.y)
        property real contentAbsY: (view_list.height/view_list.visibleArea.heightRatio)*view_list.visibleArea.yPosition

        Image {
            id: img
            anchors.left: parent.left
            anchors.right: parent.right
            y: 0
            height: width
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        FastBlur {
            id: blur
            anchors.fill: img
            source: img
            radius: fakeRadius<0? 0 : (fakeRadius>blurSize? blurSize : fakeRadius)
            Component.onDestruction: radius = 0

            property real fakeRadius: -header_back.contentAbsY<=0? blurSize :
                                      (-header_back.contentAbsY>header_back.headerHeight? 0 : blurSize*(header_back.headerHeight+header_back.contentAbsY)/(header_back.headerHeight))
            property real blurSize: 64
        }

        Rectangle {
            anchors.fill: blur
            color: "#000000"
            opacity: fakeOpacity<0? 0 : (fakeOpacity>1? 1 : fakeOpacity)

            property real fakeOpacity: (blur.radius/blur.blurSize)/2
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: blur.bottom
            height: 100*physicalPlatformScale
            anchors.margins: -1*physicalPlatformScale
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 1.0; color: view.color }
            }
        }
    }

    ListView {
        id: view_list
        anchors.fill: parent
        clip: true
        highlightMoveDuration: 250
        maximumFlickVelocity: flickVelocity
        bottomMargin: View.navigationBarHeight

        property int highlightedVid: -1
        footer: Item {
            width: view_list.width
            height: 1
            Rectangle {
                width: parent.width
                height: view.height
            }
        }

        onCurrentIndexChanged: {
            if( currentIndex != -1 )
                BackHandler.pushHandler(view, view.closeEdit)
            else
                BackHandler.removeHandler(view)
        }

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: view_list.width
            height: editMode? pitem.height + edit_frame.height + extraHeight : pitem.height + extraHeight
            clip: true

            property real extraHeight: single? txt_frame.height : 0
            property alias press: marea.pressed
            property bool editMode: view_list.currentIndex == index
            property bool anim: false

            Behavior on height {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: item.anim? 400 : 0 }
            }

            Timer {
                interval: 400
                repeat: false
                onTriggered: item.anim = true
                Component.onCompleted: start()
            }

            PoemItem {
                id: pitem
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                color: press? view.highlightColor : "#00000000"
                textColor: item.press? view.highlightTextColor : view.textColor
                vid: verseId
                pid: poemId
                highlight: view_list.highlightedVid == vid
                font.pixelSize: Devices.isMobile? 9*fontsScale : 11*fontsScale
                font.family: globalPoemFontFamily

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 25*physicalPlatformScale
                    color: "#EC4334"
                    visible: item.press || item.height != pitem.height + item.extraHeight

                    Text {
                        anchors.centerIn: parent
                        text: Meikade.numberToArabicString(index+1)
                        color: "#ffffff"
                        font.pixelSize: 9*fontScale
                        font.family: SApp.globalFontFamily
                    }
                }
            }

            MouseArea{
                id: marea
                anchors.fill: parent
                onClicked: {
                    if( view.editable ) {
                        var itemObj = showBottomPanel(share_component, true)
                        itemObj.poemId = pitem.pid
                        itemObj.vid = pitem.vid
                        itemObj.text = pitem.text
                    }

                    view.itemSelected(pitem.pid,pitem.vid)
                }
            }

            Rectangle {
                id: txt_frame
                height: poet.height
                width: parent.width
                anchors.top: pitem.bottom
                color: "#EC4334"

                Text {
                    id: poet
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 8*physicalPlatformScale
                    font.pixelSize: Devices.isMobile? 8*fontsScale : 9*fontsScale
                    font.family: SApp.globalFontFamily
                    color: "#ffffff"

                    Component.onCompleted: {
                        if( !single )
                            return

                        var cat = Database.poemCat(pitem.pid)
                        var str
                        str = Database.catName(cat) + ", "
                        str += Database.poemName(pitem.pid)

                        var poet
                        var book
                        while( cat ) {
                            book = poet
                            poet = cat
                            cat = Database.parentOf(cat)
                        }

                        str = Database.catName(poet) + ", " + Database.catName(book) + ", " + str
                        text = str
                    }
                }
            }

            Item {
                id: edit_frame
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: pitem.bottom
                height: 80*physicalPlatformScale

                property bool editMode: item.editMode
                property variant itemObj

                onEditModeChanged: {
                    if( editMode ) {
                        if( itemObj )
                            return

                        var component = Qt.createComponent("PoemEdit.qml")
                        itemObj = component.createObject(edit_frame)
                        itemObj.poemId = pitem.pid
                        itemObj.vid = pitem.vid
                        itemObj.text = pitem.text
                        itemObj.anchors.fill = edit_frame
                        itemObj.pressChanged.connect(edit_frame.pressChanged)
                    } else {
                        if( !itemObj )
                            return

                        itemObj.hidePicker()
                        Meikade.timer(400,itemObj,"deleteLater")
                    }
                }

                function pressChanged() {
                    view_list.interactive = !itemObj.press
                }
            }
        }

        focus: true
        currentIndex: -1
        header: PoemHeader{
            id: header
            width: view_list.width
            poemId: view.poemId
            font.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
            font.family: globalPoemFontFamily
            onHeightChanged: {
                header_back.headerHeight = height+view_list.y
                view_list.positionViewAtBeginning()
            }
        }

        function refresh(){
            model.clear()
            currentIndex = -1

            refresh_timer.idx = 0
            refresh_timer.moveToVerse = -1
            refresh_timer.verses = Database.poemVerses(poemId)
            refresh_timer.restart()
            focus = true
        }

        Timer {
            id: refresh_timer
            interval: 1
            repeat: false
            onTriggered: {
                for( var i=0; i<10; i++ ) {
                    if( idx < verses.length ) {
                        var vid = verses[idx]
                        view_list.add(view.poemId,vid,false)
                        if( Database.versePosition(poemId,vid)===0 && Database.versePosition(poemId,vid+1)===1 ) {
                            i++
                            idx++
                        }
                        idx++
                        refresh_timer.restart()
                    } else {
                        if( moveToVerse != -1 )
                            view_list.goTo(moveToVerse)

                        moveToVerse = -1
                        idx = 0
                        refresh_timer.stop()
                        break
                    }
                }
            }

            property int idx: 0
            property variant verses: new Array
            property int moveToVerse: -1
        }

        function add( poem_id, verse_id, single ) {
            model.append({"poemId": poem_id, "verseId": verse_id,"single":single})
        }

        function clear() {
            model.clear()
        }

        function goTo( vid ){
            if( refresh_timer.running ) {
                refresh_timer.moveToVerse = vid
                return
            }
            var index = vidIndex(vid)
            if( index === -1 )
                return

            view_list.positionViewAtIndex(index,ListView.Center)
        }

        function vidIndex( vid ) {
            for( var i=0;i<model.count; i++ )
                if( model.get(i).verseId === vid )
                    return i

            return -1
        }
    }

    Item {
        width: view_list.width
        height: 32*physicalPlatformScale
        clip: true
        visible: header_back.contentY >= -height && rememberBar

        PoemHeader{
            id: fake_header
            width: parent.width
            anchors.bottom: parent.bottom
            poemId: view.poemId
            font.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
            font.family: globalPoemFontFamily
        }
    }

    ScrollBar {
        scrollArea: view_list; height: view_list.height-View.navigationBarHeight
        anchors.left: view_list.left; anchors.top: view_list.top
    }

    MouseArea {
        anchors.fill: parent
        onClicked: SApp.back()
        visible: bottomPanel.item? true : false
    }

    Component {
        id: share_component
        Column {
            id: poem_edit
            width: parent.width

            property int poemId
            property int vid
            property bool favorited: false
            property bool signalBlocker: false
            property string text

            onVidChanged: {
                if( vid == -1 )
                    return
                signalBlocker = true
                favorited = UserData.isFavorited(poemId,vid)
                signalBlocker = false
            }
            onFavoritedChanged: {
                if( signalBlocker )
                    return
                if( favorited ) {
                    UserData.favorite(poemId,vid)
                    showTooltip( qsTr("Favorited") )
                } else {
                    UserData.unfavorite(poemId,vid)
                    showTooltip( qsTr("Unfavorited") )
                }
            }

            Button {
                width: parent.width
                height: 40*physicalPlatformScale
                text:   qsTr("Copy")
                textColor: "#333333"
                textFont.bold: false
                textFont.pixelSize: 10*fontsScale
                onClicked: {
                    var subject = Database.poemName(poem_edit.poemId)
                    var poet
                    var catId = Database.poemCat(poem_edit.poemId)
                    while( catId ) {
                        poet = Database.catName(catId)
                        subject = Database.catName(catId) + ", " + subject
                        catId = Database.parentOf(catId)
                    }

                    var message = poem_edit.text + "\n\n" + poet

                    Devices.clipboard = message
                    hideBottomPanel()
                }
            }
            Button {
                width: parent.width
                height: 40*physicalPlatformScale
                text:   qsTr("Share")
                textColor: "#333333"
                textFont.bold: false
                textFont.pixelSize: 10*fontsScale
                onClicked: {
                    var subject = Database.poemName(poem_edit.poemId)
                    var poet
                    var catId = Database.poemCat(poem_edit.poemId)
                    while( catId ) {
                        poet = Database.catName(catId)
                        subject = Database.catName(catId) + ", " + subject
                        catId = Database.parentOf(catId)
                    }

                    var message = poem_edit.text + "\n\n" + poet
                    Devices.share(subject,message)
                    hideBottomPanel()
                }
            }
            Button {
                width: parent.width
                height: 40*physicalPlatformScale
                text: poem_edit.favorited? qsTr("Unfavorite") : qsTr("Favorite")
                textColor: "#333333"
                textFont.bold: false
                textFont.pixelSize: 10*fontsScale
                onClicked: {
                    poem_edit.favorited = !poem_edit.favorited
                    hideBottomPanel()
                }
            }
        }
    }

    function goTo(vid){
        view_list.goTo(vid)
    }

    function goToBegin(){
        view_list.positionViewAtBeginning()
    }

    function closeEdit(){
        view_list.currentIndex = -1
    }

    function add( poem_id, verse_id ) {
        view_list.add(poem_id,verse_id,true)
    }

    function clear() {
        view_list.clear()
    }

    function highlightItem( vid ){
        highlight_enabler.vid = vid
        highlight_enabler.restart()
        highlight_disabler.restart()

    }
}

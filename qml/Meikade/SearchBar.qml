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
import SialanTools 1.0

BackHandlerView {
    id: search_bar
    width: 100
    height: hide? 0 : (searchMode? main.height : search_frame.height + search_frame.y)
    color: "#333333"
    viewMode: false
    clip: true

    property bool hide: true
    property bool searchMode: false

    onHideChanged: {
        if( !hide )
            txt.focus = true
        else
            main.focus = true
    }

    Behavior on height {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    Item {
        id: search_frame
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 42*physicalPlatformScale
        anchors.topMargin: View.statusBarHeight

        Image {
            id: search_img
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 11*physicalPlatformScale
            width: height
            sourceSize: Qt.size(width,height)
            source: "icons/search.png"
            mirror: true
        }

        Rectangle {
            id: search_splitter
            width: 1*physicalPlatformScale
            height: parent.height/2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: search_img.left
            anchors.margins: txt.anchors.rightMargin/2
            color: "#888888"
        }

        Text {
            id: placeholder
            anchors.fill: txt
            font: txt.font
            color: "#888888"
            text: qsTr("Search")
            visible: !txt.focus && txt.text.length == 0
        }

        TextInput {
            id: txt
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: search_img.left
            anchors.left: parent.left
            anchors.margins: 4*physicalPlatformScale
            anchors.topMargin: anchors.margins+1*physicalPlatformScale
            anchors.rightMargin: 20*physicalPlatformScale
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            inputMethodHints: Qt.ImhNoPredictiveText
            color: "#dddddd"
            font.family: SApp.globalFontFamily
            font.pixelSize: fontsScale*11
            onTextChanged: {
                if( text.length == 0 ) {
                    search_bar.searchMode = false
                    search_starter.stop()
                } else {
                    search_starter.restart()
                }
            }
        }

        Timer {
            id: search_starter
            interval: 500
            repeat: false
            onTriggered: search_bar.searchMode = true
        }
    }

    PoemView {
        id: poem
        anchors.top: search_frame.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        clip: true
        x: search_bar.viewMode? 0 : -width

        Behavior on x {
            NumberAnimation { easing.type: Easing.OutCubic; duration: animations*400 }
        }
    }

    SearchList {
        id: search_list
        anchors.top: search_frame.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        x: search_bar.viewMode? width : 0
        keyword: txt.text
        clip: true

        Behavior on x {
            NumberAnimation { easing.type: Easing.OutCubic; duration: animations*400 }
        }

        onItemSelected: {
            poem.poemId = poem_id
            poem.goTo(vid)
            poem.highlightItem(vid)
            search_bar.viewMode = true
        }
    }

    Button{
        id: back_btn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: View.statusBarHeight
        height: headerHeight
        radius: 0
        normalColor: "#00000000"
        highlightColor: "#88666666"
        textColor: "#ffffff"
        icon: "icons/back_light_64.png"
        iconHeight: 16*physicalPlatformScale
        fontSize: 11*fontsScale
        textFont.bold: false
        visible: backButton && search_bar.searchMode
        onClicked: {
            SApp.back()
            Devices.hideKeyboard()
        }
    }

    function show() {
        hide = false
    }
}

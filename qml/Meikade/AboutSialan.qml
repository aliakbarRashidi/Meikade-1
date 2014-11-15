/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import SialanTools 1.0

Rectangle {
    width: 100
    height: 62
    color: "#ffffff"

    Rectangle {
        anchors.fill: title
        anchors.topMargin: -View.statusBarHeight
        color: "#5C90FF"
    }

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: View.statusBarHeight
        anchors.right: parent.right
        titleFont.pixelSize: 13*fontsScale
        light: true
    }

    Item {
        anchors.left: parent.left
        anchors.top: title.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Flickable {
            id: flickable
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: visit_btn.top
            anchors.topMargin: title.height
            flickableDirection: Flickable.VerticalFlick
            contentHeight: column.height
            contentWidth: width
            clip: true

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 80*physicalPlatformScale
                    height: width
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width,height)
                    smooth: true
                    source: "icons/sialan.png"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SIALAN LABS"
                    font.pixelSize: 20*fontsScale
                    font.weight: Devices.isWindows? Font.Normal : Font.DemiBold
                    font.family: SApp.globalFontFamily
                    color: "#333333"
                }

                Item {
                    width: 10
                    height: 20*physicalPlatformScale
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20*physicalPlatformScale
                    text: Tools.aboutSialan()
                    font.pixelSize: 9*fontsScale
                    font.family: SApp.globalFontFamily
                    wrapMode: Text.WordWrap
                    color: "#333333"
                }
            }
        }

        ScrollBar {
            scrollArea: flickable; height: flickable.height
            anchors.right: flickable.right; anchors.top: flickable.top; color: "#888888"
        }

        Button {
            id: visit_btn
            anchors.left: parent.left
            anchors.bottom: nav_rect.top
            anchors.right: parent.right
            height: 42*physicalPlatformScale
            normalColor: "#4098bf"
            highlightColor: "#337fa2"
            text: qsTr("Check Sialan website")
            onClicked: Qt.openUrlExternally("http://labs.sialan.org/")
        }

        Rectangle {
            id: nav_rect
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            height: View.navigationBarHeight
            color: visit_btn.press? visit_btn.highlightColor : visit_btn.normalColor
        }
    }
}

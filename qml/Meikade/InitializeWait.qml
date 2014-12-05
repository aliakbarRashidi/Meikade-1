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

About {
    id: init_wait
    anchors.fill: parent
    aboutText: false

    Text {
        id: init_txt
        y: parent.height*4/5
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 12*fontsScale
        font.bold: true
        color: "#ffffff"
    }

    CradleIndicator {
        id: cradle
        anchors.top: init_txt.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10*physicalPlatformScale
    }

    ProgressBar {
        id: progressbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: cradle.bottom
        anchors.topMargin: 10*physicalPlatformScale
        anchors.margins: 20*physicalPlatformScale
        color: "#000000"
        topColor: "#0d80ec"
    }

    Connections {
        target: Database
        onExtractProgress: {
            progressbar.percent = percent
        }
    }

    Connections{
        target: Meikade
        onCurrentLanguageChanged: initTranslations()
    }

    function initTranslations(){
        init_txt.text = qsTr("Installing Database")
    }

    Component.onCompleted: initTranslations()
}

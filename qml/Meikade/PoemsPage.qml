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

Rectangle {
    id: poems_page
    width: 100
    height: 62
    color: "#ffffff"

    property int catId: -1
    property bool viewMode: false

    property int duration: 400
    property int easingType: Easing.OutQuad

    Poems {
        id: poems
        width: parent.width
        height: parent.height
        catId: poems_page.catId
//        scale: ratio
        onItemSelected: {
            if( !poems_page.viewMode )
                poems_page.switchPages()
            view.poemId = pid
            view.goToBegin()
        }

        property real ratio: poems_page.viewMode && portrait? 0.8 : 1

        Behavior on ratio {
            NumberAnimation { easing.type: poems_page.easingType; duration: animations*poems_page.duration }
        }
    }

    Rectangle {
        id: black
        anchors.fill: parent
        color: "#000000"
        opacity: (1 - poems.ratio)*3
    }

    PoemView {
        id: view
        width: portrait? parent.width : parent.width*2/3
        height: parent.height
        x: poems_page.viewMode? 0 : -width - shadow.width

        Behavior on x {
            NumberAnimation { easing.type: poems_page.easingType; duration: animations*poems_page.duration }
        }

        Rectangle{
            id: shadow
            x: parent.width
            y: -height
            width: parent.height
            height: 10*physicalPlatformScale
            rotation: 90
            transformOrigin: Item.BottomLeft
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 1.0; color: "#33000000" }
            }
        }
    }

    function switchPages() {
        poems_page.viewMode = !poems_page.viewMode
    }

    function back() {
        if( poems_page.viewMode ) {
            switchPages()
            return true
        } else {
            return false
        }
    }

    Component.onCompleted: main.backHandler = poems_page
}

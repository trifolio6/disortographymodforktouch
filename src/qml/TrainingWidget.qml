/*
 *  Copyright 2013  Sebastian Gottfried <sebastiangottfried@web.de>
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License as
 *  published by the Free Software Foundation; either version 2 of
 *  the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import ktouch 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents

FocusScope {
    id: trainingWidget

    property Lesson lesson
    property KeyboardLayout keyboardLayout
    property TrainingStats trainingStats
    property Item overlayContainer

    property alias nextChar: trainingLine.nextCharacter
    property alias isCorrect: trainingLine.isCorrect
    property alias rabbitSpeed: trainingLine.rabbitSpeed
    property double initialTime
    property double elapsedTime : 0
    signal finished
    signal keyPressed(variant event)
    signal keyReleased(variant event)

    function reset() {
        stats.reset()
        lessonPainter.reset()
        sheetFlick.scrollToCurrentLine()
        trainingLine.active = true
	timerRabbitTic.timerRabbitTicActive = false
	timerRabbitTac.timerRabbitTacActive = false
	elapsedTime = 0
	cursorRabbit.batonPosX = 0
	cursorRabbit.visible = false
    }
    
    function resetTimers()
    {
	cursorRabbit.visible = true
	stopTimer.restart()
	if ( (timerRabbitTic.timerRabbitTicActive == false) && (timerRabbitTac.timerRabbitTacActive == false) ) {
	    initialTime = new Date().valueOf() - elapsedTime
	    timerRabbitTic.restart()
	}
    }

    
    Timer {
        id: stopTimer
        interval: 30000
        onTriggered: {
	    elapsedTime = new Date().valueOf() - initialTime
            stats.stopTraining()
	    timerRabbitTic.stop()
	    timerRabbitTac.stop()
	    timerRabbitTic.timerRabbitTicActive = false
	    timerRabbitTac.timerRabbitTacActive = false
        }
    }
    
    Timer {
        id: timerRabbitTic
        interval: 100
        running: false
	property bool timerRabbitTicActive: false
        onTriggered: {
	    timerRabbitTicActive = false
	    timerRabbitTac.timerRabbitTacActive = true
	    cursorRabbit.batonPosX = rabbitSpeed * lessonPainter.cursorRabbitRectangle.width * (new Date().valueOf() - initialTime) / 60000
	    timerRabbitTac.restart()
        }
    }

    Timer {
        id: timerRabbitTac
        interval: 100
        running: false
	property bool timerRabbitTacActive: false
        onTriggered: {
	    timerRabbitTacActive = false
	    timerRabbitTic.timerRabbitTicActive = true
	    cursorRabbit.batonPosX = rabbitSpeed * lessonPainter.cursorRabbitRectangle.width * (new Date().valueOf() - initialTime) / 60000
	    timerRabbitTic.restart()
        }
    }
    
    Flickable
    {
        id: sheetFlick
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: sheet.height + 60
        clip: true
        flickableDirection: Flickable.VerticalFlick

        function currentLineY() {
            var cursorRect = lessonPainter.cursorRectangle
            var y = cursorRect.y + sheet.y + (cursorRect.height / 2)
            return Math.max(Math.min((y - (height / 2)), contentHeight - height), 0)
        }

        function scrollToCurrentLine() {
	    elapsedTime = 0
	    initialTime = new Date().valueOf() - elapsedTime
	    cursorRabbit.y = lessonPainter.cursorRectangle.y

            scrollAnimation.to = currentLineY()
            scrollAnimation.start()
        }

        onHeightChanged: {
            contentY = currentLineY()
/// TODO: cambio tamaño ventana.
        }

        NumberAnimation {
            target: sheetFlick
            id: scrollAnimation
            duration: 150
            property: "contentY"
        }

        Rectangle {
            id: sheet
            color: "#fff"
            anchors.centerIn: parent
            width: parent.width - 60
            height: lessonPainter.height

            border {
                width: 1
                color: "#000"
            }

            LessonPainter {
                id: lessonPainter
                anchors.centerIn: sheet
                lesson: trainingWidget.lesson
                maximumWidth: parent.width
                trainingLineCore: trainingLine

                onDone: {
                    trainingLine.active = false
                    trainingWidget.finished();
                    stats.stopTraining();
                }

                TrainingLineCore {
                    id: trainingLine
                    anchors.fill: parent
                    focus: true
                    trainingStats: stats
                    cursorRabbitItem: cursorRabbit
                    cursorItem: cursor

                    onFocusChanged: {
                        if (!trainingLine.activeFocus) {
                            trainingStats.stopTraining()
                        }
                    }

                    Keys.onPressed: {
                        if (!trainingLine.active)
                            return

                        cursorAnimation.restart()
                        trainingStats.startTraining()
			resetTimers()

                        if (!event.isAutoRepeat) {
                            trainingWidget.keyPressed(event)
                        }
                    }

                    Keys.onReleased: {
                        if (!trainingLine.active)
                            return

                        if (!event.isAutoRepeat) {
                            trainingWidget.keyReleased(event)
                        }
                    }
                }

                Rectangle {
                    id: cursor
                    color: "#000"
                    x: Math.floor(lessonPainter.cursorRectangle.x)
                    y: lessonPainter.cursorRectangle.y
                    width: lessonPainter.cursorRectangle.width
                    height: lessonPainter.cursorRectangle.height

                    onYChanged: sheetFlick.scrollToCurrentLine()

                    SequentialAnimation {
                        id: cursorAnimation
                        running: trainingLine.active && trainingLine.activeFocus && Qt.application.active
                        loops: Animation.Infinite
                        PropertyAction {
                            target: cursor
                            property: "opacity"
                            value: 1
                        }
                        PauseAnimation {
                            duration: 500
                        }
                        PropertyAction {
                            target: cursor
                            property: "opacity"
                            value: 0
                        }
                        PauseAnimation {
                            duration: 500
                        }
                    }
                }

                Rectangle {
                    id: cursorRabbit
                    visible: false
                    color: "#F00"
                    x: Math.floor(lessonPainter.cursorRabbitRectangle.x) + batonPosX
                    y: lessonPainter.cursorRectangle.y
                    width: lessonPainter.cursorRabbitRectangle.width / 2
                    height: lessonPainter.cursorRabbitRectangle.height
		    property double batonPosX: 0
		    
                    onYChanged: sheetFlick.scrollToCurrentLine()
                }
                
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: trainingLine.forceActiveFocus()
        }
    }

    KeyItem {
        id: hintKey
        parent: trainingWidget.overlayContainer
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.max(height, Math.min(parent.height - 2 * height,
            sheetFlick.mapToItem(parent, 0, cursor.y + 3 * cursor.height - sheetFlick.contentY).y))

        property real horizontalScaleFactor: 1
        property real verticalScaleFactor: 1
        property Key defaultKey: Key {}
        property KeyboardLayout defaultKeyboardLayout: KeyboardLayout {}

        key: {
            var specialKeyType

            switch (trainingLine.hintKey) {
            case Qt.Key_Return:
                specialKeyType = SpecialKey.Return
                break
            case Qt.Key_Backspace:
                specialKeyType =  SpecialKey.Backspace
                break
            case Qt.Key_Space:
                specialKeyType =  SpecialKey.Space
                break
            default:
                specialKeyType =  -1
            }

            for (var i = 0; i < keyboardLayout.keyCount; i++) {
                var key = keyboardLayout.key(i)

                if (key.keyType() === "specialKey" && key.type === specialKeyType) {
                    return key;
                }
            }

            return defaultKey
        }

        opacity: trainingLine.hintKey !== -1? 1: 0
        isHighlighted: opacity == 1
        keyboardLayout: screen.keyboardLayout || defaultKeyboardLayout
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    PlasmaComponents.ScrollBar {
        flickableItem: sheetFlick
    }
}


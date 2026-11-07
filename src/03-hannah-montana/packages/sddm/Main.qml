import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#4b1468"

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
    }
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(400, root.width - 40)
        height: form.implicitHeight + 48
        color: "#fff0bd"
        border.color: "#b53baf"
        border.width: 3
        radius: 12

        ColumnLayout {
            id: form
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 24 }
            spacing: 12
            Image { source: "logo.png"; Layout.alignment: Qt.AlignHCenter; sourceSize: Qt.size(80, 80) }
            Label { text: "Hannah Montana"; color: "#4b1468"; font.pixelSize: 28; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            TextField { id: username; Layout.fillWidth: true; placeholderText: "Username"; text: userModel.lastUser; Accessible.name: "Username" }
            TextField {
                id: password
                Layout.fillWidth: true
                placeholderText: "Password"
                echoMode: TextInput.Password
                focus: true
                Accessible.name: "Password"
                onAccepted: if (login.enabled) login.clicked()
            }
            ComboBox { id: session; Layout.fillWidth: true; model: sessionModel; textRole: "name"; currentIndex: sessionModel.lastIndex; Accessible.name: "Desktop session" }
            Label { id: error; color: "#921a46"; text: ""; wrapMode: Text.WordWrap; Layout.fillWidth: true }
            Button {
                id: login
                text: "Log in"
                Layout.fillWidth: true
                enabled: username.text.length > 0
                onClicked: { error.text = ""; sddm.login(username.text, password.text, session.currentIndex) }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Button { text: "Restart"; visible: sddm.canReboot; onClicked: sddm.reboot() }
                Button { text: "Shut down"; visible: sddm.canPowerOff; onClicked: sddm.powerOff() }
            }
        }
    }
    Connections {
        target: sddm
        function onLoginFailed() { error.text = "Login failed. Check your username and password."; password.text = ""; password.forceActiveFocus() }
    }
}

import QtQuick
import qs
import qs.components

Column {
    spacing: 12
    function takeInitialFocus() {
        response.forceActiveFocus();
    }
    BodyText {
        width: parent.width
        text: "Authentication"
        font.pixelSize: 22
    }
    BodyText {
        width: parent.width
        text: Auth.flow ? Auth.flow.message : ""
    }
    BodyText {
        width: parent.width
        text: Auth.flow ? Auth.flow.inputPrompt : ""
        color: Style.muted
    }
    Field {
        id: response
        width: parent.width
        echoMode: Auth.flow && Auth.flow.responseVisible ? TextInput.Normal : TextInput.Password
        enabled: Auth.flow && Auth.flow.isResponseRequired
        onAccepted: {
            if (Auth.flow && Auth.flow.isResponseRequired)
                Auth.flow.submit(text);
            clear();
        }
    }
    BodyText {
        width: parent.width
        text: Auth.flow ? Auth.flow.supplementaryMessage : ""
        color: Style.primary
    }
    Row {
        spacing: 10
        PillButton {
            text: "Cancel"
            onClicked: if (Auth.flow)
                Auth.flow.cancelAuthenticationRequest()
        }
        PillButton {
            text: "Authenticate"
            selected: true
            enabled: Auth.flow && Auth.flow.isResponseRequired
            onClicked: {
                Auth.flow.submit(response.text);
                response.clear();
            }
        }
    }
    Connections {
        target: Auth
        function onFlowChanged() {
            response.clear();
        }
    }
}

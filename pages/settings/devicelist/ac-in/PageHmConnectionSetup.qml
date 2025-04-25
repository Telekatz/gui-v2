/*
** Copyright (C) 2025 Telekatz
** This code is based on Victron Energy code
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: serial
		uid: root.bindPrefix + "/Serial"
	}

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {
						
			ListIpAddressField {
				text: CommonWords.ip_address
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/MqttUrl"
			}

			ListPortField {
				id: mqttPort
				text: qsTrId("port_field_title")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/MqttPort"
			}

			ListTextField {
				id: mqttUser
				text: qsTrId("page_settings_gsm_user_name")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/MqttUser"
			}
			
			ListTextField {
				id: mqttPasswort
				text: CommonWords.password
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/MqttPwd"
			}
			
			ListTextField {
				id: mqttPath
				//% "Inverter path"
				text:  qsTrId("hm_inverter_path")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/InverterPath"
			}
			
			ListRadioButtonGroup {
				id: microEssDtu
				text: "DTU"
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/DTU"

				optionModel: [
					{ display: "Ahoy", value: 0 },
					{ display: "OpenDTU", value: 1 }
				]
			}

			ListSpinBox {
				id: inverterID
				text: "Inverter ID"
				preferredVisible: microEssDtu.currentValue === 0
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/InverterID"
				decimals: 0
				stepSize: 1
				to: 9
				from: 0
			}

		}
	}
}

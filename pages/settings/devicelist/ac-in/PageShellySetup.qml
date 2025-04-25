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
	
	VeQuickItem {
		id: instance
		uid: root.bindPrefix + "/DeviceInstance"
	}

	GradientListView {
		id: settingsListView

		model: VisibleItemModel {


			ListRadioButtonGroup {
				id: phase
				text: CommonWords.phase
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/Phase"

				VeQuickItem {
					id: meterCount
					uid: root.bindPrefix + "/MeterCount"
					onValueChanged: {
						let options = []
						
						for (var i = 1; i < 4; i++) {
							options.push({
								display: "L" + i, 
								value: i	})
						}

						for (var i = 4; (i < 7) && value === 3; i++) {
							options.push({
								display: "L" + ((i-1) % 3 + 1) + "/L" + ((i) % 3 + 1) +"/L" + ((i+1) % 3 + 1), 
								value: i	
							})
						}

						if (value > 0) {meterIndex.to = value-1}
						phase.optionModel = options
					}
				}
			}

			ListSpinBox {
				id: meterIndex
				//% "Meter index"
				text: qsTrId("shelly_meter_index")
				preferredVisible: meterCount.value > 1 && phase.currentValue < 4
				dataItem.uid: root.bindPrefix + "/MeterIndex"
				decimals: 0
				stepSize: 1
				from: 0
				to: 3
			}

			ListIpAddressField {
				id: ipAddress
				text: CommonWords.ip_address
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/Url"
			}

			ListTextField {
				id: userName
				text: qsTrId("page_settings_gsm_user_name")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/Username"
			}
			
			ListTextField {
				id: password
				text: CommonWords.password
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/Password"
			}

			ListSpinBox {
				id: pollInterval
				//% "Polling interval"
				text: qsTrId("shelly_polling_interval")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/PollInterval"
				decimals: 1
				stepSize: 0.5
				from: 0.5
				to: 60
			}

			ListSwitch {
				id: temperatureSensor
				//% "Show temperature"
				text: qsTrId("shelly_show_temperature")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/TemperatureSensor"
			}

			ListSwitch {
				id: reverse
				//% "Reverse flow"
				text: qsTrId("shelly_reverse_flow")
				preferredVisible: reverseEnergy.value != null
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/Reverse"

				VeQuickItem {
					id: reverseEnergy
					uid: root.bindPrefix + "/Ac/Energy/Reverse"
				}

			}

		}
	}
}

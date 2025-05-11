/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	required property string bindPrefix

	function updateServiceName(role) {
		var s = bindPrefix.split('.');

		if (s[2] === role)
			return;

		s[2] = role;
		bindPrefix = s.join('.');
	}

	VeQuickItem {
		id: allowedRoles

		uid: root.bindPrefix + "/AllowedRoles"
		onValueChanged: {
			const roles = value
			role.optionModel = roles ? roles.map(function(v) {
				// heatpump feature is not properly supported yet. So, hide it unless it is the
				// currently selected option.
				return { "display": Global.acInputs.roleName(v), "value": v, "readOnly": v === "heatpump" }
			}) : []
		}
	}

	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}

	VeQuickItem {
		id: instance
		uid: root.bindPrefix + "/DeviceInstance"
	}

	GradientListView {
		model: VisibleItemModel {
			
			ListRadioButtonGroup {
				id: role

				text: CommonWords.ac_input_role
				dataItem.uid: root.bindPrefix + "/Role"
				popDestination: null
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				onOptionClicked: function(index) {
					// Changing the role invalidates this whole page, so close the radio buttons
					// page before updating the role.
					secondaryText = optionModel[index].display
					Global.pageManager.popPage()
					root.updateServiceName(optionModel[index].value)
				}
			}

			ListEvChargerPositionRadioButtonGroup {
				dataItem.uid: root.bindPrefix + "/Position"
			}

			ListSwitch {
				//% "Autostart"
				text: qsTrId("evcs_autostart")
				dataItem.uid: root.bindPrefix + "/AutoStart"
				preferredVisible: dataItem.valid
			}

			ListSwitch {
				//% "Lock charger display"
				text: qsTrId("evcs_lock_charger_display")
				dataItem.uid: root.bindPrefix + "/EnableDisplay"
				invertSourceValue: true
				preferredVisible: dataItem.valid
			}

			/* Shelly settings */

			ListSpinBox {
				id: shellyEvChargeThreshold
				//% "Charging threshold"
				text:  qsTrId("shelly_EV_charging_threshold")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/EvChargeThreshold"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				decimals: 0
				stepSize: 1
				from: 1
				to: 100
				
			}

			ListSpinBox {
				id: shellyEvDisconnectThreshold
				//% "Disconnect threshold"
				text:  qsTrId("shelly_EV_disconnect_threshold")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/EvDisconnectThreshold"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				decimals: 1
				stepSize: 0.1
				from: 0
				to: 10
				
			}

			ListSpinBox {
				id: shellyEvAutoMinSOC
				//% "Auto mode minimum SOC"
				text:  qsTrId("shelly_EV_auto_min_SOC")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/EvAutoMinSOC"
				suffix: "%"
				decimals: 0
				stepSize: 1
				from: 1
				to: 100
			}

			ListSpinBox {
				id: shellyEvAutoMinExcess
				//% "Auto mode start on minimum excess"
				text:  qsTrId("shelly_EV_auto_min_excess")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/EvAutoMinExcess"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				decimals: 0
				stepSize: 10
				from: 50
				to: 2000
			}

			ListSwitch {
				id: shellyEvAutoMpptThrottling
				//% "Auto mode start with MPPT throttling"
				text:  qsTrId("shelly_EV_auto_MPPT_throttling")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/EvAutoMpptThrottling"
			}

			ListSpinBox {
				id: shellyEvAutoMinChargeTime
				//% "Auto mode minimum charging time"
				text:  qsTrId("shelly_EV_auto_grid_timeout")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/EvAutoMinChargeTime"
				suffix: "min"
				decimals: 0
				stepSize: 5
				from: 0
				to: 300
			}

			ListSpinBox {
				id: shellyEvAutoOnTimeout
				//% "Auto mode On timeout"
				text:  qsTrId("shelly_EV_auto_on_timeout")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/EvAutoOnTimeout"
				suffix: "min"
				decimals: 1
				stepSize: 0.5
				from: 0.5
				to: 15
			}

			ListSpinBox {
				id: shellyEvAutoOffTimeout
				//% "Auto mode Off timeout"
				text:  qsTrId("shelly_EV_auto_off_timeout")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Shelly/" + instance.value + "/EvAutoOffTimeout"
				suffix: "min"
				decimals: 1
				stepSize: 0.5
				from: 0.5
				to: 15
			}

			ListNavigation {
				//% "Shelly settings"
				text: qsTrId("shelly_settings")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Shelly
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageShellySetup.qml",
							{ "bindPrefix": root.bindPrefix,
							  "title": text, })
				}
			}

		}
	}
}

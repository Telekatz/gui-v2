/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	/*
	 * This is a bit weird, when changing the role in a cgwacs service, it will
	 * directly disconnect, without a reply or signal that the value changed. So
	 * the gui blindly trust the remote for now to change its servicename and
	 * wait for it, which can take up to some seconds. It is not reacting in
	 * the meantime, but also not stuck. Eventually it ends up finding the new
	 * service, but it would not hurt to find a better way to do this.
	 */
	function updateServiceName(role) {
		var s = bindPrefix.split('.');

		if (s[2] === role)
			return;

		s[2] = role;
		bindPrefix = s.join('.');
	}

	function em24Locked() {
		return em24SwitchPos.dataItem.valid && em24SwitchPos.dataItem.value === 3
	}

	function em24SwitchText(pos) {
		switch (pos) {
		case 0:
			//% "Unlocked (kVARh)"
			return qsTrId("ac-in-setup_unlocked_(kvarh)")
		case 1:
			//% "Unlocked (2)"
			return qsTrId("ac-in-setup_unlocked_(2)")
		case 2:
			//% "Unlocked (1)"
			return qsTrId("ac-in-setup_unlocked_(1)")
		case 3:
			//% "Locked"
			return qsTrId("ac-in-setup_locked")
		}
		return CommonWords.unknown_status
	}

	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
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
				id: role

				text: CommonWords.ac_input_role
				dataItem.uid: root.bindPrefix + "/Role"
				popDestination: null
				onOptionClicked: function(index) {
					// Changing the role invalidates this whole page, so close the radio buttons
					// page before updating the role.
					secondaryText = optionModel[index].display
					Global.pageManager.popPage()
					root.updateServiceName(optionModel[index].value)
				}
			}

			ListPvInverterPositionRadioButtonGroup {
				dataItem.uid: root.bindPrefix + "/Position"
				preferredVisible: role.currentValue === "pvinverter"
			}

			ListEvChargerPositionRadioButtonGroup {
				dataItem.uid: root.bindPrefix + "/Position"
				preferredVisible: role.currentValue === "evcharger"
			}

			/* EM24 settings */

			ListRadioButtonGroup {
				//% "Phase configuration"
				text: qsTrId("ac-in-setup_phase_configuration")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Em24
				dataItem.uid: root.bindPrefix + "/PhaseConfig"
				interactive: dataItem.valid && !em24Locked()
				optionModel: [
					{ display: "3P.n", value: 0 },
					{ display: "3P.1", value: 1 },
					{ display: "2P", value: 2 },
					{ display: "1P", value: 3 },
					{ display: "3P", value: 4 }
				]
			}

			ListText {
				id: em24SwitchPos
				//% "Switch position"
				text: qsTrId("ac-in-setup_switch_position")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Em24
				dataItem.uid: root.bindPrefix + "/SwitchPos"
				secondaryText: dataItem.valid ? em24SwitchText(dataItem.value) : "--"
			}

			PrimaryListLabel {
				text: qsTr("Set the switch in an unlocked position to modify the settings.")
				preferredVisible: productId.value == ProductInfo.ProductId_EnergyMeter_Em24 && em24Locked()
			}

			/* Smappee settings */

			ListRadioButtonGroup {
				//% "Phase configuration"
				text: qsTrId("ac-in-setup_phase_configuration")
				preferredVisible: productId.value == ProductInfo.ProductId_PowerBox_Smappee
				dataItem.uid: root.bindPrefix + "/PhaseConfig"
				optionModel: [
					//% "Single phase"
					{ display: qsTrId("ac-in-setup_single_phase"), value: 0 },
					//% "2-phase"
					{ display: qsTrId("ac-in-setup_two_phase"), value: 2 },
					//% "3-phase"
					{ display: qsTrId("ac-in-setup_three_phase"), value: 1 },
				]
			}

			ListNavigation {
				text: CommonWords.current_transformers
				preferredVisible: productId.value == ProductInfo.ProductId_PowerBox_Smappee
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageSmappeeCTList.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigation {
				//% "Devices"
				text: qsTrId("ac-in-setup_devices")
				preferredVisible: productId.value == ProductInfo.ProductId_PowerBox_Smappee
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageSmappeeDeviceList.qml",
							{ "bindPrefix": root.bindPrefix })
				}
			}

			/* Hoymiles settings */

			ListSwitchForced {
				id: enabled
				text: CommonWords.enabled
				preferredVisible: productId.value == ProductInfo.ProductId_VeBus_MicroPlus && dataItem.valid
				dataItem.uid: root.bindPrefix + "/Enabled"
			}

			ListRadioButtonGroup {
				id: microEssPhase
				text: CommonWords.phase
				preferredVisible: productId.value == ProductInfo.ProductId_VeBus_MicroPlus
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/Phase"

				optionModel: [
					{ display: "L1", value: 1 },
					{ display: "L2", value: 2 },
					{ display: "L3", value: 3 }
				]
			}

			ListSpinBox {
				id: maxInverterPower
				text: qsTrId("settings_ess_max_inverter_power")
				preferredVisible: productId.value == ProductInfo.ProductId_VeBus_MicroPlus
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/MaxPower"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				decimals: 0
				stepSize: 50
				to: 2000
				from: 50
			}
						
			ListSwitch {
				id: autoRestart
				//% "Restart inverter at midnight"
				text: qsTrId("hm_restart_inverter")
				preferredVisible: productId.value == ProductInfo.ProductId_VeBus_MicroPlus && restart.valid
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mInv_" + serial.value + "/AutoRestart"

				VeQuickItem {
					id: restart
					uid: root.bindPrefix + "/Restart"
				}
			}

			ListSwitch {
				id: powerCalibration
				//% "Use AC calibration"
				text: qsTrId("hm_use_AC_calibration")
				preferredVisible: dataItem.valid && powerCalibrationValues.value != ""
				dataItem.uid: root.bindPrefix + "/Ac/Calibration"

				VeQuickItem {
					id: powerCalibrationValues
					uid: root.bindPrefix + "/Ac/CalibrationValues"
				}

			}

			ListNavigation {
				//% "Connection settings"
				text: qsTrId("hm_connection_settings")
				preferredVisible: productId.value == ProductInfo.ProductId_VeBus_MicroPlus
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageHmConnectionSetup.qml",
							{ "bindPrefix": root.bindPrefix,
							  "title": text, })
				}
			}

			/* Eastron settings */

			ListRadioButtonGroup {
				id: eastronPhase
				text: CommonWords.phase
				preferredVisible: dataItem.valid && productId.value == ProductInfo.ProductId_EnergyMeter_Eastron
				dataItem.uid: root.bindPrefix + "/Phase"
				optionModel: [
					{ display: "L1", value: 0 },
					{ display: "L2", value: 1 },
					{ display: "L3", value: 2 }
				]
			}

			ListSpinBox {
				id: eastronRefreshRate
				//% "Refresh rate"
				text: qsTrId("eastron_refresh_rate")
				preferredVisible: dataItem.valid && productId.value == ProductInfo.ProductId_EnergyMeter_Eastron
				dataItem.uid: root.bindPrefix + "/RefreshRate"
				suffix: "Hz"
				decimals: 0
				stepSize: 1
				from: 1
				to: 10
				
			}

			ListRadioButtonGroup {
				id: eastronEnergyCounter
				//% "Energy counter source"
				text: qsTrId("eastron_energy_counter_source")
				preferredVisible: dataItem.valid && productId.value == ProductInfo.ProductId_EnergyMeter_Eastron
				dataItem.uid: root.bindPrefix + "/EnergyCounter"
				optionModel: [
					//% "Device value"
					{ display: qsTrId("eastron_device_value"), value: 0 },
					//% "Balancing"
					{ display: qsTrId("eastron_balancing"), value: 1 },
					//% "Import - Export"
					{ display: qsTrId("eastron_import_export"), value: 2 }
				]
			}

			/* Shelly settings */

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

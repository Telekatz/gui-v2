/*
** Copyright (C) 2025 Telekatz
** This code is based on Victron Energy code
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQml
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix

	VeQuickItem {
		id: instance
		uid: root.bindPrefix + "/DeviceInstance"
	}

	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}

	VeQuickItem {
		id: advancedSettings
		uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/AdvancedSettings"
	}

	GradientListView {
		id:  gradientListView
		model: VisibleItemModel {
		
			ListSwitch {
				id: startLimiter
				//% "Startup limit"
				text: qsTrId("microPlus_startup_limit")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/StartLimit"
			}

			ListRangeSlider {
				id: limitSlider
				//% "Startup limit min/max"
				text: qsTrId("microPlus_startup_limit_min_max")
				preferredVisible: startLimiter.checked
				slider.suffix: "W"
				slider.decimals: 0
				slider.from: 50
				slider.to: 1000
				slider.stepSize: 50
				firstDataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/StartLimitMin"
				secondDataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/StartLimitMax"
			}

			ListRadioButtonGroup {
				id: limitMode
				//% "Feed-In limit mode"
				text: qsTrId("microPlus_feedin_limit_mode")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/LimitMode"

				optionModel: [
					{ display: CommonWords.maximum_power, value: 0 },
					{ display: qsTrId("settings_ess_debug_grid_setpoint"), value: 1 },
					//% "Base Load"
					{ display: qsTrId("microPlus_base_load"), value: 2 },
					{ display: "Venus OS", value: 3 },
					{ display: qsTrId("inverters_state_externalccontrol"), value: 4 },
				]
			}

			ListSpinBox {
				id: gridTargetPower
				text: qsTrId("settings_ess_debug_grid_setpoint")
				preferredVisible: limitMode.currentValue === 1
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/CGwacs/AcPowerSetPoint"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				decimals: 0
				stepSize: 10
			}

			ListItem {
				//% "Deviation / interval fast"
				text: qsTrId("microPlus_grid_setpoint_fast")
				preferredVisible: limitMode.currentValue === 1
				content.children: [

					ListItemSpinBox {
						id: gridTargetFastDeviation
						//% "Deviation grid setpoint fast"
						title:  qsTrId("microPlus_deviation_grid_setpoint_fast")
						dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/GridTargetFastDeviation"
						suffix: Units.defaultUnitString(VenusOS.Units_Watt)
						decimals: 0
						stepSize: 5
						from: 10
						to: 100
					},
					ListItemSpinBox {
						id: gridTargetFastInterval
						//% "Control interval fast"
						title:  qsTrId("microPlus_interval_grid_setpoint_fast")
						dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/GridTargetFastInterval"
						suffix: "s"
						decimals: 1
						stepSize: 0.5
						from: 1
						to: 60
					}
				]
			}

			ListItem {
				//% "Deviation / interval slow"
				text: qsTrId("microPlus_grid_setpoint_slow")
				preferredVisible: limitMode.currentValue === 1
				content.children: [

					ListItemSpinBox {
						id: gridTargetSlowDeviation
						//% "Deviation grid setpoint slow"
						title: qsTrId("microPlus_deviation_grid_setpoint_slow")
						dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/GridTargetSlowDeviation"
						suffix: Units.defaultUnitString(VenusOS.Units_Watt)
						decimals: 0
						stepSize: 5
						from: 10
						to: 100
					},
					ListItemSpinBox {
						id: gridTargetSlowInterval
						//% "Control interval slow"
						title: qsTrId("microPlus_interval_grid_setpoint_slow")
						dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/GridTargetSlowInterval"
						suffix: "s"
						decimals: 1
						stepSize: 0.5
						from: 5
						to: 60
					}
				]
			}

			ListSpinBox {
				id: gridTargetForcedInterval
				//% "Interval max"
				text: qsTrId("microPlus_interval_max")
				preferredVisible: limitMode.currentValue === 1
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/GridTargetForcedInterval"
				suffix: "s"
				decimals: 0
				stepSize: 1
				from: 5
				to: 60
			}

			ListSpinBox {
				id: baseLoadPeriod
				//% "Base load period"
				text: qsTrId("microPlus_base_load_period")
				preferredVisible: limitMode.currentValue === 2
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/BaseLoadPeriod"
				suffix: "min"
				decimals: 1
				stepSize: 0.5
				from: 0.5
				to: 10
			}

			ListSpinBox {
				id: inverterMinimumInterval
				//% "Inverter minimum interval"
				text: qsTrId("microPlus_inverter_minimum_interval")
				preferredVisible: limitMode.currentValue === 2 || limitMode.currentValue === 3
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/InverterMinimumInterval"
				suffix: "s"
				decimals: 1
				stepSize: 0.5
				from: 1
				to: 15
			}

			ListRadioButtonGroup {
				id: powerMeter
				//% "Energy meter"
				text: qsTrId("microPlus_energy_meter")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/PowerMeterInstance"

				VeQuickItem {
					id: availableAcLoads
					uid: root.bindPrefix + "/AvailableAcLoads"
					onValueChanged: {
						let options = []
						//% "Internal"
						options.push({display: qsTrId("microPlus_internal"), value: 0	})

						if (!value) {
							powerMeter.optionModel = options
							return
						}
						
						for (var i = 0; i < value.length; i++) {
							options.push({	
								display: value[i].split(':')[0], 
								value: parseInt(value[i].split(':')[1])
							})
						}
						powerMeter.optionModel = options
					}
				}
			}

			ListSpinBox {
				id: inverterShutdownVoltage
				//% "Inverter DC shutdown voltage"
				text: qsTrId("microPlus_inverter_DC_shutdown_voltage")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/InverterDcShutdownVoltage"
				suffix: "V"
				decimals: 2
				stepSize: 0.05
				from: 16
				to: 60
			}

			ListSpinBox {
				id: inverterRestartVoltage
				//% "Inverter DC restart voltage"
				text: qsTrId("microPlus_inverter_DC_restart_voltage")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/InverterDcRestartVoltage"
				suffix: "V"
				decimals: 2
				stepSize: 0.05
				from: 16
				to: 60
			}

			ListNavigation {
				text: qsTrId("vebus_device_page_advanced")
				preferredVisible: advancedSettings.value === 1
				onClicked: Global.pageManager.pushPage("/pages/vebusdevice/PageVeBusSettingsHmAdvanced.qml",
													   { "bindPrefix": root.bindPrefix,
														   "title": text
													   })
			}

		}
	}
}

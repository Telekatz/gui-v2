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
		id: limitMode
		uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/LimitMode"
	}

	GradientListView {
		id:  gradientListView
		model: VisibleItemModel {

			ListSpinBox {
				id: gridFilterWidth
				//% "Grid Filter Width"
				text: qsTrId("microPlus_grid_filter_width")
				preferredVisible: limitMode.value === 1
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/GridFilterWidth"
				suffix: "W"
				decimals: 0
				stepSize: 1
				from: 0
				to: 200
			}

			ListSpinBox {
				id: gridFilterFadeOut
				//% "Grid Filter Fade Out"
				text: qsTrId("microPlus_grid_filter_fade_out")
				preferredVisible: limitMode.value === 1
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/GridFilterFadeOut"
				suffix: "%"
				decimals: 0
				stepSize: 1
				from: 0
				to: 200
			}

			ListRangeSlider {
				id: gridFilterWeight
				//% "Grid filter weight min/max"
				text: qsTrId("microPlus_grid_filter_weight_min_max")
				preferredVisible: limitMode.value === 1
				slider.suffix: "%"
				slider.decimals: 0
				slider.from: 1
				slider.to: 100
				slider.stepSize: 1
				firstDataItem.uid: Global.systemSettings.serviceUid +  "/Settings/Devices/mPlus_0/GridFilterWeight"
				secondDataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/GridFilterWeightMax"
			}


			ListSwitch {
				id: debugOut
				//% "Debug Output"
				text: qsTrId("microPlus_debug_output")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Devices/mPlus_0/DebugOutput"
			}

		}
	}
}

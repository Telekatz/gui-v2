/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

OverviewWidget {
	id: root

	onClicked: {
		if ((Global.inverterChargers.veBusDevices.count
				+ Global.inverterChargers.inverterDevices.count
				+ Global.inverterChargers.chargerDevices.count
				+ Global.inverterChargers.acSystemDevices.count) > 1) {
			Global.pageManager.pushPage("/pages/invertercharger/InverterChargerListPage.qml")
		} else {
			// Show page for chargers
			if (Global.inverterChargers.chargerDevices.count) {
				const charger = Global.inverterChargers.chargerDevices.firstObject
				Global.pageManager.pushPage("/pages/settings/devicelist/PageAcCharger.qml",
						{ "bindPrefix": charger.serviceUid })
			} else {
				// Show page for inverter, vebus and acsystem services
				const device = Global.inverterChargers.firstObject
				Global.pageManager.pushPage("/pages/invertercharger/OverviewInverterChargerPage.qml",
						{ "serviceUid": device.serviceUid })
			}
		}
	}

	//% "Inverter / Charger"
	title: qsTrId("overview_widget_inverter_title")
	icon.source: "qrc:/images/inverter_charger.svg"
	type: VenusOS.OverviewWidget_Type_VeBusDevice
	enabled: !!Global.inverterChargers.firstObject || Global.inverterChargers.chargerDevices.count
	quantityLabel.visible: false
	rightPadding: Theme.geometry_overviewPage_widget_sideGauge_margins
	extraContentChildren: [
		Label {
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: systemReasonText.top
			}
			text: Global.system.systemStateToText(Global.system.state)
			font.pixelSize: Theme.font_overviewPage_widget_quantityLabel_maximumSize
			minimumPixelSize: Theme.font_overviewPage_widget_quantityLabel_minimumSize
			fontSizeMode: Text.Fit
			wrapMode: Text.WordWrap
			maximumLineCount: 4
			elide: Text.ElideRight
		},
		Label {
			id: systemReasonText

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_content_verticalMargin
			}
			text: systemReason.text
			wrapMode: Text.WordWrap
			color: Theme.color_font_secondary
			SystemReason {
				id: systemReason
			}
		},
		
		QuantityLabel {
			id: inverterPowerLabel

			anchors {
				bottom: debug0label.top
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
			}
			value: inverterPower.value
			unit: VenusOS.Units_Watt
			font.pixelSize: root.size === VenusOS.OverviewWidget_Size_XS
					  ? Theme.font_overviewPage_widget_quantityLabel_minimumSize
					  : Theme.font_overviewPage_widget_quantityLabel_maximumSize
			alignment: Qt.AlignLeft

		},

		Label {
			id: debug0label

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: debug1label.top
				bottomMargin: 0
			}
			text: debug0.value
			color: Theme.color_font_secondary
			horizontalAlignment: Text.AlignLeft
			visible: debug0.valid
		},

		Label {
			id: debug1label

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_content_verticalMargin
			}
			text: debug1.value
			color: Theme.color_font_secondary
			horizontalAlignment: Text.AlignLaft
			visible: debug1.valid
		},

		Label {
			id: debug2label

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: debug3label.top
				bottomMargin: 0
			}
			text: debug2.value
			color: Theme.color_font_secondary
			horizontalAlignment: Text.AlignRight
			visible: debug2.valid
		},

		Label {
			id: debug3label

			anchors {
				left: parent.left
				leftMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				right: parent.right
				rightMargin: Theme.geometry_overviewPage_widget_content_horizontalMargin
				bottom: parent.bottom
				bottomMargin: Theme.geometry_overviewPage_widget_content_verticalMargin
			}
			text: debug3.value
			color: Theme.color_font_secondary
			horizontalAlignment: Text.AlignRight
			visible: debug3.valid
		}

	]

	VeQuickItem {
		id: inverterPower
		uid: Global.inverterChargers.firstObject.serviceUid + "/Ac/Power"
	}
	
	VeQuickItem {
		id: debug0
		uid: Global.inverterChargers.firstObject.serviceUid + "/Debug/Debug0"
	}

	VeQuickItem {
		id: debug1
		uid: Global.inverterChargers.firstObject.serviceUid + "/Debug/Debug1"
	}

	VeQuickItem {
		id: debug2
		uid: Global.inverterChargers.firstObject.serviceUid + "/Debug/Debug2"
	}

	VeQuickItem {
		id: debug3
		uid: Global.inverterChargers.firstObject.serviceUid + "/Debug/Debug3"
	}

	Loader {
		id: sideGaugeLoader

		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			margins: Theme.geometry_overviewPage_widget_sideGauge_margins
		}
		sourceComponent: ThreePhaseBarGauge {
			valueType: VenusOS.Gauges_ValueType_RisingPercentage
			phaseModel: Global.system.load.ac.phases
			phaseModelProperty: "current"
			maximumValue: Global.system.load.maximumAcCurrent
			animationEnabled: root.animationEnabled
			inOverviewWidget: true
		}
	}
}

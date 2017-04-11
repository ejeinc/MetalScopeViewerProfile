//
//  ViewerProfile.swift
//  MetalScopeViewerProfile
//
//  Created by Jun Tanaka on 2017/04/11.
//  Copyright © 2017 eje Inc. All rights reserved.
//

import MetalScope
import SwiftProtobuf

public struct ViewerProfile: ViewerParametersProtocol {
    let deviceParams: DeviceParams

    public var vendor: String {
        return deviceParams.vendor
    }

    public var model: String {
        return deviceParams.model
    }

    public var lenses: Lenses {
        let alignment: Lenses.Alignment

        switch deviceParams.verticalAlignment {
        case .bottom:
            alignment = .bottom
        case .center:
            alignment = .center
        case .top:
            alignment = .top
        }

        return Lenses(
            separation: deviceParams.interLensDistance,
            offset: deviceParams.trayToLensDistance,
            alignment: alignment,
            screenDistance: deviceParams.screenToLensDistance)
    }

    public var distortion: Distortion {
        return Distortion(values: deviceParams.distortionCoefficients)
    }

    public var maximumFieldOfView: FieldOfView {
        return FieldOfView(
            outer: deviceParams.leftEyeFieldOfViewAngles[0],
            inner: deviceParams.leftEyeFieldOfViewAngles[1],
            upper: deviceParams.leftEyeFieldOfViewAngles[3],
            lower: deviceParams.leftEyeFieldOfViewAngles[2])
    }

    init(deviceParams: DeviceParams) {
        self.deviceParams = deviceParams
    }

    public init(serializedData: Data) throws {
        let deviceParams = try DeviceParams(serializedData: serializedData)
        self.init(deviceParams: deviceParams)
    }

    public func serializedData() throws -> Data {
        return try deviceParams.serializedData()
    }
}

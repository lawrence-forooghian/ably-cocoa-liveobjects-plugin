// The Swift Programming Language
// https://docs.swift.org/swift-book
import Ably
internal import AblyPlugin

private let pluginDataKey = "LiveObjects"

/// The class that should be passed in the `plugins` client option to enable LiveObjects.
@objc public class Plugin : NSObject {
    // This class informally conforms to AblyPlugin.LiveObjectsPluginFactoryProtocol

    @objc static private func createPlugin() -> PluginImplementation {
        return PluginImplementation()
    }
}

@objc private class PluginImplementation : NSObject, AblyPlugin.LiveObjectsPluginProtocol {
    func prepare(_ channel: ARTRealtimeChannel) {
        print("LiveObjects.Plugin received prepare(_:)")
        let liveObjects = LiveObjects(channel: channel)
        let box = Box(value: liveObjects)
        AblyPlugin.PluginAPI.setPluginDataValue(box, forKey: pluginDataKey, channel: channel)
    }
}

public extension ARTRealtimeChannel {
    var liveObjects: LiveObjects {
        guard let pluginData = AblyPlugin.PluginAPI.pluginDataValue(forKey: pluginDataKey, channel: self) else {
            // Plugin.prepare was not called
            fatalError("You must pass AblyLiveObjects.Plugin in the ClientOptions")
        }

        return (pluginData as! Box).value
    }
}

@objc
private final class Box: NSObject {
    var value: LiveObjects

    init(value: LiveObjects) {
        self.value = value
    }
}

public struct SomeStruct: Sendable {}

/// The class that provides the public API for interacting with LiveObjects. This will provide an API that uses Swift language features.
public final class LiveObjects: Sendable {
    // Just to demonstrate that you can use Swift stuff
    public let someStruct = SomeStruct()

    // Since the channel holds a strong reference to us via setPluginDataValue, we need to reference it weakly to avoid a strong reference cycle
    private let weakChannelReference: WeakChannelReference

    private struct WeakChannelReference {
        weak var channel: ARTRealtimeChannel?
    }

    init(channel: ARTRealtimeChannel) {
        weakChannelReference = .init(channel: channel)

        AblyPlugin.PluginAPI.addPluginProtocolMessageListener({ protocolMessage in
            // (printing `protocolMessage.action` to demonstrate that we can access ProtocolMessage properties)
            print("LiveObjects got protocol message \(protocolMessage), it has action \(protocolMessage.action)")
        }, channel: channel)
    }

    public func doALiveObjectsThing() async {
        print("inside doALiveObjectsThing")

        guard let channel = weakChannelReference.channel else {
            return
        }

        let protocolMessage = ARTProtocolMessage()
        protocolMessage.action = .message // arbitrary, just to demonstrate
        AblyPlugin.PluginAPI.send(protocolMessage, channel: channel)
    }
}

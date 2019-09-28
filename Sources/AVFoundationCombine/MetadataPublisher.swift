
import AVFoundation
import Combine

extension AVPlayerItem {

    public var metadataPublisher: MetadataPublisher {
        MetadataPublisher(item: self)
    }
}

public struct MetadataPublisher {
    fileprivate let item: AVPlayerItem
}

extension MetadataPublisher: Publisher {

    public typealias Output = AVTimedMetadataGroup
    public typealias Failure = Never

    public func receive<S>(subscriber: S)
    where S: Subscriber,
          Failure == S.Failure,
          Output == S.Input {

        let subscription = Subscription(item: item, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension MetadataPublisher {

    fileprivate final class Subscription<Subscriber>:
        NSObject,
        AVPlayerItemMetadataOutputPushDelegate
    where
        Subscriber: Combine.Subscriber,
        Subscriber.Failure == Failure,
        Subscriber.Input == Output
    {

        private let item: AVPlayerItem
        private let subscriber: Subscriber
        private let metadataOutput = AVPlayerItemMetadataOutput()

        fileprivate init(item: AVPlayerItem, subscriber: Subscriber) {
            self.item = item
            self.subscriber = subscriber
        }

        func metadataOutput(_: AVPlayerItemMetadataOutput,
                            didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                            from: AVPlayerItemTrack?) {

            groups.forEach { _ = subscriber.receive($0) }
        }
    }
}

extension MetadataPublisher.Subscription: Combine.Subscription {

    func request(_ demand: Subscribers.Demand) {
        let queue = DispatchQueue(label: "uk.co.danieltull.MetadataQueue")
        metadataOutput.setDelegate(self, queue: queue)
        item.add(metadataOutput)
    }

    func cancel() {
        item.remove(metadataOutput)
        metadataOutput.setDelegate(nil, queue: nil)
    }
}

library pubsub.stream;

import 'dart:async';
import '../message.dart';

class PubsubStream {
	StreamController<PubsubMessage> _controller;
	Map<Function, StreamSubscription<PubsubMessage>> _listeners;
	Map<StreamSubscription<PubsubMessage>, Function> _subscriptions;
	PubsubMessage _lastMessage = null;

	PubsubStream() {
		_controller = new StreamController<PubsubMessage>.broadcast();
		_listeners = new Map<Function, StreamSubscription<PubsubMessage>>();
		_subscriptions = new Map<StreamSubscription<PubsubMessage>, Function>();
		_controller.stream.listen(_selfListener);
	}

	void add(Function listener) {
		if(_listeners.containsKey(listener)) return;
		StreamSubscription<PubsubMessage> subscription = _controller.stream.listen(listener);
		_listeners[listener] = subscription;
		_subscriptions[subscription] = listener;
		if(_lastMessage != null) {
			listener(_lastMessage);
		}
	}

	void remove(Function listener) {
		if(_listeners.containsKey(listener)) {
			_subscriptions.remove(_listeners[listener]);
			//This is run async so any messages currently queues can finish
			scheduleMicrotask(_listeners[listener].cancel);
			_listeners.remove(listener);
		}
	}

	void fire(PubsubMessage message) {
		_controller.add(message);
		_lastMessage = message;
	}

	get hasListeners => _controller.hasListener;

	void _selfListener(PubsubMessage msg) {
		//Do nothing, just here to make sure the steam is always empty
	}
}
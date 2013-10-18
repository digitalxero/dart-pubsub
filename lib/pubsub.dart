library pubsub;

import 'src/stream.dart';
import 'message.dart';

class Pubsub {
	static final Pubsub _singleton = new Pubsub._internal();
	static final Map<String, PubsubStream> _channels = new Map<String, PubsubStream>();

	factory Pubsub() {
		return _singleton;
	}

	static subscribe(String channel, Function cb) {
		List<String> channels = _get_parent_channels(channel);
		for(String c in channels) {
			_check_or_create(c);
			_channels[c].add(cb);
		}
	}

	static subscribe_once(String channel, Function cb) {
		Function wrapper;
		wrapper = (PubsubMessage msg) {
			Pubsub.unsubscribe(channel, wrapper);
			cb(msg);
		};
		List<String> channels = _get_parent_channels(channel);
		for(String c in channels) {
			_check_or_create(c);
			_channels[c].add(wrapper);
		}
	}

	static final publish = new VarargsFunction((arguments, kwargs) {
		List args = new List.from(arguments);
		String channel = args.removeAt(0);
		List<String> parents = _get_parent_channels(channel);
		List<String> children = _get_child_channels(channel);
		for(String p in parents) {
			final PubsubMessage message = new PubsubMessage(p, args, kwargs);
			_publish(p, message);
			for(String c in children) {
				_publish(c, message);
			}
		}
	});

	static _publish(String channel, PubsubMessage msg) {
		_check_or_create(channel);
		_channels[channel].fire(msg);
	}

	static unsubscribe(String channel, Function cb) {
		List<String> channels = _get_parent_channels(channel);
		for(String c in channels) {
			if(!_channels.containsKey(c)) continue;
			_channels[c].remove(cb);
			if(!_channels[c].hasListeners) {
				_channels.remove(c);
			}
		}
	}

	static _check_or_create(String channel) {
		if(!_channels.containsKey(channel)) {
			PubsubStream stream = new PubsubStream();
			_channels[channel] = stream;
		}
	}

	static List<String> _get_parent_channels(String channel) {
		return channel.split(' ');
	}

	static List<String> _get_child_channels(String channel) {
		List<String> topics = channel.split(' ');
		List<String> channels = new List<String>();
		for(int i=0; i<topics.length; i++) {
			List<String> topic_array = topics[i].split('.');
			topic_array.removeLast();

			while(topic_array.length > 0) {
				String topic = topic_array.join('.');
				topic_array.removeLast();
				channels.add(topic);
			}

			if(!channels.contains('*')) {
				channels.add('*');
			}
		}

		return channels;
	}

	Pubsub._internal();
}

typedef dynamic OnCall(List, Map);

class VarargsFunction {
  OnCall _onCall;
  VarargsFunction(this._onCall);
  noSuchMethod(Invocation invocation) {
    final args = invocation.positionalArguments;
	final kwargs = invocation.namedArguments;
    return _onCall(args, kwargs);
  }
}

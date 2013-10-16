library pubsub;

import 'package:logging/logging.dart';

import 'src/stream.dart';
import 'message.dart';

class Pubsub {
	static final Pubsub _singleton = new Pubsub._internal();
	static final Map<String, PubsubStream> _channels = new Map<String, PubsubStream>();
	static final Logger logger = new Logger('Pubsub');

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

	static final publish = new VarargsFunction((arguments) {
		List args = new List.from(arguments);
		String channel = args.removeAt(0);
		List<String> channels = _get_all_channels(channel);
		for(String c in channels) {
			_check_or_create(c);
			PubsubMessage message = new PubsubMessage(c, args);
			_channels[c].fire(message);
		}
	});

	static unsubscribe(String channel, Function cb) {
		List<String> channels = _get_parent_channels(channel);
		for(String c in channels) {
			if(!_channels.containsKey(c)) continue;
			_channels[c].remove(cb);
			_channels[c].isEmpty().then((value){
				if(value) {
				_channels.remove(c);
				}
			});
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

	static List<String> _get_all_channels(String channel) {
		List<String> topics = channel.split(' ');
		List<String> channels = new List<String>();
		for(int i=0; i<topics.length; i++) {
			List<String> topic_array = topics[i].split('.');

			while(topic_array.length > 0) {
				String topic = topic_array.join('.');
				topic_array.removeLast();
				channels.add(topic);
			}
			channels.add('*');
		}

		return channels;
	}

	static _debug(PubsubMessage msg) {
		logger.finest(msg.channel);
	}

	Pubsub._internal();
}

typedef dynamic OnCall(List);

class VarargsFunction {
  OnCall _onCall;
  VarargsFunction(this._onCall);
  noSuchMethod(Invocation invocation) {
    final arguments = invocation.positionalArguments;
    return _onCall(arguments);
  }
}

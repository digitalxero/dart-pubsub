library pubsub.message;

import 'package:dynamic_object/dynamic_object.dart';

class PubsubMessage extends DynamicObject {
	String _chan;
	List _arguments;

	PubsubMessage(String channel, List arguments, Map kwargs) {
    	Map _objectData = new Map();
		this._chan = channel;
		this._arguments = arguments;
		kwargs.forEach((Symbol key, dynamic value){
			this[key] = value;
		});
  	}

	get channel => _chan;
	get args => _arguments;
}
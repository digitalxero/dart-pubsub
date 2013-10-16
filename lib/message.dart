library pubsub.message;

import 'dart:mirrors' as mirrors;
import 'package:dynamic_object/dynamic_object.dart';

class DynamicObject extends Object {
	Map<String, dynamic> _objectData = new Map<String, dynamic>();

	DynamicObject() {

	}

  	/** noSuchMethod() is where the magic happens.
   	* If we try to access a property using dot notation (eg: o.wibble ), then
   	* noSuchMethod will be invoked, and identify the getter or setter name.
   	* It then looks up in the map contained in _objectData (represented using
   	* this (as this class implements [Map], and forwards it's calls to that
   	* class.
   	* If it finds the getter or setter then it either updates the value, or
   	* replaces the value.
   	*/
	noSuchMethod(Invocation mirror) {
		int positionalArgs = 0;
    	if (mirror.positionalArguments != null) positionalArgs = mirror.positionalArguments.length;

    	var property = _symbolToString(mirror.memberName);

		print(property);

    	if (mirror.isGetter && (positionalArgs == 0)) {
      		//synthetic getter
      		if (_objectData.containsKey(property)) {
        		return _objectData[property];
      		}
    	} else if (mirror.isSetter && positionalArgs == 1) {
      		//synthetic setter
      		//if the property doesn't exist, it will only be added
      		property = property.replaceAll("=", "");
			_objectData[property] = mirror.positionalArguments[0]; // args[0];
      		return _objectData[property];
    	}

    	super.noSuchMethod(mirror);
  	}

  	String _symbolToString(value) {
    	if (value is Symbol) {
      		return mirrors.MirrorSystem.getName(value);
    	} else {
      		return value.toString();
    	}
  	}

  	forEach(func) => _objectData.forEach(func);

  	Iterable get keys => _objectData.keys;

  	operator [](key) => _objectData[key];

  	operator []=(key,value) {
    	return _objectData[key] = value;
  	}
}

class PubsubMessage extends DynamicObject {
	String _chan;
	List _arguments;

	PubsubMessage(String channel, List arguments, Map kwargs) {
    	_objectData = new Map();
		this._chan = channel;
		this._arguments = arguments;
		kwargs.forEach((Symbol key, dynamic value){
			String property = _symbolToString(key);
			this[property] = value;
		});
  	}

	get channel => _chan;
	get args => _arguments;
}
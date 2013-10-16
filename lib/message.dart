library pubsub.message;

import 'dart:mirrors' as mirrors;
import 'package:meta/meta.dart';

@proxy
class PubsubMessage<E> extends Object implements Map, Iterable  {
	String _chan;
	List _arguments;
  	var _objectData;

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

  	/** noSuchMethod() is where the magic happens.
   	* If we try to access a property using dot notation (eg: o.wibble ), then
   	* noSuchMethod will be invoked, and identify the getter or setter name.
   	* It then looks up in the map contained in _objectData (represented using
   	* this (as this class implements [Map], and forwards it's calls to that
   	* class.
   	* If it finds the getter or setter then it either updates the value, or
   	* replaces the value.
   	*
   	* If isExtendable = true, then it will allow the property access
   	* even if the property doesn't yet exist.
   	*/
	noSuchMethod(Invocation mirror) {
		int positionalArgs = 0;
    	if (mirror.positionalArguments != null) positionalArgs = mirror.positionalArguments.length;

    	var property = _symbolToString(mirror.memberName);

    	if (mirror.isGetter && (positionalArgs == 0)) {
      		//synthetic getter
      		if (this.containsKey(property)) {
        		return this[property];
      		}
    	} else if (mirror.isSetter && positionalArgs == 1) {
      		//synthetic setter
      		//if the property doesn't exist, it will only be added
      		property = property.replaceAll("=", "");
      		this[property] = mirror.positionalArguments[0]; // args[0];
      		return this[property];
    	}

    	//if we get here, then we've not found it - throw.
    	_log("Not found: ${property}");
    	_log("IsGetter: ${mirror.isGetter}");
    	_log("IsSetter: ${mirror.isGetter}");
    	_log("isAccessor: ${mirror.isAccessor}");
    	super.noSuchMethod(mirror);
  	}

  	String _symbolToString(value) {
    	if (value is Symbol) {
      		return mirrors.MirrorSystem.getName(value);
    	} else {
      		return value.toString();
    	}
  	}

  	/***************************************************************************
   	* Iterable implementation methods and properties *
   	*/
  	Iterable toIterable() {
    	return _objectData.values;
  	}

  	Iterator<E> get iterator => this.toIterable().iterator;

  	Iterable map(f(E element)) => this.toIterable().map(f);

  	Iterable<E> where(bool f(E element)) => this.toIterable().where(f);

  	Iterable expand(Iterable f(E element)) => this.toIterable().expand(f);

  	bool contains(E element) => this.toIterable().contains(element);

  	dynamic reduce(E combine(E value, E element)) => this.toIterable().reduce(combine);

  	bool every(bool f(E element)) => this.toIterable().every(f);

  	String join([String separator]) => this.toIterable().join(separator);

  	bool any(bool f(E element)) => this.toIterable().any(f);

  	Iterable<E> take(int n) => this.toIterable().take(n);

  	Iterable<E> takeWhile(bool test(E value)) => this.toIterable().takeWhile(test);

  	Iterable<E> skip(int n) => this.toIterable().skip(n);

  	Iterable<E> skipWhile(bool test(E value)) => this.toIterable().skipWhile(test);

  	E get first => this.toIterable().first;

  	E get last => this.toIterable().last;

  	E get single => this.toIterable().single;

  	E fold(initialValue, dynamic combine(a,b)) => this.toIterable().fold(initialValue, combine);

  	@deprecated
  	E firstMatching(bool test(E value), { E orElse() : null }) {
    	if (orElse != null) this.toIterable().firstWhere(test, orElse: orElse);
    	else this.toIterable().firstWhere(test);
  	}

  	@deprecated
  	E lastMatching(bool test(E value), {E orElse() : null}) {
    	if (orElse != null) this.toIterable().lastWhere(test, orElse: orElse);
    	else this.toIterable().lastWhere(test);
  	}

  	@deprecated
  	E singleMatching(bool test(E value)) => this.toIterable().singleWhere(test);

  	E elementAt(int index) => this.toIterable().elementAt(index);

  	List<dynamic> toList({ bool growable: true }) => this.toIterable().toList(growable:growable);

  	Set<dynamic> toSet() => this.toIterable().toSet();

  	@deprecated
  	E min([int compare(E a, E b)]) { throw "Deprecated in iterable interface"; }

  	@deprecated
  	E max([int compare(E a, E b)]) { throw "Deprecated in iterable interface"; }

  	dynamic firstWhere(test, {orElse}) => this.toIterable().firstWhere(test, orElse:orElse);
  	dynamic lastWhere(test, {orElse}) => this.toIterable().firstWhere(test, orElse:orElse);
  	dynamic singleWhere(test, {orElse}) => this.toIterable().firstWhere(test, orElse:orElse);

  	/***************************************************************************
   	* Map implementation methods and properties *
   	*
   	*/

  	bool containsValue(value) => _objectData.containsValue(value);

  	bool containsKey(value) {
    	return _objectData.containsKey(_symbolToString(value));
  	}

  	bool get isNotEmpty => _objectData.isNotEmpty;

  	operator [](key) => _objectData[key];

  	forEach(func) => _objectData.forEach(func);

  	Iterable get keys => _objectData.keys;

  	Iterable get values => _objectData.values;

  	int get length => _objectData.length;

  	bool get isEmpty => _objectData.isEmpty;

	addAll(items) => _objectData.addAll(items);

  	operator []=(key,value) {
    	return _objectData[key] = value;
  	}

  	putIfAbsent(key,ifAbsent()) {
    	return _objectData.putIfAbsent(key, ifAbsent);
  	}

  	remove(key) {
    	return _objectData.remove(key);
  	}

	clear() {
	  	_objectData.clear();
	}
}
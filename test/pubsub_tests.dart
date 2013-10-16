import 'package:unittest/unittest.dart';
import 'package:pubsub/Pubsub.dart';
import 'package:pubsub/message.dart';

void main() {
	test('Wildcard Channel Test', () {
		Pubsub.publish('whatever', 'test passed');
		cb(PubsubMessage msg){
			expect(msg.args[0], equals('test passed'));
		}
		Function c1 = expectAsync1(cb);
		Pubsub.subscribe('*', c1);
		Pubsub.unsubscribe('*', c1);
	});

	test('Single Channel Test', () {
		Pubsub.subscribe('single', expectAsync1((PubsubMessage msg){
			expect(msg.args[0], equals('test passed'));
		}));
		Pubsub.publish('single', 'test passed');
	});

	test('Multiple Channel Test', () {
		Pubsub.subscribe('first second', expectAsync1((PubsubMessage msg){
			expect(msg.args[0], equals('test passed'));
		}, count: 2));
		Pubsub.publish('first', 'test passed');
		Pubsub.publish('second', 'test passed');
	});

	test('Simple Hierarchical Channel Test', () {
		Pubsub.subscribe('simple.hierarchical', expectAsync1((PubsubMessage msg){
			expect(msg.args[0], equals('test passed'));
		}));
		Pubsub.publish('simple.hierarchical', 'test passed');
	});

	test('Complex Hierarchical Channel Test', () {
		Pubsub.subscribe('Complex', expectAsync1((PubsubMessage msg){
			expect(msg.channel, equals('Complex.hierarchical'));
			expect(msg.args[0], equals('test passed'));
		}));
		Pubsub.publish('Complex.hierarchical', 'test passed');
	});

	test('Multiple publishes before subscribe only get latest message Test', () {
		Pubsub.publish('multiple-messages', '1');
		Pubsub.publish('multiple-messages', 2);
		Pubsub.publish('multiple-messages', '3');
		Pubsub.publish('multiple-messages', 'test passed');
		Pubsub.subscribe('multiple-messages', expectAsync1((PubsubMessage msg){
			expect(msg.args[0], equals('test passed'));
		}));
	});

	test('Multiple arguments Test', () {
		Pubsub.subscribe('multi-args', expectAsync1((PubsubMessage msg){
			expect(msg.args[0], equals('test passed'));
			expect(msg.args[1], equals(1));
			expect(msg.args[2], equals(2));
			expect(msg.args[3], orderedEquals([3, 4, 5]));
		}));
		Pubsub.publish('multi-args', 'test passed', 1, 2, [3, 4, 5]);
	});

	test('Keyword arguments Test', () {
		Pubsub.subscribe('kw-args', expectAsync1((PubsubMessage msg){
			expect(msg.test, equals('passed'));
		}));
		Pubsub.publish('kw-args', test: 'passed');
	});

	test('Keyword and positional arguments Test', () {
		Pubsub.subscribe('kw-positional-args', expectAsync1((PubsubMessage msg){
		expect(msg.args[0], equals('test passed'));
			expect(msg.test, equals('passed'));
		}));
		Pubsub.publish('kw-positional-args', 'test passed', test: 'passed');
	});
}
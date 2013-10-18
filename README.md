dart-pubsub
===========

Implementation of pubsub that allows for hierarchical categorical publish and subscribe.

The full channel is sent as PubsubMessage.channel, so listeners can do their own filtering if they subscribe to a more general channel.

You can (un)subscribe to multiple topics by separating them by spaces, this does limit it to channels with no spaces in their names though. You can publish to multiple topics the same way.

    Pubsub.subscribe('app.component.action', (PubsubMessage msg){
		//msg.channel == 'app.component.action'
		//msg.args == [1, 2, 3]
		//msg.keywords == 'work also'
		//msg.isnt == 'this fun'
	});

	Pubsub.publish('app.component.action', 1, 2, 3, keywords: 'work also', isnt: 'this fun');

Remember that the system automatically publishes to the less specific channels so you should never do `Pubsuub.subscribe('app app.component app.component.change', ...)` as the subscriber would recive 3 copies of each message published to `app.component.change`

You can also subscribe well after something has been publishing to a channel and you will get the last message, this is most usefull for a ready message

	Pubsub.publish('app.component.ready', true);
	Pubsub.publish('app.component.ready', false);
	Pubsub.publish('app.component.ready', true);
	Pubsub.publish('app.component.ready', false);
	Pubsub.publish('app.component.ready', true);

	Pubsub.subscribe('app.component.ready', (PubsubMessage msg){
		//You will only get the last call, or any calls made after this subscribe
		//msg.args[0] == true
	});

hierarchical channels allow you to create super listeners to make debugging easier

	Pubsub.subscribe('app', (PubsubMessage msg){
		//msg.channel == 'app.component.action' even though you only subscribed to app
	});

	Pubsub.publish('app.component.action', 1, 2, 3, keywords: 'work also', isnt: 'this fun');
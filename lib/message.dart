library pubsub.message;

class PubsubMessage {
	String channel;
	List arguments;

	PubsubMessage(String channel, List arguments) {
		this.channel = channel;
		this.arguments = arguments;
	}
}
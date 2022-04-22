const { Storage } = require('@google-cloud/storage');
const {PubSub} = require('@google-cloud/pubsub');

// Creates clients, cache for reuse
const storage = new Storage();
const pubSubClient = new PubSub();

const bucketName = process.env.DESTINATION_STORAGE_BUCKET_NAME;
const topicName = process.env.DESTINATION_PUBSUB_TOPIC_NAME;


exports.handler = async (req, res) => {
    console.log('function invoked by HTTP!');
  try {
    // const data = Buffer.from(req.body.payload);
    const data = JSON.stringify({hello: 'world'});

    // Publishes the message as a string, e.g. "Hello, world!" or JSON.stringify(someObject)
    const dataBuffer = Buffer.from(data);

    const messageId = await pubSubClient
    .topic(topicName)
    .publish(dataBuffer);

    console.log(`Message ${messageId} sent.`);
    res.send(`Message ${messageId} sent.`);
  } catch (err) {
    console.error('AN ERROR OCCURRED');
    console.error(err);
    res.send(err);
  }
};

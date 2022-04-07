function transform(line) {
    var values = line.split(',');

    var obj = new Object();
    obj.tweet_id = values[0];
    obj.author_id = values[1];
    obj.inbound = values[2];
    obj.created_at = values[3];
    obj.text = values[4];
    obj.response_tweet_id = values[5];
    obj.in_response_to_tweet_id = values[6];

    try {
        if (obj.created_at) {  
            timestamp = new Date(Date.parse(obj.created_at)).toISOString();
            obj.created_at = timestamp;
        }
    } catch (err) {
        obj.created_at = null;
    }

    var jsonString = JSON.stringify(obj);

    return jsonString;
}

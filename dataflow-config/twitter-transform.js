function transform(line) {
    var values = line.split(',');
    // validate line isn't missing data 
    if(values.length < 7) {
        return undefined; // tell dataflow to skip record
    }

    var cleaned = values.map(function(value) {
        if (value === '') {
            return null;
        } else {
            return value;
        }
    });

    var obj = new Object();
    obj.tweet_id = cleaned[0];
    obj.author_id = cleaned[1];
    obj.inbound = cleaned[2];
    obj.created_at = cleaned[3];
    obj.text = cleaned[4];
    obj.response_tweet_id = cleaned[5];
    obj.in_response_to_tweet_id = cleaned[6];

    try {
        if (obj.created_at) {  
            timestamp = new Date(Date.parse(obj.created_at)).toISOString();
            obj.created_at = timestamp;
        }

        var jsonString = JSON.stringify(obj);
        return jsonString;
    } catch (err) {
        // for now
    }
}

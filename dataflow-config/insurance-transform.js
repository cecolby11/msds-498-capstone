function transform(line) {
    // once I define my own pipeline template I will have it skip the headerlines when it reads in the csv data
    if (line=='age,sex,bmi,children,smoker,region,charges') {
        return undefined; // tell dataflow to skip the record, this is the header
    }
    
    var values = line.split(',');
    // validate line isn't missing data 
    if(values.length < 7) {
        return undefined; // tell dataflow to skip record
    }

    var obj = new Object();
    obj.age = parseInt(values[0]);
    obj.sex = values[1];
    obj.bmi = parseFloat(values[2]);
    obj.children = parseInt(values[3]);
    obj.smoker = values[4] == 'yes' ? 1 : 0;
    obj.region = values[5];
    obj.charges = parseFloat(values[6]);

    try {
        var jsonString = JSON.stringify(obj);
        return jsonString;
    } catch (err) {
        // for now
    }
}
